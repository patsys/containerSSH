#!/bin/bash
function test {
  pushd $1

  ( for i in `seq 300` ; do
    if docker ps -a -f NAME=$2_sut_1 | grep -q Up; then
      sleep 1
      break;
    fi
    sleep 1
  done
  ret="$(docker wait $2_sut_1)"
  echo "ret: $ret"
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
    echo "$2 test success"
    return 0
  fi
  return $ret
}
set -e
testSuccess=0
test authServer authserver || echo ""
test configServer configserver || echo ""
test . containerssh || echo ""
if [ -f  /tmp/ssh_debug_timeout_test ]; then sleep $(cat /tmp/ssh_debug_timeout_test); fi
exit $testSuccess
