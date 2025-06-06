data "aws_security_group" "eks_cluster_primary_sg" {
  id = data.tfe_outputs.cluster_infrastructure.nonsensitive_values.control_plane_security_group_id
}

import {
  id = data.terraform_remote_state.infra_security_groups.outputs.sg_asset-master-efs_id
  to = aws_security_group.govuk_asset-master-efs_access
}

resource "aws_security_group" "govuk_asset-master-efs_access" {
  name        = "govuk_asset-master-efs_access"
  description = "Security group for asset-master EFS share"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id

  ingress {
    description     = "Shared EFS (Elastic File System) accepts requests from EKS nodes"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [data.aws_security_group.eks_cluster_primary_sg.id]
  }

  tags = {
    Name = "govuk_asset-master-efs_access"
  }
}

import {
  id = data.terraform_remote_state.infra_security_groups.outputs.sg_content-data-api-postgresql-primary_id
  to = aws_security_group.govuk_content-data-api-postgresql-primary_access
}

resource "aws_security_group" "govuk_content-data-api-postgresql-primary_access" {
  name        = "govuk_content-data-api-postgresql-primary_access"
  description = "Access to content-data-api-postgresql-primary from its clients"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id

  ingress {
    description     = "Database accepts requests from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.aws_security_group.eks_cluster_primary_sg.id]
  }

  tags = {
    Name = "govuk_content-data-api-postgresql-primary_access"
  }
}

import {
  id = data.terraform_remote_state.infra_security_groups.outputs.sg_elasticsearch6_id
  to = aws_security_group.govuk_elasticsearch6_access
}

resource "aws_security_group" "govuk_elasticsearch6_access" {
  name        = "govuk_elasticsearch6_access"
  description = "Access to elasticsearch6"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id

  ingress {
    description     = "ElasticSearch accepts requests from EKS nodes (for example Licence Finder queries ES directly)."
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [data.aws_security_group.eks_cluster_primary_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.search-ltr-generation_access.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.search-ltr-generation_access.id]
  }

  tags = {
    Name = "govuk_elasticsearch6_access"
  }
}

import {
  id = data.terraform_remote_state.infra_security_groups.outputs.sg_search-ltr-generation_id
  to = aws_security_group.search-ltr-generation_access
}

resource "aws_security_group" "search-ltr-generation_access" {
  name        = "search-ltr-generation_access"
  description = "Legacy SG for Search LTR Generation Access (used by ES6)"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "search-ltr-generation_access"
  }

  lifecycle {
    prevent_destroy = true
  }
}

import {
  id = data.terraform_remote_state.infra_security_groups.outputs.sg_licensify_documentdb_id
  to = aws_security_group.govuk_licensify-documentdb_access
}

resource "aws_security_group" "govuk_licensify-documentdb_access" {
  name        = "govuk_licensify-documentdb_access"
  description = "Access to licensify documentdb from its clients"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id

  ingress {
    description     = "Licensify DocumentDB accepts requests from EKS nodes"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [data.aws_security_group.eks_cluster_primary_sg.id]
  }

  tags = {
    Name = "govuk_licensify-documentdb_access"
  }
}

import {
  id = data.terraform_remote_state.infra_security_groups.outputs.sg_shared_documentdb_id
  to = aws_security_group.govuk_shared_documentdb_access
}

resource "aws_security_group" "govuk_shared_documentdb_access" {
  name        = "govuk_shared_documentdb_access"
  description = "Access to Shared Documentdb from its clients"
  vpc_id      = data.tfe_outputs.vpc.nonsensitive_values.id

  ingress {
    description     = "Shared DocumentDB accepts requests from EKS nodes"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [data.aws_security_group.eks_cluster_primary_sg.id]
  }

  tags = {
    Name = "govuk_shared_documentdb_access"
  }
}
