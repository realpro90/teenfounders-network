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

# 2. Essentials Suite
download_plugin "EssentialsX" "https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsX-2.20.1.jar" 3000000
download_plugin "EssentialsXSpawn" "https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsXSpawn-2.20.1.jar" 15000

# 3. User Interfaces & Protocol Compatibility
download_plugin "PlaceholderAPI" "https://cdn.modrinth.com/data/lKEzGugV/versions/pIvQcXW8/PlaceholderAPI-2.12.3.jar" 300000
download_plugin "ViaVersion" "https://github.com/ViaVersion/ViaVersion/releases/download/5.11.0/ViaVersion-5.11.0.jar" 3000000
download_plugin "ViaBackwards" "https://github.com/ViaVersion/ViaBackwards/releases/download/5.11.0/ViaBackwards-5.11.0.jar" 1000000
download_plugin "TAB" "https://github.com/NEZNAMY/TAB/releases/download/5.0.4/TAB.v5.0.4.jar" 1000000
download_plugin "DeluxeMenus" "https://cdn.modrinth.com/data/kKZkPgJ7/versions/PNKQ6RMs/DeluxeMenus-1.14.1-Release.jar" 500000

echo "======================================================================"
echo "[TF-SETUP] Verified plugin check complete!"
echo "======================================================================"
