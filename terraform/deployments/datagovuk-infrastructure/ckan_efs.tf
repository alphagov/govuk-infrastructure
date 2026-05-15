data "aws_route53_zone" "internal" {
  name = "${var.govuk_environment}.govuk-internal.digital"
  tags = {
    repository = "govuk-infrastructure"
  }
  private_zone = true
}

resource "aws_security_group" "ckan_efs" {
  name        = "ckan-efs"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id
  description = "Security group for ckan EFS volume"
}

resource "aws_security_group_rule" "ckan_efs" {
  description              = "Allow EKS nodes to access NFS port"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ckan_efs.id
  source_security_group_id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.node_security_group_id
}

resource "aws_efs_file_system" "ckan_efs" {
  creation_token = "ckan-outputs"
  tags = {
    "Name"        = "ckan"
    "Description" = "Outputs from CKAN jobs will be stored here."
  }
}

resource "aws_efs_mount_target" "ckan_efs" {
  for_each        = toset(data.tfe_outputs.cluster_infrastructure.nonsensitive_values.private_subnets)
  file_system_id  = aws_efs_file_system.ckan_efs.id
  subnet_id       = each.key
  security_groups = [aws_security_group.ckan_efs.id]
}

resource "aws_route53_record" "ckan_efs" {
  zone_id = data.aws_route53_zone.internal.zone_id
  name    = "ckan_outputs.${data.aws_route53_zone.internal.name}"
  type    = "CNAME"
  records = [aws_efs_file_system.ckan_efs.dns_name]
  ttl     = 300
}
