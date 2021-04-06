terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.30"
    }
  }
}

locals {
  secret_name = "${var.from_app}_to_${var.to_app}_bearer_token_${var.workspace}"
}

resource "aws_secretsmanager_secret" "bearer_token" {
  name = local.secret_name

  # "Immediately" deletes the secret, rather than scheduling the deletion.
  # Fixes a Terraform bug (TF doesn't handle a secret that is scheduled for
  # deletion). Cannot delete and apply Terraform without this:
  # https://github.com/hashicorp/terraform-provider-aws/issues/5127
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_rotation" "bearer_token" {
  secret_id           = aws_secretsmanager_secret.bearer_token.id
  rotation_lambda_arn = aws_lambda_function.bearer_token.arn

  rotation_rules {
    automatically_after_days = 30
  }
}
