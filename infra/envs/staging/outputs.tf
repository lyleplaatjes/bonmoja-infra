output "alb_dns_name"  {
     value = module.ecs.alb_dns_name 
     }

output "rds_endpoint"  {
     value = module.rds.endpoint 
     }

output "dynamo_table"  {
     value = module.dynamo.table_name 
     }