terraform {
  required_version = ">= 1.10.0"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = var.plan_only ? "mock_access_key" : null
  secret_key                  = var.plan_only ? "mock_secret_key" : null
  skip_credentials_validation = var.plan_only
  skip_requesting_account_id  = var.plan_only
  skip_metadata_api_check     = var.plan_only
  skip_region_validation      = var.plan_only
  default_tags { tags = local.tags }
}

locals { tags = { Project = "tripare", Environment = var.environment, ManagedBy = "terraform" } }

module "network" {
  source               = "../../modules/network"
  name                 = "${var.project}-${var.environment}"
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.tags
}

module "ecs" {
  source             = "../../modules/ecs"
  name               = "${var.project}-${var.environment}"
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  desired_count      = var.ecs_desired_count
  task_cpu           = var.ecs_task_cpu
  task_memory        = var.ecs_task_memory
  container_image    = var.container_image
  aws_region         = var.aws_region
  tags               = local.tags
}

module "rds" {
  source                  = "../../modules/rds"
  name                    = "${var.project}-${var.environment}"
  vpc_id                  = module.network.vpc_id
  private_subnet_ids      = module.network.private_subnet_ids
  ecs_security_group_id   = module.ecs.ecs_security_group_id
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  backup_retention_period = var.rds_backup_retention_days
  deletion_protection     = var.rds_deletion_protection
  database_name           = var.database_name
  master_username         = var.db_master_username
  master_password         = var.db_master_password
  tags                    = local.tags
}

output "application_url" { value = "http://${module.ecs.alb_dns_name}" }
output "rds_endpoint" { value = module.rds.endpoint }
