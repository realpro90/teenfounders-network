package com.teenfounders.lobby;

import org.bukkit.Bukkit;
import org.bukkit.GameMode;
import org.bukkit.GameRule;
import org.bukkit.Location;
import org.bukkit.Material;
import org.bukkit.NamespacedKey;
import org.bukkit.Sound;
import org.bukkit.World;
import org.bukkit.block.Block;
import org.bukkit.entity.Entity;
import org.bukkit.entity.Mob;
import org.bukkit.entity.Player;
import org.bukkit.entity.Slime;
import org.bukkit.event.EventHandler;
import org.bukkit.event.EventPriority;
import org.bukkit.event.Listener;
import org.bukkit.event.block.Action;
import org.bukkit.event.block.BlockBreakEvent;
import org.bukkit.event.block.BlockPlaceEvent;
import org.bukkit.event.entity.EntityDamageByEntityEvent;
import org.bukkit.event.entity.EntityDamageEvent;
import org.bukkit.event.entity.EntitySpawnEvent;
import org.bukkit.event.entity.FoodLevelChangeEvent;
import org.bukkit.event.player.PlayerChangedWorldEvent;
import org.bukkit.event.player.PlayerDropItemEvent;
import org.bukkit.event.player.PlayerInteractEvent;
import org.bukkit.event.player.PlayerJoinEvent;
import org.bukkit.event.player.PlayerMoveEvent;
import org.bukkit.event.player.PlayerRespawnEvent;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.ItemMeta;
import org.bukkit.persistence.PersistentDataType;
import org.bukkit.plugin.java.JavaPlugin;

import java.util.Arrays;

public class TeenFoundersLobby extends JavaPlugin implements Listener {

    private Location spawnLocation;
    private NamespacedKey itemKey;

    @Override
    public void onEnable() {
        itemKey = new NamespacedKey(this, "lobby_item");
        Bukkit.getPluginManager().registerEvents(this, this);

        World world = Bukkit.getWorlds().get(0);
        if (world != null) {
            configureWorld(world);
            
            // Build Plaza right on top of the ground (Y=4..8)
            buildLobbyStructure(world);

            // Spawn directly in the center of the Beacon Monument at (0.5, 8.0, 0.5)
            spawnLocation = new Location(world, 0.5, 8.0, 0.5, 0.0f, -5.0f);
            world.setSpawnLocation(0, 8, 0);

            // Purge all slimes and mobs immediately
            purgeMobs(world);
        }

        getLogger().info("TeenFoundersLobby v3.4 enabled! Plaza built at ground level (Y=4..8), Spawn set to (0.5, 8.0, 0.5).");
    }

    private void configureWorld(World world) {
        world.setGameRule(GameRule.DO_DAYLIGHT_CYCLE, false);
        world.setGameRule(GameRule.DO_WEATHER_CYCLE, false);
        world.setGameRule(GameRule.DO_MOB_SPAWNING, false);
        world.setGameRule(GameRule.DO_FIRE_TICK, false);
        world.setGameRule(GameRule.MOB_GRIEFING, false);
        world.setGameRule(GameRule.KEEP_INVENTORY, true);
        world.setGameRule(GameRule.ANNOUNCE_ADVANCEMENTS, false);

        world.setTime(6000);
        world.setStorm(false);
        world.setThundering(false);
    }

    private void purgeMobs(World world) {
        for (Entity entity : world.getEntities()) {
            if (entity instanceof Mob || entity instanceof Slime) {
                entity.remove();
            }
        }
    }

