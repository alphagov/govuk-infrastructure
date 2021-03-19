plugin "aws" {
  enabled = true
}

plugin "workspaces" {
  enabled = true

  resource "aws_appmesh_mesh" {
    attribute = "name"
  }

  resource "aws_ecs_cluster" {
    attribute = "name"
  }

  resource "aws_elasticache_replication_group" {
    attribute = "replication_group_id"
  }

  resource "aws_elasticache_subnet_group" {
    attribute = "name"
  }

  resource "aws_iam_policy" {
    attribute = "name"
  }

  resource "aws_iam_role" {
    attribute = "name"
  }

  resource "aws_lb" {
    attribute = "name"
  }

  resource "aws_lb_target_group" {
    attribute = "name"
  }

  resource "aws_security_group" {
    attribute = "name"
  }

  resource "aws_service_discovery_private_dns_namespace" {
    attribute = "name"
  }

}

config {
  varfile = [
    "../variables/test/infrastructure.tfvars",
  ]
}

rule "terraform_comment_syntax" { enabled = true }
rule "terraform_deprecated_index" { enabled = true }
rule "terraform_required_providers" { enabled = true }
rule "terraform_standard_module_structure" { enabled = true }
rule "terraform_typed_variables" { enabled = true }
rule "terraform_unused_declarations" { enabled = true }
rule "terraform_unused_required_providers" { enabled = true }

