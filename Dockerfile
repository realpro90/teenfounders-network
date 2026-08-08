# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  TeenFounders Build Network — Production Dockerfile                        ║
# ║  Minecraft Java 1.21.11 · Purpur 1.21.4 Engine · Railway Optimised        ║
# ║  © 2026 TeenFounders · https://teenfounders.in                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

FROM eclipse-temurin:21-jdk-alpine

# ─── Environment ─────────────────────────────────────────────────────────────
ENV PAPER_VERSION="1.21.4" \
    DATA_DIR="/data" \
    JAVA_MEMORY="4G" \
    PORT="25565" \
    EULA="true"

# ─── Runtime Dependencies ───────────────────────────────────────────────────
RUN apk add --no-cache \
    curl \
    jq \
    bash \
    netcat-openbsd \
    ca-certificates \
    tzdata \
    gzip \
    tar \
    coreutils \
    && rm -rf /var/cache/apk/*

# ─── Working Directory ──────────────────────────────────────────────────────
WORKDIR /server

# ─── Pre-Download Purpur Engine for Instant Startup ────────────────────────
RUN curl -sSL "https://api.purpurmc.org/v2/purpur/1.21.4/latest/download" -o /server/purpur.jar || true

# ─── Copy Application Files ─────────────────────────────────────────────────
COPY entrypoint.sh    /server/entrypoint.sh
COPY scripts/         /server/scripts/
COPY lobby/           /server/lobby/
COPY plugins/         /server/plugins/
COPY config_templates/ /server/config_templates/
COPY src/             /server/src/
COPY paper-global.yml /server/paper-global.yml

# ─── Permissions & Pre-Cache Plugins ──────────────────────────────────────────
RUN chmod +x /server/entrypoint.sh \
    && chmod +x /server/scripts/*.sh 2>/dev/null || true \
    && chmod +x /server/lobby/*.sh 2>/dev/null || true \
    && /bin/bash /server/scripts/download-plugins.sh /server/plugins

# ─── Ports ───────────────────────────────────────────────────────────────────
EXPOSE 25565/tcp
EXPOSE 25565/udp
EXPOSE 19132/udp

# ─── Health Check ────────────────────────────────────────────────────────────
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD /server/scripts/healthcheck.sh || exit 1

# ─── Entrypoint ──────────────────────────────────────────────────────────────
ENTRYPOINT ["/bin/bash", "/server/entrypoint.sh"]
