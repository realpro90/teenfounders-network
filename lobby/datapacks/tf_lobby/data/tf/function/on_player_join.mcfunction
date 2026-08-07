# ══════════════════════════════════════════════════════════════════
# TeenFounders Lobby — Player Join Handler
# Welcome title, teleport to spawn, sound, particles
# ══════════════════════════════════════════════════════════════════

# ─── Mark player as joined ───────────────────────────────────────
scoreboard players set @s tf_joined 1

# ─── Materialize Lobby Structure Under Player ───────────────────
function tf:build_plaza
function tf:build_portals
function tf:build_decorations

# ─── Teleport to spawn facing beacon monument ───────────────────
tp @s 0.5 65.0 8.0 0 -5

# ─── Welcome Title Animation ────────────────────────────────────
title @s times 20 80 20
title @s title {"text":"TEENFOUNDERS","color":"gold","bold":true}
title @s subtitle {"text":"Build Network","color":"white"}

# ─── Action Bar Message ──────────────────────────────────────────
title @s actionbar {"text":"⚡ Welcome to the Future of Humanity ⚡","color":"yellow"}

# ─── Welcome Sound ───────────────────────────────────────────────
playsound minecraft:block.note_block.chime master @s ~ ~ ~ 1 1.5
playsound minecraft:entity.player.levelup master @s ~ ~ ~ 0.5 1.2

# ─── Particles ───────────────────────────────────────────────────
particle minecraft:firework ~ ~1 ~ 1 1 1 0.1 30

# ─── Clear inventory & set adventure mode ────────────────────────
clear @s
gamemode adventure @s

# ─── Give compass (Server Navigator) ────────────────────────────
give @s compass{display:{Name:'{"text":"§6§lServer Navigator","italic":false}',Lore:['{"text":"§7Right-click to open menu","italic":false}']}} 1

# ─── Welcome chat message ───────────────────────────────────────
tellraw @s ["",{"text":"\n"},{"text":"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━","color":"gold"},{"text":"\n"},{"text":"  "},{"text":"  TEENFOUNDERS BUILD NETWORK","color":"gold","bold":true},{"text":"\n"},{"text":"  "},{"text":"  Future of Humanity","color":"white"},{"text":"\n"},{"text":"\n"},{"text":"  "},{"text":"▸ ","color":"gold"},{"text":"Website: ","color":"gray"},{"text":"teenfounders.in","color":"yellow","clickEvent":{"action":"open_url","value":"https://teenfounders.in"},"hoverEvent":{"action":"show_text","contents":"Click to visit"}},{"text":"\n"},{"text":"  "},{"text":"▸ ","color":"gold"},{"text":"Walk to a portal or use ","color":"gray"},{"text":"/server","color":"yellow"},{"text":"\n"},{"text":"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━","color":"gold"},{"text":"\n"}]
