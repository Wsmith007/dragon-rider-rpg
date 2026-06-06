# Dragon Bond System

## Core Concept

Dragons are semi-independent intelligent beings influenced by emotional, magical, and psychological bonding with riders.

The player does not directly control the dragon.

Instead, the rider influences dragon behavior through:
- trust
- synchronization
- emotional state
- magical resonance
- intent

Dragon behavior evolves over time as the bond deepens.

---

# Core Gameplay Loop

Player intent -> Bond system -> Dragon interpretation -> Dragon action -> Bond state update

The dragon continuously evaluates:
- survival
- danger
- trust
- emotional resonance
- rider intent
- instability

The dragon may choose to:
- cooperate
- hesitate
- reinterpret commands
- ignore commands
- act independently

depending on bond conditions.

---

# BondProfile Fields

Persistent bond data uses these field names everywhere (docs and code):

### Active gameplay stats (3-stat model)

- `bond_strength` — 0–100 · **relationship resilience** (protection, command responsiveness, communication clarity; future sync floors and instability resistance/recovery)
- `sync` — 0–100 · **coordination** (cooperative assist frequency)
- `instability` — 0–100 · **strain** (assist hesitation and cancellation)

### Compatibility / future fields

- `trust_state` — **DEPRECATED** · retained on `BondProfile` for save compatibility only. Not used in active gameplay. Do not add new systems that read this field.
- `communication_stage` — enum: `early`, `mid`, `deep` (design; not in prototype code yet)
- `resonance_style` — enum: `adaptive`, `harmonic`, `structured`, `fractured` (design; not in prototype code yet)

---

# Active Stat Identities (Prototype)

| Stat | Identity | Implemented in prototype |
|------|----------|--------------------------|
| Bond Strength | Relationship / resilience | Protection, command delay, communication tiers; resilience helpers (planned wiring) |
| Sync | Cooperation / frequency | Assist cooldown tiers |
| Instability | Reliability / strain | Hesitation + post-hesitation cancel (assist only) |

Command responsiveness (Q wait/recall delay) and communication tiering are **active under Bond Strength**.

---

# Bond Strength Philosophy

Bond Strength is **not combat power**. It is **relationship resilience**.

A strong bond does not prevent hardship. It makes the relationship:
- harder to destabilize
- easier to recover from stress
- more resistant to ordinary strain
- more difficult to permanently damage

Bond Strength does **not** directly increase dragon damage.

---

# Bond Tiers (Relationship Stages)

Major relationship stages use **unequal tier ranges** (single source of truth in `BondResilience`):

| Tier | Bond Strength | Stage |
|------|---------------|-------|
| 1 | 0–30 | Early / fragile connection |
| 2 | 31–60 | Developing trust |
| 3 | 61–85 | Established bond |
| 4 | 86–100 | Deep, resilient bond |

**Bond Tier Progress** (0.0–1.0) measures advancement **within** the current tier. Bond 86 and Bond 100 are both Tier 4, but Bond 100 provides stronger planned resilience benefits than Bond 86.

Helpers: `BondResilience.get_bond_tier()`, `BondResilience.get_bond_tier_progress()` (also on `BondProfile`).

All Bond Strength gameplay systems (protection, command delay, communication) use these tier boundaries via `scripts/bond/bond_resilience.gd`.

---

# Bond Strength — Active & Planned Effects

| Effect | Status |
|--------|--------|
| Protection radius / delay / persistence | **Active** — Tier 1–4 via `BondResilience.get_bond_tier()` |
| Wait/recall command responsiveness | **Active** — `BondResilience.get_command_response_delay()` |
| Communication message complexity | **Active** — tier mapped in `DragonCommunicationCatalog` |
| Sync floor (minimum coordination) | **Planned** — helpers only |
| Instability resistance (stress impact reduction) | **Planned** — helpers only |
| Instability recovery rate (decay multiplier) | **Planned** — helpers only |

### Planned Sync Floor (not wired)

Minimum sync the bond can support. Interpolated within each tier:

| Tier | Bond range | Sync floor range |
|------|------------|------------------|
| 1 | 0–30 | 0 → 10 |
| 2 | 31–60 | 15 → 25 |
| 3 | 61–85 | 30 → 45 |
| 4 | 86–100 | 50 → 65 |

Helper: `get_sync_floor(bond_strength)`

### Planned Instability Resistance (not wired)

Fraction of ordinary stress impact reduced (does not eliminate instability):

| Tier | Bond range | Resistance range |
|------|------------|----------------------|
| 1 | 0–30 | 0% → 5% |
| 2 | 31–60 | 10% → 18% |
| 3 | 61–85 | 25% → 35% |
| 4 | 86–100 | 40% → 45% |

Helper: `get_instability_resistance(bond_strength)` — returns 0.0–0.45

### Planned Instability Recovery (not wired)

Multiplier on future instability decay. **Recovery is the primary long-term reward of high Bond Strength.**

| Tier | Bond range | Recovery multiplier |
|------|------------|---------------------|
| 1 | 0–30 | 1.00x → 1.15x |
| 2 | 31–60 | 1.20x → 1.40x |
| 3 | 61–85 | 1.50x → 1.75x |
| 4 | 86–100 | 1.80x → 2.00x |

Helper: `get_instability_recovery_rate(bond_strength)`

Implementation: `scripts/bond/bond_resilience.gd`

---

# Bond Variables

## bond_strength

Represents the emotional and spiritual **resilience of the rider–dragon relationship**.

Range: 0–100

**Primary relationship stat** in the 3-stat gameplay model.

