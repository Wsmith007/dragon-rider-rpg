# Combat Overview

**Current combat prototype (live mechanics):** [`docs/project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md)  
**Relationship / bond at encounter resolve:** [`docs/project_checkpoint_milestone9A.md`](project_checkpoint_milestone9A.md)  
**Combat feel journal (passes 1–7):** [`docs/combat_feel_notes.md`](combat_feel_notes.md)

Combat is a fast-paced real-time action system centered around cooperative combat between rider and dragon.

The player and dragon fight as intelligent partners rather than as a controllable character and pet.

Combat effectiveness depends heavily on:
- movement
- timing
- positioning
- sync (coordination)
- instability (strain)
- bond strength (relationship depth)

The dragon participates dynamically during combat based on bond conditions.

---

# Combat Philosophy

Combat is designed to feel:
- fast
- reactive
- emotionally intense
- cooperative
- partially unpredictable

The player should feel like they are fighting alongside an intelligent companion rather than controlling a secondary weapon system.

Strong sync creates fluid and highly coordinated cooperative assists.

Poor sync or high instability creates hesitation, cancellation, and unpredictable assist reliability.

---

# Core Combat Loop

Observe -> Move -> Attack -> Dragon Responds -> Bond State Updates -> Combat Behavior Changes

Combat constantly modifies:
- sync (coordination — assist frequency; **Sync Δ at encounter resolve**)
- instability (strain — assist reliability; **Instability Δ at encounter resolve**)
- dragon behavior
- emotional state (future)

`bond_strength` affects protection and commands during combat but is **not modified per encounter resolve** (future session/pattern pass).

Every encounter potentially changes the rider-dragon relationship.

**Milestone 9A (live):** `RelationshipSystem` applies **Sync** from **Cooperation Rating** and **Instability** from **Encounter Quality** when an encounter resolves. **Bond Strength is not modified** per encounter. See `docs/project_checkpoint_milestone9A.md`.

---

# Player Combat

The player is responsible for:
- movement
- dodging
- positioning
- melee combat
- magic usage (future)
- timing attacks
- creating synchronization opportunities

The player does not directly command every dragon action.

Instead, player behavior influences dragon responses through intent and synchronization.

## Rider melee (live prototype — Combat Feel v1)

After Combat Feel Passes 1–7, rider melee uses **two attacks** (no weapon equipment yet — one global profile):

| Input | Attack | Role |
|-------|--------|------|
| **Space** (also LMB / J) | **Focused** directional cone | Primary damage — precision, facing-based |
| **Shift + Space** | **360° crowd-control** | Repositioning — create space when surrounded |

**Focused attack:** ~70° frontal cone (wider at close range), soft aim forgiveness, wind-up → impact → recovery, likely-target preview ring.

**CC attack:** 28 px radius circle, lower damage than focused, stronger knockback/stagger, longer wind-up and cooldown.

Full values, timing, enemy reactions, and limitations: [`project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md).

**Historical:** Passes 1–2 used a single **360° AoE on Space**; Pass 3 split focused vs CC inputs.

---

# Dragon Combat

The dragon functions as a semi-independent combat intelligence.

The dragon evaluates:
- nearby threats
- rider condition
- danger level
- synchronization state
- emotional resonance
- instinctive reactions

The dragon may:
- assist aggressively
- defend the rider
- reposition independently
- hesitate
- misinterpret intent
- act emotionally
- temporarily disengage

depending on combat conditions.

---

# Dynamic Participation System

Dragon combat participation changes dynamically based on:
- bond_strength (protection eagerness, response delay, persistence)
- sync (cooperative assist frequency)
- instability (assist hesitation and cancellation)
- emotional state (future)
- dragon personality (future)
- combat pressure

A dragon may:
- coordinate assists more often during high sync
- hesitate or cancel assists under high instability
- protect the rider sooner and longer under high bond strength
- act aggressively under stress (future emotional layer)

The dragon should never feel mechanically static.

---

# Synchronization Mechanics

High sync improves (prototype: shorter assist cooldown between cooperative strikes):
- coordinated assists
- combo timing (future)
- dragon reaction speed (future)
- positioning synergy (future)
- defensive cooperation (future)
- magical amplification (future)

Strong sync creates moments where rider and dragon appear to fight almost instinctively as a unified pair.

Sync may rise through (live at encounter resolve + design target):
- **Cooperation Rating** on resolved encounters (assists, protections, clean teamwork)
- successful coordinated combat (cooldown tiers scale with current sync)
- protecting each other
- compatible combat behavior

Sync may fall through (live at encounter resolve + design target):
- **Poor / Disastrous Cooperation Rating** (cancels, hesitations, weak joint execution)
- conflicting actions
- failed coordination
- emotional stress

---

