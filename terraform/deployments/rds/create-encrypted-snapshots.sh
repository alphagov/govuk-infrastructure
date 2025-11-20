#!/bin/bash

set -euo pipefail

if ! command -v parallel >>/dev/null 2>&1; then
  echo "Error: You need to have gnu-parallel installed to use this command. On macOS install it with 'brew install parallel'"
  exit 1
fi

# shellcheck disable=SC1091
source ./db-maintenance-lists.sh

GOVUK_ENVIRONMENT="test"

DBS=("${LITTLE_7_DBS[@]}")
export KMS_KEY="alias/govuk/rds"

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

function confirm_snapshots {
  echo "The following databases will have snapshots created in $ACCOUNT_NAME:"
  echo "----------------------------------------------------------------"
  for DB in "${DBS[@]}"; do
    echo "$DB"
  done
  echo "----------------------------------------------------------------"
  echo
  echo "AWS ACCOUNT: ${ACCOUNT_NAME}"
  echo "Are you sure you wish to create snapshots for the above instances in ${ACCOUNT_NAME}"
  echo
  read -rp "Type exactly 'yes' (without quotes) to snapshot instances: " RESPONSE

  CONFIRMATION=$(tr -d "\n" <<<"$RESPONSE")

  if [ "$CONFIRMATION" != "yes" ]; then
    echo "NOT confirmed, exiting"
    exit 1
  fi
}

function snapshot_already_exists {
  # Args:
  #   $1: Database Identifier
  #   $2: snapshot identifier
  local DB="$1"
  local SNAPSHOT_IDENTIFIER="$2"
  local RESPONSE

  while true; do
    if ! RESPONSE=$(aws rds describe-db-snapshots --db-snapshot-identifier "$SNAPSHOT_IDENTIFIER" 2>&1); then
      if [[ "$RESPONSE" == *DBSnapshotNotFound* ]]; then
        return 1
      fi

      >&2 echo -e "$DB: Unknown error describing RDS snapshot, will retry:\n$RESPONSE"

      sleep 5
      continue
    fi
    break
  done
}
export -f snapshot_already_exists

function snapshot_state {
  # Args:
  #   $1: Database identifier
  #   $1: Snapshot identiifer
  local DB="$1"
  local SNAPSHOT_IDENTIFIER="$2"

  local STATE
  while true; do
    if ! STATE=$(aws rds describe-db-snapshots --db-snapshot-identifier "$SNAPSHOT_IDENTIFIER" --query "DBSnapshots[0].Status" --output text 2>&1); then
      >&2 echo -e "$DB: Unknown error describing RDS snapshot, will retry:\n$STATE"

      sleep 5
      continue
    fi

    echo "$STATE"
    break
  done
}
export -f snapshot_state

function wait_for_snapshot_terminal_state {
  # Args:
  #   $1: Database identifier
  #   $2: snapshot identifier
  local DB="$1"
  local SNAPSHOT_IDENTIFIER="$2"

  local STATE=""
  while true; do
    STATE=$(snapshot_state "$DB" "$SNAPSHOT_IDENTIFIER")

    if [ "$STATE" == "available" ] || [ "$STATE" == "failed" ]; then
        echo "$STATE"
        break
    fi

    >&2 echo "$DB: Still waiting for $SNAPSHOT_IDENTIFIER, current state $STATE"

    sleep 5
    continue
  done

  return 0
}
export -f  wait_for_snapshot_terminal_state

function create_unencrypted_snapshot {
  # Args:
  #   $1: Database Idenfier
  #   $2: Snapshot Name
  local DB="$1"
  local SNAPSHOT_NAME="$2"

  local RESPONSE
  if ! RESPONSE=$(aws rds create-db-snapshot --db-instance-identifier "$DB" --db-snapshot-identifier "$SNAPSHOT_NAME"); then
    >&2 echo -e "$DB: Error creating snapshot:\n$RESPONSE"
    return 1
  fi
}

export -f create_unencrypted_snapshot

function copy_to_encrypted_snapshot {
  # Args:
  #   $1: Database Identifier
  #   $2: Source Snapshot Name
  #   $3: Target Snapshot Name
  local DB="$1"
  local SOURCE_SNAPSHOT_NAME="$2"
  local TARGET_SNAPSHOT_NAME="$3"

  local RESPONSE
  if ! RESPONSE=$(
      aws rds copy-db-snapshot \
        --source-db-snapshot-identifier "$SOURCE_SNAPSHOT_NAME" \
        --target-db-snapshot-identifier "$TARGET_SNAPSHOT_NAME" \
        --kms-key-id "$KMS_KEY"
  ); then
    >&2 echo -e "$DB: Error creating snapshot copy:\n$RESPONSE"
    return 1
  fi
}
export -f  copy_to_encrypted_snapshot

