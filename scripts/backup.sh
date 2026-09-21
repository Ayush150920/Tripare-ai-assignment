#!/usr/bin/env bash
set -euo pipefail

db_name="${POSTGRES_DB:-hotel_db}"
db_user="${POSTGRES_USER:-postgres}"
backup_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backups"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup_file="${backup_dir}/${db_name}-${timestamp}.dump"

mkdir -p "$backup_dir"
docker compose exec -T postgres pg_dump -U "$db_user" -d "$db_name" -Fc > "$backup_file"
test -s "$backup_file"
echo "Backup created: $backup_file"

