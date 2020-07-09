#!/usr/bin/env sh
#shellcheck shell=sh

set -x

REPO=mikenye
IMAGE=postfix
PLATFORMS="linux/386,linux/amd64,linux/arm/v7,linux/arm64"

docker context use x86_64
export DOCKER_CLI_EXPERIMENTAL="enabled"
docker buildx use homecluster

# Build latest
docker buildx build -t "${REPO}/${IMAGE}:latest" --compress --push --platform "${PLATFORMS}" .

# Get version
docker pull "${REPO}/${IMAGE}:latest"
VERSION=$(docker run --rm --entrypoint cat mikenye/postfix /VERSIONS | grep "postfix " | cut -d " " -f 2)

# Build version specific
docker buildx build -t "${REPO}/${IMAGE}:${VERSION}" --compress --push --platform "${PLATFORMS}" .
