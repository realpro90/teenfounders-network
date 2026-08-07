#!/bin/bash
# ==============================================================================
# TeenFounders Network - Automated 500x500 Lobby Provisioner & Builder
# Forces clean replacement of badlands/vanilla terrain with TeenFounders Lobby
# ==============================================================================

set -e

DATA_DIR="${1:-/data}"
WORLD_DIR="$DATA_DIR/world"

echo "======================================================================"
echo "[TF-LOBBY] Resetting and Provisioning TeenFounders 500x500 Lobby World..."
echo "======================================================================"

# 1. Force wipe old vanilla badlands/mesa terrain to ensure clean Lobby load
echo "[TF-LOBBY] Removing old terrain files..."
rm -rf "$WORLD_DIR"
mkdir -p "$WORLD_DIR"
mkdir -p "$WORLD_DIR/region"
mkdir -p "$WORLD_DIR/data"

# 2. Configure Flat Lobby Generator Settings in server.properties
touch "$DATA_DIR/server.properties"
sed -i 's/^level-type=.*/level-type=minecraft\\:flat/' "$DATA_DIR/server.properties" 2>/dev/null || echo "level-type=minecraft\\:flat" >> "$DATA_DIR/server.properties"
sed -i 's/^generator-settings=.*/generator-settings={"layers":[{"block":"minecraft:bedrock","height":1},{"block":"minecraft:blackstone","height":5},{"block":"minecraft:smooth_quartz","height":1}],"biome":"minecraft:plains"}/' "$DATA_DIR/server.properties" 2>/dev/null || echo 'generator-settings={"layers":[{"block":"minecraft:bedrock","height":1},{"block":"minecraft:blackstone","height":5},{"block":"minecraft:smooth_quartz","height":1}],"biome":"minecraft:plains"}' >> "$DATA_DIR/server.properties"
sed -i 's/^spawn-protection=.*/spawn-protection=0/' "$DATA_DIR/server.properties" 2>/dev/null || echo "spawn-protection=0" >> "$DATA_DIR/server.properties"

# 3. Download & Unpack 500x500 Production Lobby Structure
LOBBY_URL="https://github.com/realpro90/teenfounders-network/releases/download/v1.0.0/teenfounders-lobby-world.tar.gz"

echo "[TF-LOBBY] Downloading 500x500 Lobby Map Archive from $LOBBY_URL..."
curl -sSL "$LOBBY_URL" -o /tmp/lobby-world.tar.gz 2>/dev/null || true

if [ -f "/tmp/lobby-world.tar.gz" ] && [ $(wc -c </tmp/lobby-world.tar.gz 2>/dev/null || echo 0) -gt 500000 ]; then
    echo "[TF-LOBBY] Extracting 500x500 Production Lobby Map into $WORLD_DIR..."
    tar -xzf /tmp/lobby-world.tar.gz -C "$WORLD_DIR"
    rm -f /tmp/lobby-world.tar.gz
fi

# 4. Lock Spawn Coordinates at Central Plaza (0.5, 65.0, 0.5)
mkdir -p "$DATA_DIR/plugins/Essentials"
cat << 'EOF' > "$DATA_DIR/plugins/Essentials/spawn.yml"
spawns:
  default:
    world: world
    x: 0.5
    y: 65.0
    z: 0.5
    yaw: 0.0
    pitch: 0.0
EOF

echo "[TF-LOBBY] Spawn point locked at Central Plaza (0.5, 65.0, 0.5)."
echo "======================================================================"
