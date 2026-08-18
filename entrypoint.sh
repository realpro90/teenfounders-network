#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  TeenFounders Build Network — Container Entrypoint                           ║
# ║  PaperMC 1.21.11 · Purpur 1.21.4 Engine · Railway Ephemeral Runtime       ║
# ║  © 2026 TeenFounders · https://teenfounders.in                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────
readonly C_RESET='\033[0m'
readonly C_BOLD='\033[1m'
readonly C_ORANGE='\033[38;2;255;153;50m'
readonly C_GREEN='\033[38;2;80;200;120m'
readonly C_CYAN='\033[38;2;90;200;250m'
readonly C_YELLOW='\033[38;2;255;204;0m'

echo -e "${C_ORANGE}${C_BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║             TEENFOUNDERS BUILD NETWORK CONTAINER             ║"
echo "║          PaperMC 1.21.11  •  Purpur 1.21.4 Engine            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${C_RESET}"

# ─── Environment Setup ───────────────────────────────────────────────────────
DATA_DIR="${DATA_DIR:-/data}"
SERVER_NAME="${SERVER_NAME:-lobby}"
JAVA_MEMORY="${JAVA_MEMORY:-4G}"

mkdir -p "${DATA_DIR}" "${DATA_DIR}/plugins" "${DATA_DIR}/config" "${DATA_DIR}/logs"

echo -e "  ${C_CYAN}▸${C_RESET} Server Name:  ${C_BOLD}${SERVER_NAME}${C_RESET}"
echo -e "  ${C_CYAN}▸${C_RESET} Data Dir:     ${DATA_DIR}"
echo -e "  ${C_CYAN}▸${C_RESET} Java Memory:  ${JAVA_MEMORY}"

# Purge any old/stale SkinsRestorer.jar or WorldGuard.jar from persistent volume
rm -f "${DATA_DIR}/plugins/SkinsRestorer.jar"
rm -f "${DATA_DIR}/plugins/SkinsRestorer-*.jar"
rm -f "${DATA_DIR}/plugins/WorldGuard.jar"

# ─── Step 1: Sync BungeeCord / Velocity forwarding & Chat Signatures Config ─
cat > "${DATA_DIR}/config/paper-global.yml" << 'YAML'
_version: 28
proxies:
  bungeecord:
    online-mode: false
  velocity:
    enabled: false
    online-mode: false
    secret: ""
settings:
  enforce-secure-profile: false
  log-player-ip-addresses: false
YAML

cp -f "${DATA_DIR}/config/paper-global.yml" "${DATA_DIR}/paper-global.yml" 2>/dev/null || true

cat > "${DATA_DIR}/purpur.yml" << 'YAML'
verbose: false
config-version: 36
settings:
  enforce-secure-profile: false
YAML

echo -e "  ${C_GREEN}✓${C_RESET} paper-global.yml & purpur.yml written (enforce-secure-profile: false)"

# ─── Step 2: Accept EULA ─────────────────────────────────────────────────────
echo "eula=true" > "${DATA_DIR}/eula.txt"
echo -e "  ${C_GREEN}✓${C_RESET} Minecraft EULA accepted"

# ─── Step 3: Download Shared Verified Plugins ────────────────────────────────
if [[ -f "/server/scripts/download-plugins.sh" ]]; then
    /bin/bash /server/scripts/download-plugins.sh "${DATA_DIR}/plugins"
fi

# ─── Step 4: Download & Validate Server Engine ──────────────────────────────
JAR_FILE="${DATA_DIR}/purpur-${PAPER_VERSION}.jar"
NEED_DOWNLOAD=0

if [[ ! -f "${JAR_FILE}" ]]; then
    if [[ -f "/server/purpur.jar" ]]; then
        echo -e "  ${C_GREEN}✓${C_RESET} Copying pre-bundled Purpur ${PAPER_VERSION} engine..."
        cp /server/purpur.jar "${JAR_FILE}"
        NEED_DOWNLOAD=0
    else
        NEED_DOWNLOAD=1
    fi
elif ! unzip -t "${JAR_FILE}" >/dev/null 2>&1; then
    echo -e "  ${C_CYAN}▸${C_RESET} Server jar validation failed — re-downloading"
    rm -f "${JAR_FILE}"
    if [[ -f "/server/purpur.jar" ]]; then
        cp /server/purpur.jar "${JAR_FILE}"
        NEED_DOWNLOAD=0
    else
        NEED_DOWNLOAD=1
    fi
fi

if [[ "${NEED_DOWNLOAD}" -eq 1 ]]; then
    echo -e "  ${C_CYAN}▸${C_RESET} Downloading Purpur ${PAPER_VERSION} engine..."
    curl -fsSL -o "${JAR_FILE}" "https://api.purpurmc.org/v2/purpur/${PAPER_VERSION}/latest/download"
    echo -e "  ${C_GREEN}✓${C_RESET} Engine downloaded ($(du -h "${JAR_FILE}" | awk '{print $1}'))"
else
    echo -e "  ${C_GREEN}✓${C_RESET} Engine already cached ($(du -h "${JAR_FILE}" | awk '{print $1}'))"
fi

