#!/bin/bash
set -e
. ./helper-scripts/docker-env-defaults.sh
docker build -t $IMAGEPREFIX$CONTAINERSSH_IMAGE_NAME$DOCKER_TAG  .
pushd authServer
docker build -t $IMAGE_PREFIX$AUTHSERVER_IMAGE_NAME$DOCKER_TAG .
popd
pushd configServer
docker build -t $IAGE_PREFIX$CONFIGSERVER_IMAGE_NAME$DOCKER_TAG .
popd
