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

echo "Deploy started."
