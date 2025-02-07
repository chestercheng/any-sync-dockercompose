# syntax=docker/dockerfile:1
FROM alpine:3.18.4
RUN apk add --no-cache bash yq perl python3 py3-yaml
WORKDIR /code
ENTRYPOINT ["bash", "/code/generateconfig/processing.sh"]
