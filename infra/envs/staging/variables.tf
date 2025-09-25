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
  validation {
    condition     = can(regex("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$", trim(var.notification_email)))
    error_message = "notification_email must be a valid email address with no spaces."
  }
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = ""   # allows falling back to random_password
  validation {
    condition = (
      var.db_password == "" ||
      (length(var.db_password) >= 8 &&
       length(var.db_password) <= 128 &&
       !contains(var.db_password, "/") &&
       !contains(var.db_password, "'") &&
       !contains(var.db_password, "\"") &&
       !contains(var.db_password, "@") &&
       !can(regex("\\s", var.db_password)) )
    )
    error_message = "db_password must be 8–128 chars and cannot contain / ' \" @ or spaces."
  }
}
