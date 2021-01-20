#!/usr/bin/env sh
# This script runs an arbitrary task using an existing task defintion in a
# new container, using ECS RunTask.

set -eu

root_dir=$(pwd)

# Raise error if env vars not set
: "${ASSUME_ROLE_ARN:?ASSUME_ROLE_ARN not set}"
: "${AWS_REGION:?AWS_REGION not set}"
: "${APPLICATION:?APPLICATION not set}"
: "${COMMAND:?COMMAND not set}"
: "${CLUSTER:?COMMAND not set}"
: "${TASK_DEFINITION:?TASK_DEFINITION not set}"

mkdir -p ~/.aws

cat <<EOF > ~/.aws/config
[profile default]
role_arn = $ASSUME_ROLE_ARN
credential_source = Ec2InstanceMetadata
region = $AWS_REGION
EOF

task_definition_arn=$(jq -r ".${TASK_DEFINITION}.value" terraform-outputs/${APPLICATION}-terraform-outputs.json)
network_config=$(jq -r ".task_network_config.value" terraform-outputs/${APPLICATION}-terraform-outputs.json)

echo "Starting task..."

task=$(aws ecs run-task --cluster $CLUSTER \
--task-definition $task_definition_arn --launch-type FARGATE --count 1 \
--network-configuration $network_config \
--started-by "Concourse" \
--overrides '{
  "containerOverrides": [{
    "name": "'"$APPLICATION"'",
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
