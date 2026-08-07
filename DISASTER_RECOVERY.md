# Disaster Recovery & Failover Manual - TeenFounders Network

Emergency recovery procedures for database failures, corrupted world states, or proxy downtime.

---

## Scenario A: PostgreSQL Service Disruption

1. If PostgreSQL crashes, PaperMC backend servers fallback to in-memory permission caching via LuckPerms local file cache.
2. Restore database from latest `.sql.gz` dump:
   ```bash
   gunzip -c /backups/tf_db_latest.sql.gz | psql -U tf_admin -d teenfounders_mc
   ```

---

## Scenario B: Corrupted Plot World

1. Stop `creative` container on Railway.
2. Restore world snapshot from Railway Volume dashboard.
3. Use CoreProtect rollback commands to restore specific regions if corruption was caused by griefing:
   ```bash
   /co rollback t:24h r:100 #creative_plots
   ```
