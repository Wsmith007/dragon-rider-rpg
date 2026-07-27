# Game Overview

**Vertical Slice design:** [`./vertical_slice_design_v1.md`](./vertical_slice_design_v1.md) -- scope, experience goals, slice pillars, and **enemy archetypes** (Scout / Raider / Brute).  
**World / exploration constitution:** [`./world_design_framework.md`](./world_design_framework.md) -- persistent world, Area hierarchy, place-making standards. This document describes the **full game** vision; the slice intentionally defers politics, races, magic, and large-world systems until the core rider-dragon loop is proven. Exploration structure below is a high-level sketch -- **defer to the World Design Framework** for authoritative terminology and philosophy.

The game is a 2D action adventure RPG focused on dragon rider relationships, political tension between races, and semi-independent dragon companions.

The player chooses one of four races:
- Humans
- Elves
- Dwarves
- Veyrin

Each race experiences the world differently through:
- dragon bonding philosophy
- gameplay style
- synchronization behavior
- magical affinity
- political relationships

The central gameplay experience revolves around building and maintaining a bond with a dragon companion.

---

# Core Gameplay Loop

Explore -> Encounter Conflict -> Fight Alongside Dragon -> Bond State Changes -> Unlock New Abilities and Communication

The player's actions continuously influence:
- bond strength (relationship depth)
- sync (coordination)
- instability (strain)
- dragon behavior
- communication clarity (future)

The dragon responds dynamically during both combat and exploration.

---

# Core Gameplay Pillars

## Dragon Bonding

The dragon is an intelligent companion influenced through:
- bond strength (relationship depth)
- sync (coordination)
- instability (strain)
- emotional state (future)
- player intent

---

## Fast Action Combat

Combat is designed as a fast-paced action RPG system.

Core combat focuses on:
- movement
- dodging
- positioning
- timing
- synchronization with dragon behavior

The player and dragon function as cooperative combat partners.

---

## Emotional Synchronization

Combat effectiveness depends heavily on synchronization between rider and dragon.

Strong synchronization enables:
- coordinated attacks
- rapid responses
- movement synergy
- advanced bond abilities

Poor synchronization may result in:
- delayed responses
- incorrect dragon reactions
- instability spikes
- autonomous dragon behavior

---

## Political Tension

The world is shaped by conflict between the races and their rider factions.

Dragon riders are:
- political assets
- military forces
- symbols of power
- potential threats to world stability

The player eventually influences the future structure of rider society.

---

# Player Structure

The player controls a rider character.

Player systems include:
- movement
- combat
- magic
- dialogue
- bond interaction
- race modifiers

The player influences the dragon through intent rather than direct command.

---

# Dragon Structure

The dragon is a semi-independent AI companion.

The dragon continuously evaluates:
- danger
- bond strength
- sync
- instability
- emotional state (future)
- instinct
- rider intent

Dragons may:
- cooperate
- hesitate
- reinterpret commands
- act emotionally
- ignore instructions
- temporarily act independently

Dragon communication evolves over time as the bond deepens.

---

# Bond System Integration

The bond system connects major gameplay systems through three **active** stats:

| Stat | Role |
|------|------|
| `bond_strength` | Relationship **resilience** -- protection, commands, communication (active); sync floors, instability resistance/recovery (planned) |
| `sync` | Coordination -- assist frequency (prototype) |
| `instability` | Strain -- assist reliability (prototype) |

### Bond Strength = Resilience (Not Power)

High Bond Strength does not prevent conflict. It makes the relationship harder to destabilize and easier to recover from stress. It supports the bond rather than directly increasing combat damage.

### Bond Tiers & Progress

Relationship stages use four unequal tiers (0-30, 31-60, 61-85, 86-100). **Bond Tier Progress** (0.0-1.0) tracks advancement within a tier so Bond 100 is more resilient than Bond 86 even though both are Tier 4.

Central helpers live in `scripts/bond/bond_resilience.gd`. Protection, command delay, communication, and planned resilience effects all read tier boundaries from this module -- do not duplicate thresholds.

Additional persisted fields (compatibility / future):
- `trust_state` -- **deprecated**, not used in gameplay
- `communication_stage` -- design only
- `resonance_style` -- design only

