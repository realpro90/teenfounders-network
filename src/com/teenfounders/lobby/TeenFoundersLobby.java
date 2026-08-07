package com.teenfounders.lobby;

import org.bukkit.Bukkit;
import org.bukkit.GameMode;
import org.bukkit.GameRule;
import org.bukkit.Location;
import org.bukkit.Material;
import org.bukkit.NamespacedKey;
import org.bukkit.Sound;
import org.bukkit.World;
import org.bukkit.entity.ArmorStand;
import org.bukkit.entity.Cat;
import org.bukkit.entity.Entity;
import org.bukkit.entity.EntityType;
import org.bukkit.entity.Fox;
import org.bukkit.entity.Mob;
import org.bukkit.entity.Player;
import org.bukkit.entity.Slime;
import org.bukkit.entity.Tameable;
import org.bukkit.entity.Villager;
import org.bukkit.entity.Wolf;
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
import org.bukkit.event.player.PlayerInteractEntityEvent;
import org.bukkit.event.player.PlayerInteractEvent;
import org.bukkit.event.player.PlayerJoinEvent;
import org.bukkit.event.player.PlayerMoveEvent;
import org.bukkit.event.player.PlayerQuitEvent;
import org.bukkit.event.player.PlayerRespawnEvent;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.ItemMeta;
import org.bukkit.persistence.PersistentDataType;
import org.bukkit.plugin.java.JavaPlugin;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

public class TeenFoundersLobby extends JavaPlugin implements Listener {

    private Location spawnLocation;
    private NamespacedKey itemKey;
    private NamespacedKey npcKey;
    private NamespacedKey petKey;
    private final Map<UUID, Entity> playerPets = new HashMap<>();
    private final Random random = new Random();

