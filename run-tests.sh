#!/bin/bash
# Test runner script for local development
# This script allows running tests without using Make

set -e

IMAGE_NAME="${1:-}"

if [ -z "$IMAGE_NAME" ]; then
	echo "Usage: $0 <image-name>"
	echo "Example: $0 ci-helm"
	exit 1
fi

echo "Building $IMAGE_NAME image..."
docker buildx build "images/$IMAGE_NAME" --tag "$IMAGE_NAME:latest" --load

echo "Building testcontainers test image..."
docker build --target testcontainers --tag testcontainers:latest .

echo "Running tests for $IMAGE_NAME..."
docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-e IMAGE_NAME="$IMAGE_NAME:latest" \
	testcontainers:latest \
	go test -v ./...

echo "✅ Tests completed successfully for $IMAGE_NAME"
