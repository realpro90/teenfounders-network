#!/bin/bash
# ==============================================================================
# TeenFounders Build Network - Container Entrypoint Script
# Handles initial data setup, Purpur download, configuration sync, and launch
# ==============================================================================

set -e

DATA_DIR="/data"
PAPER_VERSION="${PAPER_VERSION:-1.21.4}"
MEMORY="${JAVA_MEMORY:-5G}"
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

# 2. Sync repository plugins & configurations into /data/plugins
if [ -d "/server/plugins" ]; then
    echo "[TF-INIT] Syncing network plugin configurations (Citizens, DeluxeMenus, TAB, Essentials)..."
    cp -rf /server/plugins/* "$DATA_DIR/plugins/" 2>/dev/null || true
fi

if [ -d "/server/config_templates" ]; then
    cp -rn /server/config_templates/* "$DATA_DIR/" 2>/dev/null || true
fi

# 3. Jar Integrity Validation & Engine Downloader (Purpur 1.21.4 / Paper Compatible)
JAR_FILE="$DATA_DIR/purpur-${PAPER_VERSION}.jar"
NEED_DOWNLOAD=0

if [ ! -f "$JAR_FILE" ]; then
    NEED_DOWNLOAD=1
elif ! unzip -t "$JAR_FILE" >/dev/null 2>&1; then
    echo "[TF-INIT] Server jar archive validation failed. Re-downloading Purpur engine..."
    rm -f "$JAR_FILE"
    NEED_DOWNLOAD=1
fi

if [ "$NEED_DOWNLOAD" -eq 1 ]; then
    echo "[TF-INIT] Downloading Purpur ${PAPER_VERSION} engine build (52MB)..."
    curl -sSL -o "$JAR_FILE" "https://api.purpurmc.org/v2/purpur/${PAPER_VERSION}/latest/download"
    echo "[TF-INIT] Purpur engine downloaded successfully. Size: $(du -h "$JAR_FILE" | awk '{print $1}')"
fi

# 4. Provision 500x500 Lobby Map if setup script exists
if [ -f "/server/lobby/setup_lobby_world.sh" ]; then
    /bin/bash /server/lobby/setup_lobby_world.sh "$DATA_DIR" 2>/dev/null || true
fi

# 5. Enable BungeeCord forwarding in spigot.yml
if [ -f "$DATA_DIR/spigot.yml" ]; then
    if grep -q "bungeecord:" "$DATA_DIR/spigot.yml"; then
        sed -i 's/bungeecord:.*/bungeecord: true/' "$DATA_DIR/spigot.yml"
    fi
else
    cat << 'EOF' > "$DATA_DIR/spigot.yml"
config-version: 12

settings:
  bungeecord: true

messages:
  whitelist: "§c[TeenFounders] You are not whitelisted on this builder network."
  unknown-command: "§c[TeenFounders] Unknown command. Type §e/help §cfor available commands."
  server-full: "§c[TeenFounders] Server is full! Consider upgrading your rank at https://teenfounders.in."
  outdated-client: "§c[TeenFounders] Outdated client! Please use Minecraft Java Edition 1.21.11."
  outdated-server: "§c[TeenFounders] Outdated server! Server is running 1.21.4 with ViaVersion."
EOF
fi

# 6. Preserving paper-global.yml settings via In-Place Edit
if [ -f "$DATA_DIR/config/paper-global.yml" ]; then
    python3 -c "
import re
path = '$DATA_DIR/config/paper-global.yml'
with open(path, 'r') as f:
    content = f.read()
if 'bungeecord:' in content:
    content = re.sub(r'(bungeecord:[\s\S]*?online-mode:\s*)\w+', r'\g<1>false', content)
else:
    content += '\nproxies:\n  bungeecord:\n    online-mode: false\n'
with open(path, 'w') as f:
    f.write(content)
" 2>/dev/null || true
else
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
fi

# 7. Force online-mode=false, spawn-protection=0 & server-port=25565 in server.properties
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

if grep -q "^spawn-protection=" "$DATA_DIR/server.properties"; then
    sed -i 's/^spawn-protection=.*/spawn-protection=0/' "$DATA_DIR/server.properties"
else
    echo "spawn-protection=0" >> "$DATA_DIR/server.properties"
fi

# 8. Invoke Plugin Downloader
if [ -f "/server/scripts/download-plugins.sh" ]; then
    /bin/bash /server/scripts/download-plugins.sh "$DATA_DIR/plugins"
fi

# 9. Aikar's High-Performance G1GC JVM Flags for Java 21 & Purpur
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
)

echo "[TF-INIT] Starting Purpur ${PAPER_VERSION} Engine (online-mode=false) on Port 25565 with ${MEMORY} RAM..."
exec java "${JVM_FLAGS[@]}" -jar "$JAR_FILE" nogui
