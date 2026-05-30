# Dragon Rider RPG — Milestone 5 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Repo:** `Wsmith007/dragon-rider-rpg` on GitHub  
**Main scene:** `res://scenes/world/TestWorld.tscn`  
**Branch:** `main` (as of commit `120bbe0`)

This document supersedes the older `project_checkpoint.md` for current prototype status. Milestone 5 focus: **bond scaffold + sync affecting cooperative assist cooldown**, with a major dragon combat refactor (protection vs assist) and UI/debug tooling.

---

## Milestone Summary

| Milestone | Status |
|-----------|--------|
| 1–2 Player, dragon follow, TestWorld | Done |
| 3 Combat foundation (enemies, melee, alert) | Done |
| 4 Dragon combat assistance | Done (refactored) |
| **5 Sync affects dragon behavior** | **Partial — sync → assist cooldown only** |
| 6 Instability reactions | Not started |
| 7 Communication stage | Not started |

---

## Current Working Features

### Player
- Top-down movement (WASD / arrows)
- Smooth camera follow
- Health (`Health` component) + death state
- Melee attack (Area2D hitbox, cooldown, damages enemies)
- **Player engagement** tracking (recent hit + facing) for cooperative dragon assists
- Screen HP UI: **current / max** (e.g. `75 / 120`)

### Dragon
- Follows player via `FollowAnchor` (lag catch-up, no teleport snap)
- Idle reposition when rider is slow
- **Q:** toggle WAIT / FOLLOW (recall)
- **ALERT** when enemy threatens rider (moves to anchor, faces threat)
- **PROTECTING** — automatic defensive strike (chase / close / threat)
- **ASSISTING** — cooperative strike only when player is engaging a target
- Flank **APPROACH** before lunge when path crosses rider
- Rider avoidance during approach/lunge (steer around player)
- Assist/protection **failsafes** (max duration, stuck detection, cancel)
- Enemy avoidance in follow/alert/wait (not during active lunge)
- `collision_mask = 1` (player only — no enemy body collision)

### Bond (scaffold)
- `BondProfile` resource: `bond_strength`, `sync`, `instability`, `trust_state`
- `BondSystem` autoload (global access + `bond_changed` signal)
- **Sync affects cooperative assist cooldown** (tiered by sync value)
- Debug panel (top-right): bond values + dragon state
- F1/F2: adjust sync · F3/F4: adjust instability

### Enemies
- Idle → detect → chase → engage → melee damage
- Health bar above enemy (world-space)
- `is_chasing_player()` / `is_engaging_player()` for protection targeting

### World / UI
- `TestWorld`: ground, floor grid markers, player, dragon, 3 enemies
- Player HP (top-left), bond debug (top-right), debug key help (bottom-left)

---

## Controls

| Action | Input |
|--------|--------|
| Move | **WASD** or **Arrow keys** |
| Attack | **Space**, **J**, or **Left click** |
| Dragon wait / recall | **Q** |
| Sync +5 / −5 | **F1** / **F2** |
| Instability +5 / −5 | **F3** / **F4** |
| Current HP +10 | **F5** |
| Max HP +10 (+ current) | **F6** |
| Max HP −10 (min 10) | **F7** |

**Note:** F8 is not used for health — it stops the game in the Godot editor.

---

## File Structure

```text
dragon-rider-rpg/
  project.godot              # BondSystem autoload, debug_health_* input actions
  docs/
  scenes/
    player/Player.tscn       # + Engagement node
    dragon/Dragon.tscn       # ProtectionBehavior, StrikeBehavior
    enemies/Enemy.tscn       # + HealthBar
    world/TestWorld.tscn
    ui/
      PlayerHealthUI.tscn
      BondDebugUI.tscn
      BondTestHelpUI.tscn
  scripts/
    bond/bond_profile.gd
    player/
      player.gd
      player_melee_attack.gd
      player_dragon_command.gd
      player_engagement.gd
    dragon/
      dragon.gd
      dragon_state.gd
      dragon_follow_behavior.gd
      dragon_threat_behavior.gd
      dragon_command_behavior.gd
      dragon_protection_behavior.gd
      dragon_strike_behavior.gd
      dragon_combat_approach.gd
      dragon_enemy_avoidance.gd
    enemies/enemy.gd
    systems/
      health.gd
      bond_system.gd
      camera_follow.gd
    ui/
      player_health_ui.gd
      health_bar_2d.gd
      bond_debug_ui.gd
      bond_test_controls.gd
      health_debug_controls.gd
    world/
      test_world.gd
      floor_grid_visual.gd
```

---

## Important Scripts

| Script | Role |
|--------|------|
| `bond_profile.gd` | Bond data resource + `profile_changed` |
| `bond_system.gd` | Autoload; owns live profile, adjust helpers |
| `player_engagement.gd` | Recent attack + facing → assist target |
| `dragon.gd` | State orchestrator; protection vs assist priority |
| `dragon_state.gd` | FOLLOWING, WAITING, ALERT, PROTECTING, ASSISTING |
| `dragon_protection_behavior.gd` | Finds threats (chase / close / engage / alert) |
| `dragon_strike_behavior.gd` | APPROACH → LUNGE → RETURN; sync cooldown; failsafes |
| `dragon_combat_approach.gd` | Flank point math (shared) |
| `dragon_threat_behavior.gd` | Rider threat scan → ALERT |
| `dragon_follow_behavior.gd` | Follow, alert anchor, wait, reposition |
| `bond_debug_ui.gd` | Live bond + dragon state readout |
| `health_debug_controls.gd` | F5/F6/F7 health testers (InputMap) |

