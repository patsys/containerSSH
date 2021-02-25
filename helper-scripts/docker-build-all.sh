#!/bin/bash
docker build -t $IMAGEPREFIX$IMAGE_NAME .
pushd authServer
docker build -t $IMAGE_PREFIXauthserver .
popd
pushd configServer
docker build -t $IAGE_PREFIXconfigserver .
popd
