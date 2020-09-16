resource "aws_service_discovery_service" "publisher" {
  name = var.service_name
  namespace_id = var.govuk_publishing_platform_namespace_id
}
