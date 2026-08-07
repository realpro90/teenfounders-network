#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  TeenFounders Build Network — Universal Backend Server Entrypoint          ║
# ║  Purpur 1.21.4 Engine Launcher with Aikar G1GC Flags                      ║
# ║  © 2026 TeenFounders · https://teenfounders.in                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────

DATA_DIR="/data"
PAPER_VERSION="${PAPER_VERSION:-1.21.4}"
MEMORY="${JAVA_MEMORY:-5G}"
PORT="25565"
SERVER_NAME="${SERVER_NAME:-backend}"

# ─── ANSI Colours ────────────────────────────────────────────────────────────

readonly C_RESET='\033[0m'
readonly C_BOLD='\033[1m'
readonly C_ORANGE='\033[38;2;255;153;50m'
readonly C_GREEN='\033[38;2;80;200;120m'
readonly C_CYAN='\033[38;2;90;200;250m'
readonly C_GRAY='\033[38;2;140;140;140m'

# ─── Banner ──────────────────────────────────────────────────────────────────

echo ""
echo -e "${C_ORANGE}${C_BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║              TEENFOUNDERS BUILD NETWORK                    ║"
echo "║          Minecraft Server · Railway Deploy                 ║"
echo "║                                                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${C_RESET}"
echo -e "  ${C_GRAY}Server: ${SERVER_NAME} · Engine: Purpur ${PAPER_VERSION} · RAM: ${MEMORY}${C_RESET}"
echo ""

# ─── Helper: set a property without duplicates ──────────────────────────────

set_property() {
    local key="$1" value="$2" file="$3"
    touch "${file}"
    if grep -q "^${key}=" "${file}" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=${value}|" "${file}"
    else
        echo "${key}=${value}" >> "${file}"
    fi
}

# ─── Step 1: Create directories ─────────────────────────────────────────────

mkdir -p "${DATA_DIR}" "${DATA_DIR}/config" "${DATA_DIR}/plugins" "${DATA_DIR}/logs"
cd "${DATA_DIR}"

echo -e "  ${C_GREEN}✓${C_RESET} Directories initialised"

# ─── Step 2: Accept EULA ────────────────────────────────────────────────────

echo "eula=true" > "${DATA_DIR}/eula.txt"
echo -e "  ${C_GREEN}✓${C_RESET} EULA accepted"

# ─── Step 3: Sync forwarding secret ─────────────────────────────────────────

if [[ -f "/server/forwarding.secret" ]]; then
    cp /server/forwarding.secret "${DATA_DIR}/forwarding.secret"
    echo -e "  ${C_GREEN}✓${C_RESET} Forwarding secret synced"
fi

# ─── Step 4: Sync repository plugins & configs ──────────────────────────────

if [[ -d "/server/plugins" ]]; then
    cp -rf /server/plugins/* "${DATA_DIR}/plugins/" 2>/dev/null || true
    if [[ -f "/server/plugins/TAB/config.yml" ]]; then
        mkdir -p "${DATA_DIR}/plugins/TAB"
        cp -f /server/plugins/TAB/config.yml "${DATA_DIR}/plugins/TAB/config.yml" 2>/dev/null || true
    fi
    echo -e "  ${C_GREEN}✓${C_RESET} Plugin configurations synced & TAB HUD branded"
fi

if [[ -d "/server/config_templates" ]]; then
    cp -rn /server/config_templates/* "${DATA_DIR}/" 2>/dev/null || true
fi

# ─── Step 5: Download & Validate Server Engine ──────────────────────────────

JAR_FILE="${DATA_DIR}/purpur-${PAPER_VERSION}.jar"
NEED_DOWNLOAD=0

if [[ ! -f "${JAR_FILE}" ]]; then
    NEED_DOWNLOAD=1
elif ! unzip -t "${JAR_FILE}" >/dev/null 2>&1; then
    echo -e "  ${C_CYAN}▸${C_RESET} Server jar validation failed — re-downloading"
    rm -f "${JAR_FILE}"
    NEED_DOWNLOAD=1
fi

if [[ "${NEED_DOWNLOAD}" -eq 1 ]]; then
    echo -e "  ${C_CYAN}▸${C_RESET} Downloading Purpur ${PAPER_VERSION} engine..."
    curl -fsSL -o "${JAR_FILE}" "https://api.purpurmc.org/v2/purpur/${PAPER_VERSION}/latest/download"
    echo -e "  ${C_GREEN}✓${C_RESET} Engine downloaded ($(du -h "${JAR_FILE}" | awk '{print $1}'))"
else
    echo -e "  ${C_GREEN}✓${C_RESET} Engine already cached ($(du -h "${JAR_FILE}" | awk '{print $1}'))"
fi

# ─── Step 6: Provision Lobby World (lobby server only) ───────────────────────

if [[ "${SERVER_NAME}" == "lobby" ]]; then
    if [[ ! -d "${DATA_DIR}/world/datapacks/tf_lobby" ]]; then
        export TF_FORCE_REINSTALL=1
    fi

    if [[ -f "/server/lobby/setup_lobby_world.sh" ]]; then
        echo ""
        /bin/bash /server/lobby/setup_lobby_world.sh "${DATA_DIR}"
        echo ""
    elif [[ -f "/server/common/setup_lobby_world.sh" ]]; then
        echo ""
        /bin/bash /server/common/setup_lobby_world.sh "${DATA_DIR}"
        echo ""
    fi
fi

# ─── Step 7: BungeeCord forwarding — spigot.yml ─────────────────────────────

if [[ -f "${DATA_DIR}/spigot.yml" ]]; then
    if grep -q "bungeecord:" "${DATA_DIR}/spigot.yml"; then
        sed -i 's/bungeecord:.*/bungeecord: true/' "${DATA_DIR}/spigot.yml"
    fi
