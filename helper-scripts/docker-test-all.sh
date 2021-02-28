#!/bin/bash
function test {
  pushd $1

  ( for i in `seq 150` ; do
    if [ $(docker ps -a -f NAME=$2_sut_1 | wc -l) -ge 2 ]; then
      break;
    fi
    sleep 1
  done
  ret="$(docker wait $2_sut_1)"
  sleep 1
  docker-compose -f docker-compose.test.yml ps
  docker-compose -f docker-compose.test.yml -p $2 down
  exit $ret ) &

  pid=$!
  if [ "$DOCKER_TEST_VERBOSE" == true ]; then
    docker-compose -f docker-compose.test.yml -p $2 up -V $DOCKER_COMPOSE_UP_PARAMS
    wait $pid
    ret=$?
  else
    docker-compose -f docker-compose.test.yml -p $2 up -V $DOCKER_COMPOSE_UP_PARAMS &>/tmp/$2.log
    wait $pid
    ret=$?
    if [ "$ret" -ne 0 ]; then
      cat /tmp/$2.log
    fi
  fi
  popd
  if [ $ret -ne 0 ]; then
    echo "$2 test failed"
    testSuccess=1
    return 1
  else
    echo "containerssh test success"
    return 0
  fi
  return $ret
}
testSuccess=0
test authServer authserver
test configServer configserver
test . containerssh
exit $testSuccess
