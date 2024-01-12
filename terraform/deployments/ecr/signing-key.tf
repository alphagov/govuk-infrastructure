resource "aws_kms_key" "container_signing_key" {
  description              = "Key for container image signing in GHA"
  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "RSA_4096"
}

resource "aws_kms_alias" "container_signing_key" {
  name          = "alias/container-signing-key"
  target_key_id = aws_kms_key.container_signing_key.id
}
