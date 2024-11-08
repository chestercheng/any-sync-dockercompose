# syntax=docker/dockerfile:1
FROM golang:1.22-alpine3.19
RUN apk add --no-cache bash yq
RUN go install github.com/anyproto/any-sync-tools/anyconf@latest
WORKDIR /code
ENTRYPOINT ["bash", "/code/generateconfig/anyconf.sh"]
