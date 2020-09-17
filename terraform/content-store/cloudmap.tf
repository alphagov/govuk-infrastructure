resource "aws_service_discovery_service" "service" {
  name = var.service_name

  dns_config {
    namespace_id = var.govuk_publishing_platform_namespace_id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "WEIGHTED"
  }
}