else
    cat << 'SPIGOT_EOF' > "${DATA_DIR}/spigot.yml"
config-version: 12

settings:
  bungeecord: true

messages:
  whitelist: "§c[TeenFounders] You are not whitelisted on this builder network."
  unknown-command: "§c[TeenFounders] Unknown command. Type §e/help §cfor available commands."
  server-full: "§c[TeenFounders] Server is full! Consider upgrading your rank at https://teenfounders.in."
  outdated-client: "§c[TeenFounders] Outdated client! Please use Minecraft Java Edition 1.21.11."
  outdated-server: "§c[TeenFounders] Outdated server! Server is running 1.21.4 with ViaVersion."
SPIGOT_EOF
fi
echo -e "  ${C_GREEN}✓${C_RESET} BungeeCord forwarding enabled (spigot.yml)"

# ─── Step 8: Paper-global.yml — proxy forwarding mode ───────────────────────

mkdir -p "${DATA_DIR}/config"

if [[ -f "${DATA_DIR}/config/paper-global.yml" ]]; then
    if grep -q "online-mode:" "${DATA_DIR}/config/paper-global.yml"; then
        sed -i 's/online-mode:.*/online-mode: false/' "${DATA_DIR}/config/paper-global.yml"
    fi
else
    cat << 'PAPER_EOF' > "${DATA_DIR}/config/paper-global.yml"
_version: 30

proxies:
  bungeecord:
    online-mode: false
  velocity:
    enabled: false
    online-mode: false
    secret: ""
PAPER_EOF
fi
echo -e "  ${C_GREEN}✓${C_RESET} Paper proxy forwarding configured"

# ─── Step 9: server.properties — core settings ──────────────────────────────

set_property "online-mode"      "false"     "${DATA_DIR}/server.properties"
set_property "server-port"      "25565"     "${DATA_DIR}/server.properties"
set_property "server-ip"        ""          "${DATA_DIR}/server.properties"
set_property "spawn-protection" "0"         "${DATA_DIR}/server.properties"

echo -e "  ${C_GREEN}✓${C_RESET} server.properties configured"

# ─── Step 10: Download plugins ──────────────────────────────────────────────

if [[ -f "/server/scripts/download-plugins.sh" ]]; then
    echo ""
    /bin/bash /server/scripts/download-plugins.sh "${DATA_DIR}/plugins"
    echo ""
fi

# ─── Step 11: Launch Server ──────────────────────────────────────────────────

JVM_FLAGS=(
    # Railway dual-stack: listen on IPv6 for proxy, but use IPv4 for outbound downloads
    "-Djava.net.preferIPv4Stack=false"
    # Memory
    "-Xms${MEMORY}"
    "-Xmx${MEMORY}"
    # Aikar's G1GC Flags
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

echo -e "${C_ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo -e "  ${C_GREEN}${C_BOLD}▶ Launching Purpur ${PAPER_VERSION} on :${PORT} with ${MEMORY} RAM${C_RESET}"
echo -e "${C_ORANGE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo ""

exec java "${JVM_FLAGS[@]}" -jar "${JAR_FILE}" nogui