# Instability During Combat

Instability represents **strain** on the bond during combat.

In the prototype, instability affects cooperative assist **reliability** (hesitation, post-hesitation cancel). It does not affect protection (bond strength).

Instability may increase from (live at encounter resolve + design target):
- **Encounter Quality** on resolved encounters (heavy harm, near-death, death, stressful outcomes)
- heavy damage (harm totals in encounter summary)
- emotional panic
- magical overload
- aggressive overextension
- dragon fear or anger (future emotional layer)

High instability may cause (prototype + design target):
- assist hesitation before striking
- assist cancellation after hesitation
- delayed dragon reactions (future)
- erratic positioning (future)
- emotional outbursts (future)
- temporary autonomy (future)

Critical instability creates highly dangerous and unpredictable combat situations (design target).

---

# Movement Philosophy

Combat emphasizes:
- mobility
- rapid repositioning
- reaction timing
- directional awareness (focused attacks reward facing and position)

The player should remain highly active during combat encounters.

Standing still for long periods should generally be dangerous.

Movement synchronization between rider and dragon is intended to feel increasingly natural as bonds deepen.

During attacks, the live prototype uses **reduced move speed** during wind-up and recovery rather than full animation locks — see Combat Feel v1.

---

# Enemy Design Philosophy

Enemies are designed to pressure:
- positioning
- synchronization
- emotional stability
- threat prioritization

**Live prototype:** slot-based surround, separation, chase/engage states, stagger on player hits — see [`project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md) Section 3.

Enemies should create situations where:
- dragon instinct conflicts with rider intent
- emotional stress affects combat behavior
- instability becomes difficult to manage

Some enemies may intentionally target:
- dragons
- rider concentration
- synchronization states
- magical stability

---

# Combat Roles By Race

## Humans

Flexible and aggressive.

Human combat focuses on:
- adaptability
- rapid pressure
- emotional momentum
- fast bond growth

Human dragon behavior tends to become emotionally reactive during combat.

---

## Elves

Precise and highly synchronized.

Elven combat focuses on:
- coordination
- timing
- magical control
- efficient movement

Elven dragons generally maintain strong combat discipline.

---

## Dwarves

Defensive and structured.

Dwarven combat focuses on:
- positioning
- durability
- controlled aggression
- stability management

Dwarven dragons often fight tactically and predictably.

---

## Veyrin

Volatile and reactive.

Veyrin combat focuses on:
- instability manipulation
- burst aggression
- mobility
- dangerous synchronization spikes

Veyrin dragons may become extremely aggressive under pressure.

---

# Communication During Combat

Dragon communication evolves alongside the bond.

Early combat communication relies on:
- instinct
- emotion
- urgency
- fragmented impressions

Advanced bonds may allow:
- rapid thought exchange
- emotional awareness
- predictive coordination
- instinctive synchronized reactions

Highly synchronized combat should eventually feel almost effortless between rider and dragon.

---

# Dragon Autonomy In Combat

Dragons retain independent survival instincts during combat.

Even highly bonded dragons may:
- retreat from overwhelming danger
- prioritize self-preservation
- react emotionally
- override rider expectations

Strong synchronization improves cooperation but never removes dragon individuality.

---

# Early Vertical Slice Combat

The playable combat prototype (Combat Feel v1) includes:

**Rider & enemies**
- player movement and directional facing
- focused melee (Space) + CC melee (Shift+Space)
- enemy pursuit, slot spread, and surround pressure
- knockback, stagger, attack telegraphs, and target preview

**Dragon co-op (Milestone 9A)**
- dragon follow behavior
- cooperative assist (sync + instability)
- defensive protection (bond strength)
- sync-tiered assist cooldown
- instability hesitation and cancel
- encounter resolve → Sync / Instability (not Bond Strength per encounter)

The first goal is proving:
- dragon cooperation feels alive
- combat feels fast and responsive with **readable** directional melee
- sync and instability change assist behavior meaningfully
- bond strength changes protection behavior meaningfully

Weapon systems, equipment, enemy variants, magic, and progression remain intentionally postponed. See [`project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md).

---

# Long-Term Combat Goals

Future combat systems may include:
- aerial dragon combat
- advanced combo synchronization
- environmental destruction
- rider-versus-rider battles
- dragon personality evolution
- advanced magic interactions
- large-scale faction warfare
- overbond combat states
- cooperative multiplayer rider systems

Future systems should remain modular and expandable.

---

# Combat Design Goals

Combat should create the feeling that:
- the dragon is intelligent
- sync and instability matter emotionally and mechanically (assist)
- bond strength matters for protection and relationship depth
- instability creates meaningful tension
- the rider and dragon relationship evolves through conflict

The dragon should feel like a living combat partner rather than a controllable tool.