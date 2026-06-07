# Dragon Rider RPG — Milestone 7 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Repo:** `Wsmith007/dragon-rider-rpg` on GitHub  
**Main scene:** `res://scenes/world/TestWorld.tscn`  
**Branch:** `main`

This document is the **source of truth** for current prototype status. Prefer this over older checkpoint files.

---

## Milestone Summary

| Milestone | Status |
|-----------|--------|
| 1–2 Player, dragon follow, TestWorld | Done |
| 3 Combat foundation (enemies, melee, alert) | Done |
| 4 Dragon combat assistance | Done |
| 5 Sync → assist cooldown | Done |
| 6 Instability reactions | Partial — hesitation + assist cancel (assist only) |
| 6+ Bond Strength → command delay | Done |
| **7 Unified Bond tiers + resilience framework** | **Done** |
| **7 Dragon communication + speech bubbles** | **Done** |
| **7 Bond-scaled alert + protection ranges** | **Done** |
| Bond update loop | Not started |
| Wire resilience helpers to gameplay | Not started |
| `communication_stage` in profile | Not started |

---

## Current Working Features

### Player
- Top-down movement (WASD / arrows), smooth camera follow
- Health + death; screen HP (current / max)
- Melee attack (Area2D, cooldown, damages enemies)
- Player engagement tracking (recent hit + facing) for cooperative assists

### Dragon
- Follow via `FollowAnchor` (lag catch-up, idle reposition)
- **Q:** WAIT / RECALL with bond-strength response delay (pending, cancel-safe)
- **ALERT** — bond-scaled threat awareness (separate from protection)
- **PROTECTING** — bond-scaled defensive strike
- **HESITATING** / assist cancel — instability (cooperative assist only)
- **ASSISTING** — cooperative strike (sync + instability)
- Flank approach; failsafes; safe enemy cleanup on death

### Bond
- 3 active stats: `bond_strength`, `sync`, `instability`
- `trust_state` deprecated (compatibility only)
- Unified tiers via `BondResilience` (single source of truth)
- Resilience helpers calculated; sync floor / instability resistance / recovery **not wired**
- Debug panel (tier, alert/protection ranges, threat distance, planned effects)
- Help panel; Ctrl stat testers

### Communication
- Tier-based state feedback (not dialogue)
- **Bond Debug UI:** Dragon Thought line
- **In-world:** floating speech/thought bubble above dragon (~1.75 s + fade)
- Both listen to `DragonCommunicationBehavior.message_changed`

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

## Dragon State Flow

Intended combat awareness progression:

```
FOLLOWING → ALERT → PROTECTING → ASSISTING
                ↘ HESITATING → ASSISTING or ASSIST_CANCELED
WAITING (player command, parallel branch)
```

| State | Meaning | Driver |
|-------|---------|--------|
| **FOLLOWING** | Default follow | — |
| **WAITING** | Hold position | Q (after command delay) |
| **ALERT** | Threat detected | Bond-scaled alert range |
| **PROTECTING** | Defensive intervention | Bond-scaled protection range |
| **HESITATING** | Assist gate | Instability |
| **ASSISTING** | Cooperative strike | Sync + instability + engagement |

**ALERT ≠ PROTECTING.** Alert = notice; protect = intervene. Alert range always exceeds protection range.

**ASSIST_CANCELED** is a communication event, not a persistent state.

---

## Bond Stats (3-stat model)

| Stat | Role | Affects (active) |
|------|------|------------------|
| **Bond Strength** | Relationship **resilience** | Alert range, protection, Q delay, communication clarity |
| **Sync** | Coordination | Assist cooldown frequency |
| **Instability** | Strain | Assist hesitation + cancellation |

Bond Strength does **not** increase damage. Instability does **not** affect alert, protection, or commands.

### Sync → assist cooldown

| Sync | Cooldown (approx.) |
|------|---------------------|
| 0–35 | 6.5 s |
| 36–85 | 4.0 s |
| 86–100 | 1.5 s |

### Instability → cooperative assist only

| Instability | Hesitation | Cancel |
|-------------|------------|--------|
| 0–25 | 0% | 0% |
| 26–50 | 20% | 25% |
| 51–75 | 40% | 50% |
| 76–100 | 65% | 80% |

---

## Unified Bond Strength Tier Model

**Source of truth:** `scripts/bond/bond_resilience.gd`

| Tier | Bond Strength |
|------|---------------|
| 1 | 0–30 |
| 2 | 31–60 |
| 3 | 61–85 |
| 4 | 86–100 |

**Tier progress** (`get_bond_tier_progress()`): 0.0 at tier start → 1.0 at tier end.

Used by: alert range, protection radius, command delay, communication, debug UI.

### Bond-scaled ranges (active)

Alert always wider than protection. Values from `BondResilience`:

| Tier | **Alert range** | **Protection radius** | Prot. delay | Persistence | Q delay |
|------|-----------------|----------------------|-------------|-------------|---------|
| 1 | 185 | 135 | 0.75 s | 1 s | 0.75 s |
| 2 | 230 | 185 | 0.50 s | 2 s | 0.50 s |
| 3 | 285 | 240 | 0.25 s | 3 s | 0.25 s |
| 4 | 345 | 295 | 0 s | 5 s | 0 s |

