# Railway Production Deployment Guide - TeenFounders Build Network

This step-by-step guide explains how to deploy the dockerized **TeenFounders Build Network** Minecraft Java 1.21.11 server on Railway.app.

---

## Prerequisites

1. A Railway account ([https://railway.app](https://railway.app)).
2. A GitHub account with this repository pushed to your account.
3. Recommended Railway plan: **Pro Plan** or **Developer Plan** with at least 4GB to 8GB RAM allocated.

---

## Step 1: Create New Project on Railway

1. Log into your Railway Dashboard.
2. Click **+ New Project**.
3. Select **Deploy from GitHub repo**.
4. Choose `teenfounders-build-network` (or your repository name).

---

## Step 2: Attach Persistent Volume (CRITICAL)

> [!IMPORTANT]
> Minecraft servers require stateful disk storage for worlds, player inventories, plugin databases, and LuckPerms permissions. You **MUST** attach a persistent volume to `/data`.

1. Click on your deployed service in the Railway canvas.
2. Navigate to the **Volumes** tab.
3. Click **+ Add Volume**.
4. Set the **Mount Path** to: `/data`
5. Set initial volume size (e.g. `20 GB` or `50 GB`).

---

## Step 3: Configure Environment Variables

Navigate to the **Variables** tab in Railway and add:

```env
PAPER_VERSION=1.21.11
JAVA_MEMORY=4G
EULA=true
MOTD=§6§lTEENFOUNDERS §fBuild Network §7[1.21.11]\n§eCreative Plots §7| §bWorldEdit §7| §aTeen Entrepreneurs
MAX_PLAYERS=100
VIEW_DISTANCE=8
SIMULATION_DISTANCE=6
OPS=TeenFoundersAdmin
PORT=25565
```

---

## Step 4: Configure Networking & TCP Port

1. Go to **Settings** > **Networking**.
2. Click **Generate Domain** or add a custom domain (e.g., `play.teenfounders.in`).
3. Under **TCP Proxy**, click **Add TCP Proxy** on port `25565`.
4. Railway will provide a public connection string, e.g.:
   `roundhouse.proxy.rlwy.net:12345`

Players can now connect directly using the provided domain or proxy host!

---

## Step 5: Deploy & Monitor Logs

1. Click **Deploy**.
2. Watch the deployment logs in the Railway Dashboard.
3. On first startup, the server will:
   - Accept Minecraft EULA (`eula=true`).
   - Download the latest PaperMC 1.21.11 build via API.
   - Run `download-plugins.sh` to fetch all 16 production plugins.
   - Initialize worlds and listen on port `25565`.

---

## Step 6: Assigning Yourself Owner / OP Rank

To grant yourself complete administrative power:

1. In Railway, open your service and click **View Logs** or **Exec / Terminal**.
2. Run command:
   ```bash
   lp user <YourMinecraftUsername> parent set owner
   op <YourMinecraftUsername>
   ```
3. You are now the Owner on TeenFounders Build Network!
