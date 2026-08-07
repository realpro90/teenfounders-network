package com.teenfounders.lobby;

import org.bukkit.Bukkit;
import org.bukkit.Color;
import org.bukkit.GameMode;
import org.bukkit.Location;
import org.bukkit.Material;
import org.bukkit.Particle;
import org.bukkit.Sound;
import org.bukkit.World;
import org.bukkit.block.Block;
import org.bukkit.block.BlockFace;
import org.bukkit.block.data.type.WallSign;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.EventPriority;
import org.bukkit.event.Listener;
import org.bukkit.event.entity.EntityDamageEvent;
import org.bukkit.event.entity.FoodLevelChangeEvent;
import org.bukkit.event.player.PlayerInteractEvent;
import org.bukkit.event.player.PlayerJoinEvent;
import org.bukkit.event.player.PlayerMoveEvent;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.ItemMeta;
import org.bukkit.plugin.java.JavaPlugin;

import java.util.Arrays;

public class TeenFoundersLobby extends JavaPlugin implements Listener {

    private Location spawnLocation;

    @Override
    public void onEnable() {
        Bukkit.getPluginManager().registerEvents(this, this);

        World world = Bukkit.getWorlds().get(0);
        if (world != null) {
            configureWorld(world);
            buildLobbyStructure(world);
            spawnLocation = new Location(world, 0.5, 65.0, 0.5, 0.0f, -5.0f);
            world.setSpawnLocation(0, 65, 0);
        }

        getLogger().info("TeenFoundersLobby v2.0 enabled successfully! World & Spawn initialized.");
    }

    private void configureWorld(World world) {
        world.setGameRuleValue("doDaylightCycle", "false");
        world.setGameRuleValue("doWeatherCycle", "false");
        world.setGameRuleValue("doMobSpawning", "false");
        world.setGameRuleValue("doFireTick", "false");
        world.setGameRuleValue("mobGriefing", "false");
        world.setGameRuleValue("keepInventory", "true");
        world.setGameRuleValue("announceAdvancements", "false");
        world.setTime(6000);
        world.setStorm(false);
        world.setThundering(false);
    }

