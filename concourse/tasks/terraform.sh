#!/bin/sh

set -eu

export TF_IN_AUTOMATION=1

# Assume role once here, rather than configuring the same thing (via different
# options) in each Terraform provider in every root module.
#
# TODO: If this ends up being used elsewhere, factor it out into a script and
# build it into the image.
creds="$(aws sts assume-role \
  --role-session-name "concourse-$(date +%d-%m-%y_%H-%M-%S)" \
  --role-arn "${ASSUME_ROLE_ARN}" \
  | jq .Credentials)"
export AWS_ACCESS_KEY_ID="$(echo $creds | jq -r .AccessKeyId)"
export AWS_SECRET_ACCESS_KEY="$(echo $creds | jq -r .SecretAccessKey)"
export AWS_SESSION_TOKEN="$(echo $creds | jq -r .SessionToken)"

cd "${DEPLOYMENT_PATH}"

terraform init -input=false -backend-config "${ENVIRONMENT}.backend"

terraform apply -input=false \
  -var-file "../variables/${ENVIRONMENT}/common.tfvars" \
  -auto-approve
