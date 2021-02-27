#!/bin/bash
set -e
git submodule init && git submodule update
. ./helper-scripts/docker-env-defaults.sh
docker build -t $IMAGEPREFIX$CONTAINERSSH_IMAGE_NAME$DOCKER_TAG  .
pushd authServer
docker build -t $IMAGEPREFIX$AUTHSERVER_IMAGE_NAME$DOCKER_TAG .
popd
pushd configServer
docker build -t $IMAGEPREFIX$CONFIGSERVER_IMAGE_NAME$DOCKER_TAG .
popd
