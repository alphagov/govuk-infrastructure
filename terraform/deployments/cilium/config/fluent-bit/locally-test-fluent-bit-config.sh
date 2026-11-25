#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR=$(dirname "${BASH_SOURCE[0]}")

CONFIG_FILE="${SOURCE_DIR}/fluent-bit-local-dummy-config.yaml"

yq eval-all '. as $item ireduce ({}; . * $item)' fluent-bit.yaml fluent-bit-dummy-input.yaml > "$CONFIG_FILE"

echo "Using config file $CONFIG_FILE"

docker run \
	--rm -ti \
	-v "${CONFIG_FILE}:/fluent-bit/etc/fluent-bit.yaml" fluent/fluent-bit:5.2 \
	-c /fluent-bit/etc/fluent-bit.yaml
