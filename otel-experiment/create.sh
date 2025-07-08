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
mkdir -p secrets/otel-collector/

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

if [ ! -f secrets/elasticsearch/OTEL_PASSWORD ]; then
  info_line "Generating password for otel writer"
  pwgen -s 32 1 | tr -d "\r\n" >> secrets/elasticsearch/OTEL_PASSWORD
  echo
fi

if [ ! -f secrets/kibana/ELASTICSEARCH_PASSWORD ]; then
  info_line "Copying kibana password from elasticsearch dir to kibana dir"
  cp secrets/elasticsearch/KIBANA_PASSWORD secrets/kibana/ELASTICSEARCH_PASSWORD
  echo
fi

if [ ! -f secrets/otel-collector/ELASTICSEARCH_PASSWORD ]; then
  info_line "Copying otel password from elasticsearch dir to otel-collector dir"
  cp secrets/elasticsearch/OTEL_PASSWORD secrets/otel-collector/ELASTICSEARCH_PASSWORD
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

if [ ! -f secrets/otel-collector.yaml ]; then
  info_line "Outputting otel-collector secret yaml to secrets/otel-collector.yaml"
  kubectl create secret generic otel-collector --from-file ./secrets/otel-collector/ --dry-run=client --output YAML > secrets/otel-collector.yaml
  echo
fi

info_line "Applying elasticsearch secrets"
kubectl apply -f secrets/elasticsearch.yaml

info_line "Applying kibana secrets"
kubectl apply -f secrets/kibana.yaml

info_line "Applying otel collector secrets"
kubectl apply -f secrets/otel-collector.yaml

info_line "Applying elasticsearch configs"
echo
for FILE in ./manifests/1*.yaml; do
  echo -n "  $FILE: "
  kubectl apply -f "$FILE"
done

info_line "Applying logstash configs"
echo
for FILE in ./manifests/2*.yaml; do
  echo -n "  $FILE: "
  kubectl apply -f "$FILE"
done

info_line "Applying kibana configs"
echo
for FILE in ./manifests/3*.yaml; do
  echo -n "  $FILE: "
  kubectl apply -f "$FILE"
done

info_line "Applying otel configs"
echo
for FILE in ./manifests/4*.yaml; do
  echo -n "  $FILE: "
  kubectl apply -f "$FILE"
done


echo
echo "*** Complete ***"
echo
