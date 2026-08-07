# ==============================================================================
# TeenFounders Build Network - Minecraft Java 1.21.11 Production Dockerfile
# Optimized for Railway Deployment with Java 21 & PaperMC Engine
# Branding: TeenFounders (https://teenfounders.in) - Orange (#FF9932) / White / Black
# ==============================================================================

FROM eclipse-temurin:21-jre-alpine

# Set environment variables
ENV PAPER_VERSION="1.21.11" \
    DATA_DIR="/data" \
    JAVA_MEMORY="4G" \
    PORT="25565" \
    EULA="true"

# Install necessary runtime utilities
RUN apk add --no-gradable --no-cache \
    curl \
    jq \
    bash \
    netcat-openbsd \
    ca-certificates \
    tzdata \
    && rm -rf /var/cache/apk/*

# Create working directory and data volume mount point
WORKDIR /server

# Copy startup scripts and configurations into image build context
COPY entrypoint.sh /server/entrypoint.sh
COPY scripts/ /server/scripts/

# Grant executable permissions to scripts
RUN chmod +x /server/entrypoint.sh /server/scripts/*.sh

# Expose Minecraft server default port and Bedrock UDP port (for Geyser)
EXPOSE 25565/tcp
EXPOSE 25565/udp
EXPOSE 19132/udp

# Mount volume for persistent storage on Railway
VOLUME ["/data"]

# Define container healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /server/scripts/healthcheck.sh || exit 1

# Define container entrypoint
ENTRYPOINT ["/bin/bash", "/server/entrypoint.sh"]
