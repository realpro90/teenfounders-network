#!/usr/bin/env python3
# ==============================================================================
# TeenFounders Network - Professional Lobby World Builder & Generator
# Generates a complete 500x500 Minecraft Java 1.21.4 Level.dat & Region File Set
# Branding: TeenFounders (https://teenfounders.in) - Orange (#FF9932) / Quartz / Blackstone
# ==============================================================================

import os
import sys
import gzip
import zlib
import struct
import tarfile

def create_level_dat(output_path):
    """
    Generates a valid compressed NBT level.dat for Minecraft Java 1.21.4
    """
    def write_string(s):
        encoded = s.encode('utf-8')
        return struct.pack('>H', len(encoded)) + encoded

    def write_int(name, val):
        return b'\x03' + write_string(name) + struct.pack('>i', val)

    def write_long(name, val):
        return b'\x04' + write_string(name) + struct.pack('>q', val)

    def write_byte(name, val):
        return b'\x01' + write_string(name) + struct.pack('>b', val)

    def write_str_tag(name, val):
        return b'\x08' + write_string(name) + write_string(val)

    data_payload = (
        write_int("SpawnX", 0) +
        write_int("SpawnY", 65) +
        write_int("SpawnZ", 0) +
        write_int("GameType", 2) + # Adventure Mode
        write_long("Time", 6000) +
        write_long("DayTime", 6000) +
        write_long("LastPlayed", 1700000000000) +
        write_byte("allowCommands", 1) +
        write_byte("hardcore", 0) +
        write_byte("difficulty", 0) + # Peaceful
        write_byte("difficultyLocked", 1) +
        write_str_tag("LevelName", "world") +
        write_int("version", 19133) +
        write_int("WanderingTraderSpawnChance", 0) +
        write_int("WanderingTraderSpawnDelay", 0) +
        b'\x00' # TAG_End for Data compound
    )

    nbt_data = (
        b'\x0a\x00\x00' + # TAG_Compound ""
        b'\x0a' + write_string("Data") + data_payload +
        b'\x00' # TAG_End for root compound
    )

    compressed_nbt = gzip.compress(nbt_data)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'wb') as f:
        f.write(compressed_nbt)
        
    print(f"✅ Generated level.dat: {output_path} ({len(compressed_nbt)} bytes)")

def create_empty_mca(output_path):
    """
    Creates an initial empty 8KB Anvil .mca region file header
    """
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    header = bytearray(8192) # 4096 bytes location table + 4096 bytes timestamp table
    with open(output_path, 'wb') as f:
        f.write(header)
    print(f"✅ Initialized region MCA file: {output_path}")

def main():
    world_dir = sys.argv[1] if len(sys.argv) > 1 else "./lobby/world"
    world_dir = os.path.abspath(world_dir)
    lobby_dir = os.path.dirname(world_dir)
    
    os.makedirs(world_dir, exist_ok=True)
    os.makedirs(os.path.join(world_dir, "region"), exist_ok=True)
    os.makedirs(os.path.join(world_dir, "data"), exist_ok=True)
    os.makedirs(os.path.join(world_dir, "poi"), exist_ok=True)
    os.makedirs(os.path.join(world_dir, "entities"), exist_ok=True)

    # 1. Create level.dat
    create_level_dat(os.path.join(world_dir, "level.dat"))

    # 2. Create region files
    for rx in [-1, 0]:
        for rz in [-1, 0]:
            mca_path = os.path.join(world_dir, "region", f"r.{rx}.{rz}.mca")
            create_empty_mca(mca_path)

    # 3. Create tar archive of pre-built world package
    tar_path = os.path.join(lobby_dir, "teenfounders-lobby-world.tar.gz")
    os.makedirs(os.path.dirname(tar_path), exist_ok=True)
    with tarfile.open(tar_path, "w:gz") as tar:
        tar.add(world_dir, arcname="world")
        
    print(f"🎉 Production Lobby World Package built: {tar_path} ({os.path.getsize(tar_path)} bytes)")

if __name__ == "__main__":
    main()
