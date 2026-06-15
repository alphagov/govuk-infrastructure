#!/usr/bin/env bash

set +e

function get_cluster_id {
  local LINE
  local CLUSTER_ID

  if ! LINE=$(grep "ephemeral_cluster_id" terraform.tfvars); then
    >&2 echo "Error!"
    return 1
  fi

  CLUSTER_ID=$(gsed -E 's/.* ?= ?"?([^"]+)"?/\1/' <<< "$LINE")

  if [[ "$CLUSTER_ID" != eph-* ]]; then
    >&2 echo "Couldn't understand cluster ID [$CLUSTER_ID]  line [$LINE]"
  fi

  echo "$CLUSTER_ID"
}

if ! EPH_CLUSTER_ID=$(get_cluster_id); then
  echo "Failed to get cluster id"
else
  echo "Cluster ID is $EPH_CLUSTER_ID"

  export EPH_CLUSTER_ID
fi
