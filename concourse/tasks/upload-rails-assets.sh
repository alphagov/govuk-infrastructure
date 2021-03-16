#!/usr/bin/env sh

set -eu

mkdir -p ~/.aws

cat <<EOF > ~/.aws/config
[profile default]
role_arn = $ASSUME_ROLE_ARN
credential_source = Ec2InstanceMetadata
EOF

echo "Uploading rails assets from ${IMAGE_ASSETS_PATH} to ${S3_BUCKET_PATH} ..."

aws s3 sync \
  "${IMAGE_ASSETS_PATH}" \
  "${S3_BUCKET_PATH}"

echo "Finished uploading rails assets from ${IMAGE_ASSETS_PATH} to ${S3_BUCKET_PATH}"
