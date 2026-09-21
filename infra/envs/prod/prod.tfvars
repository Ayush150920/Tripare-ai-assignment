project                   = "tripare"
environment               = "prod"
aws_region                = "ap-south-1"
plan_only                 = true
vpc_cidr                  = "10.20.0.0/16"
availability_zones        = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs       = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs      = ["10.20.11.0/24", "10.20.12.0/24"]
container_image           = "nginx:1.27-alpine"
ecs_desired_count         = 2
ecs_task_cpu              = 512
ecs_task_memory           = 1024
rds_instance_class        = "db.t4g.small"
rds_allocated_storage     = 50
rds_backup_retention_days = 14
rds_deletion_protection   = true
database_name             = "tripare"
db_master_username        = "tripareadmin"
# Demonstration-only value. Supply a secret via TF_VAR_db_master_password before applying.
db_master_password = "change-before-real-apply"

