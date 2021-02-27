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
docker-compose -f docker-compose.test.yml -p authserver down
pushd configServer
docker-compose -f docker-compose.test.yml -p configserver up -d
ret="$(docker wait configserver_sut_1)"
if [ $ret -ne 0 ]; then
  echo "configserver test failed"
  testSuccess=1
else
  echo "configserver test success"
fi
docker-compose -f docker-compose.test.yml -p configserver down
popd
bash -c '
sleep 5
ret="$(docker wait containerssh_sut_1)"
if [ $ret -ne 0 ]; then
  echo "containerssh test failed"
  testSuccess=1
else
  echo "containerssh test success"
fi
sleep 600
docker-compose -f docker-compose.test.yml -p containerssh down 
' &
docker-compose -f docker-compose.test.yml -p containerssh up 
exit $testSuccess
