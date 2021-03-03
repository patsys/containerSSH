#!/bin/bash
set -e
git submodule init && git submodule update
docker build -t $IMAGEPREFIX$CONTAINERSSH_IMAGE_NAME$DOCKER_TAG  .
pushd authServer
docker build -t $IMAGEPREFIX$AUTHSERVER_IMAGE_NAME$DOCKER_TAG .
popd
pushd configServer
docker build -t $IMAGEPREFIX$CONFIGSERVER_IMAGE_NAME$DOCKER_TAG .
popd
if [ -f  /tmp/ssh_debug_timeout_build ]; then sleep $(cat /tmp/ssh_debug_timeout_build); fi
