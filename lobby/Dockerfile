FROM eclipse-temurin:21-jre-alpine

ENV PAPER_VERSION="1.21.11" \
    JAVA_MEMORY="3G" \
    PORT="25565" \
    SERVER_NAME="lobby"

RUN apk add --no-cache curl jq bash netcat-openbsd ca-certificates tzdata

WORKDIR /server

COPY common/entrypoint.sh /server/entrypoint.sh
COPY common/download-plugins.sh /server/scripts/download-plugins.sh
COPY common/healthcheck.sh /server/scripts/healthcheck.sh
COPY proxy/secret.txt /server/forwarding.secret

RUN chmod +x /server/entrypoint.sh /server/scripts/*.sh

EXPOSE 25565/tcp
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s CMD /server/scripts/healthcheck.sh || exit 1

ENTRYPOINT ["/bin/bash", "/server/entrypoint.sh"]
