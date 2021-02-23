#!/bin/bash
set -e
pushd configServer/example/server
  openssl req -nodes -newkey rsa:4096 -keyform PEM -keyout ca.key -x509 -days 3650 -outform PEM -out ca.crt -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=CAServer"
  openssl genrsa -out server_key.pem 4096
  openssl req  -new -key server_key.pem -out server.req -subj  "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=localhost"
  openssl x509 -req -in server.req -CA ca.crt -CAkey ca.key -set_serial 100 -extensions server -extensions SAN -days 1460 -outform PEM -out server_cert.pem -extfile  <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:localhost"))
popd
pushd authServer/example/server
  openssl req -nodes -newkey rsa:4096 -keyform PEM -keyout ca.key -x509 -days 3650 -outform PEM -out ca.crt -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=CAServer"
  openssl genrsa -out server_key.pem 4096
  openssl req  -new -key server_key.pem -out server.req -subj  "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=localhost"
  openssl x509 -req -in server.req -CA ca.crt -CAkey ca.key -set_serial 100 -extensions server -extensions SAN -days 1460 -outform PEM -out server_cert.pem -extfile  <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:localhost"))

# Clientcert 1
popd
pushd authServer/example/clientCert1
  openssl req -nodes -newkey rsa:4096 -keyform PEM -keyout ca.key -x509 -days 3650 -outform PEM -out ca.crt  -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=CACart1"
  openssl genrsa -out client.key 4096
  openssl req -new -key client.key -out client.req -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=ClientCart1"
  openssl x509 -req -in client.req -CA ca.crt -CAkey ca.key -set_serial 101 -extensions client -days 365 -outform PEM -out client.crt

# Clientcert 2
popd
pushd authServer/example/clientCert2
  openssl req -nodes -newkey rsa:4096 -keyform PEM -keyout ca.key -x509 -days 3650 -outform PEM -out ca.crt  -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=CACart2"
  openssl genrsa -out client.key 4096
  openssl req -new -key client.key -out client.req -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=ClientCart2"
  openssl x509 -req -in client.req -CA ca.crt -CAkey ca.key -set_serial 101 -extensions client -days 365 -outform PEM -out client.crt

# Cientcert 3
popd
pushd authServer/example/clientCert3
  openssl req -nodes -newkey rsa:4096 -keyform PEM -keyout ca.key -x509 -days 3650 -outform PEM -out ca.crt  -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=CACart2"
  openssl genrsa -out client.key 4096
  openssl req -new -key client.key -out client.req -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=ClientCart2"
  openssl x509 -req -in client.req -CA ca.crt -CAkey ca.key -set_serial 101 -extensions client -days 365 -outform PEM -out client.crt

# Clientcert 1
popd
pushd configServer/example/clientCert1
  openssl req -nodes -newkey rsa:4096 -keyform PEM -keyout ca.key -x509 -days 3650 -outform PEM -out ca.crt  -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=CACart1"
  openssl genrsa -out client.key 4096
  openssl req -new -key client.key -out client.req -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=ClientCart1"
  openssl x509 -req -in client.req -CA ca.crt -CAkey ca.key -set_serial 101 -extensions client -days 365 -outform PEM -out client.crt

# Clientcert 2
popd
pushd configServer/example/clientCert2
  openssl req -nodes -newkey rsa:4096 -keyform PEM -keyout ca.key -x509 -days 3650 -outform PEM -out ca.crt  -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=CACart2"
  openssl genrsa -out client.key 4096
  openssl req -new -key client.key -out client.req -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=ClientCart2"
  openssl x509 -req -in client.req -CA ca.crt -CAkey ca.key -set_serial 101 -extensions client -days 365 -outform PEM -out client.crt

# Cientcert 3
popd
pushd configServer/example/clientCert3
  openssl req -nodes -newkey rsa:4096 -keyform PEM -keyout ca.key -x509 -days 3650 -outform PEM -out ca.crt  -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=CACart2"
  openssl genrsa -out client.key 4096
  openssl req -new -key client.key -out client.req -subj "/C=DE/ST=OverTheAir/L=Springfield/O=Dreams/CN=ClientCart2"
  openssl x509 -req -in client.req -CA ca.crt -CAkey ca.key -set_serial 101 -extensions client -days 365 -outform PEM -out client.crt
popd
