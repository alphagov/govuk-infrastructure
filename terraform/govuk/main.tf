# All services running on GOV.UK run in this single cluster.
resource "aws_ecs_cluster" "cluster" {
  name               = "govuk"
  capacity_providers = ["FARGATE"]
}
