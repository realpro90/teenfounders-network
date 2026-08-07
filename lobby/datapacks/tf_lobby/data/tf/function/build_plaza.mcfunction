# ══════════════════════════════════════════════════════════════════
# TeenFounders Lobby — Central Plaza Construction
# 500×500 lobby with Quartz/Orange/Blackstone palette
# ══════════════════════════════════════════════════════════════════

# ─── Ground Layer: Main Platform ─────────────────────────────────
# Central 80×80 plaza — smooth quartz base
fill -40 63 -40 40 63 40 smooth_quartz
fill -40 62 -40 40 62 40 blackstone
fill -40 61 -40 40 61 40 deepslate

# Outer ring — orange concrete accent border
fill -42 63 -42 42 63 -41 orange_concrete
fill -42 63 41 42 63 42 orange_concrete
fill -42 63 -40 -41 63 40 orange_concrete
fill 41 63 -40 42 63 40 orange_concrete

# Second accent ring — polished blackstone
fill -44 63 -44 44 63 -43 polished_blackstone
fill -44 63 43 44 63 44 polished_blackstone
fill -44 63 -42 -43 63 42 polished_blackstone
fill 43 63 -42 44 63 42 polished_blackstone

# Extended walkways — N/S/E/W paths
fill -3 63 -40 3 63 -80 smooth_quartz
fill -3 63 40 3 63 80 smooth_quartz
fill -80 63 -3 -40 63 3 smooth_quartz
fill 40 63 -3 80 63 3 smooth_quartz

# Walkway orange stripe accents
fill -1 63 -41 1 63 -80 orange_concrete
fill -1 63 41 1 63 80 orange_concrete
fill -41 63 -1 -80 63 1 orange_concrete
fill 41 63 -1 80 63 1 orange_concrete

# ─── Central Monument: TeenFounders Beacon Tower ─────────────────
# Base pedestal — 7×7 polished blackstone
fill -3 64 -3 3 64 3 polished_blackstone_bricks
fill -2 65 -2 2 65 2 polished_blackstone
fill -1 66 -1 1 66 1 smooth_quartz

# Beacon core
setblock 0 67 0 beacon
setblock 0 66 0 iron_block

# Beacon pyramid (iron blocks)
fill -1 63 -1 1 63 1 iron_block
fill -2 62 -2 2 62 2 iron_block

# Vertical pillars — Orange glass panes rising from pedestal
fill -3 64 -3 -3 72 -3 orange_stained_glass
fill 3 64 -3 3 72 -3 orange_stained_glass
fill -3 64 3 -3 72 3 orange_stained_glass
fill 3 64 3 3 72 3 orange_stained_glass

# Cap pillars with sea lanterns
setblock -3 73 -3 sea_lantern
setblock 3 73 -3 sea_lantern
setblock -3 73 3 sea_lantern
setblock 3 73 3 sea_lantern

# Cross beams connecting pillars at top
fill -3 72 -3 3 72 -3 quartz_slab[type=top]
fill -3 72 3 3 72 3 quartz_slab[type=top]
fill -3 72 -3 -3 72 3 quartz_slab[type=top]
fill 3 72 -3 3 72 3 quartz_slab[type=top]

# ─── Floating "TF" Logo above beacon ────────────────────────────
# T letter (3 wide, 5 tall) at y=78
fill -3 82 0 3 82 0 orange_concrete
fill 0 78 0 0 82 0 orange_concrete

# ─── Surrounding Water Features ─────────────────────────────────
# Decorative pools at each corner of the plaza
fill -38 63 -38 -35 63 -35 water
fill 35 63 -38 38 63 -35 water
fill -38 63 35 -35 63 38 water
fill 35 63 35 38 63 38 water

# Pool borders — quartz walls
fill -39 64 -39 -34 64 -34 quartz_slab[type=bottom]
fill 34 64 -39 39 64 -34 quartz_slab[type=bottom]
fill -39 64 34 -34 64 39 quartz_slab[type=bottom]
fill 34 64 34 39 64 39 quartz_slab[type=bottom]

# ─── Lighting ────────────────────────────────────────────────────
# Sea lantern grid embedded in plaza floor (every 8 blocks)
setblock -16 63 -16 sea_lantern
setblock -16 63 0 sea_lantern
setblock -16 63 16 sea_lantern
setblock 0 63 -16 sea_lantern
setblock 0 63 16 sea_lantern
setblock 16 63 -16 sea_lantern
setblock 16 63 0 sea_lantern
setblock 16 63 16 sea_lantern

# Additional floor lighting
setblock -8 63 -8 sea_lantern
setblock -8 63 8 sea_lantern
setblock 8 63 -8 sea_lantern
setblock 8 63 8 sea_lantern
setblock -24 63 -24 sea_lantern
setblock -24 63 24 sea_lantern
setblock 24 63 -24 sea_lantern
setblock 24 63 24 sea_lantern
setblock -32 63 0 sea_lantern
setblock 32 63 0 sea_lantern
setblock 0 63 -32 sea_lantern
setblock 0 63 32 sea_lantern

# Lantern posts along walkways
setblock -3 64 -50 polished_blackstone_wall
setblock -3 65 -50 lantern[hanging=false]
setblock 3 64 -50 polished_blackstone_wall
setblock 3 65 -50 lantern[hanging=false]
setblock -3 64 -60 polished_blackstone_wall
setblock -3 65 -60 lantern[hanging=false]
setblock 3 64 -60 polished_blackstone_wall
setblock 3 65 -60 lantern[hanging=false]
setblock -3 64 50 polished_blackstone_wall
setblock -3 65 50 lantern[hanging=false]
setblock 3 64 50 polished_blackstone_wall
setblock 3 65 50 lantern[hanging=false]
setblock -3 64 60 polished_blackstone_wall
setblock -3 65 60 lantern[hanging=false]
setblock 3 64 60 polished_blackstone_wall
setblock 3 65 60 lantern[hanging=false]

# ─── Trees & Greenery ───────────────────────────────────────────
# Place 4 custom oak trees at plaza corners
setblock -30 64 -30 oak_log
fill -30 65 -30 -30 69 -30 oak_log
fill -33 69 -33 -27 69 -27 oak_leaves[persistent=true]
fill -32 70 -32 -28 70 -28 oak_leaves[persistent=true]
fill -31 71 -31 -29 71 -29 oak_leaves[persistent=true]

setblock 30 64 -30 oak_log
fill 30 65 -30 30 69 -30 oak_log
fill 27 69 -33 33 69 -27 oak_leaves[persistent=true]
fill 28 70 -32 32 70 -28 oak_leaves[persistent=true]
fill 29 71 -31 31 71 -29 oak_leaves[persistent=true]

setblock -30 64 30 oak_log
fill -30 65 30 -30 69 30 oak_log
fill -33 69 27 -27 69 33 oak_leaves[persistent=true]
fill -32 70 28 -28 70 32 oak_leaves[persistent=true]
fill -31 71 29 -29 71 31 oak_leaves[persistent=true]

setblock 30 64 30 oak_log
fill 30 65 30 30 69 30 oak_log
fill 27 69 27 33 69 33 oak_leaves[persistent=true]
fill 28 70 28 32 70 32 oak_leaves[persistent=true]
fill 29 71 29 31 71 31 oak_leaves[persistent=true]

# Grass and flowers around trees
fill -33 64 -33 -27 64 -27 grass_block
fill 27 64 -33 33 64 -27 grass_block
fill -33 64 27 -27 64 33 grass_block
fill 27 64 27 33 64 33 grass_block
