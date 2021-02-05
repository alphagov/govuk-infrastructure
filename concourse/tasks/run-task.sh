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
# Finally, as a *third* input, the environment variables provide a) extra
# configuration for the task and b) configuration for the network config.

set -eu

root_dir=$(pwd)

# Raise error if env vars not set
: "${ASSUME_ROLE_ARN:?ASSUME_ROLE_ARN not set}"
: "${AWS_REGION:?AWS_REGION not set}"
: "${APPLICATION:?APPLICATION not set}"
: "${COMMAND:?COMMAND not set}"
: "${CLUSTER:?COMMAND not set}"
: "${VARIANT:?VARIANT not set}"

mkdir -p ~/.aws

cat <<EOF > ~/.aws/config
[profile default]
role_arn = $ASSUME_ROLE_ARN
credential_source = Ec2InstanceMetadata
region = $AWS_REGION
EOF

task_definition_arn="$(cat "task-definition-arn/task-definition-arn")"
network_config=$(jq -r ".${VARIANT}.network_config" "app-terraform-outputs/${APPLICATION}.json")

echo "Starting task..."

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
ecs-cli logs --cluster $CLUSTER --task-id $task_id --since "60"
exit_code=$(echo $task_results | jq [.tasks[0].containers[].exitCode] | jq add)
echo "Exiting with code $exit_code"
exit $exit_code
