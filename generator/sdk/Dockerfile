FROM golang:1.24.1 AS go-build

RUN go install golang.org/x/tools/cmd/goimports@latest

FROM openapitools/openapi-generator-cli:v7.16.0 AS openapigenerator

ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

COPY --from=go-build $GOPATH $GOPATH
COPY --from=go-build /usr/local/go /usr/local/go

# Copy all files from the ./generator/sdk directory to the /generator directory in the container
COPY ./generator/sdk /generator

ENV GENERATOR_DIR="/generator"
ENV GENERATOR_OUTPUT_DIR="/generated"
ENV GENERATOR_GIT_HOST="github.com"
ENV GENERATOR_GIT_USER_ID="pingidentity"
ENV CLIENT_NAME_FORMAT_MASK="%s-%s-client"
ENV GENERATOR_SDK_USER_AGENT_PREFIX="pingtools "
ENV DEBUG="false"

COPY ./generator/sdk/docker_entrypoint.sh /usr/local/bin/ping_docker_entrypoint.sh
RUN ln -s /usr/local/bin/ping_docker_entrypoint.sh /usr/local/bin/ping-openapi-generator

ENTRYPOINT ["/usr/local/bin/ping_docker_entrypoint.sh"]