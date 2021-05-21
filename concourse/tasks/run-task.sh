#!/usr/bin/env sh
# This script runs an arbitrary task using an existing task defintion in a
# new container, using ECS RunTask.
# This script expects the task-definition-arn/task-definition-arn file to
# contain the Task Definition ARN to use for the task (acquired e.g. via a
# terraform apply, or an ECS DescribeService API call).
# The script also requires a directory app-terraform-outputs as an input.
# app-terraform-outputs contains the JSON file such as publisher.json output
# from running TF apply against govuk-publishing-platform. It provides the
# network config used by the task.
# As a *third* input, the environment variables provide a) extra
# configuration for the task and b) configuration for the network config.
# To provide the COMMAND (e.g. `sleep 1 && echo "done"`) that you wish the task
# to run, you can provide either a COMMAND param or a file containing the task
# to run in run-task-command/run-task-command. Prefer the param approach where
# possible, since it is clearer.

set -eu

root_dir=$(pwd)

# Permits using input file or COMMAND param
COMMAND=${COMMAND:-"$(cat "run-task-command/run-task-command")"}

# Raise error if env vars not set
: "${ASSUME_ROLE_ARN:?ASSUME_ROLE_ARN not set}"
: "${AWS_REGION:?AWS_REGION not set}"
: "${APPLICATION:?APPLICATION not set}"
: "${COMMAND:?COMMAND param is unset or run-task-command file is empty}"
: "${CLUSTER:?CLUSTER not set}"
: "${VARIANT:?VARIANT not set}"

if [[ "${DISABLE:-false}" == "true" ]]; then
  echo "Skipping Task"
  exit 0
fi

mkdir -p ~/.aws

cat <<EOF > ~/.aws/config
[profile default]
role_arn = $ASSUME_ROLE_ARN
credential_source = Ec2InstanceMetadata
region = $AWS_REGION
EOF

task_definition_arn="$(cat "task-definition-arn/task-definition-arn")"
network_config=$(jq -r ".${VARIANT}.network_config" "app-terraform-outputs/${APPLICATION}.json")

echo "  Starting $COMMAND ❤"
ALPACA='
         , , , , ,
      /\,/"`"`"\`\ /\,
      | `         ` |
      `  ⌒       ⌒  `
      (  ◉  ❤   ◉  )
      (      ⌣      ) ------ Starting task ❤
      (             )
       (           )
       (           )
       (           )
      (             )"`"``"`(``)
      (                        )
     (                         )
     (                         )
     (                        )
      (     )`(     )((      )
       \, ,/   \, ,/   \  \ /
         ⌣       ⌣     ⌣ ⌣
'
echo "${ALPACA}"

task=$(aws ecs run-task --cluster $CLUSTER \
--task-definition $task_definition_arn --launch-type FARGATE --count 1 \
--network-configuration $network_config \
--started-by "Concourse" \
--overrides '{
  "containerOverrides": [{
    "name": "app",
    "command": ["/bin/bash", "-c", "'"$COMMAND"'"]
  }]
}')

task_arn=$(echo $task | jq .tasks[0].taskArn -r)
task_id=$(basename $task_arn)
echo "waiting for task $task_arn to finish..."
aws ecs wait tasks-stopped --tasks $task_id --cluster $CLUSTER
echo "task finished."
task_results=$(aws ecs describe-tasks --tasks $task_id --cluster $CLUSTER)

ecs-cli logs --cluster $CLUSTER --task-id $task_id --since "60" | head -n 5000

exit_code=$(echo $task_results | jq [.tasks[0].containers[].exitCode] | jq add)
echo "Exiting with code $exit_code"
exit $exit_code
