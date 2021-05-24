#!/usr/bin/env sh

set -eu

if [ "${WORKSPACE}" == "default" ]; then
  CLUSTER=govuk-ecs
else
  CLUSTER="govuk-$WORKSPACE"
fi

mkdir -p ~/.aws

cat <<EOF > ~/.aws/config
[profile default]
role_arn = $ASSUME_ROLE_ARN
credential_source = Ec2InstanceMetadata
EOF

new_task_definition_arn="$(cat "task-definition-arn/task-definition-arn")"
if [ -z "${new_task_definition_arn}" ]; then
  echo "failed to retrieve new task definition for $ECS_SERVICE, exiting..."
  exit 1
fi

echo "Updating $ECS_SERVICE service..."

aws ecs update-service \
  --cluster "$CLUSTER" \
  --service "$ECS_SERVICE" \
  --task-definition "$new_task_definition_arn" \
  --region "$AWS_REGION" > /dev/null

# Get the ID of the latest task.
task_arn=$(aws ecs list-tasks \
  --cluster "$CLUSTER" \
  --service-name "$ECS_SERVICE" \
  --region "$AWS_REGION" \
  --query 'taskArns | [0]' \
  --output text
)

echo "Task ARN: $task_arn"

# Pull the container ID from the task's associated `app` container
container_id=$(aws ecs describe-tasks \
  --cluster "$CLUSTER" \
  --tasks $task_arn \
  --query 'tasks[0] | containers[?name==`app`].runtimeId' \
  --region "$AWS_REGION" \
  --output text
)

echo "App container ID: $container_id"
echo "Check Splunk for logs: https://gds.splunkcloud.com/en-GB/app/gds-006-govuk/search?q=search%20index%3D%22govuk_replatforming%22%20container_id%3D$container_id"

echo "Deploy started."
