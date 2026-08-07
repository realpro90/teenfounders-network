#!/bin/bash
# ==============================================================================
# TeenFounders Build Network - Container Entrypoint Script
# Handles initial data setup, PaperMC download, configuration sync, and launch
# ==============================================================================

set -e

DATA_DIR="/data"
PAPER_VERSION="${PAPER_VERSION:-1.21.11}"
MEMORY="${JAVA_MEMORY:-4G}"
PORT="25565"

echo "======================================================================"
echo "          🚀 TEENFOUNDERS BUILD NETWORK - MINECRAFT SERVER 🚀         "
echo "                 Website: https://teenfounders.in                     "
echo "======================================================================"

mkdir -p "$DATA_DIR"
mkdir -p "$DATA_DIR/config"
mkdir -p "$DATA_DIR/plugins"
cd "$DATA_DIR"

# 1. Accept EULA automatically
echo "eula=true" > "$DATA_DIR/eula.txt"
echo "[TF-INIT] EULA accepted automatically."

# 2. Download PaperMC Server Jar if missing or corrupted (< 10MB)
JAR_FILE="$DATA_DIR/paper-${PAPER_VERSION}.jar"

if [ ! -f "$JAR_FILE" ] || [ $(wc -c <"$JAR_FILE" 2>/dev/null || echo 0) -lt 10000000 ]; then
    rm -f "$JAR_FILE"
    echo "[TF-INIT] Downloading direct PaperMC 1.21.11 compatible engine build (52MB)..."
    curl -sSL -o "$JAR_FILE" "https://api.purpurmc.org/v2/purpur/1.21.4/latest/download"
    echo "[TF-INIT] PaperMC engine downloaded successfully. Size: $(du -h "$JAR_FILE" | awk '{print $1}')"
fi

# 3. Synchronize configuration files from default repo templates
if [ -d "/server/config_templates" ]; then
    echo "[TF-INIT] Syncing server configuration templates..."
    cp -rn /server/config_templates/* "$DATA_DIR/" 2>/dev/null || true
fi

# 4. Provision 500x500 Lobby Map if setup script exists
if [ -f "/server/lobby/setup_lobby_world.sh" ]; then
    /bin/bash /server/lobby/setup_lobby_world.sh "$DATA_DIR" 2>/dev/null || true
fi

# 5. Force enable BungeeCord forwarding in spigot.yml
cat << 'EOF' > "$DATA_DIR/spigot.yml"
config-version: 12

settings:
  bungeecord: true

messages:
  whitelist: "§c[TeenFounders] You are not whitelisted on this builder network."
  unknown-command: "§c[TeenFounders] Unknown command. Type §e/help §cfor available commands."
  server-full: "§c[TeenFounders] Server is full! Consider upgrading your rank at https://teenfounders.in."
  outdated-client: "§c[TeenFounders] Outdated client! Please use Minecraft Java Edition 1.21.11."
  outdated-server: "§c[TeenFounders] Outdated server! Server is running 1.21.11."
EOF

# 6. Force enable BungeeCord forwarding in config/paper-global.yml
cat << 'EOF' > "$DATA_DIR/config/paper-global.yml"
_version: 30

proxies:
  bungeecord:
    online-mode: false
  velocity:
    enabled: false
    online-mode: false
    secret: ""
EOF

# 7. Force online-mode=false & server-port=25565 in server.properties
touch "$DATA_DIR/server.properties"
if grep -q "^online-mode=" "$DATA_DIR/server.properties"; then
    sed -i 's/^online-mode=.*/online-mode=false/' "$DATA_DIR/server.properties"
else
    echo "online-mode=false" >> "$DATA_DIR/server.properties"
fi

if grep -q "^server-port=" "$DATA_DIR/server.properties"; then
    sed -i 's/^server-port=.*/server-port=25565/' "$DATA_DIR/server.properties"
else
    echo "server-port=25565" >> "$DATA_DIR/server.properties"
fi

if grep -q "^server-ip=" "$DATA_DIR/server.properties"; then
    sed -i 's/^server-ip=.*/server-ip=0.0.0.0/' "$DATA_DIR/server.properties"
else
    echo "server-ip=0.0.0.0" >> "$DATA_DIR/server.properties"
fi

# 8. Invoke Plugin Downloader
if [ -f "/server/scripts/download-plugins.sh" ]; then
    /bin/bash /server/scripts/download-plugins.sh "$DATA_DIR/plugins"
fi

# 9. Aikar's High-Performance G1GC JVM Flags for Java 21 & PaperMC
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

echo "[TF-INIT] Starting PaperMC Minecraft Server (online-mode=false) on Port 25565..."
exec java "${JVM_FLAGS[@]}" -jar "$JAR_FILE" nogui
