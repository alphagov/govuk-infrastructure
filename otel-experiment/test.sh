#!/usr/bin/env bash

usage() {
  echo "Usage:"
  echo "  $0 <kubectl context>"
  exit 1
}

if [ $# -ne 1 ]; then
  usage
fi

DATE_COMMAND="date"

if [ "$(uname)" == "Darwin" ] ; then
  if ! command -v gdate >>/dev/null 2>&1; then
    # shellcheck disable=SC2016
    echo 'ERROR: You need the GNU Date utility on macOS for this to work. You can `brew install coreutils` to get it'
    exit 1
  fi

  DATE_COMMAND="gdate"
fi

CONTEXT="$1"
ORIGINAL_CONTEXT=$(kubectl config current-context)

if ! kubectl config get-contexts "$CONTEXT" >>/dev/null 2>&1; then
  echo "Error: Context $CONTEXT not found via kubectl"
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

info_line "Waiting for elasticache pod to be ready for up to 10 minutes"
kubectl wait --for=condition=ready pod --timeout=10m -l app=elasticsearch
echo

info_line "Waiting for filebeat pod to be ready for up to 10 minutes"
kubectl wait --for=condition=ready pod --timeout=10m -l app=elasticsearch
echo


CREATE_DELETE_CYCLES=5

info_line "Creating and deleting nginx container a few times"
echo
for CYCLE in $(seq 1 "$CREATE_DELETE_CYCLES"); do
  echo -n "Create ${CYCLE}/${CREATE_DELETE_CYCLES}: "
  kubectl apply -f manifests/99-dummy.yaml
  sleep 1
  echo -n "Delete ${CYCLE}/${CREATE_DELETE_CYCLES}: "
  kubectl delete -f manifests/99-dummy.yaml
  sleep 0.5
done

info_line "Sleeping for 2 seconds to ensure logs have time to get to elasticsearch"
sleep 2
echo

TMPFILE=$(mktemp)

function fail() {
  # Args:
  #   $1 - Error message to print
  #   $2 - File to dump
  echo "*** Error *** $1"

  echo "Full result query follows:"
  echo "================================================================================================"
  cat "$2"
  echo "================================================================================================"
  echo
  echo "*** FAILED ***"
  echo ""
  exit 1
}

compare_dates() {
  # Args
  #   $1: Date 1
  #   $2: Date 2
  local TIMESTAMP_1
  local TIMESTAMP_2

  if [ "$1" == "null" ] && [ "$2" == "null" ]; then
    return
  elif [ "$1" == "null" ] || [ "$2" == "null" ]; then
    return 1
  fi

  TIMESTAMP_1=$($DATE_COMMAND -d "$1" +%s)
  TIMESTAMP_2=$($DATE_COMMAND -d "$2" +%s)

  if [ "$TIMESTAMP_1" != "$TIMESTAMP_2" ]; then
    return 1
  fi
}

echo
echo "Tests running"
info_line "Querying elasticsearch"
# shellcheck disable=SC2016
kubectl exec deployments/elasticsearch -- bash -c 'curl --silent --fail --user "elastic:${ELASTIC_PASSWORD}" http://127.0.0.1:9200/k8s-events/_search?pretty' -d '{ "query": { "query_string": { "query": "nginx-dummy" } }' > "$TMPFILE"
echo

HITS=$(jq <"$TMPFILE" '.hits.total.value')
if [ "$HITS" -eq 0 ]; then
  fail "no hits when searching the k8s-events index in elasticsearch for 'nginx-dummy'"
fi

echo "1. Events returned from ElasticSearch for nginx-dummy container"

EVENT_TMPFILE=$(mktemp)
if ! jq < "$TMPFILE" '[.hits.hits[] | select(._source.reason == "Pulled" and ._source.lastTimestamp != null)][0]  | ._source' > "$EVENT_TMPFILE"; then
  fail "Jq expression to get Pulled messages with a lastTimestamp failed" "$TMPFILE"
fi


MESSAGE_FOUND_COUNT=$(jq -r < "$EVENT_TMPFILE" 'length')
if [ "$MESSAGE_FOUND_COUNT" -eq 0 ]; then
  fail "No events could be found with the 'Pulled' reason in the _source.reason field and an _source.lastTimestamp" "$TMPFILE"
fi

echo "2. Events found with a Pulled reason and lastTimestamp set"

NAMESPACE=$(jq -r <"$EVENT_TMPFILE" '.metadata.namespace')
if [ "$NAMESPACE" != "elk" ]; then
  fail "The metadata.namesapce field did not contain 'elk', it's value was $NAMESPACE" "$EVENT_TMPFILE"
fi

echo "3. The field metadata.namespace correctly contained 'elk'"

NAMESPACE=$(jq -r <"$EVENT_TMPFILE" '.involvedObject.namespace')
if [ "$NAMESPACE" != "elk" ]; then
  fail "The involvedObject.namesapce field did not contain 'elk', it's value was $NAMESPACE" "$EVENT_TMPFILE"
fi

echo "4. The field involvedObject.namespace correctly contained 'elk'"

CANONICAL_TIMESTAMP=$(jq -r <"$EVENT_TMPFILE" '.["@timestamp"]')
LAST_TIMESTAMP=$(jq -r <"$EVENT_TMPFILE" '."lastTimestamp"')
if ! compare_dates "$CANONICAL_TIMESTAMP" "$LAST_TIMESTAMP"; then
  fail "The @timestamp field ($CANONICAL_TIMESTAMP) is not the same as the lastTimestamp field ($LAST_TIMESTAMP), it should be given that lastTimestamp is populated" "$EVENT_TMPFILE"
fi

echo "5. The @timestamp field matched the lastTimestamp field"

if ! jq < "$TMPFILE" '[.hits.hits[] | select(._source.lastTimestamp == null)][0]  | ._source' > "$EVENT_TMPFILE"; then
  fail "Jq expression failed to get an event with a null lastTimestamp field" "$TMPFILE"
fi

echo "6. Events found with a null lastTimestamp"

CANONICAL_TIMESTAMP=$(jq -r <"$EVENT_TMPFILE" '.["@timestamp"]')
FIRST_TIMESTAMP=$(jq -r <"$EVENT_TMPFILE" '.firstTimestamp')
CREATED_TIMESTAMP=$(jq -r <"$EVENT_TMPFILE" '.metadata.creationTimestamp')
if ! compare_dates "$CANONICAL_TIMESTAMP" "$FIRST_TIMESTAMP" && ! compare_dates "$CANONICAL_TIMESTAMP" "$CREATED_TIMESTAMP"; then
  fail "The @timestamp ($CANONICAL_TIMESTAMP) is not the same as either the firstTimestamp ($FIRST_TIMESTAMP) or metadata.creationTimestamp ($CREATED_TIMESTAMP) fields, it should be given that lastTimestamp is not populated" "$EVENT_TMPFILE"
fi

echo "7. Events with a null lastTimestamp correctly have @timestamp set to with the firstTimestamp or metadata.creationTimestamp fields"

echo
echo "*** Complete ***"
echo
