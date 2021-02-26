#!/bin/bash
set -ex
. helper-scripts/docker-image-prefix.sh
export IMAGE_NAME="$(basename $IMAGE_NAME)"
docker build -t $IMAGEPREFIX$IMAGE_NAME .
pushd authServer
docker build -t $IMAGE_PREFIXauthserver .
popd
pushd configServer
docker build -t $IAGE_PREFIXconfigserver .
popd
