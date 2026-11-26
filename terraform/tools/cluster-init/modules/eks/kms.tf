resource "aws_kms_key" "cluster" {
  description             = "EKS Secret Encryption Key (${var.environment_name})"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

