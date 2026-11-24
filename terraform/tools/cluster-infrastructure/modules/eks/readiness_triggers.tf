resource "time_sleep" "readiness" {
  create_duration = "30s"

  triggers = {
    cluster_name     = aws_eks_cluster.this.id
    cluster_endpoint = aws_eks_cluster.this.endpoint
    kubernetes_versiom = aws_eks_cluster.this.version
    cluster_ca_data = aws_eks_cluster.this.certificate_authority[0].data
  }
}
