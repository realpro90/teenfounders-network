# ══════════════════════════════════════════════════════════════════
# TeenFounders Lobby — Tick Function (runs every game tick)
# Handles player join detection, title animation, adventure mode
# ══════════════════════════════════════════════════════════════════

# ─── New Player Join Detection ───────────────────────────────────
# Players with tf_joined score of 0 are new joiners
execute as @a[scores={tf_joined=0}] run function tf:on_player_join

# ─── Enforce Adventure Mode ──────────────────────────────────────
gamemode adventure @a[gamemode=!adventure]
