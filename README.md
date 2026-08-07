# TeenFounders Network - Multi-Server Velocity Minecraft Network

<div align="center">
  <img src="https://teenfounders.in/teenfoundersinlogo.svg" alt="TeenFounders Logo" width="120" height="120" />
  <h1>TEENFOUNDERS NETWORK</h1>
  <p><strong>A Production-Grade Velocity Minecraft Network Built for Teen Entrepreneurs, Builders & Developers (Java 1.21.11)</strong></p>
  <p>Official Website: <a href="https://teenfounders.in">https://teenfounders.in</a></p>
</div>

---

## 🌟 Network Overview

TeenFounders Network is a high-performance multi-server Minecraft network architecture containerized for full deployment on Railway. Built with **Velocity 3.3.0 Proxy**, **Paper 1.21.11 Engine**, **PostgreSQL 16**, and **Redis 7**.

### 🏰 Server Clusters

1. **Velocity Proxy** (`proxy/`): Entrypoint routing server managing online authentication, modern forwarding secrets, and player transfers.
2. **Lobby Hub** (`lobby/`): Main arrival hub featuring Citizens NPCs, DeluxeMenus GUIs, parkour, leaderboards, and news boards.
3. **Creative Build World** (`creative/`): 64x64 plot worlds with WorldEdit & FastAsyncWorldEdit support.
4. **Build Competition Arena** (`competition/`): Scheduled building contests with automated voting and seasonal themes (Future City, Cyberpunk, AI, Space).
5. **15-Day Survival Event** (`survival-event/`): Seasonal survival gameplay with custom loot, boss encounters, world borders, and automated world resets every 15 days.
6. **PvP Arena** (`pvp/`): Separate duels, FFA, and practice arena.

---

## 🎨 Branding & Identity

Matching [https://teenfounders.in](https://teenfounders.in):

- **Primary Accent**: `#FF9932` / `#FF7F3F` (Vibrant Warm Orange / `§6` & `§e`)
- **Secondary**: Pure White (`#FFFFFF` / `§f`)
- **Background**: Deep Dark Charcoal & Black (`#0A0A0C` / `§0` & `§7`)

---

## 🗄️ Database & Cache Infrastructure

- **PostgreSQL 16**: Central relational state storing 17 tables (`players`, `ranks`, `economy`, `statistics`, `playtime`, `homes`, `plot_ownership`, `friends`, `mail`, `preferences`, `cosmetics`, `achievements`, `daily_rewards`, `punishments`, `event_progress`, `leaderboards`).
- **Redis 7**: High-speed pub/sub message broker handling tablist synchronization, cross-server transfers, announcements, and session caching.

---

## 🚀 Quick Deployment Guide (Railway)

For complete instructions, refer to [RAILWAY_DEPLOYMENT_NETWORK.md](file:///Users/aaravkumar/untitled%20folder%202/RAILWAY_DEPLOYMENT_NETWORK.md).

```bash
# Local Docker Testing
docker-compose up --build -d
```
