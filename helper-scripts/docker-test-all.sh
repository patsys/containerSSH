#!/bin/bash
testSuccess=9
set -ex
. ./helper-scripts/docker-env-defaults.sh
pushd authServer
docker-compose -f docker-compose.test.yml -p authserver up -d
ret="$(docker wait authserver_sut_1)"
if [ $ret -ne 0 ]; then
  echo "authserver test failed"
  testSuccess=1
else
  echo "authserver test success"
fi
popd
pushd configServer
docker-compose -f docker-compose.test.yml -p authserver up -d
ret="$(docker wait authserver_sut_1)"
if [ $ret -ne 0 ]; then
  echo "configserver test failed"
  testSuccess=1
else
  echo "configserver test success"
fi
popd
docker-compose -f docker-compose.test.yml -p authserver up -d
ret="$(docker wait authserver_sut_1)"
if [ $ret -ne 0 ]; then
  echo "configserver test failed"
  testSuccess=1
else
  echo "configserver test success"
fi
exit $testSuccess
