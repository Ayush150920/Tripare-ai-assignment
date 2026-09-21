variable "project" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "plan_only" {
  type    = bool
  default = false
}
variable "vpc_cidr" { type = string }
variable "availability_zones" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "container_image" { type = string }
variable "ecs_desired_count" { type = number }
variable "ecs_task_cpu" { type = number }
variable "ecs_task_memory" { type = number }
variable "rds_instance_class" { type = string }
variable "rds_allocated_storage" { type = number }
variable "rds_backup_retention_days" { type = number }
variable "rds_deletion_protection" { type = bool }
variable "database_name" { type = string }
variable "db_master_username" { type = string }
variable "db_master_password" {
  type      = string
  sensitive = true
}
