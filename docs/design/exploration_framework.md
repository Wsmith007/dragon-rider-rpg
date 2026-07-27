# Emberbound -- Exploration Framework

**Status:** Authoritative production architecture for authoring, organizing, connecting, and reviewing Areas  
**Scope:** How Areas are constructed -- **not** world philosophy and **not** an implementation spec for streaming, traversal systems, or gameplay features  
**Pass:** Exploration Framework Pass 1  
**Engine:** Godot 4.6 - GDScript  

**Agent entry:** [`PROJECT_STATE.md`](../PROJECT_STATE.md) - [`CURSOR_ONBOARDING.md`](../CURSOR_ONBOARDING.md) - [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md)

---

## Document roles

| Document | Owns |
|----------|------|
| [`world_design_framework.md`](./world_design_framework.md) | **What** an Area should be -- constitution, philosophy, hierarchy language |
| [`representative_area_brief.md`](./representative_area_brief.md) | First Area quality bar -- Cinderwatch Ridge experiential blueprint |
| **This document** | **How** Areas are authored, structured, connected, grayboxed, and reviewed |
| [`vertical_slice_design_v1.md`](./vertical_slice_design_v1.md) | Slice scope, combat teaching arc, defer list |
| [`vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md) | Combat-era graybox reference -- not the exploration production template |
| [`technical_architecture.md`](./technical_architecture.md) | Code/scene modularity -- defer to this doc for Area production pipeline |

Together:

- **Why** Areas exist -- World Design Framework  
- **How** Areas are designed -- briefs + World Design Framework questions  
- **How** Areas are constructed -- this Exploration Framework  
- **How** Areas are reviewed -- checklist in this document  

---

## Design shift reminder

> Combat should serve exploration rather than exploration serving combat.

This framework is the exploration-era equivalent of reusable combat architecture: consistency so each new Area requires fewer architectural decisions.

**Do not** invent gameplay features here. Define responsibilities, workflow, language, and review gates.

---

# 1. Area Architecture

An Area is a coherent exploration unit (World Design Framework hierarchy). Architect it as **logical layers of responsibility**, not as a mandated Godot node tree.

Node organization may follow these layers when useful, but the layers are the standard -- the tree is an implementation detail.

### Logical layers

| Layer | Responsibility |
|-------|----------------|
| **Area Root** | Identity boundary: name, Region membership, brief link, entry/exit intent, what "counts" as this place |
| **Terrain / Walkable Space** | Ground, bounds, chokes, elevation intent, collision that matches visible space |
| **Navigation** | How players orient: spines, dual routes, sightlines, readable edges |
| **Landmarks** | Far-readable anchors (Navigation Landmarks; candidates for Memory Landmarks) |
| **Points of Interest** | Strong attractors with purpose -- curiosity, story, refuge, threat, vista, future hook |
| **Structures** | Built or enterable volumes (watch, hold, cave mouth) composed of Rooms only when interiors are literal rooms |
| **Environmental Storytelling** | Occupancy evidence, wear, history readable without UI |
| **Encounter Contexts** | Why bodies are here -- verbs and fiction slots, not anonymous spawn pads |
| **Refuge / Calm** | Partnership breath; spaces enemies should not casually violate |
| **Audio (intent)** | Ambient character of the place (wind ridge, grove hush, occupied hold) -- placeholders OK in graybox |
| **Lighting (intent)** | Contrast that reinforces movement and identity -- graybox lighting is directional, not final art |
| **Area Connections** | Thresholds to neighbors; return continuity; soft destination pulls |
| **Future Traversal Hooks** | Seen-but-unreachable invitations -- documented, not implemented as systems |

### Layer rules

1. **Fiction first.** Every layer supports Core Memory and place identity.  
2. **Few strong POIs.** Prefer empty honest space over filler attractors.  
3. **Visible = physical** in graybox (lesson from P1): drawn bounds match collision.  
4. **Encounter Contexts attach to place** (Hold occupies, gate guards) -- never to "combat section N."  
5. **Hooks are invitations.** Document what players should notice; do not ship traversal mechanics in Pass 1 grayboxes unless a later milestone requires it.  
6. **Avoid pure connector Areas.** Short thresholds are fine; if it is named an Area, it needs purpose.

### What an Area package should include (docs)

Before or beside geometry, each Area should have:

| Artifact | Purpose |
|----------|---------|
| **Area Brief** | Identity, Core Memory, six questions, POIs, encounter verbs, revisit hooks |
| **Connection notes** | Neighbors, transitions, return expectations |
| **Review checklist result** | Pass/fail notes against Sec. 8 |
| **Graybox validation notes** | What Pass 1 geometry proved (Sec. 7) |

Cinderwatch already has a brief. Future Areas follow the same pattern.

---

# 2. Area Lifecycle

Recommended order for creating a new Area. Skip steps only with explicit justification.

```
1. Region placement          -- where does this sit in the world?
2. Area identity             -- lived name, archetype, why it exists
3. Core Memory               -- one experiential sentence
4. Area purpose              -- journey role + emotional tone
5. Six Area questions        -- World Design Framework
6. Major landmarks           -- silhouette / elevation anchors
7. Navigation flow           -- spines, dual routes, destination pull
8. POIs                      -- few, purposeful
9. Encounter contexts        -- verbs + who belongs here
10. Environmental storytelling -- observe-first history
11. Dragon partnership beats -- exploration presence (no new mechanics required)
12. Revisit hooks            -- categories, not systems
13. Area connections         -- neighbors and continuity
14. World Design Framework check
15. Exploration Framework checklist (Sec. 8)
16. Graybox Pass             -- validate space, not polish
17. Playtest / iterate       -- protect Core Memory
18. Art / audio / balance    -- later passes only
```

### Lifecycle rules

- **Do not begin with layout or combat.** Begin with experience (identity + Core Memory).  
- **Do not graybox before a brief exists** for Representative or major Areas.  
- **Combat teaching** (if needed) is folded into encounter contexts after place fiction exists.  
- **P1 habits** (encounter-order naming) are anti-patterns for new Areas.

---

# 3. Area Connections

Conceptual only -- no streaming, loading, or scene-management implementation in this document.

### Connection types

| Type | Intent |
|------|--------|
| **Threshold** | Short transition with readable change of tone (gate, bridge stub, road cut) |
| **Neighbor continuity** | Shared silhouette, road, ridge, or river so Areas feel like one world |
| **Soft destination** | Vista or landmark that pulls toward the next place without a quest marker |
| **Return path** | Same geography on the way back -- not a different "exit level" |
| **Optional spur** | Side connection that deepens Region fiction without required completion |

### Continuity principles

1. **The world continues when the player leaves.** Neighbors exist for reasons beyond the critical path.  
2. **Returns reuse place identity.** Coming back should feel like re-entering Cinderwatch (or peer), not reloading a stage.  
3. **Logical world flow.** Regions have travel sense (ridge roads, valleys, settlement edges) -- not teleporter logic disguised as doors.  
4. **Visible unfinished world.** Distant watches, haze, or roads support Memory-Driven Exploration.  
5. **One Area, clear boundary.** Prefer a coherent Area with internal POIs over fragmenting every clearing into its own Area.

### Documentation of connections

For each Area, note:

- Inbound from where (and why a traveler would come)  
- Outbound toward where (soft goal)  
- What remains visible but unreachable (hook)  
- What should feel the same on return  

---

# 4. Revisit Hooks

Consistent categories for later support -- **design intent only**, not mechanics.

| Category | Intent | Example shape (not a feature list) |
|----------|--------|--------------------------------------|
| **Traversal invitation** | Seen capability gap | High ledge, broken span, sealed stair |
| **Dragon interaction** | Partnership re-reads the place | Marked stone, nest-scent, shared refuge |
| **Environmental change** | Soft World Memory | Thinned occupation, cold fires, opened path |
| **Optional discovery** | Curiosity residual | Half-seen interior, side spur |
| **Relationship progression** | Bond changes perception | Familiar grove feels safer / more charged |
| **World knowledge** | Clue pays later | Signal-chain meaning, Region lore click |

### Rules

- Hooks must be **noticeable on first visit** when practical.  
- Revisits are **rewarding**, not mandatory soft-locks.  
- Prefer combinations (memory + capability + relationship) over single keycard items.  
- First graybox **documents and stages** hooks; it does not implement flight, inventory keys, or world-state systems unless scoped.

---

# 5. Encounter Context Framework

Reusable language for describing encounters. Replace anonymous enemy counts with **place-bound context**.

### Context card (required fields)

| Field | Question |
|-------|----------|
| **Location** | Which POI / Structure / stretch of terrain? |
| **Verb** | occupying / guarding / patrolling / scavenging / defending / hunting / nesting / ambushing |
| **Fiction** | Why are they here if the player never arrives? |
| **Player read** | What should the player understand before fighting? |
| **Partnership angle** | How might the dragon matter (alert, protect, shared risk)? |
| **Teaching role (optional)** | Scout / Raider / Brute / mix -- only if the slice needs it |
| **Absence OK?** | Is empty space allowed here instead? |

### Verb cheat sheet

| Verb | Reads as |
|------|----------|
| **Occupying** | Living in or squatting a place |
| **Guarding** | Holding a threshold, store, or shrine |
| **Patrolling** | Moving a believable route |
| **Scavenging** | Taking from ruins / road |
| **Defending** | Reacting to intrusion of *their* space |
| **Hunting** | Seeking prey in wild approaches |
| **Nesting** | Territory / brood logic |
| **Ambushing** | Using place geometry |

### Anti-patterns

- "Three enemies in section 4"  
- Encounter placed only for pacing quota  
- Archetype checklist with no fiction  
- Combat in a Refuge without extraordinary justification  

---

# 6. Navigation Framework

Review guidelines for development -- not UI or pathfinding implementation.

### Evaluation questions

1. Can the player orient within seconds using silhouette, elevation, or light -- without a map?  
2. Is there at least one strong **Navigation Landmark**?  
3. Are major shapes recognizable from more than one approach?  
4. Do dual routes differ in **feel** (exposed vs sheltered), not only length?  
5. Does lighting/contrast reinforce the intended spine?  
6. Is brief uncertainty useful -- and does it resolve through observation?  
7. Would a player describe direction by landmark ("toward the watch") rather than "left at the third fight"?  

### Navigation review outcomes

| Result | Meaning |
|--------|---------|
| **Pass** | Diegetic orientation works in graybox play |
| **Revise layout** | Landmark weak, spine ambiguous, or false walls |
| **Revise fiction** | Space readable but identity absent -- not a lighting fix |

P1 lesson to keep: feel-differentiated routes and sealed refuges. P1 lesson to discard: encounter-order as navigation vocabulary.

---

# 7. Graybox Standards

### A Graybox Pass **should** validate

| Concern | Success looks like |
|---------|--------------------|
| **Identity** | Place readable without final art |
| **Core Memory possibility** | Staging exists for the remembered beat (even if temporary) |
| **Navigation** | Orientation without UI |
| **Landmarks / POIs** | Few strong anchors; no filler clutter |
| **Pacing / flow** | Breath between pressure; refuge works |
| **Encounter context** | Fights belong to occupation fiction |
| **Exploration flow** | Curiosity pulls; soft destination clear |
| **Bounds integrity** | Visible space matches walkable space |
| **Hook visibility** | Future invitations are noticeable |

### A Graybox Pass **should not** attempt to validate

- Final art, VFX, or production audio  
- Combat balance / DPS tuning as a primary goal  
- Progression, inventory, flight, or relationship gating systems  
- Streaming / loading architecture  
- Full Memory Landmark emergence (that requires play over time)  

### Graybox deliverables

1. Playable space matching the Area Brief's major beats  
2. Short validation notes (what passed / what failed checklist)  
3. No scope creep into systems milestones  

**Cinderwatch Ridge Graybox Pass 1** followed these standards and the Cinderwatch brief. Pass 1 was implemented but failed experiential validation -- see [`project_checkpoint_cinderwatch_graybox_pass1.md`](../checkpoints/project_checkpoint_cinderwatch_graybox_pass1.md). This framework is not redefined by that outcome.

---

# 8. Area Review Checklist

Use for every future Area (brief review and graybox review). Record yes / no / notes.

### Identity

- [ ] Recognizable lived identity (not encounter-order naming)  
- [ ] Primary archetype clear  
- [ ] Would removing combat still leave a place worth being in?  

### Core Memory

- [ ] One experiential Core Memory sentence exists  
- [ ] Geometry and beats support that memory (do not require a cutscene)  
- [ ] Players could describe the Area by experience tomorrow  

### Navigation

- [ ] Natural orientation without UI  
- [ ] Memorable Navigation Landmark(s)  
- [ ] Lighting/contrast reinforce movement intent (even in graybox)  
- [ ] Recognizable from multiple directions where relevant  

### Curiosity

- [ ] At least one honest invitation to look closer  
- [ ] POIs are few and purposeful  
- [ ] Optional path or spur differs in feel  

### Dragon Partnership

- [ ] Dragon can meaningfully participate in exploration (react, hesitate, share refuge, alert)  
- [ ] Partnership is not combat-only  
- [ ] No dependence on unimplemented traversal systems for the Core Memory  

### Environmental Storytelling

- [ ] History readable by observation  
- [ ] Occupation evidence present where encounters exist  
- [ ] Avoids expository plaques as primary teacher  

### Persistent World / Revisit

- [ ] Place feels pre-existing  
- [ ] At least one revisit hook category documented  
- [ ] Return would feel rewarding, not mandatory  

### Encounter Context

- [ ] Every fight has a verb and fiction  
- [ ] Refuge remains protected unless justified  
- [ ] Teaching roles (if any) serve the situation  

### World Design Framework

- [ ] Guiding principles upheld (places not levels; curiosity; observation; memory; partnership)  
- [ ] Six Area questions answered  
- [ ] Hierarchy terms used correctly (Area / POI / Structure / Room)  

### Exploration Framework

- [ ] Lifecycle followed (or deviations justified)  
- [ ] Connections documented  
- [ ] Graybox scope respected (if in graybox phase)  

**Template test:** If this Area became the template for every future Area, would Emberbound become a stronger game?

---

# 9. Production Workflow Recommendations

### Standard cadence for a new Area

```
Brief (docs)
  -> Checklist pass on paper
  -> Graybox Pass 1 (space + identity + context)
  -> Checklist + playtest notes
  -> Content iteration (encounters, storytelling density)
  -> Presentation passes (art, audio) -- separate milestones
```

### Role of existing spaces

| Space | Role going forward |
|-------|--------------------|
| `TestWorld` | Systems sandbox |
| `VerticalSlice_Level_P1` | Combat/partnership regression -- not the exploration template |
| **Cinderwatch Ridge** | First Representative Area -- Pass 1 implemented; validation failed; Identity and Access Correction next |

### Naming

- Use World hierarchy terms in docs and reviews  
- Scene file names may stay technical; **player-facing and design language** use Area identity  

---

# 10. Authority and conflicts

| Question | Wins |
|----------|------|
| What an Area should feel like / philosophy | [`world_design_framework.md`](./world_design_framework.md) |
| Cinderwatch fiction and quality bar | [`representative_area_brief.md`](./representative_area_brief.md) |
| How to author / review / graybox Areas | **This document** |
| Slice combat teaching requirements | [`vertical_slice_design_v1.md`](./vertical_slice_design_v1.md) |
| Live combat mechanics | Level 2 checkpoints |
| P1 layout facts | [`vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md) -- historical/combat sandbox |

If P1 practices conflict with this framework, **this framework + World Design Framework win** for new exploration work.

---

## Document history

| Date | Change |
|------|--------|
| 2026-07-26 | Exploration Framework Pass 1 -- Area architecture, lifecycle, connections, revisit hooks, encounter context language, navigation review, graybox standards, Area checklist |
