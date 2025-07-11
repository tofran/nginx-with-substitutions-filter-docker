#!/bin/bash

set -euo pipefail

image_name=${1:-nginx-with-substitutions-filter}

echo "Starting test container from $image_name"
docker run \
    -d \
    -p 8080:80 \
    --rm \
    -v ./sample.conf:/etc/nginx/conf.d/default.conf \
    --name nginx-with-substitutions-filter-test \
    "$image_name" > /dev/null

sleep 1

EXPECTED_STRING_IN_RESPONSE="Welcome to replaced!"
response=$(curl -s http://localhost:8080/)

if [[ "$response" != *"$EXPECTED_STRING_IN_RESPONSE"* ]]; then
  echo "ERROR: Response does not contain '$EXPECTED_STRING_IN_RESPONSE'"
  echo -e "\nResponse was: $response\n"

  echo "Test FAILED, stopping container"
  docker stop nginx-with-substitutions-filter-test > /dev/null

  exit 1
fi

echo "Test SUCCESS, stopping container"
docker stop nginx-with-substitutions-filter-test > /dev/null
