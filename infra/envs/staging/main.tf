terraform {
    required_version = ">= 1.5.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
        random = {
            source  = "hashicorp/random"
            version = "~> 3.0"
        }
    }
}


provider "aws" {
    region = var.aws_region
}

locals {
    name = "${var.project_name}-${var.env}"
    azs  = slice(data.aws_availability_zones.available.names, 0, 2)
}

data "aws_availability_zones" "available" {
    state = "available"
}

# --- VPC ---
module "vpc" {
  source          = "../../modules/vpc"
  name            = local.name
  cidr            = "10.20.0.0/16"
  public_subnets  = ["10.20.0.0/24", "10.20.1.0/24"]
  private_subnets = ["10.20.10.0/24", "10.20.11.0/24"]
  azs             = local.azs
  enable_nat      = true
}

# --- ECR ---
module "ecr" {
  source = "../../modules/ecr"
  name   = "${local.name}-repo"
}

# --- SQS/SNS ---
module "sqs_sns" {
  source         = "../../modules/sqs_sns"
  queue_name     = "${local.name}-queue"
  dlq_name       = "${local.name}-dlq"
  sns_topic_name = "${local.name}-topic"
  email_endpoint = var.notification_email
}

# --- DynamoDB ---
module "dynamo" {
  source = "../../modules/dynamodb"
  name   = "${local.name}-session"
}

# --- IAM (task & exec roles) ---
module "iam" {
  source           = "../../modules/iam"
  dynamo_table_arn = module.dynamo.table_arn
  sqs_queue_arn    = module.sqs_sns.queue_arn
  allow_secrets    = false
}

# --- ECS (Fargate) + ALB ---

module "ecs" {
  source              = "../../modules/ecs"
  name                = local.name
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  container_image     = "${module.ecr.repository_url}:${var.image_tag}"
  container_port      = 5678
  desired_count       = 1
  task_role_arn       = module.iam.task_role_arn
  exec_role_arn       = module.iam.exec_role_arn
  health_check_path   = "/"
}

# --- DB Password ---
resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%^&*()-_=+[]{}:,.?~"
}



# --- RDS Postgres ---
module "rds" {
  source         = "../../modules/rds"
  name           = local.name
  db_name        = "appdb"
  username       = var.db_username
  password       = var.db_password != "" ? var.db_password : random_password.db.result
  subnet_ids     = module.vpc.private_subnet_ids
  vpc_id         = module.vpc.vpc_id
  allowed_sg_ids = [module.ecs.ecs_sg_id] # expose SG via output below
  multi_az       = false                   # save cost in staging
  instance_class = "db.t3.micro"
}

# Expose ECS SG for RDS allowlist (wire via local output)
output "ecs_service_url" { value = "http://${module.ecs.alb_dns_name}" }