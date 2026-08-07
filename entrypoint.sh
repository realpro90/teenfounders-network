#!/bin/bash
# ==============================================================================
# TeenFounders Build Network - Container Entrypoint Script
# Handles initial data setup, PaperMC download, configuration sync, and launch
# ==============================================================================

set -e

DATA_DIR="/data"
PAPER_VERSION="${PAPER_VERSION:-1.21.11}"
MEMORY="${JAVA_MEMORY:-4G}"
PORT="${PORT:-25565}"

echo "======================================================================"
echo "          🚀 TEENFOUNDERS BUILD NETWORK - MINECRAFT SERVER 🚀         "
echo "                 Website: https://teenfounders.in                     "
echo "======================================================================"

mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

# 1. Accept EULA automatically
echo "eula=true" > "$DATA_DIR/eula.txt"
echo "[TF-INIT] EULA accepted automatically."

# 2. Download PaperMC Server Jar if missing or corrupted
JAR_FILE="$DATA_DIR/paper-${PAPER_VERSION}.jar"

if [ ! -f "$JAR_FILE" ] || [ $(wc -c <"$JAR_FILE" 2>/dev/null || echo 0) -lt 5000000 ]; then
    rm -f "$JAR_FILE"
    echo "[TF-INIT] Fetching latest PaperMC build for Minecraft $PAPER_VERSION..."
    BUILD_INFO=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}")
    LATEST_BUILD=$(echo "$BUILD_INFO" | jq -r '.builds[-1]' 2>/dev/null)
    
    TARGET_VER="$PAPER_VERSION"
    if [ "$LATEST_BUILD" == "null" ] || [ -z "$LATEST_BUILD" ]; then
        echo "[TF-INIT] Version $PAPER_VERSION API endpoint not found. Falling back to Paper 1.21.4 latest engine build..."
        TARGET_VER="1.21.4"
        BUILD_INFO=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${TARGET_VER}")
        LATEST_BUILD=$(echo "$BUILD_INFO" | jq -r '.builds[-1]')
    fi

    JAR_NAME="paper-${TARGET_VER}-${LATEST_BUILD}.jar"
    DOWNLOAD_URL="https://api.papermc.io/v2/projects/paper/versions/${TARGET_VER}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"

    echo "[TF-INIT] Downloading PaperMC Build #$LATEST_BUILD from $DOWNLOAD_URL..."
    curl -sSL -o "$JAR_FILE" "$DOWNLOAD_URL"
    echo "[TF-INIT] PaperMC downloaded successfully."
fi

# 3. Synchronize configuration files from default repo templates
mkdir -p "$DATA_DIR/plugins"
mkdir -p "$DATA_DIR/config"

if [ -d "/server/config_templates" ]; then
    echo "[TF-INIT] Syncing server configuration templates..."
    cp -rn /server/config_templates/* "$DATA_DIR/" 2>/dev/null || true
fi

# 4. Invoke Plugin Downloader
if [ -f "/server/scripts/download-plugins.sh" ]; then
    /bin/bash /server/scripts/download-plugins.sh "$DATA_DIR/plugins"
fi

# 5. Overwrite dynamic environment variables in server.properties if present
if [ -f "$DATA_DIR/server.properties" ]; then
    if [ -n "$MOTD" ]; then
        sed -i "s/^motd=.*/motd=${MOTD}/" "$DATA_DIR/server.properties"
    fi
    if [ -n "$MAX_PLAYERS" ]; then
        sed -i "s/^max-players=.*/max-players=${MAX_PLAYERS}/" "$DATA_DIR/server.properties"
    fi
    if [ -n "$VIEW_DISTANCE" ]; then
        sed -i "s/^view-distance=.*/view-distance=${VIEW_DISTANCE}/" "$DATA_DIR/server.properties"
    fi
    if [ -n "$SIMULATION_DISTANCE" ]; then
        sed -i "s/^simulation-distance=.*/simulation-distance=${SIMULATION_DISTANCE}/" "$DATA_DIR/server.properties"
    fi
    if [ -n "$PORT" ]; then
        sed -i "s/^server-port=.*/server-port=${PORT}/" "$DATA_DIR/server.properties"
    fi
fi

# 6. Aikar's High-Performance G1GC JVM Flags for Java 21 & PaperMC
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
    "-Dpaper.player-connection-throttle=3000"
)

echo "[TF-INIT] Starting PaperMC Minecraft Server..."
echo "[TF-INIT] Memory Allocation: $MEMORY | Target Port: $PORT"

# Execute Java with Aikar's Flags
exec java "${JVM_FLAGS[@]}" -jar "$JAR_FILE" nogui
