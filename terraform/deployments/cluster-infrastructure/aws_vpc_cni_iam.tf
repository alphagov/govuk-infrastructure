module "aws_vpc_cni_iam_role" {
  source             = "terraform-aws-modules/iam/aws//modules/iam-role"
  version            = "~> 6.0"
  name               = "aws-vpc-cni-${var.cluster_name}"
  use_name_prefix    = false
  description        = "Role used by the AWS VPC CNI for address management"
  enable_oidc        = true
  oidc_provider_urls = [module.eks.oidc_provider]
  policies = {
    "managed_cni_policy" = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  }
  oidc_subjects = ["system:serviceaccount:kube-system:aws-vpc-cni-sa"]
}