    private void buildLobbyStructure(World world) {
        // 1. Central Plaza Floor (100x100 from X=-50 to 50, Z=-50 to 50)
        for (int x = -50; x <= 50; x++) {
            for (int z = -50; z <= 50; z++) {
                // Foundation (Blackstone)
                for (int y = 58; y <= 62; y++) {
                    world.getBlockAt(x, y, z).setType(Material.BLACKSTONE, false);
                }

                // Surface pattern
                if (Math.abs(x) == 50 || Math.abs(z) == 50) {
                    world.getBlockAt(x, 63, z).setType(Material.POLISHED_BLACKSTONE_BRICK_WALL, false);
                } else if (x % 10 == 0 || z % 10 == 0) {
                    world.getBlockAt(x, 63, z).setType(Material.ORANGE_CONCRETE, false);
                } else if ((x + z) % 8 == 0) {
                    world.getBlockAt(x, 63, z).setType(Material.SEA_LANTERN, false);
                } else {
                    world.getBlockAt(x, 63, z).setType(Material.SMOOTH_QUARTZ, false);
                }

                // Clear air above plaza up to Y=90
                for (int y = 64; y <= 90; y++) {
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

        // Beacon corner pillars with lanterns
        int[][] corners = {{-4, -4}, {-4, 4}, {4, -4}, {4, 4}};
        for (int[] c : corners) {
            for (int y = 64; y <= 68; y++) {
                world.getBlockAt(c[0], y, c[1]).setType(Material.POLISHED_BLACKSTONE_BRICKS, false);
            }
            world.getBlockAt(c[0], 69, c[1]).setType(Material.SEA_LANTERN, false);
        }

        // 3. Portals
        buildPortalArch(world, 0, 64, -40, Material.ORANGE_CONCRETE, Material.ORANGE_STAINED_GLASS, "§6§l🎨 CREATIVE");
        buildPortalArch(world, 0, 64, 40, Material.YELLOW_CONCRETE, Material.YELLOW_STAINED_GLASS, "§e§l🏆 COMPETITION");
        buildPortalArch(world, -40, 64, 0, Material.GREEN_CONCRETE, Material.LIME_STAINED_GLASS, "§a§l⚔ SURVIVAL");
        buildPortalArch(world, 40, 64, 0, Material.RED_CONCRETE, Material.RED_STAINED_GLASS, "§c§l⚔ PVP ARENA");
    }

    private void buildPortalArch(World world, int cx, int cy, int cz, Material frame, Material glass, String title) {
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

        if (spawnLocation != null) {
            player.teleport(spawnLocation);
        }

        player.setGameMode(GameMode.ADVENTURE);
        player.getInventory().clear();

        // Give Lobby Items
        player.getInventory().setItem(0, createItem(Material.COMPASS, "§6§lServer Navigator", "§7Right-click to open server menu"));
        player.getInventory().setItem(1, createItem(Material.CLOCK, "§b§lCosmetics", "§7Right-click to open cosmetics"));
        player.getInventory().setItem(4, createItem(Material.BOOK, "§e§lRules & Info", "§7Right-click to read network rules"));
        player.getInventory().setItem(8, createItem(Material.EMERALD, "§a§lMy Profile", "§7Right-click to view your profile"));

        // Titles & Audio
        player.sendTitle("§6§lTEENFOUNDERS", "§fBuild Network · Future of Humanity", 10, 70, 20);
        player.playSound(player.getLocation(), Sound.ENTITY_PLAYER_LEVELUP, 1.0f, 1.2f);
        player.playSound(player.getLocation(), Sound.BLOCK_NOTE_BLOCK_CHIME, 1.0f, 1.5f);

        // Welcome Message
        player.sendMessage("§6§m--------------------------------------------------");
        player.sendMessage("  §6§lTEENFOUNDERS BUILD NETWORK");
        player.sendMessage("  §fWelcome, §e" + player.getName() + "§f! Use your §6Server Navigator §fto choose a game mode.");
        player.sendMessage("  §7Website: §eyouthfounders.in / teenfounders.in");
        player.sendMessage("§6§m--------------------------------------------------");
    }

    @EventHandler
    public void onPlayerMove(PlayerMoveEvent event) {
        Player player = event.getPlayer();
        if (player.getLocation().getY() < 50) {
            if (spawnLocation != null) {
                player.teleport(spawnLocation);
                player.playSound(player.getLocation(), Sound.ENTITY_ENDERMAN_TELEPORT, 1.0f, 1.0f);
            }
        }
    }

    @EventHandler
    public void onDamage(EntityDamageEvent event) {
        if (event.getEntity() instanceof Player) {
            event.setCancelled(true);
        }
    }

    @EventHandler
    public void onHunger(FoodLevelChangeEvent event) {
        event.setCancelled(true);
        event.setFoodLevel(20);
    }

    @EventHandler
    public void onInteract(PlayerInteractEvent event) {
        Player player = event.getPlayer();
        ItemStack item = event.getItem();

        if (item != null && item.hasItemMeta() && item.getItemMeta().hasDisplayName()) {
            String name = item.getItemMeta().getDisplayName();
            if (name.contains("Server Navigator") || name.contains("Cosmetics") || name.contains("Profile")) {
                player.performCommand("menu");
                event.setCancelled(true);
            } else if (name.contains("Rules")) {
                player.performCommand("help");
                event.setCancelled(true);
            }
        }
    }

    private ItemStack createItem(Material mat, String name, String lore) {
        ItemStack item = new ItemStack(mat);
        ItemMeta meta = item.getItemMeta();
        if (meta != null) {
            meta.setDisplayName(name);
            meta.setLore(Arrays.asList(lore));
            item.setItemMeta(meta);
        }
        return item;
    }
}
