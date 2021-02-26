if [[ ! -v IMAGEPREFIX ]] && [[ -v DOCKER_REPO ]]
  export IMAGEPREFIX="$(basename "$(dirname $DOCKER_REPO)"/
fi
