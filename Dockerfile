FROM brew.registry.redhat.io/rh-osbs/openshift-golang-builder:rhel_9_golang_1.24 AS builder
COPY loki loki
WORKDIR loki
RUN make clean && make BUILD_IN_CONTAINER=false promtail


FROM registry.access.redhat.com/ubi9-minimal:latest

# Standard Red Hat labels
LABEL com.redhat.component="promtail-container"
LABEL name="promtail"
LABEL version="v3.5.3"
LABEL summary="Provides promtail container"
LABEL io.k8s.display-name="Promtail container"
LABEL io.k8s.description="promtail-container"
LABEL io.openshift.tags="rhceph ceph dashboard loki"
LABEL maintainer="Guillaume Abrioux <gabrioux@redhat.com>"
LABEL description="Responsible for gathering logs and sending them to Loki"
LABEL cpe=cpe:/a:redhat:ceph_storage:8::el9
LABEL org.opencontainers.image.created="${BUILD_DATE}"

COPY --from=builder /loki/clients/cmd/promtail/promtail /usr/bin/promtail
COPY --from=builder /loki/clients/cmd/promtail/promtail-docker-config.yaml /etc/promtail/config.yml
ENTRYPOINT ["/usr/bin/promtail"]
CMD ["-config.file=/etc/promtail/config.yml"]