In the current prototype, bond strength affects:
- defensive protection (radius, response delay, persistence)
- wait/recall command responsiveness (Q)
- communication message complexity (what the rider perceives)

Planned (helpers exist, not wired to gameplay):
- sync floor — coordination cannot fully collapse below tier minimum
- instability resistance — ordinary stress has reduced impact
- instability recovery — faster return to calm after strain

Does **not** affect cooperative assist frequency (sync) or assist cancellation rolls (instability) today.

Does **not** directly increase dragon damage.

Higher bond strength (design target) may eventually improve:
- emotional understanding
- communication clarity
- magical amplification (future)

---

## sync

Represents how accurately the dragon and rider **coordinate** with each other.

Range: 0–100

In the prototype, sync affects **cooperative assist cooldown** (how often the dragon can assist after a strike).

High sync improves (design target):
- combo timing
- coordinated movement
- combat cooperation

Low sync may cause (design target):
- delayed reactions
- poor coordination

Does **not** affect protection behavior or assist cancellation (instability).

---

## instability

Represents emotional **strain**, magical overload, and bond stress.

Range: 0–100

In the prototype, instability affects **cooperative assist reliability** only:
- hesitation before assist
- chance to cancel assist after hesitation

Does **not** affect protection behavior or assist cooldown (sync).

High instability (design target) may cause:
- emotional surges
- dragon disobedience
- autonomous dragon behavior

---

# trust_state (DEPRECATED)

> **Deprecated.** `trust_state` remains on `BondProfile` for save compatibility and legacy documentation. It is **not used for active gameplay decisions** in the prototype. Relationship depth is expressed through **`bond_strength`**.

Enum values preserved for future narrative/save migration:

## hostile
The dragon resists cooperation.

## cautious
Limited cooperation under specific conditions.

## neutral
Basic cooperation and tolerance.

## allied
Reliable cooperation and growing emotional trust.

## deep_bond
Strong synchronization and emotional understanding.

## symbiotic
Near-complete synchronization between rider and dragon.

Overbond risks become possible at this stage.

---

# Dragon AI Priorities

Dragons are never fully controlled.

Dragon decision priority:
1. survival instinct
2. threat response
3. emotional state
4. bond influence
5. rider intent

Strong bonds increase rider influence but never completely remove dragon autonomy.

---

# Bond Formation

Dragon bonds form differently among the races.

All bonds rely on:
- emotional resonance
- magical compatibility
- dragon willingness
- psychological synchronization

However, each race approaches bonding differently.

---

# resonance_style

Race-default `resonance_style` values. Each race maps to one style (set at bond formation or race selection).

## adaptive (Humans)

Human bonds form rapidly and emotionally.

Humans rely heavily on instinct, emotion, and adaptability.

Human bonds are powerful but occasionally unstable.

---

## harmonic (Elves)

Elven bonds emphasize precision, emotional discipline, and psychic harmony.

Elven bonds form slowly but achieve exceptional stability and synchronization.

---

## structured (Dwarves)

Dwarven bonds use ritual, structure, and rune-assisted stabilization.

Dwarven riders prioritize consistency and control over emotional intensity.

---

## fractured (Veyrin)

Veyrin bonds are volatile, emotionally intense, and highly unstable.

Veyrin synchronization may fluctuate between exceptional harmony and dangerous instability.

---

# communication_stage

`communication_stage` tracks how clearly rider and dragon communicate. Values: `early`, `mid`, `deep`.

---

## early

Communication consists primarily of:
- emotional impressions
- instincts
- fragmented images
- urges
- sensations

The rider feels the dragon more than understands it.

---

## mid

Communication evolves into:
- symbolic imagery
- emotional concepts
- partial thoughts
- instinctive understanding

Synchronization improves significantly during this stage.

---

## deep

Communication may become:
- direct telepathic speech
- memory sharing
- emotional transparency
- synchronized thought patterns

At high synchronization levels, rider and dragon may begin predicting each other instinctively.

---

# Dragon Autonomy Thresholds

## Low Instability

Dragon behavior remains cooperative and predictable.

---

## Moderate Instability

The dragon may hesitate, reinterpret commands, or respond inconsistently.

---

## High Instability

The dragon may:
- partially ignore commands
- act emotionally
- prioritize instinct over rider intent

---

## Critical Instability

The dragon may become temporarily autonomous.

Possible outcomes include:
- aggressive outbursts
- flight responses
- synchronization collapse
- bond fractures

---

# Dragon Personality Traits

Each dragon possesses unique personality traits.

Possible traits include:
- aggression
- independence
- curiosity
- loyalty
- fear threshold
- emotional sensitivity

These traits influence:
- synchronization
- command interpretation
- combat behavior
- trust development
- instability reactions

Different riders may experience dramatically different bond behavior with the same dragon personality type.

---

# Overbond State

Overbond occurs when synchronization and emotional dependency become dangerously extreme.

Possible effects include:
- shared emotional overload
- shared pain responses
- involuntary thought synchronization
- magical amplification
- identity instability

Overbond may provide extraordinary power at significant psychological risk.

---

# Bond-Awakened Magic

Dragon bonding may awaken magical capability within individuals who were not born with access to magic.

This process does not guarantee magical mastery, but it may create latent magical potential over time.

Bond-awakened magic is more common among:
- Humans
- Dwarves
- Veyrin

because of their lower average natural magical affinity compared to Elves.

---

# Gameplay Goals

The dragon bond system is designed to create:
- emotionally meaningful dragon relationships
- semi-independent companion behavior
- dynamic combat cooperation
- evolving communication
- race-specific bond experiences
- emergent gameplay situations

The goal is for dragons to feel like intelligent partners rather than controllable pets or weapons.