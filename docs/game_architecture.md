# Game Overview

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
- trust
- synchronization
- instability
- dragon behavior
- communication clarity

The dragon responds dynamically during both combat and exploration.

---

# Core Gameplay Pillars

## Dragon Bonding

The dragon is not a controllable pet or weapon.

The dragon is an intelligent companion influenced through:
- trust
- emotional state
- synchronization
- magical resonance
- player intent

The bond evolves over time through gameplay.

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
- trust
- synchronization
- emotional state
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

The bond system connects nearly all major gameplay systems.

Core bond variables (`BondProfile`):
- bond_strength
- sync
- instability
- trust_state
- communication_stage
- resonance_style

These variables influence:
- combat behavior
- communication
- magical amplification
- dragon AI behavior
- advanced abilities
- emotional reactions

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

Exploration occurs through interconnected world regions.

Exploration gameplay includes:
- environmental traversal
- dragon interaction
- discovery of ancient dragon sites
- political settlements
- hidden magical locations
- optional encounters

Some areas may react differently depending on:
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

Dragon communication evolves through `communication_stage` (`early` → `mid` → `deep`).

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
- synchronization
- trust
- emotional state
- bond strength
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