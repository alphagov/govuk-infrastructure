resource "aws_kms_key" "container_signing_key" {
  description              = "Key for signing of GOV.UK App mobile backend config"
  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "ECC_NIST_P256"
}

resource "aws_kms_alias" "container_signing_key" {
  name          = "alias/container-signing-key"
  target_key_id = aws_kms_key.container_signing_key.id
}
