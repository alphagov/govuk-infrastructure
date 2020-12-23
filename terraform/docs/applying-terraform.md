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

### Monitoring

The monitoring stack of GOV.UK is in a separate cluster compared to the one where
the GOV.UK apps run. Below are the details how to run deploy the monitoring stack
which includes only Grafana for now.

1. Github Secrets

You need to ask a GitHub admin for the `alphagov` organisation to create a new
OAuth app for Grafana authentication. The redirect URL for OAuth is usually in
the format `https://<fqdn_grafana>/login/github` where `<fqdn_grafana>` is the
Fully Qualified Domain Name under which Grafana can be accessed.

Once a Grafana GitHub OAuth is created, you need to add to AWS Secret Manager
the `client_id` and the `client_secret` as `grafana_github_client_id` and
`grafana_github_client_secret` respectively.

2. Infrastructure

```sh
cd terraform/deployments/monitoring-test/infra

gds aws govuk-test-admin -- terraform init

gds aws govuk-test-admin -- terraform apply \
 -var-file=../../variables/test/common.tfvars \
 -var-file=../../variables/test/infrastructure.tfvars
```

3. Grafana Task Definition & Service Update

```sh
cd terraform/deployments/monitoring-test/grafana

gds aws govuk-test-admin -- terraform init

gds aws govuk-test-admin -- terraform apply

task_definition_arn=$(gds aws govuk-test-admin -- terraform output task_definition_arn)

gds aws govuk-test-admin -- aws ecs update-service  \
 --cluster monitoring \
 --service "grafana" \
 --task-definition "$task_definition_arn" \
 --region eu-west-1

 aws ecs wait services-stable \
  --cluster monitoring \
  --services "grafana" \
  --region eu-west-1
```

4. Grafana Internal Configuration

```sh
cd terraform/deployments/monitoring-test/grafana/app-config

gds aws govuk-test-admin -- terraform init

gds aws govuk-test-admin -- terraform apply
```

If you get an error: `Error: status: 404, body: {"message":"Data source not found"}`,
you should run: `gds aws govuk-test-admin -- terraform state rm module.grafana-app-config.grafana_data_source.cloudwatch` before re-applying the terraform.
