#!/usr/bin/env bash
set -euo pipefail


DISABLE_DEPENDABOT="$(yq '.global.disable_dependabot' ./repos.yml)"
REPOSITORY_IDS=$(terraform output -json repository_ids)

PAYLOAD=""
if [ "${DISABLE_DEPENDABOT}" == "false" ]; then
  PAYLOAD="{\"repository_ids_to_add\": ${REPOSITORY_IDS}}"
  echo "Going to disable dependabot access"
else
  PAYLOAD="{\"repository_ids_to_remove\": ${REPOSITORY_IDS}}"
  echo "Going to enable dependabot access"
fi

echo "Going to send the following payload:"
echo "${PAYLOAD}" | jq '.' # JQ to prettify for output

read -p "Continue? [y/n]" -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Stopping"
  exit 1
fi

curl -L \
  -X PATCH \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "X-GitHub-Api-Version: 2026-03-10" \
  --json "'${PAYLOAD}'" \
  https://api.github.com/organizations/alphagov/dependabot/repository-access