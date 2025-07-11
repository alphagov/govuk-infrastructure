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


if ! command -v pwgen >>/dev/null 2>&1; then
  echo "Error, need pwgen installed"
  exit 1
fi

info_line "Changing context"
kubectl config use-context "$CONTEXT"

info_line "Applying namespace"
kubectl apply -f ./manifests/00-elk-namespace.yaml

info_line "Setting namespace for context $CONTEXT"
kubectl config set-context --current --namespace elk

mkdir -p secrets/elasticsearch/
mkdir -p secrets/kibana/
mkdir -p secrets/fluentbit/

if [ ! -f secrets/elasticsearch/ELASTIC_PASSWORD ]; then
  info_line "Generating elasticsearch password"
  pwgen -s 32 1 | tr -d "\r\n" >> secrets/elasticsearch/ELASTIC_PASSWORD
  echo
fi

if [ ! -f secrets/elasticsearch/KIBANA_PASSWORD ]; then
  info_line "Generating kibana password"
  pwgen -s 32 1 | tr -d "\r\n" >> secrets/elasticsearch/KIBANA_PASSWORD
  echo
fi

if [ ! -f secrets/elasticsearch/FLUENTBIT_PASSWORD ]; then
  info_line "Generating password for fluentbit writer"
  pwgen -s 32 1 | tr -d "\r\n" >> secrets/elasticsearch/FLUENTBIT_PASSWORD
  echo
fi

if [ ! -f secrets/kibana/ELASTICSEARCH_PASSWORD ]; then
  info_line "Copying kibana password from elasticsearch dir to kibana dir"
  cp secrets/elasticsearch/KIBANA_PASSWORD secrets/kibana/ELASTICSEARCH_PASSWORD
  echo
fi

if [ ! -f secrets/fluentbit/ELASTICSEARCH_PASSWORD ]; then
  info_line "Copying fluentbit password from elasticsearch dir to fluentbit dir"
  cp secrets/elasticsearch/FLUENTBIT_PASSWORD secrets/fluentbit/ELASTICSEARCH_PASSWORD
  echo
fi

if [ ! -f secrets/elasticsearch.yaml ]; then
  info_line "Outputting elasticsearch secret yaml to secrets/elasticsearch.yaml"
  kubectl create secret generic elasticsearch --from-file ./secrets/elasticsearch/ --dry-run=client --output YAML > secrets/elasticsearch.yaml
  echo
fi

if [ ! -f secrets/kibana.yaml ]; then
  info_line "Outputting kibana secret yaml to secrets/kibana.yaml"
  kubectl create secret generic kibana --from-file ./secrets/kibana/ --dry-run=client --output YAML > secrets/kibana.yaml
  echo
fi

if [ ! -f secrets/fluentbit.yaml ]; then
  info_line "Outputting fluentbit secret yaml to secrets/fluentbit.yaml"
  kubectl create secret generic fluentbit --from-file ./secrets/fluentbit/ --dry-run=client --output YAML > secrets/fluentbit.yaml
  echo
fi

info_line "Applying elasticsearch secrets"
kubectl apply -f secrets/elasticsearch.yaml

info_line "Applying kibana secrets"
kubectl apply -f secrets/kibana.yaml

info_line "Applying fluentbit secrets"
kubectl apply -f secrets/fluentbit.yaml

info_line "Applying elasticsearch configs"
echo
for FILE in ./manifests/1*.yaml; do
  echo -n "  $FILE: "
  kubectl apply -f "$FILE"
done

info_line "Applying kibana configs"
echo
for FILE in ./manifests/2*.yaml; do
  echo -n "  $FILE: "
  kubectl apply -f "$FILE"
done

info_line "Applying fluentbit configs"
echo
for FILE in ./manifests/3*.yaml; do
  echo -n "  $FILE: "
  kubectl apply -f "$FILE"
done


echo
echo "*** Complete ***"
echo
