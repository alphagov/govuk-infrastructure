#!/usr/bin/env sh

set -eu

mkdir -p ~/.aws

cat <<EOF > ~/.aws/config
[profile default]
role_arn = $ASSUME_ROLE_ARN
credential_source = Ec2InstanceMetadata
EOF

if [[ "$WORKSPACE" == "default" ]]; then
  WORKSPACE=ecs;
fi

S3_BUCKET_PATH=$(printf "$S3_BUCKET_PATH_PATTERN" "$WORKSPACE")

echo "Uploading files from ${SOURCE_PATH} to ${S3_BUCKET_PATH} ..."

aws s3 sync \
  "${SOURCE_PATH}" \
  "${S3_BUCKET_PATH}"

echo "Finished uploading files from ${SOURCE_PATH} to ${S3_BUCKET_PATH}"
