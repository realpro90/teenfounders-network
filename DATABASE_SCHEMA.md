# Database Schema Reference - TeenFounders Network

The PostgreSQL schema for TeenFounders Network is located at [database/schema.sql](file:///Users/aaravkumar/untitled%20folder%202/database/schema.sql).

---

## Table Descriptions

1. **`players`**: Core player account metadata, UUID, username, last login, and current server location.
2. **`player_ranks`**: LuckPerms rank inheritance, permissions, and temporary rank expirations.
3. **`economy`**: Network monetary balances and premium token counts.
4. **`player_statistics`**: Aggregated block placement, PvP kills, deaths, and competition victories.
5. **`player_playtime`**: Cumulative session tracking and total playtime.
6. **`player_homes`**: Multi-server saved home locations.
7. **`plot_ownership`**: PlotSquared creative plot owner UUIDs, coordinates, and community ratings.
8. **`plot_trusted`**: Co-builders and trusted players assigned to creative plots.
9. **`player_friends`**: Cross-server friend list and pending friend requests.
10. **`player_mail`**: Off-line player mail messaging system.
11. **`player_preferences`**: Movement speed, flight, night vision, and chat settings.
12. **`player_cosmetics`**: Unlocked particle trails, hats, armor colors, and titles.
13. **`player_achievements`**: Network achievement progression.
14. **`daily_rewards`**: Consecutive login streak tracking and reward timestamps.
15. **`punishments`**: Bans, mutes, kicks, warnings, and staff moderation history.
16. **`event_progress`**: 15-day seasonal survival event points, missions, and boss kills.
17. **`leaderboards`**: High-performance cached rankings for top builders and PvP players.
