#!/bin/bash
set -e
docker push  $IMAGEPREFIX$CONTAINERSSH_IMAGE_NAME$DOCKER_TAG
docker push $IMAGE_PREFIX$AUTHSERVER_IMAGE_NAME$DOCKER_TAG
docker push $IAGE_PREFIX$CONFIGSERVER_IMAGE_NAME$DOCKER_TAG
if [ -f  /tmp/ssh_debug_timeout_push ]; then sleep $(cat /tmp/ssh_debug_timeout_push); fi
