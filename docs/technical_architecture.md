# Technical Goals

The project should be modular, scalable, and easy to expand.

The core technical goal is to support a 2D action adventure RPG centered around a lifelong rider-dragon bond.

The dragon companion is not replaceable. The player has one primary dragon bond for the entire game.

Systems should be built around long-term progression, evolving communication, and persistent relationship state.

---

# Project Structure

Recommended root structure:

```text
dragon-rider-rpg/
  autoloads/
  data/
  docs/
  resources/
  scenes/
  scripts/
  project.godot
```

---

# Scripts Structure

```text
scripts/
  globals/
  systems/
  player/
  dragon/
  enemies/
  ui/
```

---

# Scene Structure

```text
scenes/
  player/
  dragon/
  enemies/
  world/
  ui/
```

---

# Core Scene Philosophy

Each major gameplay object should have its own scene.

Examples:
- Player.tscn
- Dragon.tscn
- Enemy.tscn
- TestWorld.tscn
- DialogueBox.tscn

Scenes should remain focused and reusable.

Avoid placing too much logic directly inside world scenes.

---

# System Philosophy

Systems should be modular and responsible for one major purpose.

Examples:
- BondSystem manages rider-dragon relationship mechanics.
- CombatSystem manages damage and combat interactions.
- DialogueSystem manages dialogue flow.
- RaceSystem manages race modifiers.
- SaveSystem manages persistent data.

Avoid large scripts that handle unrelated responsibilities.

---

# Lifelong Dragon Bond Architecture

The player has one primary dragon companion for the entire game.

The dragon should persist across:
- scenes
- story progress
- combat encounters
- bond progression
- communication growth
- save/load cycles

The dragon is a central character and should be treated as a long-term gameplay and narrative object.

Future systems should assume:
- one active rider
- one active bonded dragon
- one primary BondProfile

The game should not be architected around swapping dragons.

---

# Bond System Architecture

The bond system tracks the persistent relationship between rider and dragon.

### Active gameplay stats (3-stat model)

| Field | Range | Role in prototype |
|-------|-------|-------------------|
| `bond_strength` | 0–100 | Relationship resilience — protection, command delay, communication; **not modified at encounter resolve**; planned sync floor / instability resistance / recovery |
| `sync` | 0–100 | Coordination — assist cooldown tiers; **Sync Δ applied live** from Cooperation Rating at encounter resolve |
| `instability` | 0–100 | Strain — assist hesitation/cancel (gameplay); **Instability Δ applied live** from Encounter Quality at encounter resolve |

### Compatibility / future fields (`BondProfile`)

| Field | Status |
|-------|--------|
| `trust_state` | **Deprecated** — retained for save compatibility only. Not used in gameplay. See `bond_system.md`. |
| `communication_stage` | Design — `early`, `mid`, `deep` (not in prototype code yet) |
| `resonance_style` | Design — race-default enum (not in prototype code yet) |

Bond data should persist across the full game.

### Bond Strength tiers (single source of truth)

All Bond Strength tier lookups use `scripts/bond/bond_resilience.gd`:

| Tier | Bond Strength |
|------|---------------|
| 1 | 0–30 |
| 2 | 31–60 |
| 3 | 61–85 |
| 4 | 86–100 |

Key helpers: `get_bond_tier()`, `get_bond_tier_progress()`, `get_command_response_delay()`.  
`BondProfile` exposes thin wrappers; do not hardcode tier thresholds elsewhere.

BondSystem should influence:
- dragon AI
- combat cooperation (sync, instability gameplay + encounter resolve — see Milestone 9A)
- communication clarity (future)
- ability unlocks (future)
- instability events (hesitation/cancel + encounter Instability deltas)
- magical awakening (future)

---

# Relationship System Architecture (Milestone 9A — live)

**Autoload:** `RelationshipSystem` (`scripts/systems/relationship_system.gd`)

Modular pipeline — no stat writes inside individual dragon/player combat scripts:

```
Hooks → RelationshipEventBus → RelationshipEncounterTracker
  → EncounterQualityClassifier + CooperationRatingClassifier
  → ProposedDeltaGenerator → BondSystem (Sync/Instability only)
```

