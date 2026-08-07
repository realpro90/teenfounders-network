# Server Maintenance & Update Guide - TeenFounders Build Network

This document outlines the standard operating procedures for updating PaperMC engine builds, plugins, and server configurations safely without risking data loss.

---

## 1. Automatic PaperMC Engine Updates

The container is configured to automatically check for the latest PaperMC 1.21.11 build on startup. To perform a routine engine patch:

1. Perform a full backup of `/data` (see [BACKUP_GUIDE.md](file:///Users/aaravkumar/untitled%20folder%202/BACKUP_GUIDE.md)).
2. In Railway Dashboard, trigger a **Redeploy** of your service.
3. The `entrypoint.sh` script will automatically check PaperMC API v2 and download the newest build.

---

## 2. Updating Plugins Safely

To update plugins (such as LuckPerms, EssentialsX, FAWE, TAB, or DeluxeMenus):

1. Stop the server container or put the server in maintenance mode (`/whitelist on`).
2. Delete the specific `.jar` file inside `/data/plugins/`.
3. Re-run `scripts/download-plugins.sh` or upload the updated `.jar` file directly to `/data/plugins/`.
4. Start the server and check server logs using `spark` or console output for any deprecation warnings.

---

## 3. Major Version Upgrades (e.g. Minecraft 1.21.x -> 1.22)

When upgrading to a major new Minecraft version:

1. Update `PAPER_VERSION` environment variable in Railway to the targeted version (e.g. `1.22`).
2. Verify ViaVersion and ViaBackwards are up to date so existing players can connect during migration.
3. Verify plugin API compatibility before switching main world folders.
