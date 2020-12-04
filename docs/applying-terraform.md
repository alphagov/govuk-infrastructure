# Applying Terraform

> **Note:** This document may become outdated. Please update this document
if you find it is inaccurate.

We have attempted - where possible - to separate infrastructure concerns
(ECS Services, databases, Route53 records, etc.) from application concerns
(ECS Task Definitions, containers).

Therefore, there is a single command (`terraform apply`) to create or update the
infrastructure, and another set of commands to update application concerns.

### Automated Deployment via Concourse

Once you have merged your code in the `main`, this will kick off a new deployment
in [Concourse](https://cd.gds-reliability.engineering/teams/govuk-tools/pipelines/deploy-apps-test)
which will terraform the base infrastructure to reflect the code in the `main` branch.

After the base infrastructure has been terraformed, the Concourse pipeline will create new task definitions
for any services/applications that have changed. If a new task definition has been created, the respective
ECS Service will be updated/deployed.

## Local Deployment

### Infrastructure

You can update the base infrastructure from your machine to test things.
For example, run the following commands to update the test environment:

```sh
cd terraform/deployments/govuk-test
terraform apply -var-file=../variables/test/common.tfvars \
   -var-file=../variables/test/infrastructure.tfvars
```

### Application

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
