#!/bin/sh
#
# terraform.sh runs Terraform plan or apply from the directory
# $DEPLOYMENT_PATH, acting as the IAM role specified in $ASSUME_ROLE_ARN.

set -eu

usage() {
    echo "usage: $0 plan|apply|destroy [additional_terraform_args ...]" >&2
    exit 64  # EX_USAGE
}

auto_approve=""
tf_action="${1:-}" && shift
case $tf_action in
    plan )
        ;;
    apply | destroy )
        auto_approve="-auto-approve"  # Necessary even with -input=false.
        ;;
    * )
        usage
        ;;
esac

export TF_IN_AUTOMATION=1

# Assume role once here, rather than configuring the same thing (via different
# options) in each Terraform provider in every root module.
#
# TODO: Consider factoring this out into a script and including it in the image.
creds="$(aws sts assume-role \
  --role-session-name "concourse-$(date +%d-%m-%y_%H-%M-%S)" \
  --role-arn "${ASSUME_ROLE_ARN}" \
  | jq .Credentials)"
AWS_ACCESS_KEY_ID="$(echo "$creds" | jq -r .AccessKeyId)"
AWS_SECRET_ACCESS_KEY="$(echo "$creds" | jq -r .SecretAccessKey)"
AWS_SESSION_TOKEN="$(echo "$creds" | jq -r .SessionToken)"
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

cd "${DEPLOYMENT_PATH}"

terraform init -input=false -backend-config "${ENVIRONMENT}.backend"

terraform "$tf_action" -input=false \
  -var-file "../variables/${ENVIRONMENT}/common.tfvars" \
  -var-file "../variables/common.tfvars" \
  $auto_approve "$@"
