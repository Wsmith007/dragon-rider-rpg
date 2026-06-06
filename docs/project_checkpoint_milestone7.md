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
| **7 Unified Bond tiers + resilience framework** | **Done — calculations + debug** |
| **7 Dragon communication feedback** | **Done — tier-based state messages in debug UI** |
| Bond update loop | Not started |
| `communication_stage` field in profile | Not started |

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
- **ALERT** when enemy threatens rider
- **HESITATING** before cooperative assist (instability)
- **PROTECTING** — automatic defensive strike (bond strength)
- **ASSISTING** — cooperative strike (sync + instability)
- Flank approach; assist/protection failsafes; safe enemy cleanup on death

### Bond
- 3 active stats: `bond_strength`, `sync`, `instability`
- `trust_state` deprecated (compatibility only)
- Unified Bond Strength tiers via `BondResilience`
- Resilience helpers (planned effects shown in debug, not wired)
- Debug panel, help panel, Ctrl stat testers

### Communication
- Short state feedback lines (not dialogue)
- Shown in Bond Debug UI as **Dragon Thought**
- Updates on state change, hesitation, assist cancel, bond tier change
- Message complexity scales with Bond Strength tier

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

| State | Driver | Communication cue |
|-------|--------|---------------------|
| **FOLLOWING** | Default | FOLLOWING |
| **WAITING** | Q (after delay) | WAITING |
| **ALERT** | Threat detection | ALERT |
| **HESITATING** | Instability | HESITATING |
| **PROTECTING** | Bond Strength | PROTECTING |
| **ASSISTING** | Sync + Instability | ASSISTING |

Assist cancel emits **ASSIST_CANCELED** (event, not a persistent state).

---

## Bond Stats (3-stat model)

| Stat | Role | Affects (active) |
|------|------|------------------|
| **Bond Strength** | Relationship **resilience** | Protection, Q delay, communication clarity |
| **Sync** | Coordination | Assist cooldown frequency |
| **Instability** | Strain | Assist hesitation + cancellation |

Bond Strength does **not** directly increase damage. Instability does **not** affect protection or commands.

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

**Single source of truth:** `scripts/bond/bond_resilience.gd`

All Bond Strength tier lookups use:

| Tier | Bond Strength |
|------|---------------|
| 1 | 0–30 |
| 2 | 31–60 |
| 3 | 61–85 |
| 4 | 86–100 |

Used by: protection, command delay, communication, debug tier display.

**Tier progress** (`get_bond_tier_progress()`): 0.0 at tier start, 1.0 at tier end. Bond 86 and 100 are both Tier 4 but differ in progress and planned resilience benefits.

### Active tier values (protection + Q delay)

| Tier | Radius | Prot. delay | Persistence | Q delay |
|------|--------|-------------|-------------|---------|
| 1 | 100 | 0.75 s | 1 s | 0.75 s |
| 2 | 150 | 0.50 s | 2 s | 0.50 s |
| 3 | 200 | 0.25 s | 3 s | 0.25 s |
| 4 | 250 | 0 s | 5 s | 0 s |

---

## Bond Resilience Framework

Bond Strength = resilience, not power. Helpers exist; **planned effects not wired to gameplay**.

| Helper | Purpose | Status |
|--------|---------|--------|
| `get_bond_tier()` | Relationship stage | Active (tier selection) |
| `get_bond_tier_progress()` | Within-tier advancement | Active (debug) |
| `get_command_response_delay()` | Q responsiveness | Active |
| `get_sync_floor()` | Minimum coordination floor | Planned |
| `get_instability_resistance()` | Stress impact reduction | Planned |
| `get_instability_recovery_rate()` | Faster instability decay | Planned |

Debug UI shows **Planned Effects (not active)** for the three future helpers.

---

## Dragon Communication System

**Not dialogue.** Short situational feedback the rider perceives. Dragon is always intelligent; low bond = simpler impressions.

- **Catalog:** `scripts/dragon/dragon_communication_catalog.gd`
- **Behavior:** `scripts/dragon/dragon_communication_behavior.gd` → `message_changed` signal
- **Display:** Bond Debug UI → **Dragon Thought**
- **Lookup:** `get_dragon_message(cue, bond_strength)`

Triggers: dragon state change, hesitation start, assist cancel, bond tier boundary change.

### Message progression (by Bond tier)

| Cue | Tier 1 (0–30) | Tier 2 (31–60) | Tier 3 (61–85) | Tier 4 (86–100) |
|-----|---------------|----------------|----------------|-----------------|
| FOLLOWING | Watch. | Observing. | Keeping watch. | Watching over us. |
| WAITING | Stay. | Holding. | Waiting here. | I'll be here. |
| ALERT | Danger. | Threat. | Something's there. | We aren't alone. |
| PROTECTING | No! | Protecting. | Stay near. | Behind me. |
| ASSISTING | Hunt. | Assisting. | Together. | I'm with you. |
| HESITATING | Wrong. | Uncertain. | Something's off. | I don't trust this. |
| ASSIST_CANCELED | No. | Wait. | Not now. | Bad timing. |

Ready for future speech bubbles via `message_changed` or catalog lookup.

---

## Known Stable Systems

- Player movement, attack, health, death
- Dragon follow / wait / recall (delay + cancel-safe pending)
- Threat → alert; bond-tier protection pipeline
- Sync-tiered assist cooldown; instability hesitation/cancel
- Unified Bond tier model across protection, commands, communication
- Bond resilience helpers + debug readout
- Dragon communication feedback in debug UI
- Enemy AI, death cleanup, off-screen indicators

---

## Known Remaining Limitations

- No bond update loop (stats debug-adjusted only)
- Resilience helpers not applied to sync/instability gameplay
- No command refusal (delay only, by design)
- `trust_state` retained for save compatibility
- `communication_stage`, `resonance_style` — design only, not in profile code
- No player dodge, race selection, save/load, speech bubble UI
- Instability reactions limited to cooperative assist
- Single test scene; no progression or narrative

---

## Next Recommended Milestone

1. **Bond update loop** — combat outcomes adjust bond_strength / sync / instability
2. **Wire resilience helpers** — sync floor, instability resistance, instability recovery
3. **Speech bubble UI** — subscribe to `message_changed` (keep catalog as source)
4. **Player dodge** — without breaking engagement tracking
5. **Save/load** — persist `BondProfile`

---

## Key Files

| Area | Path |
|------|------|
| Bond tier source of truth | `scripts/bond/bond_resilience.gd` |
| Bond data + wrappers | `scripts/bond/bond_profile.gd` |
| Bond autoload | `scripts/systems/bond_system.gd` |
| Communication catalog | `scripts/dragon/dragon_communication_catalog.gd` |
| Communication behavior | `scripts/dragon/dragon_communication_behavior.gd` |
| Command delay | `scripts/dragon/dragon_command_behavior.gd` |
| Dragon orchestration | `scripts/dragon/dragon.gd` |
| Protection | `scripts/dragon/dragon_protection_behavior.gd` |
| Assist / hesitation | `scripts/dragon/dragon_cooperation_behavior.gd` |
| Debug UI | `scripts/ui/bond_debug_ui.gd` |

Design reference: `docs/bond_system.md`, `docs/dragon_ai.md`, `docs/game_architecture.md`, `docs/technical_architecture.md`.
