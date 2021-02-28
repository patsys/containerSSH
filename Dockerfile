FROM golang:1.16 AS build
ENV PROJECT containerssh
WORKDIR /src/$PROJECT
COPY . .
RUN git submodule init && git submodule update
WORKDIR /src/$PROJECT/ContainerSSH
RUN  cd /src/$PROJECT/ContainerSSH && go mod download && CGO_ENABLED=0 GOBIN=/usr/local/bin/ go install -a -ldflags=-w ./...

FROM alpine
ARG user=appuser \
  group=appuser \
  uid=1001 \
  gid=1001
RUN addgroup -g ${gid} ${group} && adduser -D -u ${uid}  ${user} -G ${group}
RUN apk add --no-cache openssh-keygen
COPY /bin/entrypoint.sh /etc/entrypoint
COPY --from=build /usr/local/bin/containerssh /bin/containerssh
USER ${uid}:${gid}
ENTRYPOINT [ "/etc/entrypoint" ]
