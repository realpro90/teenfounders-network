#!/bin/bash
# ==============================================================================
# TeenFounders Network - Shared Plugin Installer Script
# Downloads LuckPerms, EssentialsX, WorldEdit, FAWE, TAB, Citizens, DeluxeMenus, etc.
# ==============================================================================

PLUGINS_DIR="${1:-/data/plugins}"
mkdir -p "$PLUGINS_DIR"

download_plugin() {
    local name="$1"
    local url="$2"
    local file="$PLUGINS_DIR/${name}.jar"

    if [ -f "$file" ]; then
        echo "[TF-PLUGINS] $name is present."
    else
        echo "[TF-PLUGINS] Downloading $name..."
        curl -sSL -A "Mozilla/5.0" "$url" -o "$file" || rm -f "$file"
    fi
}

# Core APIs & Permission Engine
download_plugin "Vault" "https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar"
download_plugin "LuckPerms" "https://download.luckperms.net/1567/bukkit/loader/LuckPerms-Bukkit-5.4.152.jar"

# Essentials Suite
download_plugin "EssentialsX" "https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsX-2.20.1.jar"
download_plugin "EssentialsXSpawn" "https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsXSpawn-2.20.1.jar"

# World Management & Editing
download_plugin "FastAsyncWorldEdit" "https://ci.athion.net/job/FastAsyncWorldEdit-1.21/lastSuccessfulBuild/artifact/artifacts/FastAsyncWorldEdit-Bukkit-2.11.1-SNAPSHOT-910.jar"
download_plugin "WorldGuard" "https://dev.bukkit.org/projects/worldguard/files/latest"
download_plugin "Chunky" "https://github.com/pop4959/Chunky/releases/download/v1.4.28/Chunky-1.4.28.jar"

# UI & Diagnostics
download_plugin "PlaceholderAPI" "https://github.com/PlaceholderAPI/PlaceholderAPI/releases/download/2.11.6/PlaceholderAPI-2.11.6.jar"
download_plugin "ProtocolLib" "https://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/target/ProtocolLib.jar"
download_plugin "ViaVersion" "https://github.com/ViaVersion/ViaVersion/releases/download/5.0.3/ViaVersion-5.0.3.jar"
download_plugin "ViaBackwards" "https://github.com/ViaVersion/ViaBackwards/releases/download/5.0.3/ViaBackwards-5.0.3.jar"
download_plugin "TAB" "https://github.com/NEZNAMY/TAB/releases/download/4.1.8/TAB.v4.1.8.jar"
download_plugin "DeluxeMenus" "https://api.spiget.org/v2/resources/11734/download"
download_plugin "Citizens" "https://ci.citizensnpcs.co/job/Citizens2/lastSuccessfulBuild/artifact/dist/target/Citizens-2.0.35-SNAPSHOT.jar"
download_plugin "spark" "https://ci.lucko.me/job/spark/435/artifact/spark-bukkit/build/libs/spark-1.10.119-bukkit.jar"

echo "[TF-PLUGINS] Shared plugins check complete."