    private void buildLobbyStructure(World world) {
        getLogger().info("Building 200x200 Central Plaza at ground level Y=4..7...");

        // 1. Central Plaza Floor (200x200 from X=-100 to 100, Z=-100 to 100 at ground level Y=4..7)
        for (int x = -100; x <= 100; x++) {
            for (int z = -100; z <= 100; z++) {
                world.getBlockAt(x, 0, z).setType(Material.BEDROCK, false);
                for (int y = 1; y <= 5; y++) {
                    world.getBlockAt(x, y, z).setType(Material.BLACKSTONE, false);
                }

                if (Math.abs(x) == 100 || Math.abs(z) == 100) {
                    world.getBlockAt(x, 7, z).setType(Material.POLISHED_BLACKSTONE_BRICK_WALL, false);
                } else if (x % 10 == 0 || z % 10 == 0) {
                    world.getBlockAt(x, 7, z).setType(Material.ORANGE_CONCRETE, false);
                } else if ((x + z) % 8 == 0) {
                    world.getBlockAt(x, 7, z).setType(Material.SEA_LANTERN, false);
                } else {
                    world.getBlockAt(x, 7, z).setType(Material.SMOOTH_QUARTZ, false);
                }

                for (int y = 8; y <= 50; y++) {
                    Block b = world.getBlockAt(x, y, z);
                    if (b.getType() != Material.AIR) {
                        b.setType(Material.AIR, false);
                    }
                }
            }
        }

        // 2. Central Beacon Monument (Pyramid at Y=5..7, Beacon at Y=7)
        for (int x = -3; x <= 3; x++) {
            for (int z = -3; z <= 3; z++) {
                world.getBlockAt(x, 5, z).setType(Material.IRON_BLOCK, false);
            }
        }
        for (int x = -2; x <= 2; x++) {
            for (int z = -2; z <= 2; z++) {
                world.getBlockAt(x, 6, z).setType(Material.IRON_BLOCK, false);
            }
        }
        world.getBlockAt(0, 7, 0).setType(Material.BEACON, false);
        world.getBlockAt(0, 8, 0).setType(Material.ORANGE_STAINED_GLASS, false);

        int[][] corners = {{-4, -4}, {-4, 4}, {4, -4}, {4, 4}};
        for (int[] c : corners) {
            for (int y = 7; y <= 11; y++) {
                world.getBlockAt(c[0], y, c[1]).setType(Material.POLISHED_BLACKSTONE_BRICKS, false);
            }
            world.getBlockAt(c[0], 12, c[1]).setType(Material.SEA_LANTERN, false);
        }

        // 3. Portals
        buildPortalArch(world, 0, 7, -30, Material.ORANGE_CONCRETE, Material.ORANGE_STAINED_GLASS);
        buildPortalArch(world, 0, 7, 30, Material.YELLOW_CONCRETE, Material.YELLOW_STAINED_GLASS);
        buildPortalArch(world, -30, 7, 0, Material.GREEN_CONCRETE, Material.LIME_STAINED_GLASS);
        buildPortalArch(world, 30, 7, 0, Material.RED_CONCRETE, Material.RED_STAINED_GLASS);

        getLogger().info("Central Plaza structure built successfully at ground level Y=7!");
    }

    private void buildPortalArch(World world, int cx, int cy, int cz, Material frame, Material glass) {
        boolean isZAxis = (cx == 0);
        for (int i = -3; i <= 3; i++) {
            for (int h = 0; h <= 6; h++) {
                int x = isZAxis ? cx + i : cx;
                int z = isZAxis ? cz : cz + i;
                if (i == -3 || i == 3 || h == 0 || h == 6) {
                    world.getBlockAt(x, cy + h, z).setType(frame, false);
                } else {
                    world.getBlockAt(x, cy + h, z).setType(glass, false);
                }
            }
        }
    }

    @EventHandler(priority = EventPriority.HIGHEST)
    public void onPlayerJoin(PlayerJoinEvent event) {
        Player player = event.getPlayer();
        purgeMobs(player.getWorld());

        // Guaranteed Triple Teleport to Central Spawn (0.5, 8.0, 0.5)
        Bukkit.getScheduler().runTaskLater(this, () -> teleportToCenter(player), 1L);
        Bukkit.getScheduler().runTaskLater(this, () -> teleportToCenter(player), 5L);
        Bukkit.getScheduler().runTaskLater(this, () -> teleportToCenter(player), 15L);

        setupPlayerLobbyState(player);

        player.sendTitle("§6§lTEENFOUNDERS", "§fBuild Network · Future of Humanity", 10, 70, 20);
        player.playSound(player.getLocation(), Sound.ENTITY_PLAYER_LEVELUP, 1.0f, 1.2f);
        player.playSound(player.getLocation(), Sound.BLOCK_NOTE_BLOCK_CHIME, 1.0f, 1.5f);

        player.sendMessage("§6§m--------------------------------------------------");
        player.sendMessage("  §6§lTEENFOUNDERS BUILD NETWORK");
        player.sendMessage("  §fWelcome, §e" + player.getName() + "§f! Use your §6Server Navigator §fto choose a game mode.");
        player.sendMessage("  §7Website: §eyouthfounders.in / teenfounders.in");
        player.sendMessage("§6§m--------------------------------------------------");
    }

    private void teleportToCenter(Player player) {
        if (spawnLocation != null && player.isOnline()) {
            player.teleport(spawnLocation);
        }
    }

