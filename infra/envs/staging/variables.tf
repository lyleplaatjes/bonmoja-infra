variable "env" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "bonmoja"
}

# App settings
variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "notification_email" {
  description = "Notification email address"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "Database password"
  type        = string
}

# set via TF_VAR_db_password Github Actions secret