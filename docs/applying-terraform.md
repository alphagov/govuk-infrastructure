# Applying Terraform

> **Note:** This document may become outdated. Please update this document
if you find it is inaccurate.

We have attempted - where possible - to separate infrastructure concerns
(ECS Services, databases, Route53 records, etc.) from application concerns
(ECS Task Definitions, containers).

Therefore, there is a single command (`terraform apply`) to create or update the
infrastructure, and another set of commands to update application concerns.


## Updating the infrastructure

Example for updating the test environment below. The ideal scenario is that
we will have separate tfvars files for each environment.

```sh
cd terraform/deployments/govuk-test
terraform apply -var-file=../variables/test/common.tfvars \
   -var-file=../variables/test/infrastructure.tfvars
```

## Deploying an application

To deploy app changes to ECS Services, we update the task definition using
the deployment module in `terraform/deployments/apps` and then run a
set of commands using the AWS CLI to update the ECS Service.

This should be performed by a Concourse pipeline.

Example:

```sh
APPLICATION=frontend
GOVUK_ENVIRONMENT=test
BUILD_TAG=release_123
AWS_REGION=eu-west-1

cd "src/terraform/deployments/apps/$GOVUK_ENVIRONMENT/$APPLICATION"

terraform apply -var "image_tag=$BUILD_TAG"

task_definition_arn=$(terraform output task_definition_arn)

aws ecs update-service \
 --cluster govuk \
 --service "$APPLICATION" \
 --task-definition "$task_definition_arn" \
 --region "$AWS_REGION"

aws ecs wait services-stable \
 --cluster govuk \
 --services "$APPLICATION" \
 --region "$AWS_REGION"
```
