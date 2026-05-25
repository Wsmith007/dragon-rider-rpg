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

- `bond_strength` — 0–100
- `sync` — 0–100 (coordination; design prose may say "synchronization")
- `instability` — 0–100
- `trust_state` — enum (see below)
- `communication_stage` — enum: `early`, `mid`, `deep` (see below)
- `resonance_style` — enum: `adaptive`, `harmonic`, `structured`, `fractured` (see below; race-default)

---

# Bond Variables

## bond_strength

Represents the emotional and spiritual depth of the rider-dragon relationship.

Range: 0-100

Higher bond strength improves:
- trust
- emotional understanding
- magical amplification
- advanced bond abilities
- communication clarity

---

## sync

Represents how accurately the dragon and rider understand and coordinate with each other.

Range: 0-100

High sync improves:
- combo timing
- coordinated movement
- dragon reaction speed
- combat cooperation
- intent interpretation

Low sync may cause:
- delayed reactions
- incorrect responses
- poor coordination
- failed abilities

---

## instability

Represents emotional strain, magical overload, and bond stress.

Range: 0-100

High instability may cause:
- emotional surges
- magical fluctuations
- dragon disobedience
- synchronization collapse
- autonomous dragon behavior
- bond fractures

---

# trust_state

Enum values for `trust_state`:

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