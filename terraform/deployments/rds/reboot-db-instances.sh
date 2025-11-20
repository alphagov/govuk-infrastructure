#!/bin/bash

set -euo pipefail

source ./db-maintenance-lists.sh

# Change GOVUK_ENVIRONMENT and the DBS assignment on line 66 to choose which databases to reboot
GOVUK_ENVIRONMENT="staging"
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
  echo "Error: You must execute this script with AWS credentials in your env"
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
