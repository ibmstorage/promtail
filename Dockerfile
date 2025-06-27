FROM brew.registry.redhat.io/rh-osbs/openshift-golang-builder:rhel_9_golang_1.21 AS builder
COPY $REMOTE_SOURCE $REMOTE_SOURCE_DIR
WORKDIR $REMOTE_SOURCE_DIR/app
RUN make clean && make BUILD_IN_CONTAINER=false promtail


FROM registry.redhat.io/ubi9/ubi-micro
# Standard Red Hat labels
LABEL com.redhat.component="promtail-container"
LABEL name="promtail"
LABEL version="v3.0.0"
LABEL summary="Provides promtail container"
LABEL io.k8s.display-name="Promtail container"
LABEL maintainer="Guillaume Abrioux <gabrioux@redhat.com>"
LABEL description="Responsible for gathering logs and sending them to Loki"
COPY --from=builder $REMOTE_SOURCE_DIR/app/clients/cmd/promtail/promtail /usr/bin/promtail
COPY --from=builder $REMOTE_SOURCE_DIR/app/clients/cmd/promtail/promtail-docker-config.yaml /etc/promtail/config.yml
ENTRYPOINT ["/usr/bin/promtail"]
CMD ["-config.file=/etc/promtail/config.yml"]
