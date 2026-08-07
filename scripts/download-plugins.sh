#!/bin/bash
# ==============================================================================
# TeenFounders Build Network - Automated Plugin Installer Script
# Downloads production-grade plugins compatible with PaperMC 1.21.11 / Java 21
# ==============================================================================

PLUGINS_DIR="${1:-/data/plugins}"
mkdir -p "$PLUGINS_DIR"

echo "======================================================================"
echo "[TF-SETUP] Checking & Downloading Production Plugins into $PLUGINS_DIR"
echo "======================================================================"

download_plugin() {
    local name="$1"
    local url="$2"
    local file="$PLUGINS_DIR/${name}.jar"

    if [ -f "$file" ]; then
        echo "[TF-PLUGINS] $name is already installed. Skipping download."
    else
        echo "[TF-PLUGINS] Downloading $name from $url..."
        curl -sSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$url" -o "$file"
        if [ $? -eq 0 ] && [ -s "$file" ]; then
            echo "[TF-PLUGINS] Successfully downloaded $name."
        else
            echo "[TF-PLUGINS] ERROR downloading $name. Will retry or rely on mounted configuration."
            rm -f "$file"
        fi
    fi
}

# 1. Vault (Permissions & Economy API abstraction)
download_plugin "Vault" "https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar"

# 2. LuckPerms (Modern Permissions Plugin)
download_plugin "LuckPerms" "https://download.luckperms.net/1567/bukkit/loader/LuckPerms-Bukkit-5.4.152.jar"

# 3. EssentialsX Suite (Core Commands, Spawn, Warps)
download_plugin "EssentialsX" "https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsX-2.20.1.jar"
download_plugin "EssentialsXSpawn" "https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsXSpawn-2.20.1.jar"

# 4. WorldEdit & FastAsyncWorldEdit (FAWE)
download_plugin "FastAsyncWorldEdit" "https://ci.athion.net/job/FastAsyncWorldEdit-1.21/lastSuccessfulBuild/artifact/artifacts/FastAsyncWorldEdit-Bukkit-2.11.1-SNAPSHOT-910.jar"

# 5. WorldGuard (Region Protection)
download_plugin "WorldGuard" "https://dev.bukkit.org/projects/worldguard/files/latest"

# 6. CoreProtect (Anti-Griefing & Rollback Logging)
download_plugin "CoreProtect" "https://download.patreon.com/CoreProtect-22.4.jar"

# 7. Chunky (World Pre-generation)
download_plugin "Chunky" "https://github.com/pop4959/Chunky/releases/download/v1.4.28/Chunky-1.4.28.jar"

# 8. spark (Performance Profiler & Diagnostics)
download_plugin "spark" "https://ci.lucko.me/job/spark/435/artifact/spark-bukkit/build/libs/spark-1.10.119-bukkit.jar"

# 9. PlaceholderAPI (Custom Variables & DeluxeMenus Integration)
download_plugin "PlaceholderAPI" "https://github.com/PlaceholderAPI/PlaceholderAPI/releases/download/2.11.6/PlaceholderAPI-2.11.6.jar"

# 10. ProtocolLib (Packet Interception Engine)
download_plugin "ProtocolLib" "https://ci.dmulloy2.net/job/ProtocolLib/lastSuccessfulBuild/artifact/target/ProtocolLib.jar"

# 11. ViaVersion & ViaBackwards (Version Backward & Forward Compatibility)
download_plugin "ViaVersion" "https://github.com/ViaVersion/ViaVersion/releases/download/5.0.3/ViaVersion-5.0.3.jar"
download_plugin "ViaBackwards" "https://github.com/ViaVersion/ViaBackwards/releases/download/5.0.3/ViaBackwards-5.0.3.jar"

# 12. TAB (Tablist, Nametags & Scoreboards)
download_plugin "TAB" "https://github.com/NEZNAMY/TAB/releases/download/4.1.8/TAB.v4.1.8.jar"

# 13. DeluxeMenus (Custom GUI Menus)
download_plugin "DeluxeMenus" "https://api.spiget.org/v2/resources/11734/download"

# 14. Citizens (NPC Engine)
download_plugin "Citizens" "https://ci.citizensnpcs.co/job/Citizens2/lastSuccessfulBuild/artifact/dist/target/Citizens-2.0.35-SNAPSHOT.jar"

# 15. DiscordSRV (Discord Integration)
download_plugin "DiscordSRV" "https://github.com/DiscordSRV/DiscordSRV/releases/download/v1.29.0/DiscordSRV-Build-1.29.0.jar"

# 16. Geyser + Floodgate (Optional Bedrock Cross-Play Engine)
download_plugin "Geyser-Spigot" "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
download_plugin "Floodgate" "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot"

echo "======================================================================"
echo "[TF-SETUP] Plugin installation complete!"
echo "======================================================================"
