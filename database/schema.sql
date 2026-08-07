-- ==============================================================================
-- TeenFounders Network - Production PostgreSQL Database Schema
-- Stores players, ranks, permissions, statistics, playtime, economy, plots,
-- friends, mail, preferences, cosmetics, achievements, rewards, punishments,
-- AND 15-Day Survival Championship Seasons, Verification Tokens & Certificates.
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Players Table
CREATE TABLE IF NOT EXISTS players (
    uuid UUID PRIMARY KEY,
    username VARCHAR(16) NOT NULL,
    first_joined TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_joined TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_ip VARCHAR(45),
    online BOOLEAN DEFAULT false,
    current_server VARCHAR(32) DEFAULT 'lobby'
);

CREATE INDEX IF NOT EXISTS idx_players_username ON players(username);

-- 2. Ranks & Permissions Table (LuckPerms compatibility)
CREATE TABLE IF NOT EXISTS player_ranks (
    uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    rank_name VARCHAR(32) NOT NULL DEFAULT 'guest',
    primary_group BOOLEAN DEFAULT true,
    expiry TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (uuid, rank_name)
);

-- 3. Economy Table
CREATE TABLE IF NOT EXISTS economy (
    uuid UUID PRIMARY KEY REFERENCES players(uuid) ON DELETE CASCADE,
    balance NUMERIC(15, 2) DEFAULT 1000.00 CHECK (balance >= 0),
    tokens INT DEFAULT 0 CHECK (tokens >= 0),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Statistics Table
CREATE TABLE IF NOT EXISTS player_statistics (
    uuid UUID PRIMARY KEY REFERENCES players(uuid) ON DELETE CASCADE,
    blocks_placed BIGINT DEFAULT 0,
    blocks_broken BIGINT DEFAULT 0,
    pvp_kills INT DEFAULT 0,
    pvp_deaths INT DEFAULT 0,
    competitions_entered INT DEFAULT 0,
    competitions_won INT DEFAULT 0,
    plots_owned INT DEFAULT 0
);

-- 5. Playtime Table
CREATE TABLE IF NOT EXISTS player_playtime (
    uuid UUID PRIMARY KEY REFERENCES players(uuid) ON DELETE CASCADE,
    total_seconds BIGINT DEFAULT 0,
    session_start TIMESTAMP WITH TIME ZONE
);

-- 6. Homes Table
CREATE TABLE IF NOT EXISTS player_homes (
    id SERIAL PRIMARY KEY,
    uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    home_name VARCHAR(32) NOT NULL,
    server VARCHAR(32) NOT NULL,
    world VARCHAR(64) NOT NULL,
    x DOUBLE PRECISION NOT NULL,
    y DOUBLE PRECISION NOT NULL,
    z DOUBLE PRECISION NOT NULL,
    yaw REAL NOT NULL,
    pitch REAL NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (uuid, home_name)
);

-- 7. Plot Ownership Table
CREATE TABLE IF NOT EXISTS plot_ownership (
    plot_id VARCHAR(64) PRIMARY KEY,
    owner_uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    world_name VARCHAR(64) DEFAULT 'creative_plots',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    rating_avg REAL DEFAULT 0.0,
    ratings_count INT DEFAULT 0
);

-- 8. Plot Trusted Players Table
CREATE TABLE IF NOT EXISTS plot_trusted (
    plot_id VARCHAR(64) REFERENCES plot_ownership(plot_id) ON DELETE CASCADE,
    trusted_uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    permission_level VARCHAR(16) DEFAULT 'builder',
    PRIMARY KEY (plot_id, trusted_uuid)
);

-- 9. Friends System Table
CREATE TABLE IF NOT EXISTS player_friends (
    user_uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    friend_uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    status VARCHAR(16) DEFAULT 'pending', -- pending, accepted, blocked
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_uuid, friend_uuid)
);

-- 10. Mail & Messaging Table
CREATE TABLE IF NOT EXISTS player_mail (
    id SERIAL PRIMARY KEY,
    sender_uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    recipient_uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    message TEXT NOT NULL,
    read_status BOOLEAN DEFAULT false,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 11. Preferences Table
CREATE TABLE IF NOT EXISTS player_preferences (
    uuid UUID PRIMARY KEY REFERENCES players(uuid) ON DELETE CASCADE,
    flight_enabled BOOLEAN DEFAULT false,
    night_vision BOOLEAN DEFAULT false,
    chat_visible BOOLEAN DEFAULT true,
    pm_enabled BOOLEAN DEFAULT true,
    fly_speed REAL DEFAULT 1.0,
    walk_speed REAL DEFAULT 1.0
);

-- 12. Cosmetics Table
CREATE TABLE IF NOT EXISTS player_cosmetics (
    uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    cosmetic_id VARCHAR(64) NOT NULL,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    equipped BOOLEAN DEFAULT false,
    PRIMARY KEY (uuid, cosmetic_id)
);

-- 13. Achievements Table
CREATE TABLE IF NOT EXISTS player_achievements (
    uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    achievement_id VARCHAR(64) NOT NULL,
    unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (uuid, achievement_id)
);

-- 14. Daily Rewards Table
CREATE TABLE IF NOT EXISTS daily_rewards (
    uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    streak_count INT DEFAULT 0,
    last_claimed TIMESTAMP WITH TIME ZONE
);

-- 15. Punishments Table (Bans, Mutes, Kicks, Warnings)
CREATE TABLE IF NOT EXISTS punishments (
    id SERIAL PRIMARY KEY,
    target_uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    staff_uuid UUID,
    punishment_type VARCHAR(16) NOT NULL, -- BAN, MUTE, KICK, WARN
    reason TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE,
    active BOOLEAN DEFAULT true
);

-- 16. SURVIVAL CHAMPIONSHIP SEASONS TABLE
CREATE TABLE IF NOT EXISTS championship_seasons (
    season_id SERIAL PRIMARY KEY,
    season_name VARCHAR(64) NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(16) DEFAULT 'ACTIVE', -- ACTIVE, FINALE, COMPLETED
    winner_uuid UUID REFERENCES players(uuid),
    verification_token VARCHAR(128) UNIQUE
);

-- 17. SURVIVAL CHAMPIONSHIP WINNERS ARCHIVE & CERTIFICATE TOKENS
CREATE TABLE IF NOT EXISTS championship_winners (
    id SERIAL PRIMARY KEY,
    season_id INT REFERENCES championship_seasons(season_id) ON DELETE CASCADE,
    winner_uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    won_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    verification_token VARCHAR(128) NOT NULL UNIQUE,
    certificate_claimed BOOLEAN DEFAULT false,
    discord_reward_claimed BOOLEAN DEFAULT false
);

-- 18. SURVIVAL CHAMPIONSHIP LEADERBOARD & PROGRESS
CREATE TABLE IF NOT EXISTS championship_leaderboard (
    season_id INT REFERENCES championship_seasons(season_id) ON DELETE CASCADE,
    player_uuid UUID REFERENCES players(uuid) ON DELETE CASCADE,
    total_points INT DEFAULT 0,
    quests_completed INT DEFAULT 0,
    bosses_defeated INT DEFAULT 0,
    survival_time_seconds BIGINT DEFAULT 0,
    PRIMARY KEY (season_id, player_uuid)
);

-- Index for fast token validation on teenfounders.in website API
CREATE INDEX IF NOT EXISTS idx_champ_verification_token ON championship_winners(verification_token);
