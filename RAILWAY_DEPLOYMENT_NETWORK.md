# Railway Multi-Service Deployment Guide - TeenFounders Network

Deploying the TeenFounders Minecraft Network on Railway involves creating a single Railway Project containing 7 separate services.

---

## Service Architecture Breakdown

| Service Name | Dockerfile Path | Public TCP | Persistent Volume | Suggested RAM |
|---|---|---|---|---|
| `proxy` | `proxy/Dockerfile` | Port `25565` | None | 1 GB |
| `lobby` | `lobby/Dockerfile` | Private | `/data` | 3 GB |
| `creative` | `creative/Dockerfile` | Private | `/data` | 4 GB |
| `competition` | `competition/Dockerfile` | Private | `/data` | 3 GB |
| `survival-event` | `survival-event/Dockerfile` | Private | `/data` | 3 GB |
| `pvp` | `pvp/Dockerfile` | Private | `/data` | 3 GB |
| `postgres` | Image: `postgres:16-alpine` | Private | `/var/lib/postgresql/data` | 2 GB |
| `redis` | Image: `redis:7-alpine` | Private | `/data` | 1 GB |

---

## Step-by-Step Deployment Instructions

### 1. Create Railway Project
1. Open Railway -> Click **+ New Project**.
2. Select **Provision PostgreSQL** to spin up the database service.
3. Select **Provision Redis** to spin up the Redis service.

### 2. Deploy Services from GitHub
1. Click **+ New** -> **GitHub Repo** -> Choose repository.
2. Under Service Settings -> **Build**:
   - For `proxy`: Set Dockerfile path to `proxy/Dockerfile`.
   - For `lobby`: Set Dockerfile path to `lobby/Dockerfile`.
   - For `creative`: Set Dockerfile path to `creative/Dockerfile`.
   - For `competition`: Set Dockerfile path to `competition/Dockerfile`.
   - For `survival-event`: Set Dockerfile path to `survival-event/Dockerfile`.
   - For `pvp`: Set Dockerfile path to `pvp/Dockerfile`.

### 3. Attach Volumes to Backend Services
Add persistent volumes mounted at `/data` for `lobby`, `creative`, `competition`, `survival-event`, and `pvp`.

### 4. Enable TCP Proxy on Velocity Proxy
In the `proxy` service settings -> **Networking** -> Add **TCP Proxy** on Port `25565`. Point your domain (`play.teenfounders.in`) to the proxy host string.
