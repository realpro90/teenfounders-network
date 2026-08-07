# Comprehensive Backup Guide - TeenFounders Network

Strategies for automated database, player data, and persistent volume backups across the network.

---

## 1. PostgreSQL Database Dump

Run daily automated dumps of the `teenfounders_mc` database:

```bash
pg_dump -U tf_admin -h postgres teenfounders_mc | gzip > /backups/tf_db_$(date +%Y%m%d).sql.gz
```

---

## 2. World & Plot Backups

World files in `/data/world` on `creative` and `lobby` services should be snapshotted using Railway's persistent volume snapshots prior to major events or updates.
