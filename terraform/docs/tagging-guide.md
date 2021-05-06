# Overview
This document will describe the tagging strategy to be used within Replatforming terraform code which will be used to create resources in the AWS environment infrastructure.

Tagging is required so that cost and resource utilisation can be processed, with an added benefit of AWS console **Tag Key** searching.

# Tagging Table

The following table highlights the tags **Tag Key** that should added to the AWS resources listed in the section "AWS Resources that can be tagged".
The common column distinguishes between Tags that have been added as part of an default set and represented by **yes** and those which are unique per service represented by **no**

| **Tag Key** | **Tag Value(s)** | **Description** | **Example** | **Common** |
|--|--|--|--|--|
| Name | [ServiceName]-[Environment]-[Workspace] | This is the identifiable name of the service. | publisher-test-default | no |
| chargeable_entity | govuk-publishing-platform-[Environment] | This is required for billing. | govuk-publishing-platform-test | yes |
| environment | test integration staging production | Environment area to which this belongs. | test | yes |
|project | replatforming | This is the project under which this was developed. | replatforming | yes |
| repository | govuk-aws govuk-infrastructure | This is the Git repo in which this service resides. | govuk-infrastructure | yes |
| terraform_deployment | concourse-iam govuk-publishing-platform task-runner monitoring-test | The source in which the service resides. | govuk-publishing-platform | yes | 
|terraform_workspace | default bill chris fred karl nadeem steve roch towers | This should be the name of the terraform workspace that created the service. | default | yes |



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

- Below example of local common tags defined in the main.tf file
```
locals {
  additional_tags = {
    chargeable_entity    = "govuk-publishing-platform-${var.govuk_environment}"
    environment          = var.govuk_environment
    project              = "replatforming"
    repository           = "govuk-infrastructure"
    terraform_deployment = "govuk-publishing-platform"
    terraform_workspace  = terraform.workspace
  }
}
```

**IMPORTANT :-** 
- The **Key** attribute **Name** should start with an Uppercase letter and the rest should be lowercase with no spaces. 
- The **Value** attribute should be lowercase and no spaces however hyphens can be used.

**NOTES :-** 
- All listed resources from below should be made compliant.
- Common Tags have been added as **locals** with in the deployment terraform **main** file.
- This tagging strategy should ideally be replicated to other and new yet to be deployed environments such as **integration**.

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
