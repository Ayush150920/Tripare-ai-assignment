project                   = "tripare"
environment               = "dev"
aws_region                = "ap-south-1"
plan_only                 = true
vpc_cidr                  = "10.10.0.0/16"
availability_zones        = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs       = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs      = ["10.10.11.0/24", "10.10.12.0/24"]
container_image           = "nginx:1.27-alpine"
ecs_desired_count         = 1
ecs_task_cpu              = 256
ecs_task_memory           = 512
rds_instance_class        = "db.t4g.micro"
rds_allocated_storage     = 20
rds_backup_retention_days = 3
rds_deletion_protection   = false
database_name             = "tripare"
db_master_username        = "tripareadmin"
# Demonstration-only value. Supply a secret via TF_VAR_db_master_password before applying.
db_master_password = "change-before-real-apply"

