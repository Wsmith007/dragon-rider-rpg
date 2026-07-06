# Dragon Rider RPG — Milestone 5+ Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Repo:** `Wsmith007/dragon-rider-rpg` on GitHub  
**Main scene:** `res://scenes/world/TestWorld.tscn`  
**Branch:** `main`

This document is the **source of truth** for current prototype status. The older `project_checkpoint.md` is retained for historical Milestone 3 context only — prefer this file for active development.

---

## Milestone Summary

| Milestone | Status |
|-----------|--------|
| 1–2 Player, dragon follow, TestWorld | Done |
| 3 Combat foundation (enemies, melee, alert) | Done |
| 4 Dragon combat assistance | Done (refactored) |
| **5 Sync affects dragon behavior** | **Done — sync → assist cooldown** |
| **6 Instability reactions** | **Partial — hesitation + assist cancel** |
| 7 Communication stage | Not started |

---

## Active Bond Model (3 Stats)

Gameplay uses three active numeric stats. **`bond_strength` is the primary relationship stat.**

| Stat | Role | Implemented gameplay |
|------|------|----------------------|
| **Bond Strength** | Relationship depth / connection | Protection radius, response delay, persistence |
| **Sync** | Coordination / cooperation | Cooperative assist cooldown tiers |
| **Instability** | Strain / reliability | Assist hesitation chance + post-hesitation cancel chance |

### Deprecated (compatibility only)

| Field | Status |
|-------|--------|
| `trust_state` | **Deprecated** — kept on `BondProfile` for save/API compatibility. **Not used in gameplay.** Not shown in debug UI. Future command responsiveness belongs under `bond_strength`, not trust. |
| `communication_stage` | Design-only — not in code yet |
| `resonance_style` | Design-only — not in code yet |

---

## Current Working Features

### Player
- Top-down movement (WASD / arrows)
- Smooth camera follow
- Health (`Health` component) + death state
- Melee attack (Area2D hitbox, cooldown, damages enemies)
- **Player engagement** tracking (recent hit + facing) for cooperative dragon assists
- Screen HP UI: **current / max**

### Dragon
- Follows player via `FollowAnchor` (lag catch-up, no teleport snap)
- Idle reposition when rider is slow
- **Q:** toggle WAIT / FOLLOW (recall) — instant; bond-strength command delay **planned, not wired**
- **ALERT** when enemy threatens rider
- **HESITATING** before cooperative assist (instability-driven)
- **PROTECTING** — automatic defensive strike (bond-strength tuned)
- **ASSISTING** — cooperative strike when player is engaging a target
- Flank **APPROACH** before lunge when path crosses rider
- Assist/protection **failsafes** (max duration, stuck detection, cancel)
- Safe enemy reference cleanup on death (`enemy_died` signal + `EnemyValidation`)

### Bond (scaffold + gameplay hooks)
- `BondProfile`: `bond_strength`, `sync`, `instability`, `trust_state` (deprecated)
- `BondSystem` autoload
- **Sync → assist cooldown** (tiered)
- **Instability → hesitation + cancel** (cooperative assist only)
- **Bond Strength → protection** (radius, delay, persistence)
- Debug panel: 3 active stats + protection tuning readout + dragon state
- Ctrl+1/2 bond strength · Ctrl+3/4 sync · Ctrl+5/6 instability

### Enemies
- Idle → detect → chase → engage → melee damage
- Health bar above enemy
- Idempotent death + `enemy_died` signal

### World / UI
- `TestWorld`: player, dragon, 5 enemies (spread spawns), floor grid
- Player HP, bond debug, debug key help, off-screen enemy indicators

---

## Controls

| Action | Input |
|--------|--------|
| Move | **WASD** or **Arrow keys** |
| Attack | **Space**, **J**, or **Left click** |
| Dragon wait / recall | **Q** |
| Bond Strength +5 / −5 | **Ctrl+1** / **Ctrl+2** |
| Sync +5 / −5 | **Ctrl+3** / **Ctrl+4** |
| Instability +5 / −5 | **Ctrl+5** / **Ctrl+6** |
| Current HP +10 | **F5** |
| Max HP +10 (+ current) | **F6** |
| Max HP −10 (min 10) | **F7** |

---

## Bond System Detail

### Where data lives
- **`BondProfile`** — `scripts/bond/bond_profile.gd`
- **`BondSystem`** — autoload in `project.godot`

### Defaults
| Field | Default | Active? |
|-------|---------|---------|
| `bond_strength` | 50 | Yes |
| `sync` | 50 | Yes |
| `instability` | 0 | Yes |
| `trust_state` | `"Neutral"` | **No (deprecated)** |

### Sync → assist cooldown

| Sync | Assist cooldown (approx.) |
|------|---------------------------|
| 0–35 | 6.5 s |
| 36–85 | 4.0 s |
| 86–100 | 1.5 s |

### Instability → cooperative assist reliability

| Instability | Hesitation | Cancel (after hesitation) |
|-------------|------------|---------------------------|
| 0–25 | 0% | 0% |
| 26–50 | 20% | 25% |
| 51–75 | 40% | 50% |
| 76–100 | 65% | 80% |

Protection is **not** affected by instability.

### Bond Strength → protection

| Bond Strength | Radius | Response delay | Persistence |
|---------------|--------|----------------|-------------|
| 0–25 | 100 | 0.75 s | 1 s |
| 26–50 | 150 | 0.50 s | 2 s |
| 51–75 | 200 | 0.25 s | 3 s |
| 76–100 | 250 | 0 s | 5 s |

### Bond Strength → command responsiveness (planned)

`BondProfile.get_command_response_delay()` defines tiers matching protection delay philosophy. **Not wired to Q toggle yet** — Q remains instant.

---

## Dragon State Logic

| State | Meaning |
|-------|---------|
| **FOLLOWING** | Default follow |
| **WAITING** | Hold position (Q) |
| **ALERT** | Rider threatened |
| **HESITATING** | Cooperative assist gate (instability) |
| **PROTECTING** | Defensive strike (bond strength) |
| **ASSISTING** | Cooperative strike (sync + instability) |

### Protection vs Assist

| | **PROTECTING** | **ASSISTING** |
|--|----------------|---------------|
| **Stat driver** | Bond Strength | Sync + Instability |
| **Triggers** | Threats near rider | Player engagement |
| **Cooldown** | Protection cooldown | Sync-tiered assist cooldown |

---

## Not Yet Implemented

- Command delay/refusal on Q (bond strength tiers exist as helper only)
- `communication_stage`, `resonance_style` in code
- Bond updates from combat outcomes (bond loop)
- Player dodge, race selection, save/load
- Complete removal of `trust_state`

---

## Next Recommended Work

1. Wire `bond_strength` command response delay to Q (optional hesitation before WAIT/recall)
2. Bond update loop from combat → stat changes
3. Milestone 7 communication stage scaffold
4. Player dodge

---

## Design Reference

- Core loop: **Player intent → Bond → Dragon AI → Action → Bond update**
- **Bond Strength** = relationship depth (protection, future commands)
- **Sync** = coordination (assist frequency)
- **Instability** = strain (assist reliability)
- **Trust (`trust_state`)** = deprecated; retained for compatibility only

Read `../design/bond_system.md` and `../design/dragon_ai.md` for the 3-stat model in design prose.
