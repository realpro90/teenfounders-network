# Architectural Blueprint - TeenFounders Network

This document presents the detailed architectural design of the **TeenFounders Network**.

---

## Network Routing Architecture

```
                          ┌──────────────────────────────┐
                          │     PUBLIC CLIENT JOIN       │
                          │   play.teenfounders.in:25565 │
                          └──────────────┬───────────────┘
                                         │
                                         ▼
                          ┌──────────────────────────────┐
                          │        VELOCITY PROXY        │
                          │    (Modern Secret Protocol)  │
                          └──────────────┬───────────────┘
                                         │
        ┌──────────────────┬─────────────┼─────────────┬──────────────────┐
        ▼                  ▼             ▼             ▼                  ▼
  ┌───────────┐      ┌───────────┐ ┌───────────┐ ┌───────────┐      ┌───────────┐
  │   LOBBY   │      │ CREATIVE  │ │COMPETITION│ │ SURVIVAL  │      │    PVP    │
  │  SERVER   │      │  SERVER   │ │  SERVER   │ │  EVENT    │      │  SERVER   │
  └─────┬─────┘      └─────┬─────┘ └─────┬─────┘ └─────┬─────┘      └─────┬─────┘
        │                  │             │             │                  │
        └──────────────────┴─────────────┼─────────────┴──────────────────┘
                                         │
                      ┌──────────────────┴──────────────────┐
                      ▼                                     ▼
           ┌─────────────────────┐               ┌─────────────────────┐
           │ PostgreSQL Database │               │     Redis Cache     │
           │ (17 Shared Tables)  │               │   (Pub/Sub Sync)    │
           └─────────────────────┘               └─────────────────────┘
```

---

## Security Model

1. **Velocity Modern Forwarding**: All PaperMC backend servers operate with `online-mode: false` behind Velocity, but enforce `velocity.enabled: true` with a shared cryptographic secret key (`forwarding.secret`).
2. **Direct IP Access Prevention**: PaperMC servers reject any incoming connections that do not contain valid Velocity modern forwarding tokens.
3. **Database Isolation**: PostgreSQL credentials are passed via Railway environment variables and never checked into source control.
