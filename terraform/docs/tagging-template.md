# Terraform Tagging Template

This template provides the standard tagging configuration for all terraform deployments.

## Standard AWS Provider Configuration

```hcl
provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = local.default_tags
  }
}

locals {
  default_tags = {
    Product              = "GOV.UK"
    System               = "[SYSTEM_NAME]"  # Replace with appropriate system name
    Environment          = var.govuk_environment
    Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
    repository           = "govuk-infrastructure"
    terraform_deployment = basename(abspath(path.root))
  }
}
```

## Standard Google Provider Configuration

```hcl
provider "google" {
  project = var.google_project_id
  region  = "europe-west2"
  default_labels = {
    product              = "govuk"
    system               = "[system-name]"  # Replace with lowercase system name
    environment          = var.govuk_environment
    owner                = "govuk-platform-engineering"
    repository           = "govuk-infrastructure"
    terraform_deployment = basename(abspath(path.root))
  }
}
```

## Resource-Specific Tagging

For resources that need additional tags:

```hcl
resource "aws_example_resource" "example" {
  # ... resource configuration ...
  
  tags = merge(local.default_tags, {
    Name    = "example-${var.govuk_environment}"
    Service = "example service"  # Optional - describe the function
  })
}
```

## System Names by Deployment

| Deployment | System Name |
|------------|-------------|
| vpc | VPC |
| cluster-infrastructure | EKS cluster infrastructure |
| cluster-services | EKS cluster services |
| rds | EKS RDS |
| elasticache | GOVUK ElastiCache |
| opensearch | OpenSearch |
| ecr | Elastic Container Registry |
| govuk-publishing-infrastructure | GOV.UK Publishing |
| datagovuk-infrastructure | DATA.GOV.UK |
| logging | Logging |
| github | GitHub |
| root-dns | DNS |
| cloudfront | CloudFront |
| csp-reporter | CSP Reporter |
| chat | GOV.UK Chat |
| mobile-backend | GOV.UK App |
| release | EKS release assumer |
| tfc-aws-config | Terraform Cloud |