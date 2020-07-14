output "alb_zone_id" {
  value       = aws_lb.alb.zone_id
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
}

output "dns_name" {
  value       = aws_lb.alb.dns_name
  description = "The DNS name of the load balancer"
}
