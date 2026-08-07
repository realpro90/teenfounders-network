# TeenFounders 15-Day Survival Championship Engine

The **Survival Championship** is the flagship competition of the TeenFounders Minecraft Network. Every season runs for exactly 15 days in a brand new, ungenerated survival world.

---

## 🏆 Season Lifecycle & Timeline

```
┌────────────────────────────────────────────────────────────────────────┐
│                        15-DAY CHAMPIONSHIP LIFECYCLE                   │
├────────────────────────────────────────────────────────────────────────┤
│  DAY 1 - DAY 15: PROGRESSION & SURVIVAL                                │
│  • Fresh survival world generation.                                    │
│  • Resource gathering, base building, alliances, and trading.          │
│  • Points awarded for achievements, quests, and boss kills.            │
│                                                                        │
│  DAY 15: THE CHAMPIONSHIP FINALE                                       │
│  • Server locks to existing players (no new joins permitted).          │
│  • 10-second warning banner displayed across screen.                   │
│  • All online survivors teleported to the PvP Championship Arena.      │
│  • World Border shrinks from 200 blocks down to 1 block over 3 minutes.│
│                                                                        │
│  CROWNING THE CHAMPION                                                 │
│  • Last surviving player declared Season Champion.                     │
│  • In-game title, Discord role, and network badge granted.             │
│  • Verification Token generated: TF-CHAMP-S<season_id>-<hash>          │
│  • Archived in PostgreSQL database (championship_winners).             │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🔑 Website Verification Tokens & Digital Certificates

When a player wins the Survival Championship, the network generates a unique cryptographic **Verification Token** formatted as:

```
TF-CHAMP-S1-a9f8b7c6d5e4f3a2
```

### Claiming Process on `https://teenfounders.in`:

1. The winner copies their token from `/championship` or server broadcast.
2. The winner navigates to **https://teenfounders.in/verify** (or profile dashboard).
3. The platform validates the token against the PostgreSQL database (`championship_winners`).
4. Upon successful verification, TeenFounders issues an official **Digital Survival Champion Certificate** showcased on the player's profile!

---

## 🛠️ Administrative Commands & Triggers

To manually trigger or test championship phases:

```bash
# Trigger Finale Mode (lock joins, teleport players, shrink border)
/server/scripts/championship_manager.sh finale

# Crown Winner & Generate Verification Token manually
/server/scripts/championship_manager.sh winner <UUID> <PlayerUsername>
```
