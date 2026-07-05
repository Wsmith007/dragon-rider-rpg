# Dragon AI Philosophy

Dragons are intelligent emotional beings, not combat utilities.

The dragon AI system is designed to create the feeling of fighting and traveling alongside an autonomous companion with:
- emotions
- instincts
- preferences
- fears
- opinions
- evolving trust

The dragon should never feel like a controllable pet or scripted weapon.

Player influence increases through bond strength, sync, and instability, but dragon individuality always remains present.

---

# Core AI Priorities

Dragon AI evaluates situations using layered priorities.

Priority order:
1. survival instinct
2. immediate danger evaluation
3. emotional state
4. bond influence
5. rider intent

Even highly synchronized dragons may override rider expectations if instinct or emotional state becomes overwhelming.

---

# Dragon Autonomy

Dragons maintain independent decision-making at all times.

The dragon may:
- assist voluntarily
- hesitate
- reposition independently
- retreat
- ignore rider intent
- protect the rider automatically
- react emotionally

High synchronization improves cooperation but never removes autonomy.

The dragon should feel alive rather than mechanically obedient.

---

# Emotional State System

Dragons possess active emotional states which influence behavior.

Possible emotional influences include:
- anger
- fear
- protectiveness
- curiosity
- aggression
- calmness
- distrust

Emotional state may change through:
- combat
- rider behavior
- synchronization success
- instability events
- environmental conditions
- story events

Emotions directly influence:
- combat choices
- positioning
- communication
- cooperation
- synchronization
- instability reactions

---

# Bond Influence

## bond_strength (relationship resilience)

`bond_strength` is the **primary relationship stat**.

Bond tier boundaries (shared across all systems): **0–30, 31–60, 61–85, 86–100** via `BondResilience.get_bond_tier()`.

In the prototype:
- protection detection radius, response delay, and persistence
- wait/recall command responsiveness (Q)
- communication message complexity (rider-perceived clarity)

Design target — low bond strength:
- slower protection reactions
- shorter protective persistence

Design target — high bond strength:
- notices threats sooner
- reacts faster
- stays protective longer

## sync (coordination)

In the prototype: cooperative **assist cooldown** tiers.

Design target: combat coordination, movement synergy, intent interpretation.

## instability (strain)

In the prototype: assist **hesitation** and **cancellation** after hesitation.

Does not affect protection.

Design target: emotional outbursts, communication breakdown, temporary autonomy.

---

# Sync Influence

`sync` represents mutual **coordination** between rider and dragon.

In the prototype, sync controls cooperative assist **frequency** (cooldown between assists).

**At encounter resolve (Milestone 9A — live):** `RelationshipSystem` applies a **Sync Δ** from **Cooperation Rating** (assists, protections, cancels, hesitations, rider/dragon contribution). Bond Strength is not modified at resolve.

High synchronization improves (design target + gameplay):
- combat coordination
- movement synergy
- reaction timing
- intent interpretation

Low synchronization may cause (design target):
- delayed reactions
- positioning mistakes
- failed cooperation

Synchronization should feel earned through shared experiences.

---

# Instability Influence

Instability represents **strain** within the bond.

In the prototype, instability affects cooperative assist **reliability** (hesitation, cancel). Protection is separate and driven by bond strength.

**At encounter resolve (Milestone 9A — live):** `RelationshipSystem` applies an **Instability Δ** from **Encounter Quality** (player harm, near-death, death, resolve outcome). Harm/outcome is separate from Cooperation Rating.

High instability (design target) may cause:
- emotional outbursts
- panic reactions
- communication breakdown
- temporary autonomy increases

Critical instability (design target) may temporarily override rider influence entirely.

---

# Relationship Events (Milestone 9A)

Dragon combat behaviors emit **relationship events** consumed by `RelationshipSystem`. Events accumulate into encounter summaries; **stats apply at resolve**, not per swing.

| Behavior | Relationship signal | Rating impact |
|----------|---------------------|---------------|
| Cooperative assist success | Assist succeeded | **Cooperation Rating** (Sync) |
| Protection strike success | Protection succeeded | **Cooperation Rating** (Sync) |
| Assist hesitation | Assist hesitated | **Cooperation Rating** (Sync) |
| Assist cancel (instability/AI) | Assist canceled | **Cooperation Rating** (Sync) |
| Protection triggered (no hit yet) | Protection triggered | Tracking only |
| Player damaged in combat | Player damaged | **Encounter Quality** (Instability) via harm totals |
| Player near-death / death | Critical HP / death | **Encounter Quality** (Instability) |

**Assist and protection are separate systems** — one strike emits one success type, never both.

- **Cooperation Rating** measures teamwork → drives **Sync** at resolve.
- **Encounter Quality** measures outcome stress → drives **Instability** at resolve.
- Cancellations and hesitations affect **Cooperation**, not Encounter Quality directly.

See `docs/relationship_event_framework.md` and `docs/project_checkpoint_milestone9A.md`.

---

# communication_stage

`communication_stage` advances as the bond deepens (`early` → `mid` → `deep`).

---

## early

Communication consists primarily of:
- emotions
- instincts
- urges
- fragmented imagery
- sensations

The rider often struggles to interpret dragon intent clearly.

---

## mid

Communication develops into:
- symbolic thoughts
- emotional concepts
- instinctive understanding
- partial mental clarity

Coordination improves significantly during this stage.

---

## deep

Communication may evolve into:
- telepathic speech
- memory sharing
- emotional transparency
- predictive thought patterns

