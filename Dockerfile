ARG REMOTE_SOURCE=loki
ARG REMOTE_SOURCE_DIR=/go/app

FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.24 AS builder

# Build Arguments
ARG REMOTE_SOURCE
ARG REMOTE_SOURCE_DIR

COPY $REMOTE_SOURCE $REMOTE_SOURCE_DIR
WORKDIR $REMOTE_SOURCE_DIR
RUN make clean && make BUILD_IN_CONTAINER=false promtail


FROM --platform=$BUILDPLATFORM registry.access.redhat.com/ubi9-minimal:latest

# Build Arguments
ARG REMOTE_SOURCE
ARG REMOTE_SOURCE_DIR

LABEL com.redhat.component="promtail-container"
LABEL name="promtail"
LABEL version="v3.0.0"
LABEL summary="Provides promtail container"
LABEL io.k8s.display-name="Promtail container"
LABEL maintainer="Guillaume Abrioux <gabrioux@redhat.com>"
LABEL description="Responsible for gathering logs and sending them to Loki"
COPY --from=builder $REMOTE_SOURCE_DIR/clients/cmd/promtail/promtail /usr/bin/promtail
COPY --from=builder $REMOTE_SOURCE_DIR/clients/cmd/promtail/promtail-docker-config.yaml /etc/promtail/config.yml
ENTRYPOINT ["/usr/bin/promtail"]
CMD ["-config.file=/etc/promtail/config.yml"]