Helpers: `get_alert_range()`, `get_protection_radius()`, `get_command_response_delay()`.

---

## Bond Resilience Framework

Bond Strength = resilience, not power. Strong bonds are harder to destabilize and (when wired) recover faster.

| Helper | Purpose | Status |
|--------|---------|--------|
| `get_bond_tier()` | Relationship stage | **Active** |
| `get_bond_tier_progress()` | Within-tier advancement | **Active** (debug) |
| `get_alert_range()` | Threat awareness radius | **Active** |
| `get_protection_radius()` | Defensive intervention radius | **Active** |
| `get_command_response_delay()` | Q responsiveness | **Active** |
| `get_sync_floor()` | Minimum coordination floor | Planned |
| `get_instability_resistance()` | Stress impact reduction | Planned |
| `get_instability_recovery_rate()` | Faster instability decay | Planned |

Debug UI: **Planned Effects (not active)** for the three future helpers. Also shows **Alert Range**, **Prot. Radius**, **Threat Dist**.

---

## Dragon Communication System

**Not dialogue.** Short situational feedback — dragon is always intelligent; low bond = simpler perceived impressions.

| Layer | Path / role |
|-------|-------------|
| Catalog | `scripts/dragon/dragon_communication_catalog.gd` |
| Behavior | `scripts/dragon/dragon_communication_behavior.gd` → `message_changed` |
| Debug UI | Bond panel → **Dragon Thought** |
| Speech bubble | `scenes/dragon/DragonCommunicationBubble.tscn` on dragon |

**Triggers:** state change, hesitation, assist cancel, bond tier boundary change.  
**Timing:** bubble visible ~1.75 s, fades ~0.25 s; new message replaces current.

### Message progression (approved copy)

| Cue | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|-----|--------|--------|--------|--------|
| FOLLOWING | Watch. | Observing. | Keeping watch. | Watching over us. |
| WAITING | Stay. | Holding. | Waiting here. | I'll be here. |
| ALERT | Danger. | Threat. | Something's there. | We aren't alone. |
| PROTECTING | No! | Protecting. | Stay near. | Behind me. |
| ASSISTING | Hunt. | Assisting. | Together. | I'm with you. |
| HESITATING | Wrong. | Uncertain. | Something's off. | I don't trust this. |
| ASSIST_CANCELED | No. | Wait. | Not now. | Bad timing. |

Bubble scene is swappable for future styles, emotion icons, race themes, or hide option.

---

## Known Stable Systems

- Player movement, attack, health, death
- Dragon follow / wait / recall (delay + cancel-safe pending)
- Bond-tier alert → protect → assist flow
- Sync-tiered assist cooldown; instability hesitation/cancel
- Unified Bond tiers across alert, protection, commands, communication
- Bond resilience helpers + debug readout
- Communication in debug UI + in-world speech bubble
- Enemy AI, death cleanup, off-screen indicators

---

## Known Remaining Limitations

- No bond update loop (stats debug-adjusted only)
- Resilience helpers not applied to sync/instability gameplay
- No command refusal (delay only, by design)
- `trust_state` retained for save compatibility
- `communication_stage`, `resonance_style` — design only, not in profile
- No player dodge, race selection, save/load
- Instability reactions limited to cooperative assist
- Speech bubble is placeholder art only
- Single test scene; no progression or narrative

---

## Next Recommended Milestone

1. **Bond update loop** — combat outcomes adjust bond_strength / sync / instability
2. **Wire resilience helpers** — sync floor, instability resistance, instability recovery
3. **Speech bubble polish** — art, optional hide setting, emotion/style variants
4. **Player dodge** — without breaking engagement tracking
5. **Save/load** — persist `BondProfile`

---

## Key Files

| Area | Path |
|------|------|
| Bond tier source of truth | `scripts/bond/bond_resilience.gd` |
| Bond data + wrappers | `scripts/bond/bond_profile.gd` |
| Bond autoload | `scripts/systems/bond_system.gd` |
| Alert detection | `scripts/dragon/dragon_threat_behavior.gd` |
| Protection | `scripts/dragon/dragon_protection_behavior.gd` |
| Communication catalog | `scripts/dragon/dragon_communication_catalog.gd` |
| Communication behavior | `scripts/dragon/dragon_communication_behavior.gd` |
| Speech bubble | `scripts/dragon/dragon_communication_bubble.gd` |
| Command delay | `scripts/dragon/dragon_command_behavior.gd` |
| Dragon orchestration | `scripts/dragon/dragon.gd` |
| Assist / hesitation | `scripts/dragon/dragon_cooperation_behavior.gd` |
| Debug UI | `scripts/ui/bond_debug_ui.gd` |

Design reference: `docs/bond_system.md`, `docs/dragon_ai.md`, `docs/game_architecture.md`, `docs/technical_architecture.md`.
