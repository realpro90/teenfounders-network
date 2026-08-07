#!/bin/bash
# ==============================================================================
# TeenFounders Network - 15-Day Survival Championship Engine
# Handles 15-day season lifecycle, FINALE phase, shrinking arena border,
# winner determination, PostgreSQL archiving, and TeenFounders Verification Tokens.
# ==============================================================================

set -e

DATA_DIR="/data"
DB_HOST="${DB_HOST:-postgres}"
DB_NAME="${DB_NAME:-teenfounders_mc}"
DB_USER="${DB_USER:-tf_admin}"
DB_PASS="${DB_PASSWORD:-TeenFoundersSecretPassword2026!}"

export PGPASSWORD="$DB_PASS"

echo "======================================================================"
echo "          🏆 TEENFOUNDERS SURVIVAL CHAMPIONSHIP MANAGER 🏆          "
echo "                 Website: https://teenfounders.in                     "
echo "======================================================================"

# 1. Fetch current active season or initialize Season 1
CURRENT_SEASON=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c \
    "SELECT season_id FROM championship_seasons WHERE status != 'COMPLETED' ORDER BY season_id DESC LIMIT 1;" | tr -d '[:space:]')

if [ -z "$CURRENT_SEASON" ]; then
    echo "[TF-CHAMP] No active season found. Initializing Season 1..."
    END_TIME=$(date -d "+15 days" --iso-8601=seconds 2>/dev/null || date -v+15d +"%Y-%m-%dT%H:%M:%S%z")
    CURRENT_SEASON=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c \
        "INSERT INTO championship_seasons (season_name, end_time, status) VALUES ('Season 1: Entrepreneur Survival', '$END_TIME', 'ACTIVE') RETURNING season_id;" | tr -d '[:space:]')
    echo "[TF-CHAMP] Created Season $CURRENT_SEASON (Ends: $END_TIME)."
fi

echo "[TF-CHAMP] Active Season ID: $CURRENT_SEASON"

# 2. Check Season Status
SEASON_STATUS=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c \
    "SELECT status FROM championship_seasons WHERE season_id = $CURRENT_SEASON;" | tr -d '[:space:]')

if [ "$SEASON_STATUS" == "ACTIVE" ]; then
    echo "[TF-CHAMP] Season $CURRENT_SEASON is currently ACTIVE. Monitoring 15-day timeline..."
fi

# Function to execute FINALE Phase
trigger_finale() {
    echo "[TF-CHAMP] 15-Day Timer Completed! Triggering FINALE Championship Phase..."

    # Update database status to FINALE
    psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c \
        "UPDATE championship_seasons SET status = 'FINALE' WHERE season_id = $CURRENT_SEASON;"

    # Lock server to new joins via whitelist
    echo "[TF-CHAMP] Locking server joins..."
    rcon-cli "whitelist on" || true
    rcon-cli "title @a title {\"text\":\"SURVIVAL CHAMPIONSHIP FINALE\",\"color\":\"gold\",\"bold\":true}" || true
    rcon-cli "title @a subtitle {\"text\":\"Teleporting to Final Battle Arena in 10s...\",\"color\":\"yellow\"}" || true

    sleep 10

    # Teleport remaining players to arena center (0, 64, 0)
    rcon-cli "tp @a 0 64 0" || true
    rcon-cli "gamemode survival @a" || true
    rcon-cli "effect give @a minecraft:instant_health 5 255 true" || true

    # Initialize World Border for Arena
    rcon-cli "worldborder center 0 0" || true
    rcon-cli "worldborder set 200" || true
    
    rcon-cli "broadcast §6§l[TF-CHAMPIONSHIP] §fThe Final Arena Battle has begun!"
    rcon-cli "broadcast §c§l[TF-CHAMPIONSHIP] §fThe World Border is shrinking from 200 to 1 block over 180 seconds!"

    # Shrink world border to 1 block over 3 minutes
    rcon-cli "worldborder set 1 180" || true
}

# Function to record champion and generate website verification token
record_winner() {
    local WINNER_UUID="$1"
    local WINNER_NAME="$2"

    echo "[TF-CHAMP] CROWNING CHAMPION: $WINNER_NAME ($WINNER_UUID)"

    # Generate Cryptographic Verification Token (TF-CHAMP-SEASON_<id>-<uuid_short>-<hash>)
    HASH_SALT=$(date +%s%N)
    RAW_TOKEN="TF-CHAMP-S${CURRENT_SEASON}-${WINNER_UUID}-${HASH_SALT}"
    VERIFICATION_TOKEN=$(echo -n "$RAW_TOKEN" | md5sum | awk '{print $1}')
    FINAL_TOKEN="TF-CHAMP-S${CURRENT_SEASON}-${VERIFICATION_TOKEN:0:16}"

    # Insert into PostgreSQL
    psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c \
        "INSERT INTO championship_winners (season_id, winner_uuid, verification_token) VALUES ($CURRENT_SEASON, '$WINNER_UUID', '$FINAL_TOKEN');"

    psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c \
        "UPDATE championship_seasons SET status = 'COMPLETED', winner_uuid = '$WINNER_UUID', verification_token = '$FINAL_TOKEN' WHERE season_id = $CURRENT_SEASON;"

    # Announce in-game
    rcon-cli "title @a title {\"text\":\"SEASON $CURRENT_SEASON CHAMPION\",\"color\":\"gold\",\"bold\":true}" || true
    rcon-cli "title @a subtitle {\"text\":\"$WINNER_NAME\",\"color\":\"yellow\",\"bold\":true}" || true

    rcon-cli "broadcast §6§l=================================================="
    rcon-cli "broadcast §6§l   TEENFOUNDERS SURVIVAL CHAMPION DECLARED!"
    rcon-cli "broadcast §f   Winner: §e$WINNER_NAME"
    rcon-cli "broadcast §f   Verification Token: §a$FINAL_TOKEN"
    rcon-cli "broadcast §7   Submit your token at §ehttps://teenfounders.in §7to claim your Official Certificate!"
    rcon-cli "broadcast §6§l=================================================="

    echo "[TF-CHAMP] Token generated: $FINAL_TOKEN. Archived in PostgreSQL."
}

# Check command line arguments for manual triggers
case "$1" in
    "finale")
        trigger_finale
        ;;
    "winner")
        record_winner "$2" "$3"
        ;;
    *)
        echo "[TF-CHAMP] Management script initialized."
        ;;
esac