Deep bonds may allow rider and dragon to understand each other instinctively during combat.

---

# Dragon Personality Traits

Each dragon possesses unique personality traits.

Possible traits include:
- aggression
- independence
- curiosity
- loyalty
- patience
- emotional sensitivity
- territorial behavior
- confidence
- caution

Personality traits influence:
- synchronization behavior
- combat decisions
- trust growth
- emotional reactions
- communication style

No two dragons should behave identically.

---

# Rider Compatibility

Dragons naturally respond differently to different rider personalities and behaviors.

Examples:
- aggressive dragons may prefer bold riders
- disciplined dragons may prefer calm and controlled riders
- independent dragons may resist overly controlling behavior
- protective dragons may bond strongly to compassionate riders

Compatibility influences:
- sync growth speed
- trust development
- instability frequency
- emotional reactions
- communication progression

Compatibility should create different experiences across playthroughs.

---

# Combat Decision Making

During combat, dragons evaluate:
- nearby threats
- rider danger
- emotional state
- positioning
- synchronization
- instinctive priorities

The dragon may choose to:
- attack aggressively
- defend the rider
- reposition
- retreat temporarily
- protect civilians
- react emotionally

Dragon combat behavior should remain dynamic rather than scripted.

---

# Exploration Behavior

Outside combat, dragons should display autonomous behavior.

Possible behaviors include:
- observing environments
- reacting to magical locations
- showing curiosity
- displaying territorial behavior
- responding emotionally to NPCs or events
- protecting the rider instinctively

Exploration behavior helps reinforce dragon personality.

---

# Rider Protection Logic

Most bonded dragons possess strong protective instincts toward their riders.

Protection behaviors may include:
- intercepting attacks
- repositioning near danger
- aggressive retaliation
- defensive reactions during rider injury

Some dragons may become emotionally unstable if the rider is severely threatened.

---

# Fear and Survival Logic

Dragons are not fearless.

Extreme danger, injury, or instability may trigger:
- panic
- retreat behavior
- defensive aggression
- temporary withdrawal
- refusal to engage

Even powerful dragons prioritize survival instinct under extreme conditions.

This helps preserve the feeling that dragons are living beings rather than fearless combat units.

---

# Overbond Behavior

Overbond occurs when synchronization and emotional dependency become dangerously extreme.

Possible effects include:
- involuntary emotional sharing
- instinctive synchronized actions
- emotional overload
- magical amplification
- identity instability
- synchronization addiction

Overbond may increase combat effectiveness while creating psychological danger.

---

# Vertical Slice AI Scope

The first playable prototype only needs:
- dragon follow behavior
- basic combat assist behavior
- simple emotional reactions
- basic sync influence
- instability response behavior
- limited autonomous reactions

The first goal is proving:
- the dragon feels alive
- synchronization affects behavior
- emotional cooperation feels meaningful

Advanced systems should be postponed until the core relationship works successfully.

---

# Navigation Stability (Vertical Slice)

**Status: IMPLEMENTED (v4 direct follow + rare catch-up) — playtest validation pending**

## Why direct follow failed in the graybox

The layout uses walls, pinch gates, and grove wings. The dragon steers at **`FollowAnchor`**. With a wall between dragon and rider, it pushes into geometry — there is no obstacle navigation.

## Breadcrumb follow — disabled

**v3 breadcrumb following was reverted.** It caused worse behavior when the dragon was already close:

| Problem | Cause |
|---------|--------|
| **Back-and-forth near corners** | Line-of-sight blocked → lock old trail point → player turns corner → dragon routes to stale crumb while player is nearby |
| **Premature path mode** | ~0.30 s LOS block triggered breadcrumbs even at **close range** |
| **Still stuck** | Trail points did not guarantee valid detours in tight geometry |

`PlayerPathBreadcrumbs` recording is **off**; follow goal override removed.

## Current behavior (v4)

**Default:** direct follow + `move_and_slide` (Godot wall slide). **No** breadcrumbs, side-step, or per-frame detour steering.

| Condition | Behavior |
|-----------|----------|
| **Within 140 px of anchor** | Recovery **never** runs — pure direct follow |
| **≥155 px + stuck ~1.25 s** | Faster direct catch-up velocity (~265 px/s) |
| **Still stuck ~2.75 s + far** | **Rare teleport** to clear spot near anchor (6 s cooldown) |
| **Q wait** | All recovery **off** — hold position |
| **Assist / protection** | Strike movement only; no catch-up during strike |

Debug: **F12** — `mode`, distance, stuck timer.

## Level design (vertical slice)

Until proper pathfinding exists:

- Keep passages **wide enough** for the dragon body (~32 px radius)
- Avoid tight companion traps behind single-tile corners
- Catch-up / teleport is a **safety net**, not primary navigation

## Future work

Proper navigation / navmesh when level complexity increases beyond graybox companion following.

---

# Long-Term AI Goals

Future AI systems may include:
- advanced emotional memory
- evolving dragon personality
- dynamic fear systems
- environmental preferences
- rider behavior learning
- advanced communication
- large-scale aerial behavior
- faction awareness
- social dragon interactions
- dragon political opinions

Future AI expansion should prioritize emotional believability over pure combat efficiency.

---

# AI Design Goals

Dragon AI should create the feeling that:
- dragons are intelligent beings
- bonds are emotionally meaningful
- synchronization is earned
- instability creates real tension
- dragons possess individuality
- rider and dragon grow together over time

The dragon should ultimately feel like a true partner rather than a game mechanic.