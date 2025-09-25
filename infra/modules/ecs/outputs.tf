output "alb_dns_name" {
     value = aws_lb.alb.dns_name 
     }

output "ecs_sg_id" {
     value = aws_security_group.ecs.id 
     }
