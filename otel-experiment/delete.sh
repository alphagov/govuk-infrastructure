#!/usr/bin/env bash

set -euo pipefail

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

info_line "Changing context"
kubectl config use-context "$CONTEXT"

info_line "Setting namespace for context $CONTEXT"
kubectl config set-context --current --namespace elk

info_line "Deleting fluentbit configs"
echo
for FILE in $(find manifests/ -maxdepth 1 -mindepth 1 -name '3*.yaml' | sort -r); do
  echo -n "  $FILE: "
  kubectl delete --ignore-not-found -f "$FILE"
done
echo

info_line "Deleting kibana configs"
echo
for FILE in $(find manifests/ -maxdepth 1 -mindepth 1 -name '2*.yaml' | sort -r); do
  echo -n "  $FILE: "
  kubectl delete --ignore-not-found -f "$FILE"
done
echo

info_line "Deleting elasticsearch configs"
echo
for FILE in $(find manifests/ -maxdepth 1 -mindepth 1 -name '1*.yaml' | sort -r); do
  echo -n "  $FILE: "
  kubectl delete --ignore-not-found -f "$FILE"
done
echo

info_line "Deleting all secrets"
echo
for SECRET_NAME in $(kubectl get secrets -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'); do
  echo -n "  $SECRET_NAME: "
  kubectl delete secret "$SECRET_NAME"
done
echo

info_line "Deleting all persistent volume claims"
echo
for PVC_NAME in $(kubectl get pvc -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'); do
  echo -n "  $PVC_NAME: "
  kubectl delete secret "$PVC_NAME"
done

info_line "Deleting namespace"
kubectl delete --ignore-not-found -f ./manifests/00-elk-namespace.yaml
echo

echo
echo "*** Complete ***"
echo
