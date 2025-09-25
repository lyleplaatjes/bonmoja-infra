variable "queue_name"       { type = string }
variable "sns_topic_name"   { type = string }
variable "email_endpoint"   { type = string }

variable "dlq_name" {
     type = string
     default = null 
     }