| Module | Role |
|--------|------|
| `RelationshipEvent` / `RelationshipEventBus` | Stable event IDs + payloads |
| `RelationshipEncounterTracker` | Local encounter lifecycle, involved enemies |
| `RelationshipEncounterSummary` | Counters at resolve |
| `EncounterQualityClassifier` | Outcome/stress → Instability Δ |
| `CooperationRatingClassifier` | Teamwork → Sync Δ |
| `ProposedDeltaGenerator` | Deltas + Bond preview (Bond not applied) |
| `RelationshipSessionTracker` | Encounter quality history (Bond input future) |

**Bond Strength:** protected at resolve; future **Bond pattern evaluation** across sessions.

**Source of truth:** `docs/relationship_event_framework.md`, `docs/project_checkpoint_milestone9A.md`.

---

# Dragon AI Architecture

Dragon AI should be layered.

Dragon decision priority:
1. survival instinct
2. threat response
3. emotional state
4. bond influence
5. rider intent

The dragon should not behave like a directly controlled unit.

The player influences the dragon through:
- movement
- combat behavior
- bond strength (relationship depth)
- sync (coordination)
- instability (strain)
- emotional state (future)
- intent signals

---

# Event / Signal Philosophy

Systems should communicate through signals or event-style messages whenever possible.

Avoid excessive direct references between unrelated systems.

Examples:
- Player emits `player_damaged`
- Dragon emits `dragon_assisted`
- BondSystem emits `bond_changed`
- CombatSystem emits `enemy_defeated`
- DialogueSystem emits `dialogue_finished`

Signals help keep systems modular and easier to expand.

---

# Autoload Structure

Autoloads should be used sparingly.

Recommended future autoloads:
- GameManager
- EventBus
- SaveManager

**Active today:** `BondSystem`, **`RelationshipSystem`** (encounter tracking + live Sync/Instability at resolve).

Autoloads should not become dumping grounds for unrelated logic.

Use autoloads only for systems that truly need global access.

---

# Data-Driven Design

Race modifiers, dragon traits, enemy values, and bond thresholds should eventually be data-driven.

Prefer reusable data resources over hardcoded values.

Future resource examples:
- RaceData
- DragonPersonalityData
- EnemyData
- BondThresholdData

This allows balancing without rewriting core scripts.

---

# Race System Structure

Race selection should affect gameplay through modifiers and data.

Race data may include:
- bond_growth_modifier
- sync_modifier
- instability_modifier
- magic_affinity_modifier
- combat_style_bias

Race logic should not be scattered across unrelated scripts.

Race-related behavior should be centralized through RaceSystem or RaceData resources.

---

# Combat System Structure

Combat should remain fast, responsive, and modular.

Combat systems should support:
- player attacks
- enemy damage
- dragon assist behavior
- sync-based combat reactions
- instability events

The dragon should participate dynamically based on bond state rather than fixed cooldown commands only.

---

# Save System Philosophy

Save data should eventually preserve:
- player race
- player stats
- dragon state
- BondProfile
- story progress
- world state
- faction relationships
- unlocked abilities

Because the dragon bond is lifelong, bond state must be treated as core save data.

---

# Vertical Slice Scope

The first playable technical milestone should include:
- player movement
- camera follow
- dragon follow behavior
- basic enemy chase AI
- simple combat damage
- basic BondProfile (all six fields)
- basic sync and instability changes
- one test map

Do not build large systems before proving the core rider-dragon relationship works.

---

# Long-Term Scalability Goals

Future systems may include:
- advanced dragon AI
- advanced magic
- race-specific quest branches
- faction reputation
- dialogue consequences
- rider politics
- aerial travel
- save/load
- larger world regions

All systems should be built in a way that allows expansion without rewriting the project foundation.

---

# Technical Design Rule

The dragon bond system is the central pillar of the game.

When adding new systems, consider how they interact with:
- rider
- dragon
- bond_strength (relationship depth)
- sync (coordination)
- instability (strain)
- communication growth (future)

`trust_state` is deprecated — do not add new gameplay hooks that read it.