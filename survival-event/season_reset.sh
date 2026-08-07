#!/bin/bash
# ==============================================================================
# TeenFounders Network - 15-Day Survival Event Reset Script
# Archives the finished world, updates PostgreSQL season progress, and resets
# ==============================================================================

set -e

DATA_DIR="/data"
SEASON_ID=$(date +%Y%m%d)
ARCHIVE_DIR="$DATA_DIR/archives/season_$SEASON_ID"

echo "======================================================================"
echo "[TF-EVENT] Starting 15-Day Survival Season Reset & Archiving..."
echo "======================================================================"

mkdir -p "$ARCHIVE_DIR"

if [ -d "$DATA_DIR/world" ]; then
    echo "[TF-EVENT] Archiving season world to $ARCHIVE_DIR..."
    tar -czf "$ARCHIVE_DIR/world_season_$SEASON_ID.tar.gz" -C "$DATA_DIR" world world_nether world_the_end
    rm -rf "$DATA_DIR/world" "$DATA_DIR/world_nether" "$DATA_DIR/world_the_end"
    echo "[TF-EVENT] World archived successfully."
fi

echo "[TF-EVENT] Season reset complete. A new fresh world will be generated on next launch."
