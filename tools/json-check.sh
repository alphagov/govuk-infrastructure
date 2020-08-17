#!/usr/bin/env bash
set -eu

for file in "$@"; do
  lint=$(jq -r '.' $file >/dev/null 2>/dev/null || echo "failed")

  if [[ $lint == "failed" ]]; then
    echo "${file} has invalid JSON"
    exit 1
  fi
done
