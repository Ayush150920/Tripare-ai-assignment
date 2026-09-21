<<<<<<< HEAD
# Tripare DevOps Assessment

This repository models `Internet → ALB → ECS/Fargate → private RDS PostgreSQL` in Terraform and provides a runnable local PostgreSQL backup/restore exercise.

## Repository layout

| Path | Purpose |
| --- | --- |
| `infra/modules/network` | VPC, public/private subnets, IGW, NAT gateway and routing |
| `infra/modules/ecs` | Internet-facing ALB, ECS cluster/service, Fargate task, task roles and logs |
| `infra/modules/rds` | Private PostgreSQL RDS instance, subnet group and database security group |
| `infra/envs/dev`, `infra/envs/prod` | Independent backend, variables and sizing examples |
| `db/migrations` | PostgreSQL schema, indexes and 150-row seed dataset |
| `scripts` | Database dump and fresh-database restore scripts |

## Local database

Prerequisites: Docker Desktop with Compose v2 and Bash.

```bash
docker compose up -d
docker compose ps
docker compose exec postgres psql -U postgres -d hotel_db -c 'SELECT COUNT(*) FROM hotel_bookings;'
```

The first startup runs both SQL files automatically. The final query should report `150`. To start completely over, run `docker compose down -v` (this intentionally deletes the local database volume) and then start Compose again.

### Query and index rationale

```sql
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

`idx_hotel_bookings_city_created_org_status` is ordered as `(city, created_at, org_id, status) INCLUDE (amount)`. The equality predicate on `city` comes first, followed by the range on `created_at`; the grouping fields and aggregate input are then in the index. This sharply limits the rows examined for the requested city/time window and can allow an index-only scan after PostgreSQL's visibility map is current.

Inspect the plan locally with:

```bash
docker compose exec postgres psql -U postgres -d hotel_db -c "EXPLAIN (ANALYZE, BUFFERS) SELECT org_id, status, COUNT(*), SUM(amount) FROM hotel_bookings WHERE city = 'delhi' AND created_at >= NOW() - INTERVAL '30 days' GROUP BY org_id, status;"
```

### Backup and restore

```bash
./scripts/backup.sh
./scripts/restore.sh                 # restores the newest dump into hotel_restore
# or: RESTORE_DB=my_fresh_db ./scripts/restore.sh backups/hotel_db-YYYYMMDDTHHMMSSZ.dump
```

`backup.sh` makes a timestamped PostgreSQL custom-format dump under `backups/`. `restore.sh` recreates a separate, fresh database (default: `hotel_restore`), restores the dump, and prints its `hotel_bookings` count. Verify it is `150`, then compare source and restore explicitly:

```bash
docker compose exec postgres psql -U postgres -d hotel_db -c 'SELECT COUNT(*) FROM hotel_bookings;'
docker compose exec postgres psql -U postgres -d hotel_restore -c 'SELECT COUNT(*) FROM hotel_bookings;'
```

## Terraform

The RDS instance is in private subnets and has `publicly_accessible = false`. Its security group permits port 5432 solely from the ECS task security group. The task security group permits port 80 solely from the ALB security group. Private task subnets have outbound access through NAT for pulling images and emitting logs.

Dev and prod intentionally differ:

| Environment | ECS | RDS | Backup retention | Deletion protection |
| --- | --- | --- | --- | --- |
| dev | 1 × 0.25 vCPU / 512 MiB | `db.t4g.micro`, 20 GiB | 3 days | false |
| prod | 2 × 0.5 vCPU / 1 GiB | `db.t4g.small`, 50 GiB | 14 days | true |

Each environment has its own S3 backend declaration. Replace `REPLACE_WITH_TERRAFORM_STATE_BUCKET` before using a real remote backend. The checked-in `tfvars` passwords are illustrative only; supply a real secret outside version control before an apply, for example `TF_VAR_db_master_password`.

For an offline state-independent review (the same behavior used by CI), use placeholder AWS credentials and disable the remote backend:

```bash
cd infra/envs/dev
terraform fmt -check -recursive ../..
terraform init -backend=false
terraform validate
AWS_ACCESS_KEY_ID=testing AWS_SECRET_ACCESS_KEY=testing terraform plan -refresh=false -input=false -var-file=dev.tfvars
```

Repeat in `infra/envs/prod` with `prod.tfvars`. The included GitHub Actions pull-request workflow runs formatting, init, validation and a no-refresh plan for both environments, then uploads each human-readable plan as an artifact. A real deployment requires valid AWS credentials, a real state bucket, and replacing the example password; it is deliberately outside this assessment's scope.
=======
# Tripare-ai-assignment
>>>>>>> b082d61718f35c760150ce13fab5cd2c5612267c
