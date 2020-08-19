output "public_service_sg_id" {
  value = aws_security_group.public_service_sg.id
  description = "The security group to link the public load balancer to the service"
}

output "public_tg_arn" {
  value = aws_lb_target_group.lb_tg.arn
  description = "The target group to link the public load balancer to the service"
}
