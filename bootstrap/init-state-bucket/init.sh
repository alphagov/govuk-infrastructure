#!/usr/bin/env bash

set -e -u -o pipefail

ENV_NAME="${1}"

if [ -z "${ENV_NAME}" ]; then
    echo "Usage: $0 <env_name>"
    exit 1
fi

BUCKET_NAME="govuk-${ENV_NAME}-state-files"
LOCAL_STATE_FILE_NAME="${BUCKET_NAME}__state-bucket.tfstate"
REMOTE_STATE_FILE_NAME="state-bucket.tfstate"

echo "Bucket name: ${BUCKET_NAME}"

if aws s3api head-bucket --bucket "${BUCKET_NAME}"; then
    echo "Bucket already exists"

    if aws s3api head-object --bucket "${BUCKET_NAME}" --key "${REMOTE_STATE_FILE_NAME}"; then
        echo "State file already exists. Downloading it in case there are changes."
        aws s3 cp "s3://${BUCKET_NAME}/state-bucket.tfstate" "${LOCAL_STATE_FILE_NAME}"
    else
        echo "State file did not already exist. Will upload the new one afterwards."
    fi
fi

terraform init -upgrade -reconfigure
terraform apply \
  -var "bucket_name=${BUCKET_NAME}" \
  -state "${LOCAL_STATE_FILE_NAME}"

BUCKET_NAME="$(terraform output -state "${LOCAL_STATE_FILE_NAME}" -raw "bucket_name")"

echo "Uploading state file to s3://${BUCKET_NAME}/${REMOTE_STATE_FILE_NAME}"
aws s3 cp "${LOCAL_STATE_FILE_NAME}" "s3://${BUCKET_NAME}/${REMOTE_STATE_FILE_NAME}"
