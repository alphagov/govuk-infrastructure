#!/usr/bin/env bash

usage() {
  echo "Usage:"
  echo "  $0 <kubectl context>"
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

CONTEXT="$1"
ORIGINAL_CONTEXT=$(kubectl config current-context)

if ! kubectl config get-contexts "$1" >>/dev/null 2>&1; then
  echo "Error: Context $1 not found via kubectl"
  echo
  usage
fi

restore_original_context() {
  info_line "Restoring original context $ORIGINAL_CONTEXT"
  kubectl config use-context "$ORIGINAL_CONTEXT"
}
trap restore_original_context EXIT

info_line() {
  echo -n "* $1: "

  return
}

info_line "Waiting elasticache pod to be ready for up to 10 minutes"
kubectl wait --for=condition=ready pod --timeout=10m -l app=elasticsearch
echo

CREATE_DELETE_CYCLES=5

info_line "Creating and deleting nginx container a few times"
echo
for CYCLE in $(seq 1 "$CREATE_DELETE_CYCLES"); do
  echo -n "Create ${CYCLE}/${CREATE_DELETE_CYCLES}: "
  kubectl apply -f manifests/99-validator.yaml
  sleep 1
  echo -n "Delete ${CYCLE}/${CREATE_DELETE_CYCLES}: "
  kubectl delete -f manifests/99-validator.yaml
  sleep 0.5
done

echo
echo "*** Complete ***"
echo