# ─── Step 5: Provision Lobby World (lobby server only) ───────────────────────
if [[ "${SERVER_NAME}" == "lobby" ]]; then
    # Purge playerdata, stats, advancements, Essentials userdata so players always spawn at Plaza center (0.5, 90.0, 0.5)
    rm -rf "${DATA_DIR}/world/playerdata"
    rm -rf "${DATA_DIR}/world/stats"
    rm -rf "${DATA_DIR}/world/advancements"
    rm -rf "${DATA_DIR}/plugins/Essentials/userdata"

    if [[ ! -f "${DATA_DIR}/world/level.dat" ]]; then
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
fi

# Force server.properties enforce-secure-profile=false
if [[ -f "${DATA_DIR}/server.properties" ]]; then
    if grep -q "^enforce-secure-profile=" "${DATA_DIR}/server.properties"; then
        sed -i 's/^enforce-secure-profile=.*/enforce-secure-profile=false/' "${DATA_DIR}/server.properties"
    else
        echo "enforce-secure-profile=false" >> "${DATA_DIR}/server.properties"
    fi
fi

# ─── Step 6: FINAL OVERWRITE WITH REPOSITORY PLUGINS RIGHT BEFORE ENGINE LAUNCH ─
if [[ -d "/server/plugins" ]]; then
    echo -e "  ${C_CYAN}▸${C_RESET} Force copying repository plugins into ${DATA_DIR}/plugins/..."
    cp -f /server/plugins/FreedomChat.jar "${DATA_DIR}/plugins/" 2>/dev/null || true
    cp -f /server/plugins/SkinsRestorer.jar "${DATA_DIR}/plugins/" 2>/dev/null || true
    cp -f /server/plugins/TeenFoundersLobby.jar "${DATA_DIR}/plugins/" 2>/dev/null || true
    if [[ -f "/server/plugins/TAB/config.yml" ]]; then
        mkdir -p "${DATA_DIR}/plugins/TAB"
        cp -f /server/plugins/TAB/config.yml "${DATA_DIR}/plugins/TAB/config.yml" 2>/dev/null || true
    fi
    if [[ -f "/server/ops.json" ]]; then
        cp -f /server/ops.json "${DATA_DIR}/ops.json" 2>/dev/null || true
    fi
    echo -e "  ${C_GREEN}✓${C_RESET} Repository plugins forced into ${DATA_DIR}/plugins/"
fi

# Patch FreedomChat api-version to 1.20 if needed
python3 -c "
import zipfile, os
for jar in ['${DATA_DIR}/plugins/FreedomChat.jar', '/server/plugins/FreedomChat.jar']:
    if os.path.exists(jar):
        tmp = jar + '.tmp'
        try:
            with zipfile.ZipFile(jar, 'r') as zin:
                with zipfile.ZipFile(tmp, 'w') as zout:
                    for item in zin.infolist():
                        content = zin.read(item.filename)
                        if item.filename == 'plugin.yml':
                            text = content.decode('utf-8')
                            text = text.replace('api-version: \"26.2\"', 'api-version: \"1.20\"').replace('api-version: 26.2', 'api-version: \"1.20\"')
                            content = text.encode('utf-8')
                        zout.writestr(item, content)
            os.replace(tmp, jar)
        except Exception:
            pass
" 2>/dev/null || true

# Compile fresh TeenFoundersLobby plugin if source is available
if [[ -f "/server/src/com/teenfounders/lobby/TeenFoundersLobby.java" ]]; then
    echo -e "  ${C_CYAN}▸${C_RESET} Compiling fresh TeenFoundersLobby.jar..."
    mkdir -p /tmp/tf_lobby_build
    cp_jars=$(find "${DATA_DIR}/plugins" -name "*.jar" | tr '\n' ':')
    javac -cp "${cp_jars}" -d /tmp/tf_lobby_build /server/src/com/teenfounders/lobby/TeenFoundersLobby.java || true
    cp /server/src/plugin.yml /tmp/tf_lobby_build/plugin.yml || true
    jar -cf "${DATA_DIR}/plugins/TeenFoundersLobby.jar" -C /tmp/tf_lobby_build . || true
    echo -e "  ${C_GREEN}✓${C_RESET} TeenFoundersLobby.jar freshly compiled & installed!"
fi

if [[ -d "/server/config_templates" ]]; then
    cp -rn /server/config_templates/* "${DATA_DIR}/" 2>/dev/null || true
fi

# ─── Step 7: Launch Paper/Purpur Server Engine ──────────────────────────────
echo -e "${C_ORANGE}${C_BOLD}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  LAUNCHING MINECRAFT SERVER: ${SERVER_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${C_RESET}"

cd "${DATA_DIR}"

exec java \
    -Xms"${JAVA_MEMORY}" \
    -Xmx"${JAVA_MEMORY}" \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC \
    -XX:+AlwaysPreTouch \
    -XX:G1NewSizePercent=30 \
    -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapRegionSize=8M \
    -XX:G1ReservePercent=20 \
    -XX:G1HeapWastePercent=5 \
    -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 \
    -XX:G1MixedGCLiveThresholdPercent=90 \
    -XX:G1RSetUpdatingPauseTimePercent=5 \
    -XX:SurviorRatio=32 \
    -XX:+PerfDisableSharedMem \
    -XX:MaxTenuringThreshold=1 \
    -Dusing.aikars.flags=https://mcflags.emc.gs \
    -Daikars.new.flags=true \
    -jar "${JAR_FILE}" --nogui
