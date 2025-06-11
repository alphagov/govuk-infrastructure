# Overview
This document will describe the tagging strategy to be used within govuk-infrastructure Terraform code which will be used to create resources in the AWS environment infrastructure.

Tagging is required so that cost and resource utilisation can be processed, with an added benefit of AWS console **Tag Key** searching.

# Tagging Table

The following table highlights the tags **Tag Key** that should added to the AWS resources listed in the section "AWS Resources that can be tagged".
The common column distinguishes between Tags that have been added as part of an default set and represented by **yes** and those which are unique per service represented by **no**

| **Tag Key** | **Tag Value(s)** | **Description** | **Example** | **Common** |
|--|--|--|--|--|
| Name | [ServiceName]-[Environment]-[Workspace] | This is the identifiable name of the service. | publisher-test-default | no |
| Product | GOV.UK One Login / GOV.UK or DSP | The product this resource belongs to. | GOV.UK | yes |
| System | Authentication, Identity proofing and verification core, VPC, etc. | The name of the software system (avoid abbreviations). | VPC | yes |
| Environment | production, staging, integration, development | Environment area to which this belongs. | production | yes |
| Owner | Email address for resource owner | Individual email for dev environments, group email elsewhere. | govuk-platform-engineering@digital.cabinet-office.gov.uk | yes |
| Service | account management, session storage, front end, etc. | Function of the particular resource (optional). | session storage | no |
| repository | govuk-aws govuk-infrastructure | This is the Git repo where this service resides. | govuk-infrastructure | yes |
| terraform_deployment | cluster-infrastructure cluster-services ecr govuk-publishing-infrastructure | The source directory where the resource's Terraform code resides. | cluster-infrastructure | yes |



# Tag Policy
- Below example of a correct local tag definition for the non common **Tag Key** Name.
```
tags = merge(
    local.additional_tags,
    {
      Name = "publisher-${var.environment}-${local.workspace}"
    }
```
- Below example of a correct module tag definition for the non common **Tag Key** Name
```
tags = merge(
    var.additional_tags,
    {
      Name = "publisher-${var.environment}-${var.workspace}"
    }
```

- Below example of common tags defined via provider default_tags in the main.tf file
```
provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Product              = "GOV.UK"
      System               = "[System description - e.g., VPC, Authentication]"
      Environment          = var.govuk_environment
      Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
      repository           = "govuk-infrastructure"
      terraform_deployment = basename(abspath(path.root))
    }
  }
}
```

- Below example of local additional tags for resource-specific tagging
```
locals {
  default_tags = {
    Product              = "GOV.UK"
    System               = "[System description]"
    Environment          = var.govuk_environment
    Owner                = "govuk-platform-engineering@digital.cabinet-office.gov.uk"
    repository           = "govuk-infrastructure"
    terraform_deployment = basename(abspath(path.root))
  }
}
```

**IMPORTANT :-**
- The **Key** attribute **Name** should start with an Uppercase letter and the rest should be lowercase with no spaces.
- The **Value** attribute should be lowercase and no spaces however hyphens can be used.

**NOTES :-**
- All listed resources from below should be made compliant.
- Common Tags are implemented via AWS provider **default_tags** in the deployment terraform **main** file.
- Additional resource-specific tags should use the merge pattern with locals when needed.
- This tagging strategy applies to all environments (production, staging, integration, development).

## Mandatory Tags
The following tags are **MANDATORY** and must be present on all taggable resources:

- **Product**: GOV.UK One Login / GOV.UK or DSP
- **System**: The name of the software system (avoid abbreviations)  
- **Environment**: production, staging, integration, or development
- **Owner**: Email address - individual for dev environments, group elsewhere

## Optional Tags
The following tag is **OPTIONAL** but recommended:

- **Service**: Function of the particular resource (e.g., account management, session storage, front end)

# AWS Resources
## Can be tagged
The following lists the resources that **should** be tagged:-

- AWS::EC2::SecurityGroup
- AWS::EC2::Subnet
- AWS::ECR::Repository
- AWS::ECS::Cluster
- AWS::ECS::Service
- AWS::ECS::TaskDefinition
- AWS::ElastiCache::ReplicationGroup
- AWS::ElasticLoadBalancingV2::TargetGroup
- AWS::ElasticLoadBalancing::LoadBalancer
- AWS::ElasticLoadBalancingV2::LoadBalancer
- AWS::Lambda::Function
- AWS::S3::Bucket
- AWS::ACM::Certificate

## Can NOT be tagged
The following is a list of AWS resources that do NOT support tags :-

- AWS::CloudWatch::Alarm
- AWS::EC2::SecurityGroupIngress
- AWS::EC2::SubnetRouteTableAssociation
- AWS::ElasticLoadBalancingV2::Listener
- AWS::IAM::Policy
- AWS::IAM::Role
- AWS::IAM::ManagedPolicy
- AWS::Logs::LogStream
- AWS::Route53::HostedZone
- AWS::Route53::RecordSet
- AWS::S3::BucketPolicy
- AWS::WAFRegional::IPSet
- AWS::WAFRegional::WebACL

# Reference content
- For the definitive list of AWS resources that support tagging see [here](https://docs.aws.amazon.com/awsconsolehelpdocs/latest/gsg/supported-resources.html)
