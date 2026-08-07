# ══════════════════════════════════════════════════════════════════
# TeenFounders Build Network — Lobby Initialisation
# Runs once on world load. Builds the central plaza & structures.
# ══════════════════════════════════════════════════════════════════

# --- Announce ---
say §6§l[TeenFounders] §fLobby Provisioning System loading...

# --- Force Load Lobby Chunks ---
forceload add -100 -100 100 100

# --- Game Rules for Lobby ---
gamerule doDaylightCycle false
gamerule doWeatherCycle false
gamerule doMobSpawning false
gamerule doFireTick false
gamerule mobGriefing false
gamerule keepInventory true
gamerule announceAdvancements false
gamerule disableRaids true
gamerule doInsomnia false
gamerule doPatrolSpawning false
gamerule doTraderSpawning false
gamerule doWardenSpawning false
gamerule randomTickSpeed 0
gamerule spawnRadius 0
gamerule showDeathMessages false
gamerule commandBlockOutput false

# --- Lock time to golden hour ---
time set 6000

# --- Set world border ---
worldborder center 0 0
worldborder set 500

# --- Set spawn ---
setworldspawn 0 65 0

# --- Build the lobby ---
function tf:build_plaza
function tf:build_portals
function tf:build_decorations
function tf:setup_spawn_experience

say §6§l[TeenFounders] §a✓ §fLobby build complete!
