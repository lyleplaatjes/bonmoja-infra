variable "name"                { type = string }
variable "vpc_id"              { type = string }
variable "private_subnet_ids"  { type = list(string) }
variable "public_subnet_ids"   { type = list(string) }
variable "container_image"     { type = string }
variable "task_role_arn"       { type = string }
variable "exec_role_arn"       { type = string }
variable "region"              { type = string }


variable "container_port" { 
    type = number 
    default = 5678 
    }

variable "desired_count" {
     type = number 
     default = 1 
     }

variable "health_check_path" {
     type = string 
     default = "/health" 
     }