---

## Dragon State Logic

**Orchestrator:** `dragon.gd` · **Strike executor:** `dragon_strike_behavior.gd`

| State | Meaning | Movement | Notes |
|-------|---------|----------|-------|
| **FOLLOWING** | Default follow | FollowAnchor | Coop assist if player engaging |
| **WAITING** | Hold position (Q) | `wait_position` | Wait-zone protection only |
| **ALERT** | Rider threatened | FollowAnchor | Faces threat; coop assist first, then protection |
| **PROTECTING** | Defensive strike | Strike phases | Automatic; not cooperation |
| **ASSISTING** | Cooperative strike | Strike phases | **Temporary** — always exits via failsafe or completion |

### Protection vs Assist

| | **PROTECTING** | **ASSISTING** |
|--|----------------|---------------|
| **Purpose** | Rider safety | Synchronization / cooperation |
| **Triggers** | Enemy chasing, engaging, very close, or alert threat | Player recent attack or facing target |
| **Cooldown** | `protection_cooldown` (~4.5s) | **Sync-tiered** assist cooldown |
| **Skips** | Player's engaged target (assist handles that enemy) | — |

**Strike phases:** `APPROACH` (flank if blocked) → `LUNGE` → `RETURN`

**Assist failsafes:** `max_assist_duration` (~1.35s), stuck detection (<4px / 0.4s), target invalid/out of range, `cancel_assist(reason)`

```text
FOLLOWING ↔ ALERT → PROTECTING / ASSISTING → return → FOLLOWING or ALERT
WAITING → PROTECTING (nearby threat) → WAITING
Q recall: WAITING → FOLLOWING
```

---

## Bond System

### Where data lives
- **`BondProfile`** — `scripts/bond/bond_profile.gd` (`Resource`, class_name)
- **`BondSystem`** — autoload in `project.godot`; creates profile at run start

### Defaults
| Field | Default |
|-------|---------|
| `bond_strength` | 50 |
| `sync` | 50 |
| `instability` | 0 |
| `trust_state` | `"Neutral"` |

### Implemented bond gameplay
- **Sync → cooperative assist cooldown** (`dragon_strike_behavior.gd`, Inspector-tunable tiers):

| Sync | Assist cooldown (approx.) |
|------|---------------------------|
| 0–35 | 6.5 s |
| 36–85 | 4.0 s |
| 86–100 | 1.5 s |

### Access pattern (for future systems)
```gdscript
var bond := BondSystem.get_profile()
bond.sync = 70.0
# or
BondSystem.adjust_sync(10.0)
BondSystem.bond_changed.connect(_on_bond_changed)
```

### Not implemented yet
- `bond_strength` effects
- `instability` hesitation / misfire
- `trust_state` progression
- `communication_stage`, `resonance_style`
- Bond updates from combat outcomes

---

## Physics Layers

| Layer | Name | Used by |
|-------|------|---------|
| 1 | player | Player body |
| 2 | dragon | Dragon body |
| 3 | enemy | Enemy body |
| 4 | player_attack | Melee hitbox |

---

## Known Fixed Bugs (since Milestone 3 checkpoint)

- Assist conflated with protection → split into PROTECTING vs ASSISTING
- Assist on any nearby enemy in ALERT → requires player engagement
- Dragon stuck in ASSISTING forever (player blocking path) → timeout, stuck detect, rider avoidance, `cancel_assist`
- Dragon lunging through player → flank APPROACH + steer-around
- F8 closing editor instead of HP down → max HP down moved to **F7** + InputMap
- Enemy HP bars, player HP UI, floor grid markers added (visual-only pass)

---

## Not Yet Implemented

- Instability affecting behavior (Milestone 6)
- Communication stage evolution (Milestone 7)
- Bond strength / trust_state gameplay hooks
- Player dodge
- Race selection (Human / Elf)
- Save/load, EventBus, inventory, real map art
- Full bond update loop from combat → bond change

---

## Next Recommended Work

**Milestone 6 — Instability reactions**
1. Hook `instability` into assist misfire, hesitation, or wrong-target chance
2. Optional visual/audio feedback when instability is high
3. Keep using F3/F4 debug keys to test

**Quick wins**
- Player dodge (vertical slice pillar)
- `bond_strength` lightly affecting protection eagerness or follow distance
- Update `project_checkpoint.md` or retire it in favor of this file

---

## Design Reference

- Core loop: **Player intent → Bond → Dragon AI → Action → Bond update**
- Dragon is semi-autonomous; bond influences cooperation, not direct control
- Canonical bond fields: `bond_strength`, `sync`, `instability`, `trust_state`, `communication_stage`, `resonance_style`
- Read `docs/bond_system.md`, `docs/vertical_slice_plan.md`, `docs/technical_architecture.md` before generating code

---

## Git / PR Notes

Recent main commits include:
- Visual feedback (HP bars, grid, player HUD)
- Bond scaffold, protection/assist refactor, strike failsafes (`120bbe0`)

Use this doc as the handoff point for Milestone 6+ work.
