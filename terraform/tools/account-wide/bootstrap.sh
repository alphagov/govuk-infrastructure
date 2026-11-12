#!/usr/bin/env bash

set -euo pipefail

REQUIRED_COMMANDS=(
  aws
  jq
)

BACKEND_DISABLED=false

for COMMAND in "${REQUIRED_COMMANDS[@]}"; do
	if ! command -v "$COMMAND" >/dev/null 2>&1; then
		echo "$COMMAND required, you need to install it and retry"
		exit 1
	fi
done

STS_CALLER_IDENTITY=

if ! STS_CALLER_IDENTITY=$(aws sts get-caller-identity); then
	echo "You are not authenticated with AWS, you need to auth as admin in the tools account"
	exit 1
fi

ACCOUNT_ID=$(jq -r .Account <<<"$STS_CALLER_IDENTITY")

if [ "$ACCOUNT_ID" != "900804735337" ]; then
	echo "This can only be run in the tools account (with ID 900804735337), you are authenticated to account with ID $ACCOUNT_ID"
	exit 1
fi

if aws s3api head-bucket --bucket govuk-tools-state-files >/dev/null 2>&1; then
	echo "State file bucket exists"
	if [ -f "backend.tf" ]; then
		echo "./backend.tf present, continuing with s3 backend"
	else
		echo "backend.tf not present"
		if [ -f "backend.tf.disabled" ]; then
			echo "backend.tf.disabled is present, moving backend.tf.disabled to backend.tf and continuing with S3 backend"
			mv backend.tf.disabled backend.tf
		else
			echo "backend.tf.disabled also not present, cannot continue. Either backend.tf or backend.tf.disabled must exist"
			exit 1
		fi
	fi
else
	echo "State file bucket does not exist"
	BACKEND_DISABLED=true

	if [ -f "backend.tf" ]; then
		echo "Disabling s3 backend config by moving backend.tf to backend.tf.disabled"
		mv backend.tf backend.tf.disabled
	else
		echo "backend.tf is not present"
		if [ -f "backend.tf.disabled" ]; then
			echo "backend.tf.disabled is present, can continue"
		else
			echo "backend.tf.disabled is missing. Cannot continue. Either backend.tf or backend.tf.disabled must exist"
		fi
	fi
fi

echo "Initialising terraform"
terraform init

echo "Applying terraform"
terraform apply

if [ "$BACKEND_DISABLED" == "true" ]; then
	echo "Backend was disabled, enabling, moving backend.tf.disabled back to backend.tf"
	mv backend.tf.disabled backend.tf

	echo "Migrating terraform state to state bucket"
	terraform init --migrate-state
fi
