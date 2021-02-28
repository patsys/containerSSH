#!/bin/bash
set -ex
. ./helper-scripts/docker-env-defaults.sh
docker push  $IMAGEPREFIX$CONTAINERSSH_IMAGE_NAME$DOCKER_TAG
docker push $IMAGE_PREFIX$AUTHSERVER_IMAGE_NAME$DOCKER_TAG
docker push $IAGE_PREFIX$CONFIGSERVER_IMAGE_NAME$DOCKER_TAG
