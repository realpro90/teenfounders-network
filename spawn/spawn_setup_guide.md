# TeenFounders Build Network - Premium Spawn Architecture & Setup Guide

This guide details the layout, Citizens NPC creation, floating holograms, navigation portals, parkour courses, and info boards for the TeenFounders Minecraft network spawn.

---

## 1. Spawn Architecture & Coordinates

- **Central Spawn Point**: `X: 0.5, Y: 64.0, Z: 0.5 (Yaw: 0, Pitch: 0)`
- **WorldGuard Region Name**: `spawn` (Radius: 100 blocks, cuboid height -64 to 320)
- **Visual Aesthetic**: Modern architectural plaza featuring obsidian/quartz pathways, TeenFounders orange glass accents (`#FF9932`), floating beacon light pillars, and interactive GUI terminals.

---

## 2. Citizens NPC Setup Commands

Run the following commands in-game as an Admin/Owner to instantiate interactive network NPCs:

```bash
# 1. Navigation NPC (Server & World Navigator)
/npc create "&6&lWORLD NAVIGATOR" --type VILLAGER --at 0.5 64.0 10.5 world
/npc cmd add menu

# 2. Plot Master NPC (Creative Plot Assistant)
/npc create "&a&lPLOT MASTER" --type PLAYER --skin TeenFounders --at -8.5 64.0 5.5 world
/npc cmd add warp plots

# 3. Builder Tools NPC (WorldEdit & Brushes)
/npc create "&d&lBUILDER TOOLKIT" --type PLAYER --skin Alex --at 9.5 64.0 5.5 world
/npc cmd add build

# 4. Rules & Guidelines NPC
/npc create "&b&lRULES & INFO" --type LIBRARIAN --at 0.5 64.0 -10.5 world
/npc cmd add rules
```

---

## 3. Floating Holograms Layout (TAB / DecentHolograms)

Create floating holograms above key spawn monuments:

```bash
# Main Welcome Hologram (Above Spawn Center at Y=68.5)
/hd create welcome_hd 0.5 68.5 0.5
/hd addline welcome_hd "&6&lWELCOME TO TEENFOUNDERS"
/hd addline welcome_hd "&fThe #1 Build Network for Young Entrepreneurs & Creators"
/hd addline welcome_hd "&7Website: &ehttps://teenfounders.in"
/hd addline welcome_hd "&aUse &e/menu &ato open the Navigator"

# Competition Portal Hologram (Above Portal Gate)
/hd create comp_hd 0.5 67.0 25.5
/hd addline comp_hd "&b&lBUILDING COMPETITIONS"
/hd addline comp_hd "&fActive Contest: &eTech Startup HQ Challenge"
/hd addline comp_hd "&7Rewards: Architect Rank & Badge"
```

---

## 4. Parkour & Navigation Setup

1. **Parkour Course**: Starts at `X: -25, Y: 64, Z: 0` leading up to the High View Platform at `Y: 95`.
   - Command set at finish block: `/warp parkour_finish` granting a cosmetic title.
2. **Builder Portals**: Built with Orange Stained Glass & Nether Portal frames linked to plot world arrival pads.
