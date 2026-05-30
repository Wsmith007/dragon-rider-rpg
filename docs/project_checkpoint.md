# Dragon Rider RPG — Project Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Repo:** `Wsmith007/dragon-rider-rpg` on GitHub  
**Main scene:** `res://scenes/world/TestWorld.tscn`  
**Active dev branch (recent work):** `cursor/milestone-3-combat-foundation`

---

## Current Working Features

### Player
- Top-down movement (WASD / arrows)
- Smooth camera follow
- Health (100 HP) + death state
- Melee attack (Area2D hitbox, cooldown, damages enemies)

### Dragon
- Follows player via `FollowAnchor` (offset behind rider)
- Lag catch-up (no hard teleport snap)
- Idle reposition when player is slow (random point near anchor, cooldown-based)
- **Q command:** toggle WAIT / FOLLOW (recall)
- Wait position memory + return after self-defense
- **ALERT** when enemy near **player** (moves to rider anchor, faces enemy)
- **ASSISTING** — brief lunge, one hit, return to player/wait point (cooldown)
- Wait-mode self-defense (enemy in defense radius, defense cooldown)
- Enemy avoidance (separation + sidestep) in FOLLOW/ALERT/WAIT — not during assist lunge
- No physical collision with enemies (mask = player only)

### Enemies
- Idle → detect player → chase → stop in range → melee damage (cooldown)
- Health + death + `queue_free`

### World
- `TestWorld` with player, dragon, 3 test enemies, placeholder ground

### Docs (design only, not implemented in code)
- `docs/` — architecture, bond system, combat, races, lore, story, vertical slice plan

---

## Controls

| Action | Input |
|--------|--------|
| Move | **WASD** or **Arrow keys** |
| Attack | **Space**, **J**, or **Left click** |
| Dragon wait / recall | **Q** |

---

## File Structure

```text
dragon-rider-rpg/
  project.godot
  docs/                    # Design docs (9 .md files)
  scenes/
    player/Player.tscn
    dragon/Dragon.tscn
    enemies/Enemy.tscn
    world/TestWorld.tscn
  scripts/
    player/
      player.gd
      player_melee_attack.gd
      player_dragon_command.gd
    dragon/
      dragon.gd              # State orchestrator
      dragon_state.gd        # State enum
      dragon_follow_behavior.gd
      dragon_threat_behavior.gd
      dragon_command_behavior.gd
      dragon_assist_behavior.gd
      dragon_enemy_avoidance.gd
    enemies/enemy.gd
    systems/
      health.gd
      camera_follow.gd
    world/test_world.gd
```

---

## Important Scripts

| Script | Role |
|--------|------|
| `player.gd` | Movement, health signals, death |
| `player_melee_attack.gd` | Attack input, brief hitbox, enemy damage |
| `player_dragon_command.gd` | **Q** → emits toggle signal |
| `dragon.gd` | **Main dragon brain** — state machine, wires all behavior nodes |
| `dragon_state.gd` | `FOLLOWING`, `WAITING`, `ALERT`, `ASSISTING` enum |
| `dragon_follow_behavior.gd` | Movement: follow, alert anchor, wait, reposition + avoidance |
| `dragon_threat_behavior.gd` | Scans enemies near **rider** → ALERT |
| `dragon_command_behavior.gd` | WAIT/FOLLOW command + `wait_position` memory |
| `dragon_assist_behavior.gd` | Lunge → one hit → return lifecycle, cooldowns |
| `dragon_enemy_avoidance.gd` | Separation + path sidestep (static helper) |
| `enemy.gd` | Idle/chase/engage AI, player damage |
| `health.gd` | Reusable HP component (`take_damage`, `died`, death guard) |
| `camera_follow.gd` | Smooth camera lerp to player |
| `test_world.gd` | Wires player ↔ dragon ↔ camera ↔ Q command |

---

## Dragon State Logic

**Orchestrator:** `dragon.gd` owns `state: DragonState.State`

| State | Movement target | Look target | Notes |
|-------|-----------------|-------------|-------|
| **FOLLOWING** | `FollowAnchor` | Velocity | Idle reposition when player slow, no threat |
| **WAITING** | Stored `wait_position` | Velocity | Ignores rider ALERT; defends if enemy in defense radius |
| **ALERT** | `FollowAnchor` (near player) | Enemy | Threat = enemy within radius of **rider** |
| **ASSISTING** | Enemy (lunge) → return point | Enemy during lunge, player on return | Only state that intentionally moves toward enemy |

**Flow:**

```text
FOLLOWING ↔ ALERT → ASSISTING (lunge/return) → ALERT or FOLLOWING
WAITING → ASSISTING (defense) → WAITING
Q recall: WAITING → FOLLOWING (catch-up movement, no teleport)
```

**Component layers (modular):**
- `FollowBehavior` — movement math
- `ThreatBehavior` — rider threat scan
- `CommandBehavior` — wait/recall
- `AssistBehavior` — combat assist lifecycle
- `DragonEnemyAvoidance` — steer around enemies (not during lunge)

**Signals:** `state_changed`, `behavior_changed`, `dragon_assisted`

---

## Physics Layers

| Layer | Name | Used by |
|-------|------|---------|
| 1 | player | Player body |
| 2 | dragon | Dragon body |
| 3 | enemy | Enemy body |
| 4 | player_attack | Melee hitbox |

Dragon `collision_mask = 1` (player only — **no enemy body collision**).

---

## Known Fixed Bugs

- Dragon falling behind player indefinitely → lag catch-up speed + leash (soft, no snap)
- Recall from WAIT teleporting → removed position snap; uses follow catch-up
- Wait defense spamming lunges → defense cooldown + block same target
- Assist latching on enemy → clear target on hit, phased lifecycle (LUNGE→RETURN→IDLE)
- Freed enemy crash in `enter_alert` → `is_instance_valid` + threat re-scan
- Double enemy death / attack crash → `Health._death_handled`, enemy `_is_dying`
- ALERT moving toward enemy → movement uses FollowAnchor only; enemy = look only
- Idle reposition oscillation → anchor-based targets, min distance, single target per cooldown
- Enemy-between-player latch → removed dragon-enemy collision + avoidance/sidestep

---

## Not Yet Implemented

- Bond system (`bond_strength`, `sync`, `instability`, `trust_state`, etc.)
- Bond UI, race selection, sync affecting behavior
- Player dodge, dragon personality, EventBus autoloads
- Save/load, inventory, magic, factions, dialogue, real map art
- Milestones 5–7 from vertical slice (sync/instability affecting behavior, communication evolution)

---

## Next Recommended Milestone

**Milestone 5 — Sync affects dragon behavior** (from `docs/vertical_slice_plan.md`)

Scaffold only (no full bond RPG yet):
1. `BondProfile` resource / autoload with the six canonical fields
2. Simple UI readout of bond values
3. Hook `sync` into assist cooldown, follow distance, or alert response delay
4. Prove bond state visibly changes dragon cooperation

Alternative quick win before bond: **player dodge** + **simple bond UI placeholder** to support testing Milestone 5.

---

## Design Reference (for new chats)

- Central loop: **Player intent → Bond → Dragon AI → Action → Bond update**
- Dragon is semi-autonomous; player influences via trust/sync/commands, not direct control
- Canonical bond fields: `bond_strength`, `sync`, `instability`, `trust_state`, `communication_stage`, `resonance_style`
- Read `docs/vertical_slice_plan.md` and `docs/technical_architecture.md` before generating code
