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

echo "Waiting for $ECS_SERVICE ECS service to reach steady state..."

aws ecs wait services-stable \
  --cluster "$CLUSTER" \
  --services "$ECS_SERVICE" \
  --region "$AWS_REGION"

echo "ECS Service $ECS_SERVICE deployment complete. Service is now stable."
