#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --env <environment>"
  echo "  --env    Required. Specify the environment to use."
  exit 1
}

env=""

while getopts ":e:-:" opt; do
  case $opt in
    e)
      env="$OPTARG"
      ;;
    -)
      case "${OPTARG}" in
        env)
          env="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
          ;;
        env=*)
          env="${OPTARG#*=}"
          ;;
        *)
          echo "Invalid option: --${OPTARG}" >&2
          usage
          ;;
      esac
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Check if env parameter was provided
if [ -z "$env" ]; then
  echo "Error: --env parameter is required." >&2
  usage
fi

if [ -z "$AWS_SESSION_TOKEN" ]; then
  echo "Error: you do not have AWS session credentials in your environment" >&2
  exit 2
fi

echo "==> Starting Concourse"
docker compose up -d

echo "==> Downloading Fly binary"
curl 'http://localhost:8080/api/v1/cli?arch=amd64&platform=darwin' -o fly
chmod +x ./fly
FLY="./fly"

echo "==> Logging into Concourse"
$FLY -t bootstrap login -c http://localhost:8080 -u bootstrap -p govuk

$FLY -t bootstrap set-pipeline -n -p bootstrap -c ../pipelines/bootstrap.yml \
  -v BOOTSTRAP_AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  -v BOOTSTRAP_AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  -v BOOTSTRAP_AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}"

$FLY -t bootstrap unpause-pipeline -p bootstrap

open "$($FLY targets | grep bootstrap | awk '{print $2}')/teams/main/pipelines/bootstrap"

echo "==> Credentials"
echo "==> Username: bootstrap"
echo "==> Password: govuk"
