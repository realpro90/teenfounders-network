#!/bin/bash
# ==============================================================================
# TeenFounders Network - Universal Backend Server Entrypoint Script
# PaperMC 1.21.11 Engine Launcher with Aikar G1GC Flags & Database Bindings
# ==============================================================================

set -e

DATA_DIR="/data"
PAPER_VERSION="${PAPER_VERSION:-1.21.11}"
MEMORY="${JAVA_MEMORY:-3G}"
PORT="${PORT:-25565}"

echo "======================================================================"
echo "          🚀 TEENFOUNDERS NETWORK - BACKEND SERVER LAUNCH 🚀         "
echo "                 Server Name: ${SERVER_NAME:-backend}                 "
echo "======================================================================"

mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

# 1. Accept EULA automatically
echo "eula=true" > "$DATA_DIR/eula.txt"

# 2. Sync velocity forwarding secret key
if [ -f "/server/forwarding.secret" ]; then
    cp /server/forwarding.secret "$DATA_DIR/forwarding.secret"
fi

# 3. Download PaperMC Server Jar if missing
JAR_FILE="$DATA_DIR/paper-${PAPER_VERSION}.jar"

if [ ! -f "$JAR_FILE" ]; then
    echo "[TF-INIT] Fetching latest PaperMC build for Minecraft $PAPER_VERSION..."
    BUILD_INFO=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}")
    LATEST_BUILD=$(echo "$BUILD_INFO" | jq -r '.builds[-1]')
    
    if [ "$LATEST_BUILD" == "null" ] || [ -z "$LATEST_BUILD" ]; then
        LATEST_BUILD="120"
    fi

    JAR_NAME="paper-${PAPER_VERSION}-${LATEST_BUILD}.jar"
    DOWNLOAD_URL="https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"

    echo "[TF-INIT] Downloading PaperMC Build #$LATEST_BUILD from $DOWNLOAD_URL..."
    curl -sSL -o "$JAR_FILE" "$DOWNLOAD_URL"
fi

# 4. Sync configuration templates if provided
if [ -d "/server/config_templates" ]; then
    cp -rn /server/config_templates/* "$DATA_DIR/" 2>/dev/null || true
fi

# 5. Invoke Plugin Downloader Script
if [ -f "/server/scripts/download-plugins.sh" ]; then
    /bin/bash /server/scripts/download-plugins.sh "$DATA_DIR/plugins"
fi

# 6. Aikar's High-Performance G1GC JVM Flags
JVM_FLAGS=(
    "-Xms${MEMORY}"
    "-Xmx${MEMORY}"
    "-XX:+UseG1GC"
    "-XX:+ParallelRefProcEnabled"
    "-XX:MaxGCPauseMillis=200"
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:+DisableExplicitGC"
    "-XX:+AlwaysPreTouch"
    "-XX:G1NewSizePercent=30"
    "-XX:G1MaxNewSizePercent=40"
    "-XX:G1HeapRegionSize=8M"
    "-XX:G1ReservePercent=20"
    "-XX:G1HeapWastePercent=5"
    "-XX:G1MixedGCCountTarget=4"
    "-XX:InitiatingHeapOccupancyPercent=15"
    "-XX:G1MixedGCLiveThresholdPercent=90"
    "-XX:G1RSetUpdatingPauseTimePercent=5"
    "-XX:SurvivorRatio=32"
    "-XX:+PerfDisableSharedMem"
    "-XX:MaxTenuringThreshold=1"
    "-Dusing.aikars.flags=https://mcflags.emc.gs"
    "-Daio.paper.async-chunk-loading=true"
)

echo "[TF-INIT] Executing Java PaperMC Engine with ${MEMORY} RAM..."
exec java "${JVM_FLAGS[@]}" -jar "$JAR_FILE" nogui
