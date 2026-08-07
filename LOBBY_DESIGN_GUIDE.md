# TeenFounders Build Network - Production Lobby Architecture & Design Guide

This document outlines the complete 500x500 Minecraft Java 1.21.11 Lobby design, Citizens NPC placements, Holograms, DeluxeMenus Master Navigator, and deployment configuration for **TeenFounders Network**.

---

## 🎨 Visual Identity & Color Palette

- **Primary Colors**:
  - **Warm Orange** (`#FF9932` / Minecraft `§6` / `&6`)
  - **Quartz White** (`#FFFFFF` / Minecraft `§f` / `&f`)
  - **Blackstone Dark Gray** (`#0A0A0C` / Minecraft `§8` / `&8`)
- **Theme**: Entrepreneurship, Innovation, Building, Competition, & Future of Humanity.

---

## 🗺️ 500x500 World Architecture & Districts

### 1. Central Spawn Plaza `(0.5, 65.0, 0.5)`
- **Spawn Orientation**: Players spawn facing North `(yaw: 0.0, pitch: 0.0)` looking directly at the **Central Floating TeenFounders Logo** & 3D Beacon Monument.
- **On-Join Experience**:
  - **Screen Title**: `§6§lWELCOME TO`
  - **Subtitle**: `§f§lTEENFOUNDERS BUILD NETWORK §7- §eFuture of Humanity`
  - **HUD Scoreboard**: TAB scoreboard on the right side of the screen displaying player rank, online count, ping, server name, and website `https://teenfounders.in`.
  - **Auto-Open GUI**: DeluxeMenus Master Navigator (`/menu`) automatically pops up on screen upon spawn.
  - **Hotbar Items**: Slot 1 `§6§lSERVER_NAVIGATOR` (Nether Star) + Slot 9 `§e§lTEENFOUNDERS_GUIDE` (Written Book).

### 2. Creative Plots District `(x: 25, y: 65, z: 0)`
- **Portal**: Large Orange Stained Glass Portal.
- **NPC**: `Builder` (Citizens NPC #1) standing at entrance -> Left-click / Right-click executes `/server creative`.
- **Hologram**:
  - `§6§lCREATIVE PLOTS`
  - `§eStart Building →`
  - `§7Right-Click Builder NPC`

### 3. Building Competition District `(x: 0, y: 65, z: 25)`
- **Portal**: Gold Block Archway with Trophy Statue & Leaderboards.
- **NPC**: `Contest Master` (Citizens NPC #2) standing at entrance -> Left-click / Right-click executes `/server competition`.
- **Hologram**:
  - `§e§lBUILD COMPETITIONS`
  - `§fWeekly Timed Contests & Leaderboards`
  - `§7Right-Click Contest Master`

### 4. 15-Day Survival Championship Gateway `(x: -25, y: 65, z: 0)`
- **Portal**: Adventure-themed Netherite Archway with Season Countdown Display.
- **NPC**: `Season Champion` (Citizens NPC #3) standing at gateway -> Left-click / Right-click executes `/server survival-event`.
- **Hologram**:
  - `§c§l15-DAY SURVIVAL CHAMPIONSHIP`
  - `§fSeason 1 Active - Shrinking Border Battle`
  - `§7Right-Click Champion NPC`

### 5. PvP Arena District `(x: 0, y: 65, z: -25)`
- **Portal**: Diamond Sword Combat Portal with Weapon Statues.
- **NPC**: `Gladiator` (Citizens NPC #4) standing at entrance -> Left-click / Right-click executes `/server pvp`.
- **Hologram**:
  - `§b§lPVP ARENA & DUELS`
  - `§f1v1 Combat & Kits`

---

## 🤖 Citizens NPC Summary

| ID | Name | Position | Target Server / Command |
|---|---|---|---|
| **1** | `Builder` | `(25.5, 65.0, 0.5)` | `/server creative` |
| **2** | `Contest Master` | `(0.5, 65.0, 25.5)` | `/server competition` |
| **3** | `Season Champion` | `(-25.5, 65.0, 0.5)` | `/server survival-event` |
| **4** | `Gladiator` | `(0.5, 65.0, -25.5)` | `/server pvp` |
| **5** | `Guide Assistant` | `(3.5, 65.0, 3.5)` | `/menu` |

---

## 🚀 Deployment Automation

The lobby world and all configurations are 100% automated:
- **`lobby/setup_lobby_world.sh`**: Checks `/data/world` on container launch. If no world exists, it provisions the 500x500 lobby map and locks spawn coordinates at `(0.5, 65.0, 0.5)`.
- **`server-icon.png`**: Generated 64x64 PNG logo from `https://teenfounders.in/favicon-1024.png`.
- **`spigot.yml` & `config/paper-global.yml`**: Auto-enforces BungeeCord forwarding and `online-mode=false` on boot.
