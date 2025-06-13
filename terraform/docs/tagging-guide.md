# Overview

This document will describe the tagging strategy to be used within govuk-infrastructure Terraform code which will be used to create resources in the AWS environment infrastructure.

Tagging is required so that cost and resource utilisation can be processed, with an added benefit of AWS console **Tag Key** searching.

# Tagging Table

The following table highlights the tags **Tag Key** that should added to AWS resources.
The common column distinguishes between Tags that have been added as part of an default set and represented by **yes** and those which are unique per service represented by **no**

| **Tag Key** | **Tag Value(s)** | **Description** | **Example** | **Common** |
|--|--|--|--|--|
| Name | [ServiceName]-[Environment]-[Workspace] | This is the identifiable name of the service. | publisher-test-default | no |
| product | GOV.UK | The product this resource belongs to. | GOV.UK | yes |
| system | Authentication, Identity proofing and verification core, VPC, etc. | The name of the software system (avoid abbreviations). | VPC | yes |
| environment | production, staging, integration, development | Environment area to which this belongs. | production | yes |
| owner | Email address for resource owner | Individual email for dev environments, group email elsewhere. | <govuk-platform-engineering@digital.cabinet-office.gov.uk> | yes |
| service | account management, session storage, front end, etc. | Function of the particular resource (optional). | session storage | no |
| repository | govuk-aws govuk-infrastructure | This is the Git repo where this service resides. | govuk-infrastructure | yes |
| terraform-deployment | cluster-infrastructure cluster-services ecr govuk-publishing-infrastructure | The source directory where the resource's Terraform code resides. | cluster-infrastructure | yes |

**NOTES :-**

- Common Tags are implemented via AWS provider **default_tags** in the deployment terraform **main** file.
- Additional resource-specific tags should use the merge pattern with locals when needed.
- This tagging strategy applies to all environments (production, staging, integration).

# Reference content

- For the definitive list of AWS resources that support tagging see [here](https://docs.aws.amazon.com/awsconsolehelpdocs/latest/gsg/supported-resources.html)
- The tagging strategy is also defined in the [GDS Ways](https://gds-way.digital.cabinet-office.gov.uk/manuals/aws-tagging.html#alerting-and-enforcement)
