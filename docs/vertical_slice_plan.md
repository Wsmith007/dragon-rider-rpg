# Vertical Slice Goal

The goal of the first playable prototype is to prove that:
- the dragon feels emotionally alive
- synchronization changes gameplay meaningfully
- combat feels cooperative and dynamic
- the rider-dragon relationship is emotionally engaging

The prototype is not intended to represent the full game.

The focus is entirely on proving the core rider-dragon gameplay loop.

---

# Core Prototype Pillars

The first prototype focuses on four core pillars:

1. Fast movement-based combat
2. Semi-independent dragon AI
3. Emotional synchronization systems
4. Evolving rider-dragon cooperation

All early development decisions should support these pillars.

---

# Included Features

The prototype should include:
- player movement
- camera follow
- one small playable map
- basic enemy AI
- player melee attacks
- dodging
- dragon follow behavior
- dragon combat assist behavior
- basic sync system (assist frequency)
- basic instability system (assist hesitation / cancel)
- bond strength protection tuning
- early communication behavior (future)
- Human race option
- Elf race option
- simple UI for active bond stats (bond strength, sync, instability)

---

# Excluded Features

The prototype should NOT include:
- full open world
- flight systems
- inventory systems
- crafting
- advanced magic systems
- multiple dragons
- faction reputation
- complex dialogue trees
- advanced save systems
- large-scale politics
- mounted aerial combat
- multiplayer
- advanced enemy variety

Features should remain intentionally limited.

---

# First Playable Scenario

The prototype begins shortly after the player has bonded with a young dragon.

The rider and dragon are inexperienced and poorly synchronized.

The player explores a small region while:
- learning combat
- surviving enemy encounters
- improving synchronization
- experiencing evolving dragon communication

The prototype should establish:
- emotional attachment
- cooperation
- instability tension
- dragon individuality

---

# First Map Scope

The first map should remain small and focused.

Suggested areas:
- small settlement
- forest path
- open combat clearing
- ruined dragon site
- small cave or ruins area

The first map exists primarily to support:
- movement testing
- combat testing
- dragon behavior testing

World size should remain intentionally limited.

---

# Initial Systems

## Player Systems

- movement
- dodging
- melee attacks
- health
- race modifiers

---

## Dragon Systems

- follow behavior
- autonomous positioning
- combat participation
- emotional reactions
- synchronization influence
- instability reactions

---

## Enemy Systems

- chase behavior
- attack behavior
- threat targeting
- basic damage handling

---

## Bond Systems

**Active gameplay stats:**
- `bond_strength` — relationship depth; protection (prototype)
- `sync` — coordination; assist frequency (prototype)
- `instability` — strain; assist hesitation and cancellation (prototype)

**Compatibility / future (not active gameplay):**
- `trust_state` — **deprecated**; retained on `BondProfile` only
- `communication_stage` — design only
- `resonance_style` — design only

The three active stats should visibly influence dragon behavior. See `project_checkpoint_milestone5.md` for implemented hooks.

---

# First Combat Goals

Combat should feel:
- fast
- responsive
- mobile
- cooperative
- emotionally dynamic

The dragon should:
- assist autonomously
- respond to player actions
- occasionally act independently
- visibly react to sync and instability

Combat should avoid feeling scripted or turn-based.

---

# Dragon Participation System

The prototype uses a hybrid dragon combat system.

The dragon:
- acts autonomously at baseline
- reacts dynamically to player behavior
- becomes more coordinated during strong synchronization moments

The player does not directly command every dragon action.

Instead, combat cooperation emerges through:
- movement
- timing
- emotional state
- synchronization
- intent

High synchronization creates stronger cooperative combat behavior.

Low synchronization creates hesitation and inconsistency.

---

# First Bond Goals

The prototype should demonstrate:
- evolving communication (future)
- bond strength growth (relationship depth → protection behavior)
- sync improvement (coordination → assist frequency)
- instability tension (strain → assist reliability)
- changing dragon behavior

The dragon relationship should feel different after extended play.

---

# Initial Race Scope

The first prototype only includes:
- Humans
- Elves

These races provide enough contrast to test:
- different synchronization styles
- different combat pacing
- different bond behaviors

Dwarves and Veyrin are intentionally postponed until the core systems feel successful.

---

# Initial Dragon Scope

The prototype only includes:
- one dragon companion
- one dragon personality profile
- one primary bond progression path

The goal is proving the emotional relationship system before expanding complexity.

---

# Prototype Milestones

## Milestone 1
Player movement and camera.

---

## Milestone 2
Dragon follow behavior.

---

## Milestone 3
Basic enemy combat.

---

## Milestone 4
Dragon combat assistance.

---

## Milestone 5
Sync affecting dragon behavior (assist cooldown tiers). **Done in prototype.**

---

## Milestone 6
Instability reactions (assist hesitation and cancellation). Bond strength protection tuning. **Partial / done in prototype.**

---

## Milestone 7
`communication_stage` progression (`early` → `mid`). Bond strength command responsiveness (planned).

---

# Success Criteria

The prototype succeeds if:
- the dragon feels alive
- synchronization feels meaningful
- combat feels cooperative
- instability creates tension
- the rider-dragon relationship feels emotionally engaging

The prototype does NOT need:
- large content volume
- advanced graphics
- full story systems
- complete RPG mechanics

The emotional gameplay loop is the true goal.

---

# Future Expansion After Prototype

After the prototype succeeds, future systems may include:
- Dwarves and Veyrin
- advanced dragon personalities
- advanced magic systems
- faction reputation
- large world regions
- aerial gameplay
- rider politics
- advanced dialogue systems
- multiple enemy factions
- larger narrative progression

Future expansion should only occur after the core rider-dragon relationship feels successful.

---

# Development Philosophy

The project should prioritize:
- emotional gameplay
- strong system foundations
- modular architecture
- emergent dragon behavior
- small iterative progress

The project should avoid:
- feature creep
- premature world expansion
- oversized early scope
- unnecessary complexity

The first goal is not building the full RPG.

The first goal is proving the dragon bond system works emotionally and mechanically.