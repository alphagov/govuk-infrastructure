data "aws_eks_cluster_auth" "auth" {
  name = "govuk"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.govuk.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.govuk.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.govuk.name]
    command     = "aws"
  }
}

data "tls_certificate" "govuk" {
  url = aws_eks_cluster.govuk.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "govuk" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.govuk.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.govuk.identity[0].oidc[0].issuer
}
