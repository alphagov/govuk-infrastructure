terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.30"
    }
  }
}

locals {
  secret_name = "${var.app_shortname}_${var.workspace}"
}

resource "aws_secretsmanager_secret" "oauth_id" {
  name = "${local.secret_name}_id"

  # "Immediately" deletes the secret, rather than scheduling the deletion.
  # Fixes a Terraform bug (TF doesn't handle a secret that is scheduled for
  # deletion). Cannot delete and apply Terraform without this:
  # https://github.com/hashicorp/terraform-provider-aws/issues/5127
  recovery_window_in_days = 0

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.app_shortname}-${var.environment}-${var.workspace}"
    },
  )
}

resource "aws_secretsmanager_secret" "oauth_secret" {
  name = "${local.secret_name}_secret"

  # See comment above.
  recovery_window_in_days = 0

  tags = merge(
    var.additional_tags,
    {
      Name = "${var.app_shortname}-${var.environment}-${var.workspace}"
    },
  )
}
