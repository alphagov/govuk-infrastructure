output "concourse_web_url" {
  value = "https://concourse.${local.external_dns_zone_name}"
}
