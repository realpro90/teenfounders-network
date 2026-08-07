FROM eclipse-temurin:21-jre-alpine

ENV PAPER_VERSION="1.21.4" \
    JAVA_MEMORY="3G" \
    PORT="25565" \
    SERVER_NAME="lobby"

RUN apk add --no-cache curl jq bash netcat-openbsd ca-certificates tzdata tar gzip

WORKDIR /server

RUN curl -sSL "https://api.purpurmc.org/v2/purpur/1.21.4/latest/download" -o /server/purpur.jar || true

COPY common/entrypoint.sh /server/entrypoint.sh
COPY common/download-plugins.sh /server/scripts/download-plugins.sh
COPY common/healthcheck.sh /server/scripts/healthcheck.sh
COPY lobby/ /server/lobby/
COPY proxy/secret.txt /server/forwarding.secret

RUN chmod +x /server/entrypoint.sh /server/scripts/*.sh /server/lobby/*.sh 2>/dev/null || true

EXPOSE 25565/tcp

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s CMD /server/scripts/healthcheck.sh || exit 1

ENTRYPOINT ["/bin/bash", "/server/entrypoint.sh"]
