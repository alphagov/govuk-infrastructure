#!/usr/bin/env sh

set -eu

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

CLUSTER=govuk

aws ecs update-service \
  --cluster "$CLUSTER" \
  --service "$ECS_SERVICE" \
  --task-definition "$new_task_definition_arn" \
  --region "$AWS_REGION" > /dev/null

# Get the ID of the latest task so we can stream its logs.
# ecs-cli just wants the numeric ID of the task, not the whole ARN.
# So we have to use `awk` to fish that out.
task_id=$(aws ecs list-tasks \
  --cluster "$CLUSTER" \
  --service-name "$ECS_SERVICE" \
  --region "$AWS_REGION" \
  --query 'taskArns | [0]' \
  --output text \
  | awk -F / '{print $NF}'
)
echo "Task ID: $task_id"

echo "Waiting for $ECS_SERVICE ECS service to reach steady state..."

ecs-cli logs --region "$AWS_REGION" --cluster "$CLUSTER" --task-id "$task_id" --container-name "app" --follow &

aws ecs wait services-stable \
  --cluster "$CLUSTER" \
  --services "$ECS_SERVICE" \
  --region "$AWS_REGION"

echo "Finished updating $ECS_SERVICE to task definition $new_task_definition_arn."
