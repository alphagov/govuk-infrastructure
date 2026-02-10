locals {
  bucket_name        = "${var.govuk_environment}-eks-exec-audit-logs"
  sa_name            = "fluent-bit-tf-managed"
  logging_namespace  = "logging"
  tetragon_namespace = "tetragon"
  serviceaccount_rules = [
    {
      api_groups = [""]
      resources = [
        "namespaces",
        "pods",
        "events"
      ]
      verbs = [
        "get",
        "list",
        "watch"
      ]
    },
  ]

}
