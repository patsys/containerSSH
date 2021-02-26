if [[ ! -v IMAGEPREFIX ]]; then 
  export IMAGEPREFIX=""
  if [[ -v DOCKER_REPO ]]; then
    export IMAGEPREFIX="$(basename "$(dirname $DOCKER_REPO)")"/
  fi
fi
if [[ ! -v CONTAINERSSH_IMAGE_NAME ]]; then
  if [[ -v IMAGE_NAME ]]; then
    export CONTAINERSSH_IMAGE_NAME="$(basename $IMAGE_NAME)"
  else
    export CONTAINERSSH_IMAGE_NAME=containerssh
  fi
fi

export AUTHSERVER_IMAGE_NAME="${AUTHSERVER_IMAGE_NAME:-authserver}"
export CONFIGSERVER_IMAGE_NAME="${CONFIGSERVER_IMAGE_NAME:-conigserver}"

