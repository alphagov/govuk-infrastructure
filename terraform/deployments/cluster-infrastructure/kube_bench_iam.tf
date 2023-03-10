resource "aws_iam_policy" "kube_bench_security_hub" {
  name        = "kube_bench_security_hub_${module.eks.cluster_name}"
  description = "Kube-bench integration to AWS Security Hub"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "securityhub:BatchImportFindings",
        "Resource" : "arn:aws:securityhub:eu-west-1::product/aqua-security/kube-bench"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kube_bench_security_hub" {
  role       = module.eks.eks_managed_node_groups["main"].iam_role_name
  policy_arn = aws_iam_policy.kube_bench_security_hub.arn
}