    @Override
    public void onEnable() {
        itemKey = new NamespacedKey(this, "lobby_item");
        npcKey = new NamespacedKey(this, "lobby_npc");
        petKey = new NamespacedKey(this, "lobby_pet");
        Bukkit.getPluginManager().registerEvents(this, this);

        World world = Bukkit.getWorlds().get(0);
        if (world != null) {
            configureWorld(world);
            
            Location worldSpawn = world.getSpawnLocation();
            if (worldSpawn != null) {
                spawnLocation = new Location(world, worldSpawn.getX() + 0.5, worldSpawn.getY() + 0.5, worldSpawn.getZ() + 0.5, worldSpawn.getYaw(), worldSpawn.getPitch());
            } else {
                spawnLocation = new Location(world, 0.5, 65.0, 0.5, 0.0f, 0.0f);
            }

            purgeMobs(world);
            spawnLobbyNPCs(world);
        }

        getLogger().info("TeenFoundersLobby v5.0 enabled! Singapore Region active, Random Companion Pets, Storyline Quests, PvP Arena Pit online.");
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
            if (entity instanceof Slime || (entity instanceof Mob && !entity.getPersistentDataContainer().has(npcKey, PersistentDataType.STRING) && !entity.getPersistentDataContainer().has(petKey, PersistentDataType.STRING))) {
                entity.remove();
            }
        }
    }

    private void spawnLobbyNPCs(World world) {
        double sx = spawnLocation.getX();
        double sy = spawnLocation.getY();
        double sz = spawnLocation.getZ();

        for (Entity entity : world.getEntities()) {
            if (entity.getPersistentDataContainer().has(npcKey, PersistentDataType.STRING)) {
                entity.remove();
            }
        }

        // 1. Creative Plots Master (X + 5)
        createNPC(world, new Location(world, sx + 5.0, sy, sz, 90.0f, 0.0f), "creative", "§a§lBUILD MASTER", "§fCreative Plots · Right-Click to Join!");

        // 2. Survival Event Champion (X - 5)
        createNPC(world, new Location(world, sx - 5.0, sy, sz, -90.0f, 0.0f), "survival-event", "§c§lSURVIVAL CHAMPION", "§f15-Day Event · Right-Click to Join!");

        // 3. Build Offs Judge (Z + 5)
        createNPC(world, new Location(world, sx, sy, sz + 5.0, 180.0f, 0.0f), "competition", "§b§lBUILD OFFS JUDGE", "§fBuild Competition · Right-Click to Join!");

        // 4. PvP Gladiator (Z - 5)
        createNPC(world, new Location(world, sx, sy, sz - 5.0, 0.0f, 0.0f), "pvp", "§e§lPVP GLADIATOR", "§fPvP Arena · Right-Click to Join!");

        getLogger().info("4 Interactive Server Guide NPCs spawned successfully!");
    }

    private void createNPC(World world, Location loc, String serverTarget, String name, String subtitle) {
        Villager npc = (Villager) world.spawnEntity(loc, EntityType.VILLAGER);
        npc.setCustomName(name);
        npc.setCustomNameVisible(true);
        npc.setProfession(Villager.Profession.LIBRARIAN);
        npc.setVillagerType(Villager.Type.PLAINS);
        npc.setAI(false);
        npc.setInvulnerable(true);
        npc.setSilent(true);
        npc.setCollidable(false);
        npc.getPersistentDataContainer().set(npcKey, PersistentDataType.STRING, serverTarget);

        Location holoLoc = loc.clone().add(0, 2.2, 0);
        ArmorStand holo = (ArmorStand) world.spawnEntity(holoLoc, EntityType.ARMOR_STAND);
        holo.setCustomName(subtitle);
        holo.setCustomNameVisible(true);
        holo.setGravity(false);
        holo.setCanPickupItems(false);
        holo.setVisible(false);
        holo.setMarker(true);
        holo.getPersistentDataContainer().set(npcKey, PersistentDataType.STRING, "holo_" + serverTarget);
    }

    private void spawnRandomPet(Player player) {
        // Remove existing pet if any
        if (playerPets.containsKey(player.getUniqueId())) {
            Entity oldPet = playerPets.get(player.getUniqueId());
            if (oldPet != null && oldPet.isValid()) oldPet.remove();
        }

        World world = player.getWorld();
        Location loc = player.getLocation().add(1, 0, 1);
        int petType = random.nextInt(3);

        Entity pet = null;
        if (petType == 0) {
            Wolf wolf = (Wolf) world.spawnEntity(loc, EntityType.WOLF);
            wolf.setOwner(player);
            wolf.setTamed(true);
            wolf.setCustomName("§6§l" + player.getName() + "'s Companion Wolf");
            pet = wolf;
        } else if (petType == 1) {
            Cat cat = (Cat) world.spawnEntity(loc, EntityType.CAT);
            cat.setOwner(player);
            cat.setTamed(true);
            cat.setCustomName("§b§l" + player.getName() + "'s Mystic Cat");
            pet = cat;
        } else {
            Fox fox = (Fox) world.spawnEntity(loc, EntityType.FOX);
            fox.setCustomName("§e§l" + player.getName() + "'s Founder Fox");
            pet = fox;
        }

        if (pet != null) {
            pet.setCustomNameVisible(true);
            pet.setInvulnerable(true);
            pet.getPersistentDataContainer().set(petKey, PersistentDataType.STRING, player.getUniqueId().toString());
            playerPets.put(player.getUniqueId(), pet);
        }
    }

    @EventHandler(priority = EventPriority.HIGHEST)
    public void onPlayerJoin(PlayerJoinEvent event) {
        Player player = event.getPlayer();
        purgeMobs(player.getWorld());

        // Guaranteed Triple Teleport to Spawn Location
        Bukkit.getScheduler().runTaskLater(this, () -> teleportToSpawn(player), 1L);
        Bukkit.getScheduler().runTaskLater(this, () -> teleportToSpawn(player), 5L);
        Bukkit.getScheduler().runTaskLater(this, () -> teleportToSpawn(player), 15L);

        // Spawn Random Companion Pet
        Bukkit.getScheduler().runTaskLater(this, () -> spawnRandomPet(player), 20L);

        setupPlayerLobbyState(player);

        // Storyline Title & Lore Dialogue
        player.sendTitle("§6§lTEENFOUNDERS", "§fChapter I: The Builder's Awakening", 10, 70, 20);
        player.playSound(player.getLocation(), Sound.ENTITY_PLAYER_LEVELUP, 1.0f, 1.2f);
        player.playSound(player.getLocation(), Sound.BLOCK_NOTE_BLOCK_CHIME, 1.0f, 1.5f);

        player.sendMessage("§6§m--------------------------------------------------");
        player.sendMessage("  §6§lTEENFOUNDERS BUILD NETWORK §7[Singapore Region]");
        player.sendMessage("  §fWelcome, §e" + player.getName() + "§f! Your journey as a Founder begins here.");
        player.sendMessage("  §7• Right-click §aBuild Master §7for Creative Plots");
        player.sendMessage("  §7• Right-click §cSurvival Champion §7for the 15-Day Event");
        player.sendMessage("  §7• Step into the §ePvP Arena Pit §7below spawn to fight!");
        player.sendMessage("  §7Website: §eyouthfounders.in / teenfounders.in");
        player.sendMessage("§6§m--------------------------------------------------");
    }

    @EventHandler
    public void onPlayerQuit(PlayerQuitEvent event) {
        Entity pet = playerPets.remove(event.getPlayer().getUniqueId());
        if (pet != null && pet.isValid()) {
            pet.remove();
        }
    }

    private void teleportToSpawn(Player player) {
        if (spawnLocation != null && player.isOnline()) {
            player.setFallDistance(0.0f);
            player.teleport(spawnLocation);
        }
    }

    @EventHandler
    public void onNPCInteract(PlayerInteractEntityEvent event) {
        Entity entity = event.getRightClicked();
        if (entity.getPersistentDataContainer().has(npcKey, PersistentDataType.STRING)) {
            String target = entity.getPersistentDataContainer().get(npcKey, PersistentDataType.STRING);
            if (target != null && !target.startsWith("holo_")) {
                Player player = event.getPlayer();
                player.playSound(player.getLocation(), Sound.ENTITY_EXPERIENCE_ORB_PICKUP, 1.0f, 1.2f);
                player.sendTitle("§6§lCONNECTING...", "§fSwitching to " + target.toUpperCase() + " server", 5, 40, 10);
                player.performCommand("server " + target);
                event.setCancelled(true);
            }
        }
    }

    @EventHandler
    public void onEntitySpawn(EntitySpawnEvent event) {
        Entity entity = event.getEntity();
        if (entity instanceof Slime || (entity instanceof Mob && !entity.getPersistentDataContainer().has(npcKey, PersistentDataType.STRING) && !entity.getPersistentDataContainer().has(petKey, PersistentDataType.STRING))) {
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
        teleportToSpawn(event.getPlayer());
    }

    private void setupPlayerLobbyState(Player player) {
        player.setGameMode(GameMode.ADVENTURE);
        player.getInventory().clear();

        player.getInventory().setItem(0, createItem(Material.COMPASS, "nav", "§6§lServer Navigator", "§7Right-click to open server menu"));
        player.getInventory().setItem(1, createItem(Material.CLOCK, "cosmetics", "§b§lCosmetics", "§7Right-click to open cosmetics"));
        player.getInventory().setItem(4, createItem(Material.BOOK, "rules", "§e§lRules & Info", "§7Right-click to read network rules"));
        player.getInventory().setItem(8, createItem(Material.EMERALD, "profile", "§a§lMy Profile", "§7Right-click to view your profile"));

        player.updateInventory();
    }

    @EventHandler
    public void onPlayerMove(PlayerMoveEvent event) {
        Player player = event.getPlayer();
        Location loc = player.getLocation();
        
        // Instant Void Protection Guard (Teleports back to spawn if Y < 40)
        if (loc.getY() < 40) {
            teleportToSpawn(player);
            player.playSound(player.getLocation(), Sound.ENTITY_ENDERMAN_TELEPORT, 1.0f, 1.2f);
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
        // Allow damage inside PvP Arena Pit (Z < -15 near PvP NPC)
        Location loc = event.getEntity().getLocation();
        if (loc.getZ() < -15) {
            event.setCancelled(false);
            return;
        }
        event.setCancelled(true);
    }

    @EventHandler(priority = EventPriority.HIGHEST)
    public void onPvP(EntityDamageByEntityEvent event) {
        // Allow PvP combat inside PvP Arena Pit (Z < -15 near PvP NPC)
        Location loc = event.getEntity().getLocation();
        if (loc.getZ() < -15) {
            event.setCancelled(false);
            return;
        }
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
            org.bukkit.block.Block b = event.getClickedBlock();
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
