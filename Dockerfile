FROM golang:1.16 AS build
ENV PROJECT containerssh
WORKDIR /src/$PROJECT
COPY . .
RUN git submodule init && git submodule update
WORKDIR /src/$PROJECT/ContainerSSH
RUN  cd /src/$PROJECT/ContainerSSH && go mod download && CGO_ENABLED=0 GOBIN=/usr/local/bin/ go install -a -ldflags=-w ./...

FROM alpine
RUN apk add --no-cache openssh-keygen
COPY /bin/entrypoint.sh /etc/entrypoint
COPY --from=build /usr/local/bin/containerssh /bin/containerssh
ENTRYPOINT [ "/etc/entrypoint" ]
