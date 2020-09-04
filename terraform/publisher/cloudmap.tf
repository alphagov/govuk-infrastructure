resource "aws_service_discovery_service" "publisher" {
  name = "publisher"
  namespace_id = var.govuk_publishing_platform_http_namespace_id
}
