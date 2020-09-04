resource "aws_service_discovery_service" "service" {
  name = var.service_name
  namespace_id = var.govuk_publishing_platform_http_namespace_id
}
