# Adding an app

This document covers the general steps required to bring up a new application
in the GOV.UK infrastructure (AWS ECS and supporting services).

The steps below may get out of date, so make sure you double check that they
are still accurate (please correct this doc if you find the steps are inaccurate).

## Steps

1. Add new variables required to [terraform/deployments/variables](../terraform/deployments/variables)

   (Optional). If the app needs a variable that will be common across apps or
   used throughout the project, you might find it useful to put these variables
   in the `deployments/variables` directory.

2. Create a new module in [terraform/modules/task-definitions](../terraform/modules/task-definitions)

   See the directory `task-definitions` for examples of other apps.
   The task definition should output an `arn` and it will probably
   accept similar variables to other apps such as `sentry_environment`.

3. Create a new module in [terraform/modules/apps](../terraform/modules/apps)

   See the `apps` directory for examples. You'll probably just want to call the
   `app` module to create an ECS service for your task, but this is the place
   for other app-specific infrastructure such as databases, Route53 records,
   load balancers, and so on.

4. Add the new `app` module to the [terraform/modules/govuk](../terraform/modules/govuk) module

   This is required to bring up the app's infrastructure, including the
   ECS Service and accompanying infrastructure.

5. Create a deployment module in [terraform/deployments/apps](../terraform/deployments/apps)

   See the other apps for examples on how to proceed. This directory
   is responsible for creating a new task definition, it calls the task
   definition module you created in step 2. This module will be called in
   the final step.

6. Apply the `govuk` module in your environment

   This will bring up the app's infrastructure, defined in step 3.
   This part may be performed by a Concourse pipeline in future

  Example:

   ```sh
   $ cd terraform/deployments/govuk-test
   $ terraform apply -var-file=../variables/test/common.tfvars \
      -var-file=../variables/test/infrastructure.tfvars
   ```

7. Apply the app deployment module in your environment

   This will bring up the app's task, defined in step 2.

   This part should be performed by [a Concourse pipeline](../concourse/pipelines)
   in future.

   For more detail see [applying terraform](applying-terraform.md).

   Example:

   ```sh
   $ cd terraform/deployments/apps/frontend
   $ terraform apply -var-file=../../variables/test/common.tfvars \
      -var-file=../../variables/test/apps.tfvars \
      -var=image_tag=release_123
   ```
