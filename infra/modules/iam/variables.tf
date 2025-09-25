variable "dynamo_table_arn" { type = string }
variable "sqs_queue_arn"    { type = string }
variable "allow_secrets"    { type = bool, default = false }
