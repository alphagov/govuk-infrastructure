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

aws ecs update-service \
  --cluster govuk \
  --service "$ECS_SERVICE" \
  --task-definition "$new_task_definition_arn" \
  --region "$AWS_REGION"

echo "Waiting for $ECS_SERVICE ECS service to reach steady state..."

aws ecs wait services-stable \
  --cluster govuk \
  --services "$ECS_SERVICE" \
  --region "$AWS_REGION"

echo "Finished updating $ECS_SERVICE to task definition $new_task_definition_arn."
