#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [path/to/backup.dump]" >&2
  exit 2
fi

db_user="${POSTGRES_USER:-postgres}"
restore_db="${RESTORE_DB:-hotel_restore}"
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backup_file="${1:-}"

if [[ -z "$backup_file" ]]; then
  for candidate in "$root_dir"/backups/*.dump; do
    [[ -s "$candidate" ]] || continue
    if [[ -z "$backup_file" || "$candidate" -nt "$backup_file" ]]; then
      backup_file="$candidate"
    fi
  done
fi

if [[ -z "$backup_file" || ! -f "$backup_file" ]]; then
  echo "No backup dump found. Run ./scripts/backup.sh or pass a dump path." >&2
  exit 1
fi

# Refuse to replace the Compose application's source database by accident.
if [[ "$restore_db" == "${POSTGRES_DB:-hotel_db}" ]]; then
  echo "RESTORE_DB must name a fresh database, not the source database." >&2
  exit 1
fi

for _ in {1..30}; do
  if docker compose exec -T postgres pg_isready -U "$db_user" -d postgres >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

if ! docker compose exec -T postgres pg_isready -U "$db_user" -d postgres >/dev/null 2>&1; then
  echo "PostgreSQL did not become ready within 60 seconds." >&2
  exit 1
fi

docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U "$db_user" -d postgres \
  -c "DROP DATABASE IF EXISTS \"$restore_db\";" \
  -c "CREATE DATABASE \"$restore_db\";"
docker compose exec -T postgres pg_restore -U "$db_user" -d "$restore_db" --no-owner --no-privileges < "$backup_file"
docker compose exec -T postgres psql -U "$db_user" -d "$restore_db" \
  -c "SELECT COUNT(*) AS restored_bookings FROM hotel_bookings;"
echo "Restore completed into database: $restore_db"
