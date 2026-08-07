# Maintenance Guide - TeenFounders Network

This guide covers routine operational maintenance, plugin upgrades, and PaperMC engine patches across the Velocity network.

---

## Zero-Downtime Maintenance Flow

1. **Proxy Redirection**: Use Velocity's forced host routing to redirect incoming joins to a maintenance announcement screen if necessary.
2. **Backend Patching**: Restart individual backend servers (`creative`, `pvp`, `competition`) one at a time. Velocity will automatically failover connected players back to `lobby`.
3. **Database Maintenance**: Perform PostgreSQL table indexing and vacuuming during off-peak hours:
   ```sql
   VACUUM ANALYZE players;
   VACUUM ANALYZE plot_ownership;
   ```
