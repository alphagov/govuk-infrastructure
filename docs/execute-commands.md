# Execute commands

You can run commands inside containers using Amazon ECS Exec. This is a lot
like SSH, although what happens under the hood is quite different.

To use this feature, you need to install the AWS CLI and [install the Session Manager plugin][].

## Finding a task ID

An ECS service can have one or more tasks running, depending on how scaled up it is.

To exec into a container, first you need the ARN of the task it's running in.
For example, to get the ARN for frontend in the default cluster:

```
task_arn="$(aws ecs list-tasks --cluster govuk-ecs --service-name frontend --query 'taskArns[0]' --output text)"
```

## Executing a command

An ECS task can include more than one container. Our tasks usually include an
`app` container and an `envoy` container (which is used by AWS AppMesh).

To run an interactive bash shell in the `app` container of the task:

```
aws ecs execute-command \
  --cluster govuk-ecs \
  --task "$task_arn" \
  --container app \
  --interactive \
  --command "bash"
```

## Known bugs

AWS ECS is a new feature, and it has some known bugs.

### The execute command failed because execute command was not enabled when the task was run

Sometimes something goes wrong with the agent, and you'll get a message like:

```
An error occurred (InvalidParameterException) when calling the ExecuteCommand
operation: The execute command failed because execute command was not enabled
when the task was run or the execute command agent isn’t running. Wait and try
again or run a new task with execute command enabled and try again.
```

This sometimes happens in the `app` container, sometimes in the `envoy`
container, sometimes in both. It can also occur if the container is not yet in a
`RUNNING` / `HEALTHY` state (e.g. because it just started) so ensure that the
container is ready before troubleshooting further:

```
aws ecs describe-tasks \
  --cluster govuk-ecs \
  --tasks "$task_arn" \
  --query "tasks[0].containers[?name=='app'] | [0] | [ lastStatus, healthStatus ]" \
  --output text
```

If there are multiple instances of a task you could try one of the other instances:

```
aws ecs list-tasks --cluster govuk-ecs --service-name frontend
```

If you've tried all the tasks and they're all broken, you can stop one of the
tasks and AWS will start a new one for you.

NOTE: this will reduce the number of tasks handling traffic. If there's only one
task running in the service, stopping it will cause an outage. Be careful if
you're doing this in production.

```
aws ecs stop-task --cluster govuk-ecs --task "$task_arn"
```

The new task will have a different ARN, so you'll need to run `aws ecs
list-tasks` again. It may take a minute or two after the new task starts before
you can `execute-command` inside.

[install the Session Manager plugin]: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