These variables influence (design target):
- combat behavior
- communication
- dragon AI behavior
- emotional reactions

In the vertical slice prototype, only the three active stats above have gameplay hooks.

---

# Combat Structure

Combat is real-time and movement-focused.

The player uses:
- melee attacks
- dodging
- magic
- movement positioning
- synchronization timing

The dragon supports combat dynamically rather than through fixed commands.

Combat pacing prioritizes:
- mobility
- reaction speed
- cooperative flow
- emotional intensity

---

# Exploration Structure

**Authoritative reference:** [`./world_design_framework.md`](./world_design_framework.md) (World -> Region -> Area -> POI -> Structure -> Room).

Exploration occurs through interconnected world **Regions** composed of meaningful **Areas**.

Exploration gameplay includes:
- environmental traversal
- dragon interaction
- discovery of ancient dragon sites
- political settlements
- hidden magical locations
- optional encounters

Some Areas may react differently depending on:
- race
- dragon status
- faction alignment
- bond state

---

# Race System

Each race changes:
- gameplay style
- dragon bonding behavior
- synchronization patterns
- magical affinity
- political interactions
- progression pacing

Races are intended to feel fundamentally different rather than cosmetic.

---

# Communication Philosophy

Dragon communication evolves through `communication_stage` (`early` -> `mid` -> `deep`).

At `early`, communication relies on:
- emotions
- instincts
- impressions
- fragmented imagery

Deeper bonds may eventually allow:
- symbolic thought
- emotional transparency
- memory sharing
- telepathic speech

Communication progression is intended to feel emotionally meaningful.

---

# AI Philosophy

Dragons are intelligent beings, not controllable pets.

The player influences dragon behavior through:
- bond strength (relationship depth)
- sync (coordination)
- instability (strain)
- combat behavior

Strong bonds improve cooperation but never completely remove dragon autonomy.

The dragon AI should feel:
- alive
- emotional
- reactive
- partially unpredictable

---

# Progression Structure

Player progression is tied to:
- dragon bond growth
- synchronization mastery
- combat experience
- magical development
- political alignment

Progression is intended to feel relational rather than purely statistical.

## Long-term progression axes (design target)

| Axis | Role |
|------|------|
| **Character Level** | Personal power -- rider combat capability |
| **Relationship Stats** | Rider/dragon effectiveness together (Bond, Sync, Instability) |
| **World Regions** | Difficulty and content progression |
| **Enemy Variants** | Strength and behavior progression within regions |

Enemy scaling should come primarily from **region difficulty**, **enemy type**, and **enemy variants** -- not full player-level scaling. Returning to earlier areas should demonstrate growth. **Relationship progression should remain as important as character progression.**

See `./relationship_event_framework.md` (Long-Term Progression Philosophy).

## Relationship system (Milestone 9A -- live)

`RelationshipSystem` (autoload) tracks local encounters and applies **Sync** (Cooperation Rating) and **Instability** (Encounter Quality) at resolve. **Bond Strength is protected** from per-encounter rolls; future Bond changes are session/pattern-based.

See `../checkpoints/project_checkpoint_milestone9A.md`.

---

# Vertical Slice Scope

The first playable version focuses only on:
- player movement
- dragon follow behavior
- basic enemy combat
- synchronization reactions
- one small playable environment
- basic race selection
- `communication_stage` at `early`

The initial goal is to prove that:
- the dragon feels intelligent
- synchronization feels meaningful
- combat feels cooperative and dynamic

Large-scale systems are intentionally postponed.

---

# Long-Term Expansion Goals

Future systems may include:
- advanced magic systems
- aerial dragon gameplay
- multiple dragon personalities
- faction reputation
- large world exploration
- rider politics
- advanced dialogue systems
- large-scale rider conflicts
- dragon councils
- unified rider order systems

These systems should remain modular and expandable.

---

# Technical Philosophy

Systems should remain:
- modular
- scalable
- data-driven
- AI-friendly
- easy to expand

Gameplay systems should prioritize:
- emergent interactions
- reusable behaviors
- flexible AI logic
- race-specific variation

The project should avoid tightly coupled systems whenever possible.

The dragon bond system is the central pillar around which all major gameplay systems are built.