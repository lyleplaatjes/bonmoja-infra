variable "name" { type = string }
variable "cidr" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "azs" { type = list(string) }

variable "enable_nat" {
     type = bool 
     default = true 
}
