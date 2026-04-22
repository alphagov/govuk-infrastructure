#!/usr/bin/env bash

PROJECT_ID="${project_id}"
IMAGE="${image_path}"

docker run -d \
  --name asset-manager \
  --log-driver=gcplogs \
  --log-opt gcp-project=$PROJECT_ID \
  $IMAGE