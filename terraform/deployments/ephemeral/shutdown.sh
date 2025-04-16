#!/usr/bin/env nix-shell
#!nix-shell -i bash -p awscli kubectl kubernetes-helm jq curl

CLUSTER_ID="${1}"

if [ "${CLUSTER_ID:0:4}" != "eph-" ] && [ "${IGNORE_BAD_CLUSTER_ID}" != "true" ]; then
  echo "Provided cluster ID is invalid: ${CLUSTER_ID}"
  echo "Set IGNORE_BAD_CLUSTER_ID=true or provide a valid cluster ID (e.g. eph-123abc)"
  exit 1
fi

# list all ArgoCD Application resources that are managed by Helm
function application_list {
  kubectl get application -l app.kubernetes.io/managed-by=Helm --all-namespaces --no-headers=true
}

# delete an ArgoCD Application resource
function application_delete {
  echo "deleting app ${1}/${2}"
  kubectl -n "${1}" delete application "${2}"
}

# delete all Helm-managed ArgoCD Applications
function application_shutdown {
  echo "deleting apps"
  while read -r app; do
    if [ "${app}" = "" ]; then
      echo "no apps to delete"
      continue
    fi
    app_ns=$(awk '{ print $1 };' <<< "${app}")
    app_name=$(awk '{ print $2 };' <<< "${app}")
    echo "ns: ${app_ns} app: ${app_name}"
    application_delete "${app_ns}" "${app_name}"
  done <<< "$(application_list)"
}

function helm_list {
  SELECTOR="${1}"
  helm list --selector "${SELECTOR}" --no-headers -n cluster-services
}

function helm_uninstall {
  echo "uninstalling chart ${1}/${2}"
  helm -n "${1}" uninstall "${2}"
}

function helm_uninstall_charts {
  CHARTS=$(helm_list "${1}")
  while read -r chart; do
    if [ "${chart}" = "" ]; then
      echo "no charts to uninstall"
      continue
    fi
    chart_ns=$(awk '{ print $2 }' <<< "${chart}")
    chart_name=$(awk '{ print $1 }' <<< "${chart}")
    echo "ns: ${chart_ns} chart: ${chart_name}"
    helm_uninstall "${chart_ns}" "${chart_name}"
  done <<< "${CHARTS}"
}

# uninstall all Helm charts
function helm_shutdown {
  # don't uninstall LB controller or external-dns as they manage other cloud resources
  # that won't be deleted if the charts are uninstalled before other things
  echo "uninstall charts 1st pass"
  helm_uninstall_charts "name!=aws-load-balancer-controller,name!=external-dns"
  echo "waiting..."
  sleep 20
  echo "uninstall charts 2nd pass"
  helm_uninstall_charts ""
}

function tfc_token {
  jq -r '.credentials."app.terraform.io".token' < ~/.terraform.d/credentials.tfrc.json
}

function tfc_get_workspace_id {
  TOKEN="$(tfc_token)"
  WORKSPACE_NAME="${1}"
  curl \
    --header "Authorization: Bearer ${TOKEN}" \
    --header "Content-Type: application/vnd.api+json" \
    --silent --get \
    --data-urlencode "filter[tagged][0][key]=${CLUSTER_ID}" \
    --data-urlencode "filter[tagged][1][key]=${WORKSPACE_NAME}" \
    "https://app.terraform.io/api/v2/organizations/govuk/workspaces" \
    | jq -r ".data[0].id"
}

function tfc_destroy_start {
  TOKEN="$(tfc_token)"
  WORKSPACE_NAME="${1}"
  WORKSPACE_ID="$(tfc_get_workspace_id "${WORKSPACE_NAME}")"
  PAYLOAD=$(cat <<EOF
{
  "data": {
    "attributes": {
      "message": "Destroy by shutdown.sh",
      "is-destroy": true,
      "auto-apply": true
    },
    "type": "runs",
    "relationships": {
      "workspace": {
        "data": {
          "type": "workspaces",
          "id": "${WORKSPACE_ID}"
        }
      }
    }
  }
}
EOF
)
  RUN_ID=$(curl --silent \
    --header "Authorization: Bearer ${TOKEN}" \
    --header "Content-Type: application/vnd.api+json" \
    --request POST --data @- \
    "https://app.terraform.io/api/v2/runs" <<< "${PAYLOAD}" | jq -r ".data.id")
  echo "${RUN_ID}"
}

function tfc_run_status {
  RUN_ID="${1}"
  curl --silent \
    --header "Authorization: Bearer $(tfc_token)" \
    --header "Content-Type: application/vnd.api+json" \
    "https://app.terraform.io/api/v2/runs/${RUN_ID}" | jq -r ".data.attributes.status"
}

function tfc_wait_for_run {
  WORKSPACE_NAME="${1}"
  RUN_ID="${2}"
  echo "Waiting for destroy run to complete..."
  echo "  Run ID: ${RUN_ID}"
  echo "  https://app.terraform.io/app/govuk/workspaces/${WORKSPACE_NAME}-${CLUSTER_ID}/runs/${RUN_ID}"

  sleep 5
  
  while true; do
    RUN_STATUS=$(tfc_run_status "${RUN_ID}")
    echo "${RUN_STATUS}" | grep -E '(applied|planned_and_finished)' > /dev/null
    if [ "$?" = "0" ]; then
      echo "Run ID ${RUN_ID} finished: ${RUN_STATUS}"
      return 0
    fi
    echo "${RUN_STATUS}" | grep -E '(errored|canceled|force_canceled|discarded)' > /dev/null
    if [ "$?" = "0" ]; then
      echo "Run ID ${RUN_ID} failed: ${RUN_STATUS}"
      return 1
    fi
    echo "Waiting... (${RUN_STATUS})"
    sleep 15
  done
}

function tfc_do_destroy {
  WORKSPACE_NAME="${1}"
  RUN_ID="$(tfc_destroy_start "${WORKSPACE_NAME}")"
  tfc_wait_for_run "${WORKSPACE_NAME}" "${RUN_ID}"
}

# try a command X number of times until it finishes with exit code 0
function retry {
  RETRY_COUNT="${1}"
  shift
  for i in $(seq 1 "${RETRY_COUNT}"); do
    if [ "${i}" != "1" ]; then
      echo "retrying '$*' attempt ${i}/${RETRY_COUNT}"
    fi
    ($@)
    if [ "$?" = "0" ]; then
      return 0
    fi
  done
  echo "command '$*' failed after ${RETRY_COUNT} attempts"
  exit 1
}

aws eks update-kubeconfig --name "${CLUSTER_ID}"

# delete ArgoCD Application resources
application_shutdown

# uninstall Helm charts
helm_shutdown

# do destroy runs on workspaces in the correct order
retry 2 tfc_do_destroy "datagovuk-infrastructure"
retry 2 tfc_do_destroy "cluster-services"
retry 2 tfc_do_destroy "cluster-infrastructure"
