# Emberbound -- Representative Area Design Brief

**Status:** Approved design brief -- fiction authoritative; **current graybox has not fulfilled this brief**  
**Milestone:** Exploration & Dungeon Pass 1 - Milestone 2 (brief)  
**Graybox status:** Pass 1 implemented -- validation failed -- see [`project_checkpoint_cinderwatch_graybox_pass1.md`](../checkpoints/project_checkpoint_cinderwatch_graybox_pass1.md)  
**Constitution:** [`world_design_framework.md`](./world_design_framework.md) (Rev 1A)  
**Production architecture:** [`exploration_framework.md`](./exploration_framework.md) (Pass 1)  
**Implementation notes:** [`cinderwatch_ridge.md`](../level/cinderwatch_ridge.md)  
**Slice constitution:** [`vertical_slice_design_v1.md`](./vertical_slice_design_v1.md)  
**Combat-era graybox (sandbox):** [`vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md)

**Agent entry:** [`PROJECT_STATE.md`](../PROJECT_STATE.md)

This brief is the experiential and philosophical blueprint for Emberbound's first **Representative Area**. It establishes the quality bar for future Areas. It intentionally stops short of geometry, scenes, scripts, and systems.

---

## Core Memory

> **"Cinderwatch Ridge -- where my dragon stopped at the broken signal road, and I learned to trust what it sensed before I did."**

This is the emotional anchor for the entire Area. Layout, encounters, and POIs exist to make this memory *possible* -- not to guarantee a cutscene.

The remembered experience is **shared judgment**: the dragon notices danger or wrongness in a place the rider might rush; the pair takes a harder, truer path together. Combat may occur. Combat is not the Core Memory.

---

## Area Identity

| | |
|--|--|
| **Working Area name** | **Cinderwatch Ridge** |
| **Working Region name** | **The Emberwake Marches** |
| **Primary archetype** | Stronghold / watch (abandoned signal ridge) |
| **Secondary notes** | Occupied ruin - Refuge - Threshold |
| **Area purpose** | Prove Emberbound's place-first exploration while still hosting the Vertical Slice's partnership + combat teaching arc |
| **Sense of place** | A high, wind-scraped ridge road that once carried messages between settlements -- now half-claimed by scrub, ash, and whoever nests in abandoned stone |
| **Emotional tone** | Melancholy frontier - cautious wonder - earned trust - intermittent danger |
| **Why it exists in the world** | The Marches kept **signal watches** and ridge roads for rider-era and pre-rider messaging. Cinderwatch was one link in that chain. The road failed (collapse, raid, or nesting pressure -- readable in environment, not a lore dump). The watch was abandoned. The place did not vanish; it was **reoccupied** by scavengers and opportunists who prefer a choke they did not build |

### Lived identity (how players should name it)

Prefer:

- "Cinderwatch -- the ridge where my dragon wouldn't take the easy road."  
- "The broken signal bridge and the old watch."  
- "The hearth grove below the tower."  

Avoid:

- "The Scout tutorial area."  
- "Vertical slice level."  
- "Combat spine west of the Hold."  

---

## Player Experience (before systems)

| Question | Answer |
|----------|--------|
| **What should the player feel?** | That they are walking a real abandoned artery of the world; that the dragon is reading the land with them; that quiet and danger both belong here |
| **What should they remember hours later?** | The Core Memory -- trust at the broken road -- and the silhouette of the watch against the ridge |
| **Why is it worth revisiting?** | A sealed stair / high ledge on the watch; a dragon-marked stone that means more later; a path seen but not yet walkable; the ridge as a known landmark when returning from deeper Marches |
| **How does it strengthen the rider-dragon relationship?** | By making the dragon's presence **useful in exploration** (hesitation, curiosity, shared refuge), not only in combat assists |

---

## Six Area Questions

### 1. Where am I?

On a **signal ridge** above ash scrub and broken roadbed: stone watch, collapsed span, wind-cut overlooks, a sheltered bowl where watchkeepers once rested. The Marches feel open and exposed; the ridge is a spine of purpose through that openness.

### 2. Why does this place exist?

To **watch and relay** -- fire, banner, or rider signal -- along a frontier road. Its stones and road cuts are older than the player's journey. Abandonment and reoccupation are later chapters of the same place, not excuses for arena props.

### 3. What is the player's immediate objective?

**Reach the far outlook** along the ridge -- the next stretch of world is visible from there. Soft goal: travel the abandoned signal road with your dragon. Hard goal is not "clear all enemies"; it is **arrive**, having chosen how to move through occupation and quiet.

### 4. What encourages curiosity?

- The **watchtower silhouette** and a **high ledge / sealed stair** clearly out of reach  
- A **dragon-marked stone** the dragon reacts to before the rider understands why  
- A **collapsed signal span** with something visible on the far stub  
- The **hearth grove** as an inviting bowl off the main road  
- Smoke, banners, or scavenged watch gear showing the Hold is lived-in, not staged  

### 5. What story does this Area tell?

A frontier that once coordinated -- then failed to hold the ridge. Nature and opportunists moved in. The road still *wants* to be a road; the watch still *wants* to see. The player and dragon are early visitors in a long emptiness, not the reason the set was built.

### 6. Why will the player want to return later?

| Hook | Nature |
|------|--------|
| High watch ledge / sealed interior | Traversal + partnership (future assistance / flight context) |
| Dragon-marked stone | Knowledge + relationship -- meaning deepens with bond / world knowledge |
| Far stub of the broken span | Observation remembered; reachable when capability grows |
| Ridge as Navigation Landmark for the Region | Orientation when traveling the Marches again |
| Changed occupation | Soft World Memory -- place persists; presence may thin or shift after clearing (without requiring complex simulation) |

Revisit should feel like **returning to a known ridge**, not replaying a mission.

---

## Dragon Relationship

No new mechanics are required for this brief. The Area should make partnership **legible in space**.

| Beat | Intent |
|------|--------|
| **Approach to the broken signal road** | Dragon hesitates, holds, or angles away from the "easy" occupied choke -- Core Memory seed |
| **Hearth Grove** | Shared calm; dragon settles; partnership breathes without combat |
| **Dragon-marked stone** | Curiosity, unease, or reverence -- dragon reads history the rider only sees as carving |
| **Occupied Hold / gate** | Dragon alert before full visibility; protection moments feel like defending *this road together* |
| **Outlook** | Pair looks outward; dragon's body language toward distant nest-country or next watch |

The dragon is an **active exploration partner**: sensing, preferring, reacting -- not a combat pet waiting for the next arena.

Future traversal stages (assistance -> gliding -> flight) should recontextualize Cinderwatch (tower ledge, span gap, ridge from above) without rewriting the Area's identity.

---

## Persistent World Exploration

### World Memory

Cinderwatch should feel inhabited by history and present scavengers whether or not the player is there. Ash on the road, repaired barricades that don't match original watch stone, nests or bedrolls in the Hold, a cold hearth in the grove -- causes independent of the player's spawn.

### Revisit opportunities (non-keycard)

| Driver | At Cinderwatch |
|--------|----------------|
| **Observation / memory** | Far span stub, sealed stair, marked stone |
| **Dragon growth** | Reactions deepen; later assistance makes the tower meaningful |
| **Relationship** | Returning to the grove or stone with a stronger bond feels different |
| **Player growth** | Former chokes are readable and manageable; optional hard pockets open |
| **World knowledge** | Later lore or Region travel makes the signal chain click ("this was one bead on a larger road") |
| **Future traversal** | Ledge and span become invitations fulfilled |

Avoid a mandatory "return to Cinderwatch" quest. Desire should come from the silhouette and unfinished questions.

---

## Points of Interest

Few, strong, identity-bearing. No filler.

| POI | Purpose |
|-----|---------|
| **Ashroad Watchtower** | Navigation Landmark - silhouette - future Memory Landmark - Structure with sealed high ledge |
| **Broken Signal Span** | Curiosity - environmental history - future traversal tease - Core Memory stage |
| **Hearth Grove** | Refuge - partnership calm - memorable composition - optional quiet route |
| **Waystation Hold** | Occupied ruin - contextual combat pressure - scavenger "home" |
| **Ember-scar Stone** (dragon-marked) | Story - dragon interaction - memory invitation |
| **Ridge Outlook** | Vista - journey's soft destination - view of the wider Marches |

### Density rule

If a prop does not support identity, navigation, story, curiosity, or partnership -- cut it.

---

## Encounter Philosophy

Combat exists because the ridge is **useful to occupy**, not because the design needs a combat section.

| Presence | Verb | Fiction |
|----------|------|---------|
| Light skirmishers in scrub / choke approaches | **Scout / Hunt / Ambush** | Probe travelers on the abandoned road; use pinch geometry |
| Scavenger fighters in waystation and Hold | **Occupy / Patrol** | Live in the Hold; treat the ridge as theirs |
| Heavy enforcer at fortified pinch / gate | **Guard / Defend** | Hold the choke the watch once controlled; brute force presence |

### Teaching without classroom naming

Scout / Raider / Brute roles from the slice constitution still apply as **gameplay roles**. Here they wear place fiction:

| Role | Place reading |
|------|----------------|
| **Scout** | Fast opportunists using scrub and flanks of the ridge road |
| **Raider** | Baseline scavengers of the waystation -- the occupied everyday threat |
| **Brute** | The muscle holding the old gate / fortified pinch |

Mixed encounters should feel like **who holds this stretch of road**, not an archetype checklist.

Empty stretches and the Hearth Grove remain legitimate. Silence is part of the ridge.

---

## Environmental Storytelling

Observable without exposition:

- Roadbed cut into stone, then interrupted by collapse  
- Watch stone vs crude barricade wood (original purpose vs scavenger reuse)  
- Cold signal brazier cups / banner stubs on the tower  
- Bedrolls, stolen crates, and cook-sign in the Hold  
- Grove stones darkened by old fires -- rest place, not arena lobby  
- Ember-scar Stone: heat scoring or claw-scale marks the dragon notices first  
- Outlook: distant second watch or nest-country haze -- the Marches continue  

Avoid plaques and tutorial text as primary teachers. Confirm with UI only if observation already did the work.

---

## Navigation

Orientation without UI dependence:

| Cue | Role |
|-----|------|
| **Watchtower silhouette** | Primary Navigation Landmark -- always pull toward / along the ridge |
| **Ridge elevation** | Spine of travel; low scrub reads as off-road |
| **Broken span** | Memorable composition; marks the Core Memory site |
| **Hearth Grove bowl** | Soft light / sheltered shape vs exposed road |
| **Hold smoke or banners** | Threat readable before engagement |
| **Outlook brightness / open sky** | Soft destination pull |

Dual feel routes (exposed occupied road vs sheltered grove approach) should differ in **tone**, not only length -- same spirit as P1's dual path, with stronger fiction.

---

## Relationship to `VerticalSlice_Level_P1`

### Options

| | |
|--|--|
| **A** | Evolve P1 in place -- rename spaces, retrofit fiction onto the combat spine |
| **B** | Author **Cinderwatch Ridge** as a new Representative Area |

### Recommendation: **B -- New Area entirely**

**Justification (identity over convenience):**

1. **P1 was built encounter-first.** Its named spaces still read as teaching beats (Ambush, Crossing, Hold, Last Stand). Retrofitting risks cosmetic place names on a combat syllabus -- exactly what the framework forbids.  
2. **The Representative Area is a quality bar**, not a save of sunk graybox cost. Long-term Emberbound identity needs a place designed from Core Memory outward.  
3. **P1 remains valuable** as combat/partnership sandbox and regression bed (`TestWorld` + P1). It should not be erased; it should stop being the *definition* of Emberbound's world.  
4. **Teaching arc is portable.** Scout -> Raider -> mixes -> Brute -> climax can live inside Cinderwatch's occupation fiction when grayboxing begins. Preserve lessons; do not preserve "level" ontology.  
5. **Quiet Grove -> Hearth Grove** is spiritual inheritance, not a copy-paste of geometry. Dual routes and refuge matter; they must belong to the ridge's story.

### What to carry forward from P1

- Feel-differentiated dual routes  
- Refuge that enemies do not casually violate  
- Encounter spacing that teaches roles in isolation then combination  
- Diegetic guidance over map UI  

### What not to carry forward

- Encounter-order identity as place names  
- Pure connector spaces without fiction  
- "END marker" as the emotional climax (Outlook is a vista and invitation, not a credits wall)

---

## Representative Standards Checklist

| Framework standard | How Cinderwatch meets it |
|--------------------|--------------------------|
| Sense of place | Melancholy ridge + earned trust; memorable without combat |
| Place identity | Lived naming around watch, span, grove, dragon's warning |
| Persistent world | Abandoned signal chain; scavenger reoccupation; revisit hooks |
| Memory-driven potential | Sealed stair, span stub, Ember-scar Stone |
| Area questions | Answered above |
| Navigation | Watch silhouette, elevation, compositions |
| Contextual encounters | Occupy / guard / ambush the road |
| Environmental storytelling | Watch vs scavenger materials; collapse; dragon marks |
| Meaningful POIs | Six strong POIs -- no filler list |
| Partnership | Core Memory is shared judgment, not a DPS check |

**Template test:** If every future Area aimed at this depth of fiction, memory, and partnership-in-space, Emberbound would become a stronger game. **Yes.**

---

## Explicitly out of scope (this milestone)

- Scenes, graybox geometry, collision, art  
- Scripts, traversal abilities, flight, inventory  
- Final enemy species art or faction names  
- Quest markers, map UI, save systems  
- Exact encounter counts, HP, or trigger volumes  

Those belong to a later **graybox implementation milestone** after this brief is accepted.

---

## Open implementation questions

For the first graybox pass -- not blockers for this brief:

1. Exact footprint: one Area spanning road + grove + Hold + outlook, or Area + adjacent micro-threshold? (Recommend **one Area** with clear POIs.)  
2. How strongly to show the dragon's "stop" at the broken road with **current** AI/personality tools vs temporary staging?  
3. When does Cinderwatch **replace** P1 as the F6 player-facing slice vs run in parallel during transition?  
4. How much of the sealed tower interior is hinted vs enterable in first graybox (hint-only recommended)?  
5. Naming freeze: keep working names or localize to final lore pass?

---

## Document history

| Date | Change |
|------|--------|
| 2026-07-26 | Initial brief -- Cinderwatch Ridge / Emberwake Marches; recommend new Area (B) |
| 2026-07-26 | Linked Graybox Pass 1 implementation doc |
