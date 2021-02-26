#!/bin/bash
set -ex
. helper-scripts/docker-env-defaults.sh
docker build -t $IMAGEPREFIX$CONTAINERSSH_IMAGE_NAME  .
pushd authServer
docker build -t $IMAGE_PREFIX$AUTHSERVER_IMAGE_NAME .
popd
pushd configServer
docker build -t $IAGE_PREFIX$CONFIGSERVER_IMAGE_NAME .
popd
