variable "name"             { type = string }
variable "db_name"          { type = string }
variable "username"         { type = string }
variable "password"         { type = string }
variable "subnet_ids"       { type = list(string) }
variable "vpc_id"           { type = string }
variable "allowed_sg_ids"   { type = list(string) } # e.g., ECS SG

variable "multi_az" {
     type = bool
     default = true 
     }

variable "instance_class" { 
    type = string
    default = "db.t3.micro" 
    }
