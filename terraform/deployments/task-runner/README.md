# Task runner

This project enables developers to run manual and scheduled tasks in ECS.

## Applying

```shell
terraform init -backend-config <govuk_environment>.backend -reconfigure

terraform apply \
 -var-file ../variables/common.tfvars \
 -var-file ../variables/<govuk_environment>/common.tfvars
```

where:
`<govuk_environment>` is the GOV.UK environment where you want the changes to be
applied.

## Running a rake task

To run a one-off rake task, you must do something like the following:

Create a task definition using the terraform project (e.g. frontend app)

Run the task, with an override for the command:

```sh
aws ecs run-task --cluster task_runner --task-definition frontend \
--launch-type FARGATE --count 1 --started-by "Harry Potter" \
--network-configuration '{
  "awsvpcConfiguration": {
    "subnets": ["subnet-6dc4370b", "subnet-463bfd0e", "subnet-bfecd0e4"],
    "securityGroups": ["sg-0b873470482f6232d"],
    "assignPublicIp": "DISABLED"
  }
}' \
--overrides '{
  "containerOverrides": [{
    "name": "frontend",
    "command": ["bundle", "exec", "rake", "stats"]
  }]
}'
```

This specifies that we will re-use the task definition created by the frontend
app. All task definitions must be created in Terraform.

The task_runner cluster is used for grouping together tasks, to make it easy
to find rake tasks.

The `command` override enables developers to run anything they like within the
container.

The intent is to expose this interface somehow via a CLI to replace the
"Run Rake Task" Jenkins job:

```sh
gds run-task --app frontend --command "bundle exec rake stats"
```

The [Proposal for running rake tasks in AWS ECS Fargate][] has more details of
what this command will do.

[Proposal for running rake tasks in AWS ECS Fargate]: https://github.com/alphagov/govuk-replatforming-discovery-2020/pull/6
