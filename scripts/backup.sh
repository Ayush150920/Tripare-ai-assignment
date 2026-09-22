#!/usr/bin/env bash
set -euo pipefail

db_name="${POSTGRES_DB:-hotel_db}"
db_user="${POSTGRES_USER:-postgres}"
backup_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backups"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup_file="${backup_dir}/${db_name}-${timestamp}.dump"
temporary_file="${backup_file}.tmp"

mkdir -p "$backup_dir"
for _ in {1..30}; do
  if docker compose exec -T postgres pg_isready -U "$db_user" -d "$db_name" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

if ! docker compose exec -T postgres pg_isready -U "$db_user" -d "$db_name" >/dev/null 2>&1; then
  echo "PostgreSQL did not become ready within 60 seconds." >&2
  exit 1
fi

trap 'rm -f "$temporary_file"' EXIT
docker compose exec -T postgres pg_dump -U "$db_user" -d "$db_name" -Fc > "$temporary_file"
test -s "$temporary_file"
mv "$temporary_file" "$backup_file"
trap - EXIT
echo "Backup created: $backup_file"
