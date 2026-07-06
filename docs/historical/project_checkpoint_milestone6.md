# Dragon Rider RPG — Milestone 6 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Repo:** `Wsmith007/dragon-rider-rpg` on GitHub  
**Main scene:** `res://scenes/world/TestWorld.tscn`  
**Branch:** `main`

This document is the **source of truth** for current prototype status. Prefer this over `project_checkpoint_milestone5.md` and the older `project_checkpoint.md`.

---

## Milestone Summary

| Milestone | Status |
|-----------|--------|
| 1–2 Player, dragon follow, TestWorld | Done |
| 3 Combat foundation (enemies, melee, alert) | Done |
| 4 Dragon combat assistance | Done |
| 5 Sync → assist cooldown | Done |
| 6 Instability reactions | Partial — hesitation + assist cancel (cooperative only) |
| **6+ Bond Strength → command delay** | **Done — Q wait/recall responsiveness** |
| 7 Communication stage | Not started |

---

## Recent Change (since Milestone 5)

**Bond Strength now affects wait/recall command delay (Q).**

- `BondProfile.get_command_response_delay()` drives tiered delay before WAIT/RECALL executes.
- `DragonCommandBehavior` owns pending command timing; `dragon.gd` applies state on execution.
- Dragon always obeys — no refusal, no Trust system.
- Double-Q while pending cancels the same pending command (toggle-back).
- Debug: console prints + bond panel shows **Pending Cmd** and **Cmd Delay** remaining.
- Help UI restyled (larger/darker text, light panel backdrop).
- Bond stat debug keys moved to **Ctrl+1–6** (health keys unchanged on F5–F7).

---

## Current Working Features

### Player
- Top-down movement (WASD / arrows), smooth camera follow
- Health component + death state; screen HP (current / max)
- Melee attack (Area2D, cooldown, damages enemies)
- Player engagement tracking (recent hit + facing) for cooperative assists

### Dragon
- Follow via `FollowAnchor` (lag catch-up, idle reposition)
- **Q:** WAIT / RECALL with bond-strength response delay
- **ALERT** when enemy threatens rider
- **HESITATING** before cooperative assist (instability)
- **PROTECTING** — automatic defensive strike (bond strength)
- **ASSISTING** — cooperative strike (sync + instability)
- Flank approach before lunge; assist/protection failsafes
- Safe enemy cleanup on death (`enemy_died` + `EnemyValidation`)

### Bond
- 3 active stats: `bond_strength`, `sync`, `instability`
- `trust_state` deprecated (compatibility only, not in gameplay)
- Sync → assist cooldown tiers
- Instability → cooperative assist hesitation + cancel
- Bond Strength → protection (radius, delay, persistence)
- Bond Strength → command responsiveness (wait/recall delay)
- Debug panel + on-screen help + Ctrl stat testers

### Enemies & World
- Enemy AI: idle → chase → engage → melee; health bar; idempotent death
- `TestWorld`: player, dragon, 5 enemies, floor grid
- Off-screen enemy indicators

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

## Dragon States

| State | Meaning | Primary driver |
|-------|---------|----------------|
| **FOLLOWING** | Default follow | — |
| **WAITING** | Hold position (Q, after delay) | Player command |
| **ALERT** | Rider threatened | Threat detection |
| **HESITATING** | Assist gate pause | Instability |
| **PROTECTING** | Defensive strike | Bond Strength |
| **ASSISTING** | Cooperative strike | Sync + Instability |

Protection is bond-strength driven. Assist is sync/instability driven. Command delay does not add a new state — pending commands run while dragon stays in current activity state until execution.

---

## Bond Stats (3-stat model)

| Stat | Role | Affects |
|------|------|---------|
| **Bond Strength** | Relationship / connection | Protection radius, protection response delay, protection persistence, **Q wait/recall delay** |
| **Sync** | Coordination | Cooperative assist cooldown frequency |
| **Instability** | Strain / reliability | Cooperative assist hesitation chance, post-hesitation cancel chance |

**Not affected by instability:** protection, wait/recall commands.

### Bond Strength tiers (protection + command delay)

All systems use **BondResilience** tier boundaries: 0–30, 31–60, 61–85, 86–100.

| Tier | Bond Strength | Protection radius | Protection delay | Persistence | **Q command delay** |
|------|---------------|-------------------|------------------|-------------|---------------------|
| 1 | 0–30 | 100 | 0.75 s | 1 s | **0.75 s** |
| 2 | 31–60 | 150 | 0.50 s | 2 s | **0.50 s** |
| 3 | 61–85 | 200 | 0.25 s | 3 s | **0.25 s** |
| 4 | 86–100 | 250 | 0 s | 5 s | **0 s (instant)** |

### Sync → assist cooldown

| Sync | Cooldown (approx.) |
|------|---------------------|
| 0–35 | 6.5 s |
| 36–85 | 4.0 s |
| 86–100 | 1.5 s |

### Instability → cooperative assist only

| Instability | Hesitation | Cancel (after hesitation) |
|-------------|------------|---------------------------|
| 0–25 | 0% | 0% |
| 26–50 | 20% | 25% |
| 51–75 | 40% | 50% |
| 76–100 | 65% | 80% |

---

## Known Stable Systems

- Player movement, attack, health, death
- Dragon follow / wait / recall (with delay + cancel-safe pending)
- Threat → alert; bond-strength protection pipeline
- Sync-tiered assist cooldown; instability hesitation/cancel (assist only)
- Enemy AI, damage, death signal, reference cleanup
- Bond debug UI, help panel, stat test keys
- Off-screen enemy indicators

---

## Known Remaining Limitations

- No command **refusal** (by design — delay only, always obeys)
- `trust_state` still on profile for compatibility; not removed from saves
- `communication_stage`, `resonance_style` — design only, not in code
- No bond update loop from combat outcomes (stats are debug-adjusted only)
- No player dodge, race selection, save/load, or Milestone 7 communication stage
- Instability milestone incomplete if broader non-assist reactions are desired later
- Single test scene; no progression or narrative systems

---

## Next Recommended Milestone

1. **Bond update loop** — combat outcomes adjust bond_strength / sync / instability
2. **Milestone 7 communication stage** — scaffold `communication_stage` in profile + first gameplay hook
3. **Player dodge** — defensive option without breaking engagement tracking
4. **Save/load** — persist `BondProfile` (including deprecated fields for migration)

---

## Key Files

| Area | Path |
|------|------|
| Bond data | `scripts/bond/bond_profile.gd` |
| Bond tier source of truth | `scripts/bond/bond_resilience.gd` |
| Bond autoload | `scripts/systems/bond_system.gd` |
| Command delay | `scripts/dragon/dragon_command_behavior.gd` |
| Dragon orchestration | `scripts/dragon/dragon.gd` |
| Protection | `scripts/dragon/dragon_protection_behavior.gd` |
| Assist / hesitation | `scripts/dragon/dragon_cooperation_behavior.gd` |
| Debug UI | `scripts/ui/bond_debug_ui.gd`, `scenes/ui/BondTestHelpUI.tscn` |
| Stat test keys | `scripts/ui/bond_test_controls.gd` |

Design reference: `../design/bond_system.md`, `../design/dragon_ai.md`, `../design/game_architecture.md`.
