# Scaling & Performance Optimization Guide - TeenFounders Network

This guide explains how to scale the TeenFounders network to handle 100+ to 1,000+ concurrent players across Railway containers.

---

## Horizontal Scaling Strategies

1. **Multiple Lobby Instances**: Spin up `lobby-1` and `lobby-2` instances behind Velocity proxy using round-robin load balancing in `velocity.toml`:
   ```toml
   try = ["lobby-1", "lobby-2"]
   ```
2. **Sub-divided Plot Worlds**: Split creative building across distinct world servers (`creative-1`, `creative-2`) linked to the shared PostgreSQL plot ownership database.
3. **Redis Pub/Sub Synchronization**: Redis synchronizes tablists, player locations, and global chat commands seamlessly across scaled instances.