function colour_red {
  # shellcheck disable=SC2028
  echo "\033[91m${1}\033[00m"
}
export -f colour_red

function colour_green {
  # shellcheck disable=SC2028
  echo "\033[92m${1}\033[00m"
}
export -f colour_green

function perform_snapshot {
  # Args:
  #   $1: instance identifier
  local DB="$1"
  local UNENCRYPTED_SNAPSHOT_NAME="${DB}-pre-encryption"
  local ENCRYPTED_SNAPSHOT_NAME="${DB}-post-encryption"

  echo "$DB: starting snapshot process for $DB"
  if snapshot_already_exists "$DB" "$UNENCRYPTED_SNAPSHOT_NAME"; then
    echo "$DB: snapshot $UNENCRYPTED_SNAPSHOT_NAME already exists"
  else
    echo "$DB: snapshot $UNENCRYPTED_SNAPSHOT_NAME doesn't exist, creating"
    if ! create_unencrypted_snapshot "$DB" "$UNENCRYPTED_SNAPSHOT_NAME"; then
      >&2 echo "$DB: FAILED!"
      echo -e "$(colour_red "$DB: creating unencrytped snapshot FAILED!")"
      return 1
    fi
  fi

  echo "$DB: waiting for snapshot $UNENCRYPTED_SNAPSHOT_NAME to complete"
  local STATE
  if ! STATE=$(wait_for_snapshot_terminal_state "$DB" "$UNENCRYPTED_SNAPSHOT_NAME"); then
    >&2 echo "$DB: FAILED to query state of snapshot"
    echo -e "$(colour_red "$DB: FAILED to query state of snapshot")"
    return 1
  fi

  if [ "$STATE" == "available" ]; then
    echo -e "$(colour_green "$DB: successfully created snapshot")"
  elif [ "$STATE" == "failed" ]; then
    >&2 echo "$DB: snapshot creation FAILED!"
    echo -e "$(colour_red "$DB: snapshot creation FAILED!")"
    return 1
  else
    >&2 echo "$DB: Unknown final state of snapshot ${STATE}!"
    echo -e "$(colour_red "$DB: Unknown final state of snapshot ${STATE}!")"
    return 1
  fi

  if snapshot_already_exists "$DB" "$ENCRYPTED_SNAPSHOT_NAME"; then
    echo "$DB: snapshot copy $ENCRYPTED_SNAPSHOT_NAME already exists..."
  else
    echo "$DB: snapshot copy doesn't exist, creating"
    if ! copy_to_encrypted_snapshot "$DB" "$UNENCRYPTED_SNAPSHOT_NAME" "$ENCRYPTED_SNAPSHOT_NAME"; then
      >&2 echo "$DB: FAILED  to create encrypted snapshot copy!"
      echo -e "$(colour_red "$DB: FAILED  to create encrypted snapshot copy!")"
      return 1
    fi
  fi

  echo "$DB: waiting for snapshot copy from $UNENCRYPTED_SNAPSHOT_NAME to $ENCRYPTED_SNAPSHOT_NAME to complete"
  if ! STATE=$(wait_for_snapshot_terminal_state "$DB" "$ENCRYPTED_SNAPSHOT_NAME"); then
    >&2 echo "$DB: FAILED to query state of snapshot"
    echo -e "$(colour_red "$DB: FAILED to query state of snapshot")"
    return 1
  fi

  if [ "$STATE" == "available" ]; then
    echo -e "$(colour_green "$DB: successfully created snapshot copy. COMPLETE")"
  elif [ "$STATE" == "failed" ]; then
    >&2 echo "$DB: snapshot copy creation FAILED!"
    echo -e "$(colour_red "$DB: snapshot copy creation FAILED!")"
    return 1
  else
    >&2 echo "$DB: Unknown final state of snapshot copy ${STATE}!"
    echo -e "$(colour_red "$DB: Unknown final state of snapshot copy ${STATE}!")"
    return 1
  fi
}
export -f perform_snapshot

confirm_snapshots

FAILURE_LOG=$(mktemp -t create-snapshot-error-log)
FULL_LOG_FILE=$(mktemp -t create-snapshot-log)
echo "STDERR log file, tail this if you want to see errors and also info output showing the current snapshot status while waiting for them to complete: $FAILURE_LOG"

if ! parallel --line-buffer perform_snapshot {} ::: "${DBS[@]}" 2>> "$FAILURE_LOG" | tee -a "$FULL_LOG_FILE"; then
  echo "-----------------------------------------------------------------------------------------------"
  echo "ERRORS OCCURRED: Some errors occured, see failure log file: $FAILURE_LOG"
  echo "-----------------------------------------------------------------------------------------------"
fi

echo "Full log saved to $FULL_LOG_FILE"
