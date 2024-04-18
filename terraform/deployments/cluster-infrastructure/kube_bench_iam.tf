data "aws_iam_policy_document" "kube_bench_security_hub" {
  statement {
    effect = "Allow"
    actions = [
      "securityhub:BatchImportFindings"
    ]
    resources = [
      "arn:aws:securityhub:eu-west-1::product/aqua-security/kube-bench"
    ]
  }
}

resource "aws_iam_policy" "kube_bench_security_hub" {
  name        = "kube_bench_security_hub_${module.eks.cluster_name}"
  description = "Kube-bench integration to AWS Security Hub"

  policy = data.aws_iam_policy_document.kube_bench_security_hub.json
}

resource "aws_iam_role_policy_attachment" "kube_bench_security_hub" {
  role       = aws_iam_role.node.name
  policy_arn = aws_iam_policy.kube_bench_security_hub.arn
}
