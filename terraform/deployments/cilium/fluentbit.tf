locals {
  fluent_bit_service_account_name = "fluent-bit-hubble-export"
  hubble_log_s3_bucket_name       = "hubble-logs-${var.govuk_environment}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  hubble_log_s3_path_prefix       = "logs/network-mapping"
  hubble_log_s3_file_format       = "json_lines"
}

resource "helm_release" "fluent_bit" {
  name      = "fluent-bit-hubble-exporter"
  namespace = kubernetes_namespace_v1.cilium.metadata[0].name

  repository = "oci://ghcr.io/fluent/helm-charts/"
  chart      = "fluent-bit-collector"
  version    = "1.1.3"

  values = [yamlencode({
    serviceAccount = {
      create = true
      name   = local.fluent_bit_service_account_name
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.fluent_bit_hubble_exporter.arn
      }
      automountToken = true
    }
    storage = {
      enabled = true
    }
    config = yamldecode(
      templatefile("${path.module}/config/fluent-bit/fluent-bit.yaml", {
        hubble_log_s3_bucket_name   = local.hubble_log_s3_bucket_name,
        hubble_log_s3_bucket_region = data.aws_region.current.region,
        hubble_log_s3_path_prefix   = local.hubble_log_s3_path_prefix
        hubble_log_s3_file_format   = local.hubble_log_s3_file_format
      })
    )
    hostVolumes = [
      // This first volume is included by default and we should keep it so fluent bit can augment the logs
      {
        name      = "machine-id"
        mountPath = "/etc/machine-id"
        hostPath = {
          path = "/etc/machine-id"
          type = "File"
        }
        }, {
        name      = "hubble-export"
        mountPath = "/var/run/cilium/hubble"
        hostPath = {
          path = "/var/run/cilium/hubble"
          type = "Directory"
        }
      }
    ]
  })]
}

locals {
}

module "hubble_logs_bucket" {
  source = "../../shared-modules/s3"

  name              = local.hubble_log_s3_bucket_name
  govuk_environment = var.govuk_environment
}

resource "aws_iam_role" "fluent_bit_hubble_exporter" {
  name               = "govuk-${var.govuk_environment}-fluent-bit-hubble-export"
  assume_role_policy = data.aws_iam_policy_document.fluent_bit_hubble_exporter_assume_role.json
}

data "aws_iam_policy_document" "fluent_bit_hubble_exporter_assume_role" {
  statement {
    sid     = "AllowEKSFluentBit"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn, "/^(.*provider/)/", "")}:sub"
      values   = ["system:serviceaccount:${kubernetes_namespace_v1.cilium.metadata[0].name}:${local.fluent_bit_service_account_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.cluster_oidc_provider_arn, "/^(.*provider/)/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "fluent_bit_hubble_exporter" {
  statement {
    actions = [
      "s3:PutObject",
    ]
    resources = ["${module.hubble_logs_bucket.arn}/logs/network-mapping/*"]
  }
}

resource "aws_iam_policy" "fluent_bit_hubble_exporter" {
  name        = "govuk-${var.govuk_environment}-fluent-bit-hubble-exporter"
  description = "Policy to allow fluent bit to export hubble logs to S3"
  policy      = data.aws_iam_policy_document.fluent_bit_hubble_exporter.json
}

resource "aws_iam_role_policy_attachment" "fluent_bit_hubble_exporter" {
  role       = aws_iam_role.fluent_bit_hubble_exporter.name
  policy_arn = aws_iam_policy.fluent_bit_hubble_exporter.arn
}
