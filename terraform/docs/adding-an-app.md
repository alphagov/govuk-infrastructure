# Adding an app

This document covers the general steps required to bring up a new application
in the GOV.UK infrastructure (AWS ECS and supporting services).

The steps below may get out of date, so make sure you double check that they
are still accurate (please correct this doc if you find the steps are inaccurate).

## Steps

1. Build the app image

   Add the app to the Concourse build pipeline at
   [concourse/pipelines/build-images](../concourse/pipelines/build-images.yml).

   This will start building the app container image and pushing it to our
   Elastic Container Registry when there are new releases.

2. Add new variables required to [terraform/deployments/variables](../terraform/deployments/variables)

   (Optional). If the app needs a variable that will be common across apps or
   used throughout the project, you might find it useful to put these variables
   in the `deployments/variables` directory.

3. Create the app file for your new app in the [terraform/deployments/govuk-publishing-platform](../terraform/deployments/govuk-publishing-platform) deployment module

   This is required to bring up the app's infrastructure, including the
   ECS Service and accompanying infrastructure.

4. Apply the `govuk` module in your environment

   This will bring up the app's infrastructure, defined in step 3.
   This part will be performed by a Concourse pipeline automatically, so
   you don't need to do it manually.

  Example:

   ```sh
   $ cd terraform/deployments/govuk-publishing-platform
   $ terraform apply \
   $  -var-file ../variables/common.tfvars \
   $  -var-file ../variables/$ENVIRONMENT/common.tfvars \
   $  -var-file=../variables/$ENVIRONMENT/infrastructure.tfvars
   ```

5. Set up automated deployments

   Add the app to the Concourse deploy pipeline at
   [concourse/pipelines/deploy](../concourse/pipelines/deploy.yml).

   This will start deploy the app container image to ECS when there are new
   builds.

## Deploying apps

To set up automated deployments for your app, you'll need to modify the `deploy.yml`

We update an app's task definition and ECS Service (a deployment) using the
AWS CLI, rather than Terraform.

### Manually

First, register the new task definition revision (below).

Warning: It's not expected that you would do this, but it's useful to know
that you could do this (if Concourse is down, for example).

```shell
APPLICATION="frontend"
VARIANT="live"
IMAGE="release_3083"
AWS_REGION="eu-west-1"

cd terraform/deployments/govuk-publishing-platform
terraform output -json "${APPLICATION}" > "$root_dir/${APPLICATION}-terraform-outputs/${APPLICATION}.json"

jq \
  ".${VARIANT}.task_definition_cli_input_json | .containerDefinitions[0].image = \"${IMAGE}\"" \
  "app-terraform-outputs/${APPLICATION}.json" \
  > task-definition.json

aws ecs register-task-definition \
  --cli-input-json "file://task-definition.json" \
  --region "$AWS_REGION" \
  --query "taskDefinition.taskDefinitionArn" \
  --output "text" \
  | tee "task-definition-arn/task-definition-arn"
```

### Automatically

The above manual step is done by Concourse. Run the deploy apps pipeline -
you will need to complete step 5 above first.

For more detail see [applying terraform](applying-terraform.md).
