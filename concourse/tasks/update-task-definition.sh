#!/usr/bin/env sh

set -eu

mkdir -p ~/.aws

cat <<EOF > ~/.aws/config
[profile default]
role_arn = $ASSUME_ROLE_ARN
credential_source = Ec2InstanceMetadata
EOF

IMAGE="${REGISTRY}/${APPLICATION}@$(cat app-image/digest)"

echo "Creating a new task definition for ${IMAGE} in ECS"
echo "================================================="

jq \
  ".${VARIANT}.task_definition_cli_input_json | .containerDefinitions[0].image = \"${IMAGE}\"" \
  "app-terraform-outputs/${APPLICATION}.json" \
  > task-definition.json

aws ecs register-task-definition \
  --cli-input-json "file://task-definition.json" \
  --region "$AWS_REGION" \
  --query "taskDefinition.taskDefinitionArn" \
  --output "text" \
  | tee "task-definition-arn/task-definition-arn"
