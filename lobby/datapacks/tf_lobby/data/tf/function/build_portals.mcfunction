# ══════════════════════════════════════════════════════════════════
# TeenFounders Lobby — Portal District Construction
# 4 destination portals at N/S/E/W ends of walkways
# ══════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════
# NORTH — Creative Plots Portal (z = -70)
# ═══════════════════════════════════════

# Portal arch — orange concrete frame
fill -4 64 -70 4 64 -70 orange_concrete
fill -4 64 -70 -4 72 -70 orange_concrete
fill 4 64 -70 4 72 -70 orange_concrete
fill -4 72 -70 4 72 -70 orange_concrete

# Portal interior — orange stained glass
fill -3 65 -70 3 71 -70 orange_stained_glass

# Portal platform
fill -5 63 -72 5 63 -68 smooth_quartz
fill -5 63 -73 5 63 -73 orange_concrete

# Side columns with lanterns
fill -6 64 -70 -6 68 -70 polished_blackstone_bricks
fill 6 64 -70 6 68 -70 polished_blackstone_bricks
setblock -6 69 -70 sea_lantern
setblock 6 69 -70 sea_lantern

# Sign (wall sign on the arch)
setblock 0 73 -70 oak_wall_sign[facing=south]{front_text:{messages:['{"text":""}','{"text":"§6§l🎨 CREATIVE","color":"gold","bold":true}','{"text":"§fStart Building","color":"white"}','{"text":""}']}}

# ═══════════════════════════════════════
# SOUTH — Building Competition Portal (z = 70)
# ═══════════════════════════════════════

# Portal arch
fill -4 64 70 4 64 70 yellow_concrete
fill -4 64 70 -4 72 70 yellow_concrete
fill 4 64 70 4 72 70 yellow_concrete
fill -4 72 70 4 72 70 yellow_concrete

# Portal interior — yellow stained glass
fill -3 65 70 3 71 70 yellow_stained_glass

# Portal platform
fill -5 63 68 5 63 72 smooth_quartz
fill -5 63 73 5 63 73 yellow_concrete

# Trophy statue — gold blocks
fill 0 64 74 0 67 74 gold_block
setblock -1 68 74 gold_block
setblock 0 68 74 gold_block
setblock 1 68 74 gold_block
setblock 0 69 74 gold_block

# Side columns
fill -6 64 70 -6 68 70 polished_blackstone_bricks
fill 6 64 70 6 68 70 polished_blackstone_bricks
setblock -6 69 70 sea_lantern
setblock 6 69 70 sea_lantern

# Sign
setblock 0 73 70 oak_wall_sign[facing=north]{front_text:{messages:['{"text":""}','{"text":"§e§l🏆 COMPETITION","color":"yellow","bold":true}','{"text":"§fBuild to Win","color":"white"}','{"text":""}']}}

# ═══════════════════════════════════════
# WEST — Survival Event Portal (x = -70)
# ═══════════════════════════════════════

# Portal arch — green concrete frame
fill -70 64 -4 -70 64 4 green_concrete
fill -70 64 -4 -70 72 -4 green_concrete
fill -70 64 4 -70 72 4 green_concrete
fill -70 72 -4 -70 72 4 green_concrete

# Portal interior
fill -70 65 -3 -70 71 3 lime_stained_glass

# Portal platform
fill -72 63 -5 -68 63 5 smooth_quartz
fill -73 63 -5 -73 63 5 green_concrete

# Adventure arch details
fill -70 73 -2 -70 73 2 mossy_stone_bricks
setblock -70 74 0 lantern[hanging=false]

# Side columns
fill -70 64 -6 -70 68 -6 polished_blackstone_bricks
fill -70 64 6 -70 68 6 polished_blackstone_bricks
setblock -70 69 -6 sea_lantern
setblock -70 69 6 sea_lantern

# Sign
setblock -70 73 0 oak_wall_sign[facing=east]{front_text:{messages:['{"text":""}','{"text":"§a§l⚔ SURVIVAL","color":"green","bold":true}','{"text":"§f15-Day Championship","color":"white"}','{"text":""}']}}

# ═══════════════════════════════════════
# EAST — PvP Arena Portal (x = 70)
# ═══════════════════════════════════════

# Portal arch — red concrete frame
fill 70 64 -4 70 64 4 red_concrete
fill 70 64 -4 70 72 -4 red_concrete
fill 70 64 4 70 72 4 red_concrete
fill 70 72 -4 70 72 4 red_concrete

# Portal interior
fill 70 65 -3 70 71 3 red_stained_glass

# Portal platform
fill 68 63 -5 72 63 5 smooth_quartz
fill 73 63 -5 73 63 5 red_concrete

# Weapon statues — netherite blocks
setblock 73 64 -3 netherite_block
setblock 73 65 -3 netherite_block
setblock 73 64 3 netherite_block
setblock 73 65 3 netherite_block

# Side columns
fill 70 64 -6 70 68 -6 polished_blackstone_bricks
fill 70 64 6 70 68 6 polished_blackstone_bricks
setblock 70 69 -6 sea_lantern
setblock 70 69 6 sea_lantern

# Sign
setblock 70 73 0 oak_wall_sign[facing=west]{front_text:{messages:['{"text":""}','{"text":"§c§l⚔ PVP ARENA","color":"red","bold":true}','{"text":"§fEnter the Battle","color":"white"}','{"text":""}']}}

# ═══════════════════════════════════════
# Connecting path ground cover to hide flat terrain
# ═══════════════════════════════════════
fill -80 62 -80 80 62 80 blackstone
fill -44 63 -44 -44 63 44 air
fill 44 63 -44 44 63 44 air