    @EventHandler
    public void onEntitySpawn(EntitySpawnEvent event) {
        if (event.getEntity() instanceof Mob || event.getEntity() instanceof Slime) {
            event.setCancelled(true);
        }
    }

    @EventHandler
    public void onRespawn(PlayerRespawnEvent event) {
        if (spawnLocation != null) {
            event.setRespawnLocation(spawnLocation);
        }
        Bukkit.getScheduler().runTaskLater(this, () -> setupPlayerLobbyState(event.getPlayer()), 1L);
    }

    @EventHandler
    public void onWorldChange(PlayerChangedWorldEvent event) {
        setupPlayerLobbyState(event.getPlayer());
        teleportToCenter(event.getPlayer());
    }

    private void setupPlayerLobbyState(Player player) {
        player.setGameMode(GameMode.ADVENTURE);
        player.getInventory().clear();

        player.getInventory().setItem(0, createItem(Material.COMPASS, "nav", "§6§lServer Navigator", "§7Right-click to open server menu"));
        player.getInventory().setItem(1, createItem(Material.CLOCK, "cosmetics", "§b§lCosmetics", "§7Right-click to open cosmetics"));
        player.getInventory().setItem(4, createItem(Material.BOOK, "rules", "§e§lRules & Info", "§7Right-click to read network rules"));
        player.getInventory().setItem(8, createItem(Material.EMERALD, "profile", "§a§lMy Profile", "§7Right-click to view your profile"));
    }

    @EventHandler
    public void onPlayerMove(PlayerMoveEvent event) {
        Player player = event.getPlayer();
        Location loc = player.getLocation();
        
        // Perimeter guard: If player strays outside X/Z = +-95 or falls below Y = 0, teleport back to center
        if (Math.abs(loc.getX()) > 95 || Math.abs(loc.getZ()) > 95 || loc.getY() < 0) {
            teleportToCenter(player);
            player.playSound(player.getLocation(), Sound.ENTITY_ENDERMAN_TELEPORT, 1.0f, 1.0f);
        }
    }

    @EventHandler(priority = EventPriority.HIGHEST)
    public void onBlockBreak(BlockBreakEvent event) {
        if (!event.getPlayer().isOp()) event.setCancelled(true);
    }

    @EventHandler(priority = EventPriority.HIGHEST)
    public void onBlockPlace(BlockPlaceEvent event) {
        if (!event.getPlayer().isOp()) event.setCancelled(true);
    }

    @EventHandler(priority = EventPriority.HIGHEST)
    public void onDamage(EntityDamageEvent event) {
        event.setCancelled(true);
    }

    @EventHandler(priority = EventPriority.HIGHEST)
    public void onPvP(EntityDamageByEntityEvent event) {
        event.setCancelled(true);
    }

    @EventHandler
    public void onHunger(FoodLevelChangeEvent event) {
        event.setCancelled(true);
        event.setFoodLevel(20);
    }

    @EventHandler
    public void onDrop(PlayerDropItemEvent event) {
        event.setCancelled(true);
    }

    @EventHandler
    public void onInteract(PlayerInteractEvent event) {
        Player player = event.getPlayer();
        ItemStack item = event.getItem();

        if (item != null && item.hasItemMeta()) {
            ItemMeta meta = item.getItemMeta();
            if (meta != null && meta.getPersistentDataContainer().has(itemKey, PersistentDataType.STRING)) {
                String id = meta.getPersistentDataContainer().get(itemKey, PersistentDataType.STRING);
                if ("nav".equals(id) || "cosmetics".equals(id) || "profile".equals(id)) {
                    player.performCommand("menu");
                    event.setCancelled(true);
                    return;
                } else if ("rules".equals(id)) {
                    player.performCommand("help");
                    event.setCancelled(true);
                    return;
                }
            }
        }

        if (event.getAction() == Action.RIGHT_CLICK_BLOCK) {
            Block b = event.getClickedBlock();
            if (b != null && !player.isOp()) {
                Material m = b.getType();
                if (m.name().contains("DOOR") || m.name().contains("BUTTON") || m.name().contains("LEVER") || m.name().contains("CHEST")) {
                    event.setCancelled(true);
                }
            }
        }
    }

    private ItemStack createItem(Material mat, String id, String name, String lore) {
        ItemStack item = new ItemStack(mat);
        ItemMeta meta = item.getItemMeta();
        if (meta != null) {
            meta.setDisplayName(name);
            meta.setLore(Arrays.asList(lore));
            meta.getPersistentDataContainer().set(itemKey, PersistentDataType.STRING, id);
            item.setItemMeta(meta);
        }
        return item;
    }
}
