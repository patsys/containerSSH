if [[ ! -v DOCKER_TAG ]]; then 
  export DOCKER_TAG=""
else
  export DOCKER_TAG=":$DOCKER_TAG"
fi
if [[ ! -v IMAGEPREFIX ]]; then 
  export IMAGEPREFIX=""
  if [[ -v DOCKER_REPO ]]; then
    export IMAGEPREFIX="$(basename "$(dirname $DOCKER_REPO)")"/
  fi
fi
if [[ ! -v CONTAINERSSH_IMAGE_NAME ]]; then
  if [[ -v IMAGE_NAME ]]; then
    export CONTAINERSSH_IMAGE_NAME="$(basename $DOCKER_REPO)"
  else
    export CONTAINERSSH_IMAGE_NAME=containerssh
  fi
fi

export AUTHSERVER_IMAGE_NAME="${AUTHSERVER_IMAGE_NAME:-containerssh-authserver}"
export CONFIGSERVER_IMAGE_NAME="${CONFIGSERVER_IMAGE_NAME:-containerssh-conigserver}"

