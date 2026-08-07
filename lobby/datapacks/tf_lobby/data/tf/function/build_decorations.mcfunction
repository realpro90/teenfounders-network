# ══════════════════════════════════════════════════════════════════
# TeenFounders Lobby — Decorations & Ambiance
# Benches, fences, flowers, info boards, floating islands
# ══════════════════════════════════════════════════════════════════

# ─── Garden Patches ──────────────────────────────────────────────
# NE garden
fill 15 64 -25 22 64 -18 grass_block
setblock 17 65 -21 poppy
setblock 19 65 -22 orange_tulip
setblock 20 65 -19 dandelion
setblock 16 65 -20 cornflower
setblock 21 65 -23 allium

# NW garden
fill -22 64 -25 -15 64 -18 grass_block
setblock -17 65 -21 orange_tulip
setblock -19 65 -22 poppy
setblock -20 65 -19 dandelion
setblock -16 65 -20 cornflower
setblock -21 65 -23 allium

# SE garden
fill 15 64 18 22 64 25 grass_block
setblock 17 65 21 poppy
setblock 19 65 22 orange_tulip
setblock 20 65 19 dandelion
setblock 16 65 20 blue_orchid
setblock 21 65 23 allium

# SW garden
fill -22 64 18 -15 64 25 grass_block
setblock -17 65 21 orange_tulip
setblock -19 65 22 poppy
setblock -20 65 19 dandelion
setblock -16 65 20 blue_orchid
setblock -21 65 23 allium

# ─── Benches (quartz stairs) ────────────────────────────────────
setblock -12 64 -12 quartz_stairs[facing=south]
setblock -11 64 -12 quartz_stairs[facing=south]
setblock 11 64 -12 quartz_stairs[facing=south]
setblock 12 64 -12 quartz_stairs[facing=south]
setblock -12 64 12 quartz_stairs[facing=north]
setblock -11 64 12 quartz_stairs[facing=north]
setblock 11 64 12 quartz_stairs[facing=north]
setblock 12 64 12 quartz_stairs[facing=north]

# ─── Information Boards ─────────────────────────────────────────
# Community board near spawn
setblock 8 65 5 oak_wall_sign[facing=west]{front_text:{messages:['{"text":"§6§lTeenFounders","bold":true}','{"text":"§fBuild Network","color":"white"}','{"text":"§7teenfounders.in","color":"gray"}','{"text":"§eJoin our Discord!","color":"yellow"}']}}

setblock -8 65 5 oak_wall_sign[facing=east]{front_text:{messages:['{"text":"§6§lRules","bold":true}','{"text":"§f1. Be Respectful","color":"white"}','{"text":"§f2. No Griefing","color":"white"}','{"text":"§f3. Have Fun!","color":"white"}']}}

setblock 8 65 -5 oak_wall_sign[facing=west]{front_text:{messages:['{"text":"§6§lTop Builders","bold":true}','{"text":"§e#1 §f—","color":"white"}','{"text":"§e#2 §f—","color":"white"}','{"text":"§e#3 §f—","color":"white"}']}}

# ─── Floating Island (decorative) ────────────────────────────────
# Small floating island at y=85
fill -8 84 -55 8 84 -45 grass_block
fill -7 83 -54 7 83 -46 dirt
fill -6 82 -53 6 82 -47 stone
fill -4 81 -52 4 81 -48 stone
fill -2 80 -51 2 80 -49 cobblestone

# Tree on floating island
fill 0 85 -50 0 89 -50 oak_log
fill -2 89 -52 2 89 -48 oak_leaves[persistent=true]
fill -1 90 -51 1 90 -49 oak_leaves[persistent=true]
setblock 0 91 -50 oak_leaves[persistent=true]

# Waterfall from floating island
fill 3 78 -50 3 84 -50 water

# ─── Perimeter Walls (low decorative border) ─────────────────────
# Outer boundary fencing at ±90 blocks
fill -90 64 -90 90 64 -90 polished_blackstone_wall
fill -90 64 90 90 64 90 polished_blackstone_wall
fill -90 64 -90 -90 64 90 polished_blackstone_wall
fill 90 64 -90 90 64 90 polished_blackstone_wall

# Corner towers
fill -90 64 -90 -88 68 -88 polished_blackstone_bricks
fill 88 64 -90 90 68 -88 polished_blackstone_bricks
fill -90 64 88 -88 68 90 polished_blackstone_bricks
fill 88 64 88 90 68 90 polished_blackstone_bricks

setblock -89 69 -89 sea_lantern
setblock 89 69 -89 sea_lantern
setblock -89 69 89 sea_lantern
setblock 89 69 89 sea_lantern

# ─── Particle Emitters (armor stands with tags) ─────────────────
# Note: Particle effects need a plugin; armor stands mark positions
summon armor_stand 0 65 0 {Invisible:1b,Invulnerable:1b,NoGravity:1b,Tags:["tf_particle_center"],CustomName:'{"text":"§6Beacon Center"}'}
