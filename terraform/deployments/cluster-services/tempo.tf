locals {
  tempo_service_account = "tempo"
  cluster_name          = data.terraform_remote_state.cluster_infrastructure.outputs.cluster_id
}

resource "aws_s3_bucket" "tempo" {
  bucket = "govuk-${var.govuk_environment}-tempo"
}

module "tempo_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "~> 5.27"

  role_name        = "${local.tempo_service_account}-${local.cluster_name}"
  role_description = "Role for Tempo to access AWS data sources. Corresponds to ${local.tempo_service_account} k8s ServiceAccount."
  role_policy_arns = {
    TempoPolicy = aws_iam_policy.tempo.arn
  }

  cluster_service_accounts = {
    "${local.cluster_name}" = ["${local.monitoring_ns}:${local.tempo_service_account}"]
  }
}

resource "aws_iam_policy" "tempo" {
  name        = "tempo-${local.cluster_name}"
  description = "Allows Tempo to access AWS data sources."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "TempoPermissions",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging"
        ],
        "Resource" : [
          "${aws_s3_bucket.tempo.arn}/*",
          "${aws_s3_bucket.tempo.arn}"
        ]
      }
    ]
  })
}

resource "helm_release" "tempo" {
  depends_on = [module.tempo_iam_role, aws_s3_bucket.tempo]
  chart      = "tempo-distributed"
  name       = "tempo"
  namespace  = local.monitoring_ns
  repository = "https://grafana.github.io/helm-charts"
  version    = "1.4.8" # TODO: Dependabot or equivalent so this doesn't get neglected.
  values = [yamlencode({
    reportingEnabled = false

    ingester = {
      persistence = {
        enabled      = true
        size         = "30Gi"
        storageClass = "ebs-gp3"
      }
    }

    metricsGenerator = {
      enabled = true
      config = {
        storage = {
          remote_write = [
            {
              url = "${local.prometheus_internal_url}/api/v1/write"
            }
          ]
        }
      }
    }

    storage = {
      trace = {
        backend = "s3"
        s3 = {
          bucket   = aws_s3_bucket.tempo.id
          region   = aws_s3_bucket.tempo.region
          endpoint = "s3.dualstack.${aws_s3_bucket.tempo.region}.amazonaws.com"
        }
      }
    }

    serviceAccount = {
      name = "tempo"
      annotations = {
        "eks.amazonaws.com/role-arn" = module.tempo_iam_role.iam_role_arn
      }
    }


    metaMonitoring = {
      serviceMonitor = {
        enabled   = true
        namespace = local.monitoring_ns
      }
    }

    traces = {
      otlp = {
        grpc = {
          enabled = true
        }
        http = {
          enabled = true
        }
      }
    }

    overrides = yamlencode({
      overrides = {
        "*" = {
          ingestion_burst_size_bytes   = 20000000
          metrics_generator_processors = ["service-graphs", "span-metrics"]
        }
      }
    })
  })]
}
