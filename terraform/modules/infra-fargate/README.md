# Infra Fargate

Status: `alpha`

The Infra Fargate module is used to bring up an application in ECS Fargate.

The variables `service_name`, `container_definitions`, and `desired_count`
enable the module to bring up a Fargate cluster, service, and task
with an application load balancer (ALB) and application logging to CloudWatch.

This does not handle the DNS records required to route traffic to the service.
