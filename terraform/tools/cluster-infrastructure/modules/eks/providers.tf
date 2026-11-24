terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.54.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    host = aws_eks_cluster.this.endpoint

    token                  = data.aws_eks_cluster_auth.auth.token
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
  }
}
