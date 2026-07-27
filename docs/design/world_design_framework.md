# Emberbound -- World Design Framework

**Status:** Authoritative design constitution for world, exploration, regions, settlements, dungeons, and Areas  
**Scope:** Philosophy and architectural language -- **not** an implementation spec  
**Revision:** 1A (philosophy refinement)  
**Engine:** Godot 4.6 - GDScript  

**Agent entry points:** [`README.md`](../README.md) - [`PROJECT_STATE.md`](../PROJECT_STATE.md) - [`CURSOR_ONBOARDING.md`](../CURSOR_ONBOARDING.md) - [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md)

This document is the **world design constitution**. Every future exploration-related design, graybox, dungeon, settlement, and Area should be measured against it before implementation begins.

It does **not** replace the Vertical Slice design constitution ([`vertical_slice_design_v1.md`](./vertical_slice_design_v1.md)), which still owns slice scope, combat-partnership proof, and the fifteen-minute teaching arc. Where world language and slice content meet, this framework supplies place-making standards; the slice constitution supplies what must ship in the first playable experience.

**Related:**

| Document | Role |
|----------|------|
| [`vertical_slice_design_v1.md`](./vertical_slice_design_v1.md) | Slice constitution -- partnership, combat teaching, feature scope |
| [`game_architecture.md`](./game_architecture.md) | Full-game systems map -- politics, races, progression axes |
| [`vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md) | Current combat-teaching graybox (pre-exploration-era layout) |
| [`exploration_framework.md`](./exploration_framework.md) | How Areas are authored, grayboxed, and reviewed |
| [`representative_area_brief.md`](./representative_area_brief.md) | First Representative Area -- Cinderwatch Ridge |
| [`dragon_ai.md`](./dragon_ai.md) | Dragon autonomy -- exploration behavior goals |
| [`combat.md`](./combat.md) | Combat philosophy -- encounters must still serve place context |

---

## Design shift (post-Combat Foundation)

Combat Foundation is complete and treated as a **stable foundation**.

From this point forward:

> **Combat should serve exploration rather than exploration serving combat.**

Combat remains essential. It is no longer the sole reason a space exists. Places come first; encounters, rewards, and story emerge from what those places are.

---

# 1. World Philosophy

Emberbound's world is a **persistent, meaningful geography** -- not a playlist of disposable levels.

Players travel through places that existed before they arrived and will remain after they leave. Growth (rider, dragon, knowledge, traversal) changes how familiar places feel. The fantasy of becoming a Dragon Rider is inseparable from how the pair learns to move through and understand the world together.

### Guiding principles

These are foundational. Measure every Area against them.

1. **Design places, not levels.**  
2. **Players should remember places by their experiences there, not by their coordinates on a map.**  
3. **The world should reward curiosity.**  
4. **The world should reward observation.**  
5. **The world should reward memory.**  
6. **The player's evolving relationship with the dragon should continually change how they perceive, navigate, and interact with the world.**

### Core beliefs

1. **Places before systems.** If a space has no believable reason to exist, no mechanic justifies it.
2. **Partnership in space.** Rider and dragon experience the world as a pair -- curiosity, caution, and capability should often be shared or complementary.
3. **Depth over breadth.** A small set of rich, revisit-worthy places beats a large map of empty connectors.
4. **Show, don't lecture.** Environment, layout, and occupation teach history before UI and dialogue do.
5. **Curiosity is a verb.** Looking around, taking the long way, and returning later should frequently pay off.
6. **Memory is a skill.** Noticing and remembering the world should open doors that markers would cheapen.

### What this is not

- A mission-select lobby disguised as a map  
- A sequence of combat rooms with cosmetic skins  
- An open-world checklist of icons  
- A tutorial hallway that discards itself after use  

---

# 2. Sense of Place

Areas are remembered for the **experiences** they create, not for their geometry.

Players retain emotions, discoveries, stories, relationships, and memorable moments far more than wall layouts or path lengths. A perfectly connected graybox that leaves no impression fails Emberbound's world design -- even if it teaches combat well.

Every significant Area should strive to leave an **emotional impression**. Tone may include wonder, mystery, isolation, comfort, danger, melancholy, triumph, curiosity, or others. Do **not** prescribe a required emotion per archetype or Area. Choose tone from the place's fiction; let gameplay and observation deliver it.

### Design tests

- If the player described this Area tomorrow, would they lead with a **feeling or moment** -- or with "the third fight"?  
- Does the Area create at least one moment worth carrying forward (quiet or dramatic)?  
- Would removing combat still leave a place worth being in?

Sense of place is the difference between a space the player *uses* and a place the player *remembers*.

---

# 3. Place Identity

Every Area should have a **recognizable identity** -- something the player can name in lived language.

Players should describe Areas by experience, not coordinates:

| Prefer | Avoid |
|--------|--------|
| "The abandoned watchtower where we first crossed the ravine." | "The third combat area." |
| "The ruined village with the dragon shrine." | "Zone 2B." |
| "The waterfall where I found the hidden passage." | "The optional side path." |

Identity grows from fiction, silhouette, occupation, and what happened there. Layout supports identity; layout is not identity.

When an Area cannot be described without referring to encounter order or map position, redesign its fiction before polishing its collisions.

---

# 4. Persistent World Exploration

The world stays. The player changes.

### World Memory

Areas should feel as if they **continue existing** beyond the player's visit. The player travels through an existing world -- they do not progress through constructed gameplay levels that appear only because they arrived.

Encourage the sense that:

- life (or aftermath) goes on when the rider is elsewhere  
- occupation, weather, and ruin have causes independent of the critical path  
- returning is re-entering a place, not reloading a stage  

Avoid spaces that read as spawned for the session. Persistence is a **design feeling** first; full simulation systems are not required to achieve it.

### Why players return

Revisits should feel **rewarding**, not mandatory. Natural reasons include:

| Driver | Example feel |
|--------|----------------|
| **Player growth** | A former choke is now manageable; a nest is approachable |
| **Dragon growth** | New assist, traversal help, or presence changes risk and route |
| **World knowledge** | A clue noticed earlier finally makes sense |
| **New traversal** | A ledge, gap, or overlook becomes reachable |
| **New interaction** | A sealed shrine, nest, or settlement option opens |
| **Relationship** | Bond state changes how the pair reads danger or invitation |
| **Memory** | Something noticed earlier now invites a different approach |

### Memory-Driven Exploration

Emberbound rewards **player memory**.

The world should encourage players to remember:

- unusual landmarks  
- strange environmental details  
- dragon reactions  
- NPC conversations  
- inaccessible locations  
- mysterious structures  

Players who remember the world should naturally discover additional opportunities later. Observation and memory are meaningful player skills -- not secondary to a quest log.

Avoid artificial objective markers whenever practical. When a marker would replace remembering a silhouette, a dragon's unease, or a half-seen ledge, prefer the diegetic cue.

### Design tests

- Would a player **want** to come back without a quest marker forcing it?  
- Does returning reveal something that was always *there*, not newly spawned for padding?  
- Does the place remain **itself** -- only the player's relationship to it has changed?  
- Can attentive players unlock something later by what they noticed now?

Avoid soft-locking progress behind "you must revisit Area X" unless the fiction and geography make that desire natural.

---

# 5. World Hierarchy

Use this terminology in **all** future documentation and design conversation.

```
World
  v
Region
  v
Area
  v
Point of Interest (POI)
  v
Structure
  v
Room
```

### Definitions

| Term | Meaning |
|------|---------|
| **World** | The full persistent setting of Emberbound |
| **Region** | A large geographic / cultural / ecological identity (biome + people + conflict tone) |
| **Area** | The **standard exploration unit** -- a coherent place the player can name and remember |
| **Point of Interest (POI)** | A distinct attractor inside an Area (landmark, nest, shrine, camp, vista, ruin focus) |
| **Structure** | A built or natural construction the player can enter or circumnavigate (tower, mine, hall, cave mouth) |
| **Room** | A **literal architectural interior** inside a Structure -- not a synonym for "combat space" |

### Terminology rules

- Prefer **Area** over "level," "map," "stage," or "combat room."  
- Prefer **POI** over "objective marker" when describing diegetic attractors.  
- Use **Room** only for interiors that are actually rooms.  
- A dungeon is not a hierarchy level of its own: it is typically a **Structure** (or chain of Structures) composed of **Rooms**, situated in an **Area**, within a **Region**.

### Relationship to the current slice graybox

`VerticalSlice_Level_P1` was built as a **combat-teaching route** (named spaces along a spine). It remains valid as a partnership / combat proof. Future exploration work should **reframe and evolve** place language toward this hierarchy rather than treating that graybox as the long-term world model. See Sec. 15.

---

# 6. Area Design Principles

Every Area should answer:

1. **Where am I?** -- Readable identity within seconds (silhouette, materials, light, sound potential).  
2. **Why does this place exist?** -- Fiction and geography, not "because the next fight needed a box."  
3. **What is the player's immediate objective?** -- Can be soft (reach the far side, investigate smoke, find shelter).  
4. **What encourages curiosity?** -- A side spur, a half-seen ruin, a nest, a vista, an odd occupation.  
5. **What story does this Area tell?** -- Occupation, abandonment, conflict, stewardship, danger.  
6. **Why might the player return later?** -- At least one honest revisit hook (traversal, knowledge, relationship, memory, or reward class).  
7. **What impression might linger?** -- Not a prescribed emotion -- a honest sense of place (Sec. 2).

### Hard rules

- **No pure connectors.** Avoid Areas that exist only to link two other Areas. Transitions may be short paths or thresholds, but if it is called an Area, it needs purpose.  
- **Combat is contextual.** Encounters occupy the place; the place is not a frame for encounters.  
- **One job per Area, many textures.** An Area may host fight, rest, discovery, and story -- but it should have a clear primary identity (e.g. "flooded quarry," not "generic combat zone 3").  
- **Believable before clever.** Clever loops and gates are welcome when they grow from the place's logic.  
- **Nameable by experience.** If players would only call it by encounter order, it lacks place identity (Sec. 3).

### Design Places, Not Levels

| Avoid | Prefer |
|-------|--------|
| Combat Room | Abandoned Watchtower |
| Treasure Room | Ancient Shrine |
| Puzzle Room | Flooded Quarry |
| Hub Room | Village Square |
| Transition Room | River Crossing |
| Camp Room | Caravan Camp |

Every place should feel like it existed before the player arrived.

---

# 7. Area Archetypes

Archetypes are **place roles**, not biome skins. A Region may contain several. An Area usually leans on one primary archetype and may borrow secondary notes.

| Archetype | Purpose in the journey | Typical feelings |
|-----------|------------------------|------------------|
| **Threshold** | Entry into a Region or major change of tone | Arrival, orientation, soft invitation |
| **Lived settlement** | People, trade, rest, social stakes | Safety, politics, rumor, belonging |
| **Wild corridor** | Travel between denser places | Journey, weather, occasional threat |
| **Occupied ruin** | History under present danger | Memory, caution, layered story |
| **Resource / industry** | Quarry, mine, mill, logging cut | Labor, scar, opportunity, hazard |
| **Sacred / marked ground** | Shrine, burial, bond site, omen stone | Reverence, taboo, dragon reaction |
| **Stronghold / watch** | Tower, gate, fort, roadblock | Authority, denial, confrontation |
| **Nest / lair adjacency** | Places shaped by dragons or predators | Territory, scent of power, risk |
| **Refuge** | Grove, camp, overlook, shelter | Recovery, partnership calm, vista |
| **Depths (dungeon-like)** | Interior Structures with Room sequences | Compression, discovery, commitment |

"Typical feelings" are compositional hints, not assigned emotional scripts. Sense of place (Sec. 2) still chooses tone from fiction.

These archetypes guide **composition**. They are not a mandatory checklist for every Region.

**Deferred detail:** exact Vertical Slice Region/Area roster is chosen in a later content milestone -- this framework only defines the language.

---

# 8. Points of Interest

A POI is something the player can **point at and remember**.

### Good POIs

- Create desire ("I want to get closer to that")  
- Anchor navigation (silhouette, elevation, unusual light)  
- Carry micro-story (who was here, what they left, what still lives here)  
- Optionally gate or reward curiosity without requiring UI  
- Invite memory ("I'll come back when I can reach that")  

### POI classes (non-exhaustive)

| Class | Role |
|-------|------|
| **Landmark** | Far-readable navigation and memory |
| **Discovery** | Hidden or subtle reward for looking |
| **Interaction** | Touch, inspect, bond moment, rest, short event |
| **Threat** | Occupied space that explains danger |
| **Vista** | Emotional and spatial breath; "I was here" |
| **Traversal key** | Place that matters more after new movement options |

### Density

Prefer **few strong POIs** over many weak markers. If everything is highlighted, nothing is a Point of Interest.

---

# 9. Navigation Philosophy

Players should primarily navigate through:

- landmarks and silhouettes  
- elevation and ridgelines  
- lighting and contrast  
- memorable layouts and bottlenecks  
- environmental composition (paths worn by use, water flow, settlement edges)

### Principles

1. **Diegetic first.** UI maps, markers, and breadcrumbs are last resorts -- not the default teacher.  
2. **Readable at the body scale.** The player should often know the next inviting direction without opening a menu.  
3. **Memory over minimap.** Distinct shapes beat repeated modular corridors.  
4. **Dual routes when meaningful.** Alternate paths should differ in **feel** (quiet vs exposed, high vs low), not only length.  
5. **Lost is rare; uncertain is useful.** Brief ambiguity that resolves through observation is good. True disorientation is a failure of place design.

The current slice's dual route (direct choke vs Quiet Grove) is a useful early example of **feel-differentiated** paths -- future Areas should preserve that spirit with stronger place fiction.

---

# 10. Memory Landmarks

Not all landmarks serve the same purpose.

| Type | Role |
|------|------|
| **Navigation Landmark** | Helps the player orient and wayfind (silhouette, tower, ridge, distinctive tree) |
| **Memory Landmark** | Becomes emotionally significant because of **what happened there** |

A single place may be both. Many Navigation Landmarks never become Memory Landmarks. A Memory Landmark may start as an ordinary ledge, shrine, or clearing until experience charges it.

### How Memory Landmarks form

They emerge from gameplay -- not from scripted spectacle alone. Examples of the *kind* of moment (not a content checklist):

- first successful dragon-assisted traversal  
- first true flight over a known Area  
- an unforgettable battle in a specific place  
- a meaningful discovery  
- a quiet place of reflection with the dragon  

### Design implications

- Leave room for moments to **attach** to places -- do not over-script every landmark as "the emotional beat."  
- Prefer conditions that make memorable partnership and discovery *possible*.  
- Do not rename or badge a site as a Memory Landmark in UI; players name them in recollection.  
- Revisits gain power when a Navigation Landmark has become a Memory Landmark.

---

# 11. Encounter Philosophy

Combat must have **context**.

Enemies should appear to:

| Verb | Meaning |
|------|---------|
| **Guard** | Hold a threshold, shrine, gate, or store |
| **Patrol** | Move along a believable route |
| **Occupy** | Live in or squatted within a place |
| **Defend** | React to intrusion of *their* space |
| **Hunt** | Seek prey; pressure in the wild |
| **Nest** | Territory and brood logic |
| **Ambush** | Use place geometry (choke, blind corner, overlook) |

### Rules

- Do **not** place encounters because "this is the combat section."  
- Encounter composition should still respect combat teaching roles (Scout / Raider / Brute and future roles) from the slice constitution -- **roles serve the situation**, not the reverse.  
- Mixed fights should feel like **who is here and why**, not a random archetype checklist.  
- Empty space is allowed. Silence and absence are part of storytelling.  
- Refuge Areas and calm beats remain necessary; partnership needs breath between strain.  
- A great fight can help create a Memory Landmark (Sec. 10); a fight without place context rarely does.

### Partnership lens

Ask: *Does this encounter create a decision that involves the dragon as partner -- protection, assist timing, shared risk -- because of how the place is occupied?* If not, reconsider placement or composition.

---

# 12. Reward Philosophy

Exploration rewards extend **beyond equipment**.

| Reward class | Examples |
|--------------|----------|
| **Traversal** | Shortcuts, ledges, alternate returns |
| **Knowledge** | Lore fragments, readable scenes, remembered clues |
| **Dragon** | Reactions, bond-flavored moments, nest/site interactions |
| **Spectacle** | Vistas, reveals, environmental set pieces |
| **Material** | Rare resources (when economy exists) |
| **Challenge** | Optional encounters, risky side pockets |
| **World state** | Soft changes: cleared camp, opened path, quieter road |
| **Memory** | A place that now means something -- often the lasting reward |

### Principles

1. **Curiosity should frequently pay.** Not every spur needs loot -- but empty curiosity trains players to stop looking.  
2. **Observation should frequently pay.** Details noticed now may matter later (Sec. 4).  
3. **Memory should frequently pay.** Remembering a ledge, reaction, or conversation is progress.  
4. **Avoid loot-as-apology.** Do not compensate for a hollow place with a chest. Fix the place.  
5. **Power is not the only progress.** Knowledge, traversal, and memorable place are first-class.  
6. **Optional != irrelevant.** Side POIs should deepen the world even when skipped for the critical path.

Inventory, crafting, and full loot economies remain deferred per the slice constitution; this section defines **what kinds of rewards** exploration may eventually grant so implementation does not default to gear alone.

---

# 13. Environmental Storytelling

Players should often understand what happened by **observing**.

### Prefer

- Arrangement of objects, bodies of evidence, wear patterns  
- Damage, repair, and abandonment layered in space  
- Dragon-relevant signs (scorch, claw, nesting, reverence, fear)  
- Settlement logic (who cooks where, what is guarded, what is hidden)

### Avoid

- Expository plaques as the primary teacher  
- Combat clutter that reads as "arena props" with no history  
- Contradictory occupation (pristine shrine guarded by random bandits with no fiction)

**Show rather than explain** whenever possible. Dialogue and UI may confirm; they should rarely be the first reveal.

Environmental storytelling feeds Sense of Place (Sec. 2) and Memory-Driven Exploration (Sec. 4). It is how the world teaches without becoming a level select.

---

# 14. Traversal Progression

Traversal progression expands **possibility**, not merely speed.

### Philosophy

- New movement options should recontextualize **known** Areas.  
- Gates should prefer **understanding + capability** over pure keycard items.  
- "Locked door needs Item X" is allowed sparingly when the fiction is strong; it must not be the default vocabulary of progress.  
- Elevation, gaps, water, instability of ground, and social barriers (guards, taboo) are valid soft gates.  
- Remembered inaccessible places are intentional invitations -- not designer taunts.

### Preferred gate types

| Gate | Player experience |
|------|-------------------|
| **Observation** | "I saw how to do this earlier" |
| **Capability** | Rider skill, tool, or dragon assistance |
| **Relationship** | Bond/sync-gated trust moments (use rarely and clearly) |
| **Knowledge** | Riddle of place, not UI password |
| **Courage / risk** | Optional hard path with clear stakes |
| **Memory** | "I remember that ledge / reaction / warning" |

Implementation of specific traversal skills is **out of scope** for this document -- only the progression philosophy is binding.

---

# 15. Dragon Exploration Progression

The dragon must not become **a horse with wings**.

Traversal and exploration progression should reinforce the fantasy of becoming a **Dragon Rider** -- a deepening partnership that changes how the world is perceived and crossed.

### Progression philosophy (not an implementation schedule)

```
Companion
  v
Partner
  v
Traversal Assistance
  v
Short Mounted Gliding
  v
True Flight
```

| Stage | Design intent |
|-------|----------------|
| **Companion** | Present in the world; follow, react, share space |
| **Partner** | Mutual reliance in danger and calm; readable cooperation |
| **Traversal Assistance** | Dragon helps with reach, clearance, or access without full mounting fantasy |
| **Short Mounted Gliding** | Taste of aerial freedom -- limited, local, memorable |
| **True Flight** | **Transformative** -- familiar Areas become newly legible; not "faster run" |

### Rules

1. **True flight is a chapter change**, not a movement buff.  
2. Each stage should change **how the pair reads the world**, not only how far they travel.  
3. Dragon reactions to sacred sites, nests, ruins, and settlements are part of exploration progression -- capability is not only locomotion.  
4. Partnership moments in specific places are prime candidates for Memory Landmarks (Sec. 10).  
5. Do not fully define mounts, stamina, maps, or aerial combat here. Future milestones own mechanics; this owns the fantasy arc.

Ground partnership remains the proven Vertical Slice core. Aerial progression is **post-proof expansion** guided by this philosophy.

---

# 16. Representative Area Standards

The first playable Area of the exploration era should be a **proof of philosophy**, not merely a tutorial and not merely "the first level."

### It must demonstrate

| Standard | Evidence in design |
|----------|--------------------|
| **Sense of place** | A lingering impression beyond geometry (Sec. 2) |
| **Place identity** | Describable in lived language, not encounter order (Sec. 3) |
| **Persistent World Exploration** | Honest revisit hook; World Memory; place remains relevant (Sec. 4) |
| **Memory-driven potential** | Something worth noticing now that may matter later |
| **Area philosophy** | Answers the Area questions (Sec. 6) |
| **Navigation** | Navigation Landmarks / layout guide without UI dependence |
| **Contextual encounters** | Enemies guard, occupy, hunt, etc. -- not "combat section" |
| **Environmental storytelling** | Readable history without a quest log |
| **Meaningful POIs** | Few, strong, memorable |
| **Reasons to return** | Growth, knowledge, traversal, or memory -- not a forced checklist |

Memory Landmarks cannot be fully guaranteed in a design brief -- they emerge in play. The Area must **make them possible**.

### It must not be

- A corridor of archetype classrooms with cosmetic names only  
- Disposable after first clear  
- A feature demo for systems that ignore place fiction  
- Memorable only as "where the Brute tutorial was"  

### Relationship to `VerticalSlice_Level_P1`

The current graybox proves **combat partnership teaching** and pacing. It is a valuable foundation and playtest bed. It is **not** automatically the Representative Area until it is redesigned (or replaced) to meet the standards above while preserving partnership lessons.

Future content milestones will decide whether to evolve P1 in place or author a new Representative Area that still hosts the combat teaching arc.

**No Area implementation belongs in the World Design Framework milestone.**

---

# 17. Future Expansion Guidelines

When adding Regions, Areas, dungeons, or settlements:

1. **Start from place fiction** -- name, purpose, occupation, history, and intended sense of place.  
2. **Write the lived name** -- how would a player describe this Area after leaving?  
3. **Assign hierarchy terms correctly** -- Region -> Area -> POI -> Structure -> Room.  
4. **Write the Area answers** before graybox geometry (Sec. 6).  
5. **Place encounters with verbs** (Sec. 11).  
6. **Define reward classes** beyond gear -- include knowledge, memory, and traversal (Sec. 12).  
7. **Plan at least one revisit hook** (Sec. 4).  
8. **Plant memory invitations** -- details, inaccessible teases, dragon reactions worth remembering.  
9. **Check dragon fantasy** -- how does the pair's stage of progression change this place?  
10. **Defer systems** that are not required to make the place true (economy, politics, flight, races) until the place works without them.  
11. **Prefer refining one Region** over sketching five empty ones.  
12. **Combat Foundation stays stable** -- do not reopen combat pillars unless playtesting shows a place-driven need.

### Dungeon guidance (summary)

Dungeons are **Structures (and Rooms) with commitment and discovery**, not a separate game mode. They should still feel like places -- mines, vaults, buried shrines, nest caverns -- continuous with the Region's fiction.

### Settlement guidance (summary)

Settlements are Areas (or clusters of Areas) whose primary archetype is lived space. They support rest, story, and soft progression without becoming menu towns disconnected from geography.

---

## Authority & conflicts

| Question | Wins |
|----------|------|
| World / exploration / Area philosophy | **This document** |
| Slice scope, combat teaching arc, defer list | [`vertical_slice_design_v1.md`](./vertical_slice_design_v1.md) |
| Live combat / relationship mechanics | Level 2 checkpoints |
| Full-game politics / races / systems map | [`game_architecture.md`](./game_architecture.md) -- must not contradict this hierarchy or place philosophy |
| Current graybox layout | [`vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md) until superseded by Cinderwatch graybox |
| Representative Area fiction / quality bar | [`representative_area_brief.md`](./representative_area_brief.md) |

---

## Open design questions

Tracked for future milestones -- **not** decided here:

1. How early may **Traversal Assistance** appear without undermining ground partnership proof?  
2. How strongly may **relationship state** gate traversal without feeling like a soft lock?  
3. What is the first **dungeon-like Structure** that best proves Rooms-as-architecture (not combat boxes)?  
4. How do **settlements** share space with wild Areas in the first Region without splitting the game into "town mode" vs "fight mode"?  

**Resolved (working):** Representative Area = **Cinderwatch Ridge**; Region = **Emberwake Marches**; evolve-P1 vs new Area = **new Area** -- see [`representative_area_brief.md`](./representative_area_brief.md). Naming may finalize in a later lore pass.

---

## Document history

| Date | Change |
|------|--------|
| 2026-07-26 | Initial draft -- Exploration & Dungeon Pass 1, Milestone 1 (World Design Framework, planning phase) |
| 2026-07-26 | Revision 1A -- Sense of Place, Place Identity, World Memory, Memory-Driven Exploration, Memory Landmarks; guiding principles elevated; construction sections preserved |
| 2026-07-26 | Open questions updated -- Cinderwatch Ridge / Emberwake Marches resolved via Representative Area brief |
