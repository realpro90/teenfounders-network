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
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.EventPriority;
import org.bukkit.event.Listener;
import org.bukkit.event.block.Action;
import org.bukkit.event.block.BlockBreakEvent;
import org.bukkit.event.block.BlockPlaceEvent;
import org.bukkit.event.entity.EntityDamageByEntityEvent;
import org.bukkit.event.entity.EntityDamageEvent;
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
            
            // Build 400x400 Plaza if beacon monument doesn't exist
            Block centerBlock = world.getBlockAt(0, 64, 0);
            if (centerBlock.getType() != Material.BEACON) {
                buildLobbyStructure(world);
            }

            spawnLocation = new Location(world, 0.5, 65.0, 0.5, 0.0f, -5.0f);
            world.setSpawnLocation(0, 65, 0);
        }

        getLogger().info("TeenFoundersLobby v3.3 enabled! 400x400 Central Plaza active, Spawn set to (0.5, 65.0, 0.5).");
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

    private void buildLobbyStructure(World world) {
        getLogger().info("Building 400x400 Central Plaza & Beacon Monument...");

        // 1. Central Plaza Floor (400x400 from X=-200 to 200, Z=-200 to 200)
        for (int x = -200; x <= 200; x++) {
            for (int z = -200; z <= 200; z++) {
                for (int y = 58; y <= 62; y++) {
                    world.getBlockAt(x, y, z).setType(Material.BLACKSTONE, false);
                }

                if (Math.abs(x) == 200 || Math.abs(z) == 200) {
                    world.getBlockAt(x, 63, z).setType(Material.POLISHED_BLACKSTONE_BRICK_WALL, false);
                } else if (x % 10 == 0 || z % 10 == 0) {
                    world.getBlockAt(x, 63, z).setType(Material.ORANGE_CONCRETE, false);
                } else if ((x + z) % 8 == 0) {
                    world.getBlockAt(x, 63, z).setType(Material.SEA_LANTERN, false);
                } else {
                    world.getBlockAt(x, 63, z).setType(Material.SMOOTH_QUARTZ, false);
                }

                for (int y = 64; y <= 120; y++) {
                    Block b = world.getBlockAt(x, y, z);
                    if (b.getType() != Material.AIR) {
                        b.setType(Material.AIR, false);
                    }
                }
            }
        }

        // 2. Central Beacon Monument (7x7 Pyramid at 0,60,0)
        for (int x = -3; x <= 3; x++) {
            for (int z = -3; z <= 3; z++) {
                world.getBlockAt(x, 62, z).setType(Material.IRON_BLOCK, false);
            }
        }
        for (int x = -2; x <= 2; x++) {
            for (int z = -2; z <= 2; z++) {
                world.getBlockAt(x, 63, z).setType(Material.IRON_BLOCK, false);
            }
        }
        world.getBlockAt(0, 64, 0).setType(Material.BEACON, false);
        world.getBlockAt(0, 65, 0).setType(Material.ORANGE_STAINED_GLASS, false);

        int[][] corners = {{-4, -4}, {-4, 4}, {4, -4}, {4, 4}};
        for (int[] c : corners) {
            for (int y = 64; y <= 68; y++) {
                world.getBlockAt(c[0], y, c[1]).setType(Material.POLISHED_BLACKSTONE_BRICKS, false);
            }
            world.getBlockAt(c[0], 69, c[1]).setType(Material.SEA_LANTERN, false);
        }

        // 3. Portals
        buildPortalArch(world, 0, 64, -40, Material.ORANGE_CONCRETE, Material.ORANGE_STAINED_GLASS);
        buildPortalArch(world, 0, 64, 40, Material.YELLOW_CONCRETE, Material.YELLOW_STAINED_GLASS);
        buildPortalArch(world, -40, 64, 0, Material.GREEN_CONCRETE, Material.LIME_STAINED_GLASS);
        buildPortalArch(world, 40, 64, 0, Material.RED_CONCRETE, Material.RED_STAINED_GLASS);

        getLogger().info("400x400 Central Plaza structure built successfully!");
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

        // Guaranteed Triple Teleport to Central Spawn (0.5, 65.0, 0.5)
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
        
        // Perimeter guard: If player strays outside X/Z = +-190 or falls below Y = 50, teleport back to center
        if (Math.abs(loc.getX()) > 190 || Math.abs(loc.getZ()) > 190 || loc.getY() < 50) {
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
