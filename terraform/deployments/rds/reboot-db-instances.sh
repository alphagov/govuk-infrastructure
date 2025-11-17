#!/bin/bash

set -euo pipefail

# Change GOVUK_ENVIRONMENT and the DBS assignment on line 66 to choose which databases to reboot
GOVUK_ENVIRONMENT=integration

# shellcheck disable=SC2034
BIG_20_DBS=(
  "account-api-postgres"
  "authenticating-proxy-postgres"
  "blue-content-data-api-postgresql-primary-postgres"
  "collections-publisher-mysql"
  "content-block-manager-postgres"
  "content-store-postgres"
  "content-tagger-postgres"
  "draft-content-store-postgres"
  "email-alert-api-postgres"
  "imminence-postgres"
  "local-links-manager-postgres"
  "locations-api-postgres"
  "publisher-postgres"
  "publishing-api-postgres"
  "search-admin-mysql"
  "signon-mysql"
  "transition-postgres"
  "whitehall-mysql"
)

# shellcheck disable=SC2034
BIG_20_DBS_NEW_NAMES=(
  "account-api-${GOVUK_ENVIRONMENT}-postgres"
  "authenticating-proxy-${GOVUK_ENVIRONMENT}-postgres"
  "content-data-api-${GOVUK_ENVIRONMENT}-postgres"
  "collections-publisher-${GOVUK_ENVIRONMENT}-mysql"
  "content-block-manager-${GOVUK_ENVIRONMENT}-postgres"
  "content-store-${GOVUK_ENVIRONMENT}-postgres"
  "content-tagger-${GOVUK_ENVIRONMENT}-postgres"
  "draft-content-store-${GOVUK_ENVIRONMENT}-postgres"
  "email-alert-api-${GOVUK_ENVIRONMENT}-postgres"
  "places-manager-${GOVUK_ENVIRONMENT}-postgres"
  "local-links-manager-${GOVUK_ENVIRONMENT}-postgres"
  "locations-api-${GOVUK_ENVIRONMENT}-postgres"
  "publisher-${GOVUK_ENVIRONMENT}-postgres"
  "publishing-api-${GOVUK_ENVIRONMENT}-postgres"
  "search-admin-${GOVUK_ENVIRONMENT}-mysql"
  "signon-${GOVUK_ENVIRONMENT}-mysql"
  "transition-${GOVUK_ENVIRONMENT}-postgres"
  "whitehall-${GOVUK_ENVIRONMENT}-mysql"  
)

# shellcheck disable=SC2034
LITTLE_7_DBS=(
  "ckan-postgres"
  "content-data-admin-postgres"
  "release-mysql"
  "search-admin-mysql"
  "link-checker-api-postgres"
  "service-manual-publisher-postgres"
  "support-api-postgres"
)

# shellcheck disable=SC2034
LITTLE_7_DBS_NEW_NAMES=(
  "ckan-${GOVUK_ENVIRONMENT}-postgres"
  "content-data-admin-${GOVUK_ENVIRONMENT}-postgres"
  "release-${GOVUK_ENVIRONMENT}-mysql"
  "search-admin-${GOVUK_ENVIRONMENT}-mysql"
  "link-checker-api-${GOVUK_ENVIRONMENT}-postgres"
  "service-manual-publisher-${GOVUK_ENVIRONMENT}-postgres"  
  "support-api-${GOVUK_ENVIRONMENT}-postgres"
)

DBS=("${BIG_20_DBS[@]}")

function usage {
  echo
  echo "Usage:"
  echo
  echo "  gds aws govuk-<env>-fulladmin -- $0"
  echo
  exit 1
}

function account_name {
  case "$1" in
    "172025368201")
      echo "production"
      return;;
    "696911096973")
      echo "staging"
      return;;
    "210287912431")
      echo "integration"
      return;;
    "430354129336")
      echo "test"
      return;;
    *)
      return 1
  esac
}

if [[ -z "${AWS_ACCESS_KEY_ID:-}" ]]; then
  echo "Error: You execute this script with AWS credentials in your env"
  usage
fi

if ! ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text); then
  echo "Error: Couldn't query AWS to get the Account ID"
  usage
fi

if ! ACCOUNT_NAME=$(account_name "$ACCOUNT_ID"); then
  echo "Error: The ACCOUNT ID $ACCOUNT_ID is not a GOV.UK Account ID. Perhaps you used gds cli with the wrong account?"
  usage
fi

if [ "$ACCOUNT_NAME" != "$GOVUK_ENVIRONMENT" ]; then
  echo "Error: Account NAME is not the same as the GOVUK_ENVIRONMENT env var!"
  usage
fi

function confirm_reboot {
  echo "The following databases will be rebooted in $ACCOUNT_NAME:"
  echo "----------------------------------------------------------------"
  for DB in "${DBS[@]}"; do
    echo "$DB"
  done
  echo "----------------------------------------------------------------"
  echo
  echo "AWS ACCOUNT: ${ACCOUNT_NAME}"
  echo "Are you sure you wish to reboot the above instances in ${ACCOUNT_NAME}"
  echo
  read -rp "Type exactly 'yes' (without quotes) to reboot instances: " RESPONSE

  CONFIRMATION=$(tr -d "\n" <<<"$RESPONSE")

  if [ "$CONFIRMATION" != "yes" ]; then
    echo "NOT confirmed, exiting"
    exit 1
  fi
}

confirm_reboot

NUM_INSTANCES_TO_REBOOT="${#DBS[@]}"
NUM_INSTANCES_REBOOTED=0

INSTANCES_FAILED_TO_REBOOT=()

for DB in "${DBS[@]}"; do
  echo -n "Sending reboot command for ${DB}..."
  TMPFILE=$(mktemp)
  if ! aws rds reboot-db-instance --db-instance-identifier "$DB" --no-force-failover > "$TMPFILE" 2>&1; then
    echo "FAILED, output in $TMPFILE and below!"
    cat "$TMPFILE"
    INSTANCES_FAILED_TO_REBOOT+=("$DB")
    echo
    echo
    continue
  fi

  echo "success"
  NUM_INSTANCES_REBOOTED=$((NUM_INSTANCES_REBOOTED + 1))
done

echo
echo
echo "=============================================================================================="
echo "Successfully started reboot for ${NUM_INSTANCES_REBOOTED}/${NUM_INSTANCES_TO_REBOOT} instances"
echo

if [ "${#INSTANCES_FAILED_TO_REBOOT[@]}" -ne 0 ]; then
  echo "The following instances failed to start rebooting:"
  echo "----------------------------------------------------------------"
  for FAILED_DB in "${INSTANCES_FAILED_TO_REBOOT[@]}"; do
    echo "$FAILED_DB"
  done
  echo "----------------------------------------------------------------"

  exit 1
fi
