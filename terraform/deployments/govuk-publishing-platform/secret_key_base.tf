resource "aws_secretsmanager_secret" "secret_key_base" {
  for_each = toset([
    "authenticating_proxy",
    "content_store",
    "draft_content_store",
    "draft_frontend",
    "draft_static",
    "draft_router_api",
    "frontend",
    "publisher",
    "publishing_api",
    "signon",
    "static",
    "router_api",
  ])

  name = "${each.key}-${local.workspace}-SECRET_KEY_BASE"

  # HACK: Fixes a bug where Terraform can't handle secrets scheduled for deletion:
  # https://github.com/hashicorp/terraform-provider-aws/issues/5127
  recovery_window_in_days = 0

  tags = merge(
    local.additional_tags,
    {
      Name = "${each.key}-secret_key_base-${var.govuk_environment}-${local.workspace}"
    },
  )
}
