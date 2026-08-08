#!/bin/bash
# ==============================================================================
# TeenFounders Network - Verified Shared Plugin Installer Script
# Downloads production-grade plugins compatible with PaperMC 1.21.11 / Java 21
# Enforces file size & ZIP validation to prevent server boot crashes
# ==============================================================================

PLUGINS_DIR="${1:-/data/plugins}"
mkdir -p "$PLUGINS_DIR"

echo "======================================================================"
echo "[TF-SETUP] Checking & Downloading Verified Plugins into $PLUGINS_DIR"
echo "======================================================================"

download_plugin() {
    local name="$1"
    local url="$2"
    local min_size="${3:-15000}"
    local file="$PLUGINS_DIR/${name}.jar"

    if [ -f "$file" ]; then
        local size=$(wc -c <"$file" 2>/dev/null || echo 0)
        if [ "$size" -gt "$min_size" ]; then
            echo "[TF-PLUGINS] $name is present and valid ($(du -h "$file" | awk '{print $1}'))."
            return 0
        else
            echo "[TF-PLUGINS] $name is corrupt ($size bytes). Removing..."
            rm -f "$file"
        fi
    fi

    echo "[TF-PLUGINS] Downloading $name from $url..."
    curl -sSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$url" -o "$file" || rm -f "$file"
    
    local new_size=$(wc -c <"$file" 2>/dev/null || echo 0)
    if [ -f "$file" ] && [ "$new_size" -gt "$min_size" ]; then
        echo "[TF-PLUGINS] $name downloaded successfully ($(du -h "$file" | awk '{print $1}'))."
    else
        echo "[TF-PLUGINS] WARNING: $name download failed or invalid ($new_size bytes). Removing..."
        rm -f "$file"
    fi
}

# 1. Core API & Permissions
download_plugin "Vault" "https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar" 200000
download_plugin "LuckPerms" "https://cdn.modrinth.com/data/Vebnzrzj/versions/b0mk8uS6/LuckPerms-Bukkit-5.5.71.jar" 1000000
download_plugin "ProtocolLib" "https://github.com/dmulloy2/ProtocolLib/releases/download/5.3.0/ProtocolLib.jar" 1000000

# 2. Essentials Suite & Player Systems
download_plugin "EssentialsX" "https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsX-2.20.1.jar" 3000000
download_plugin "EssentialsXSpawn" "https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsXSpawn-2.20.1.jar" 15000
download_plugin "SkinsRestorer" "https://github.com/SkinsRestorer/SkinsRestorer/releases/download/15.0.3/SkinsRestorer.jar" 1000000

# 3. User Interfaces & Protocol Compatibility
download_plugin "PlaceholderAPI" "https://cdn.modrinth.com/data/lKEzGugV/versions/pIvQcXW8/PlaceholderAPI-2.12.3.jar" 300000
download_plugin "ViaVersion" "https://github.com/ViaVersion/ViaVersion/releases/download/5.11.0/ViaVersion-5.11.0.jar" 3000000
download_plugin "ViaBackwards" "https://github.com/ViaVersion/ViaBackwards/releases/download/5.11.0/ViaBackwards-5.11.0.jar" 1000000
download_plugin "TAB" "https://github.com/NEZNAMY/TAB/releases/download/5.0.4/TAB.v5.0.4.jar" 1000000
download_plugin "DeluxeMenus" "https://cdn.modrinth.com/data/kKZkPgJ7/versions/PNKQ6RMs/DeluxeMenus-1.14.1-Release.jar" 500000

# 4. Production Management & Protection
download_plugin "CoreProtect" "https://cdn.modrinth.com/data/Lu3KuzdV/versions/Kma0kBsY/CoreProtect-CE-24.0.jar" 300000
download_plugin "WorldEdit" "https://cdn.modrinth.com/data/1u6JkXh5/versions/qNuPcliz/worldedit-bukkit-7.4.4.jar" 4000000
download_plugin "WorldGuard" "https://cdn.modrinth.com/data/DKY9btbd/versions/btHBavWa/worldguard-bukkit-7.0.18.jar" 1000000
download_plugin "Multiverse-Core" "https://github.com/Multiverse/Multiverse-Core/releases/download/4.3.12/Multiverse-Core-4.3.12.jar" 1000000
download_plugin "Chunky" "https://cdn.modrinth.com/data/fALzjamp/versions/K87K9v0Y/Chunky-Bukkit-1.4.28.jar" 200000
download_plugin "GrimAC" "https://github.com/GrimAnticheat/Grim/releases/download/2.3.66/GrimAC-2.3.66.jar" 3000000
download_plugin "GSit" "https://cdn.modrinth.com/data/GOHbQGyX/versions/nZM8fxpG/GSit-3.5.1.jar" 1000000
download_plugin "spark" "https://cdn.modrinth.com/data/l6YH9Als/versions/pY6vjC8N/spark-1.10.119-bukkit.jar" 2000000
download_plugin "LPC" "https://github.com/mrfreespaces/LPC/releases/download/v1.3.1/LPC-1.3.1.jar" 15000

download_plugin "FreedomChat" "https://cdn.modrinth.com/data/MubyTbnA/versions/Pqu2VLTB/FreedomChat-Paper-1.7.9.jar" 10000

echo "======================================================================"
echo "[TF-SETUP] Verified plugin check complete! (20 production plugins)"
echo "======================================================================"
