# Dragon Rider RPG — Vertical Slice Design v1

**Status:** Primary design reference for the first playable version  
**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest shell:** `res://scenes/world/TestWorld.tscn`

**Agent entry points:** [`README.md`](../README.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md) · [`CURSOR_ONBOARDING.md`](../CURSOR_ONBOARDING.md) · [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md)

This document is the **design constitution** for the Vertical Slice. It defines *what the first playable version must feel like* and *what belongs in scope*. It is **not** a milestone checkpoint.

**Technical references (live behavior):**

| Document | Role |
|----------|------|
| [`project_checkpoint_combat_feel_v1.md`](../checkpoints/project_checkpoint_combat_feel_v1.md) | Rider melee, enemy combat prototype, combat feel passes 1–7 |
| [`project_checkpoint_milestone9A.md`](../checkpoints/project_checkpoint_milestone9A.md) | Relationship pipeline, Sync/Instability application, encounter resolve |
| [`relationship_event_framework.md`](./relationship_event_framework.md) | Event catalog, stat ownership, encounter philosophy |

**Supporting context:** [`combat.md`](./combat.md), [`combat_feel_notes.md`](../notes/combat_feel_notes.md), [`bond_system.md`](./bond_system.md), [`dragon_ai.md`](./dragon_ai.md), [`game_architecture.md`](./game_architecture.md), [`technical_architecture.md`](./technical_architecture.md)

**Supersedes for design direction:** [`vertical_slice_plan.md`](../historical/vertical_slice_plan.md) — retained as historical early prototype planning; mechanics and scope have evolved since that document was written.

**Level prototype:** [`vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md) — graybox scene `scenes/world/VerticalSlice_Level_P1.tscn` (Pass 1 + P1.1 fix + **Pass 2** layout)

---

## Purpose of the Vertical Slice

The Vertical Slice exists to answer one question:

> **Is the rider–dragon partnership fun enough that a player wants to keep playing?**

It is **not** a feature demo, a content vertical, or a proof that every planned RPG system works. It is a **tight, handcrafted first experience** that proves:

1. **Combat decisions matter** — positioning, facing, and timing create readable outcomes.
2. **The dragon feels like a partner** — not a pet, not a weapon, not a scripted ally.
3. **Relationship stats change how play feels** — Sync and Instability are felt in combat, not only read on a HUD.
4. **Systems create moments** — cooperation and strain emerge from gameplay, not cutscenes.

If the player finishes fifteen minutes wanting to explore more, fight again, and see how the dragon responds next time, the slice succeeds.

---

# Section 1 — Design Philosophy

### Systems over scripted moments

The bond should deepen because the player **fought well together**, **protected each other**, and **recovered from mistakes** — not because a dialogue tree said so. Encounters resolve into relationship changes; dragon behavior reacts to stats and threat context. Story beats may frame the slice, but **gameplay is the teacher**.

### Meaningful combat decisions

Every swing should answer a question: *Who am I facing? Do I need damage or space? Can my dragon help right now?* Focused attacks reward facing and target choice. Crowd-control exists for survival, not DPS. The player should never feel that holding one button is optimal.

### Relationship through gameplay

Sync, Instability, and Bond Strength are **partnership quality**, not hidden combat stats. High Sync means reliable cooperation; high Instability means hesitation and failed assists. The player learns this by **playing**, with UI support — not by reading a tutorial essay.

### Positioning over button mashing

Enemies surround and pressure. Knockback and stagger create brief windows. The player creates space with CC, commits with focused strikes, and uses movement and facing to stay readable. Skill is spatial and temporal, not input frequency.

### Readability over unnecessary complexity

Telegraphs, hit confirmation, target preview, and clear enemy states teach the fight. Complexity is reserved for **emergent combinations** (player spacing + dragon assist + relationship strain), not opaque mechanics or bloated HUDs.

### Player skill and dragon cooperation

The rider is competent alone but **stronger together**. Solo kills are possible; coordinated fights feel better and build Sync. The dragon does not replace player skill — it **amplifies** intent when the partnership is healthy and **falters** when strained.

### Enemies teach the partnership

**Every new enemy should teach the player to use a different aspect of the rider–dragon partnership rather than simply requiring more damage.**

Enemy variety must emerge from **gameplay roles** — speed, pressure, resistance, threat shape — not from inflated HP or damage numbers alone. A "harder" fight should mean **new decisions**: prioritize the scout, CC the brute, protect against a slow wind-up, coordinate an assist on the right target. Stat bloat creates grind; role diversity creates mastery.

The dragon becomes more meaningful when **enemy behavior** creates situations where protection, assist timing, and target prioritization matter — not when a script forces a dragon moment.

### Polish before expansion (full game)

A small space that feels excellent beats a large space that feels hollow. The slice prioritizes **feel** in one region over **breadth** across a world. *(See Section 12 for slice **build** order — archetypes before major polish.)*

---

# Section 2 — Core Game Pillars

These pillars describe the **current project identity** for the Vertical Slice. Full-game pillars (politics, races, magic economies) exist in [`game_architecture.md`](./game_architecture.md) but are **deferred** until the core loop is proven.

### 1. Rider + Dragon Partnership

The dragon is a semi-independent companion with priorities, fear, and instinct. The player influences through intent, positioning, and bond state — not direct puppet control. Combat and exploration should constantly reinforce *we are two beings learning to fight together*.

### 2. Intentional Combat

Attacks have wind-up, recovery, and role. Focused strikes demand facing; CC demands timing when surrounded. Dragon assists reward engagement alignment. The player should feel **deliberate**, not spammy.

### 3. Positioning Matters

Enemy steering spreads groups; solo hold and engage wind-ups punish careless approach. Player knockback and stagger create windows. CC is a reposition tool. Where you stand and face is as important as when you press attack.

### 4. Living Relationship

Sync and Instability update from **resolved encounters** (live per Milestone 9A). Assist hesitation, protection, and cooperation ratings make the dragon feel **responsive to recent history**. Bond Strength changes slowly (pattern-based, future) — the slice may **preview** Bond effects without full progression.

### 5. Exploration Through Discovery

The first map is small but **worth walking**. Short paths, a clearing, a ruin or landmark — enough space to breathe between fights, notice the dragon following, and feel progression from *inexperienced pair* toward *coordinated partners*. Exploration feeds calm; combat feeds strain.

---

# Section 3 — Enemy Archetypes

**Status: IMPLEMENTED in Vertical Slice — Archetype Pass 1 (2026-05-29).**

These are **gameplay roles**, not final enemy species, factions, or visual designs. The same archetype might later appear as different creatures per region. For the slice, three roles are enough to teach the full combat + partnership toolkit.

### Scout

| | |
|--|--|
| **Role** | Skirmisher / guerrilla |
| **Purpose** | Pressure and positioning — creates threat without raw damage |
| **Characteristics** | Fast movement · low health · low damage · frequent repositioning |
| **Lessons taught** | Positioning · target prioritization · weapon precision · dragon assistance |

**Behavior goals (Archetype Pass 1 — implemented):**

- Hit-and-run — **DISENGAGE** state after each strike  
- Orbit chase + strafe engage — tangential steering, never trades toe-to-toe  
- Quick wind-up (0.28 s), longer reposition window (0.72 s disengage + 0.95 s cooldown)  
- Low knockback resistance — pushed more easily when caught retreating  

The Scout punishes standing still and ignoring flanks.

### Raider

| | |
|--|--|
| **Purpose** | Baseline combat enemy |
| **Characteristics** | Balanced speed · balanced damage · balanced health · general-purpose melee opponent |
| **Lessons taught** | Core combat loop · rider/dragon cooperation · weapon comparison |

The Raider maps to the **current default prototype tuning** ([`project_checkpoint_combat_feel_v1.md`](../checkpoints/project_checkpoint_combat_feel_v1.md)). It is the reference opponent: focused attack cadence, engage wind-up, surround slots. Players learn the loop without a special gimmick — cooperation and weapon feel emerge here.

### Brute

| | |
|--|--|
| **Role** | Control check |
| **Purpose** | Spacing and crowd control — punishes poor positioning, not chase speed |
| **Characteristics** | Slow movement · high health · high knockback resistance · slow dangerous attacks |
| **Lessons taught** | Crowd control · space management · dragon protection · timing over aggression |

**Behavior goals (Archetype Pass 1 — implemented):**

- **Knockback resistance** — focused knockback (≤26 px) ignored; CC knockback reduced before resistance applied  
- **RECOVER** state — 0.58 s post-attack stillness + extended cooldown  
- Long wind-up (0.72 s), player knockback/stagger on connect  
- Future heavy / dragon combo attacks — **not implemented**  

The Brute does not die to panic focused spam.

### Archetypes vs "variants"

| Concept | Meaning |
|---------|---------|
| **Archetype (slice)** | A **role** with distinct behavior and teaching purpose — Scout, Raider, Brute |
| **Variant (full game)** | Regional or faction **expressions** of types (elite, corrupted, aged) — strength progression within regions per [`game_architecture.md`](./game_architecture.md) |

Slice archetypes are **not** "Raider but +50% HP." A Brute is slow, resistant, and threatening on a different axis than a Raider — not a larger reskin.

**Naming note:** [`combat_feel_notes.md`](../notes/combat_feel_notes.md) uses older exploratory labels (Standard, Heavy, Beast). **Raider** = Standard/default; **Brute** = Heavy-like role. Beast and ranged roles remain **post-slice**.

---

# Section 4 — Enemy Design Principles

Principles for all future enemy creation — slice and beyond.

1. **Every enemy should have a clear gameplay purpose.** If the design doc cannot finish the sentence *"This enemy teaches…"*, defer or redesign.

2. **Avoid enemies that are only larger versions of another enemy.** HP and damage inflation are not a design. New roles must change **player decisions**.

3. **New enemies should encourage different player decisions.** Different facing priorities, CC timing, assist targets, or protection needs — not longer time-to-kill alone.

4. **Weapon identities should naturally interact with enemy roles.** Dagger vs scout (precision), sword vs raider (baseline), polearm vs brute (control) — without hard counters, soft affordances.

5. **Dragon behaviors should become more meaningful because of enemy behavior, not scripted events.** Protection triggers when brutes wind up; assists matter when scouts leak damage; cooperation ratings reflect real teamwork against mixed groups.

6. **Mixed encounters test synthesis.** Single-archetype fights teach tools; Scout + Brute (etc.) teach **prioritization** and partnership under split attention.

7. **Tune behavior before tuning numbers.** Speed, resistance, and attack cadence define role; HP is the last knob, not the first.

---

# Section 5 — The Player Experience

Describe the slice by **feelings**, not feature lists.

### Trust and partnership

*"I trust my dragon — sometimes."*  
Early play feels tentative. After clean assists and protection, the player expects the dragon to show up. After hesitations and cancels, they expect unreliability. Trust is **earned in combat**, not granted at spawn.

### Spatial mastery

*"I created space with my polearm."* / *"I carved an opening with CC."*  
Surrounded moments are scary but solvable. The player learns that panic-mashing focused attacks is the wrong tool; CC or repositioning is. Weapon choice reinforces *I picked control* vs *I picked speed*.

### Target clarity

*"I killed the scout first — then handled the brute."*  
Mixed archetype fights create readable priority puzzles. The player feels clever, not overwhelmed.

### Protection beats

*"My dragon protected me."*  
When a brute winds up or threat spikes, protection strikes should feel like the dragon **noticed** danger without being ordered.

### Cost of mistakes

*"I barely survived that fight."*  
Near-death and heavy damage feel consequential — Instability rises, Excellent quality is lost, the dragon may hesitate next fight.

### Cooperation pride

*"We took that group down together."*  
Excellent Cooperation — both contributed, clean execution — feels like a **team highlight**, distinct from a solo kill.

### Wanting more

*"I want to see what happens if I fight cleaner / explore further / bond better."*  
The emotional hook is **curiosity about the partnership**, not checklist completion.

---

# Section 6 — The First Fifteen Minutes

Gameplay progression only — **not** a full story script. Pacing follows **archetype introduction**; timing is approximate.

### Flow overview

```
Safe introduction
      ↓
Single Scout
      ↓
Single Raider
      ↓
Scout + Raider
      ↓
Exploration break
      ↓
Two Raiders
      ↓
Brute introduction
      ↓
Scout + Brute
      ↓
Small climax encounter
      ↓
Quiet ending
```

### Safe introduction (~0–2 min)

| Aspect | Intent |
|--------|--------|
| **Gameplay** | Spawn at safe map edge. Movement, facing, dragon follow. Bond stats visible. |
| **Enemies** | None — combat pressure withheld. |
| **Combat lessons** | Facing will matter; camera and space readability. |
| **Relationship lessons** | Dragon is present in the world, not a menu stat. |
| **Exploration** | Short path toward first combat space — player opts in. |

### Single Scout (~2–4 min)

| Aspect | Intent |
|--------|--------|
| **Gameplay** | One Scout in open terrain. Focused attack, preview ring, telegraphs, hit confirm. |
| **Enemies** | **Scout** — fast, fragile, low damage. |
| **Combat lessons** | Track a moving target; precision over spam; wind-up → impact → recovery. |
| **Relationship lessons** | First assist if engagement aligns — dragon participates without a command. |
| **Exploration** | Bounded arena — no getting lost. |

### Single Raider (~4–6 min)

| Aspect | Intent |
|--------|--------|
| **Gameplay** | One Raider — baseline duel. Same toolkit, different tempo than Scout. |
| **Enemies** | **Raider** — default prototype tuning. |
| **Combat lessons** | Core loop at "normal" speed; compare pressure to Scout. |
| **Relationship lessons** | Cooperation on a steadier target; first clean encounter resolve. |
| **Exploration** | Exit through choke toward next space. |

### Scout + Raider (~6–8 min)

| Aspect | Intent |
|--------|--------|
| **Gameplay** | Two enemies, different roles. **Target prioritization** — scout urgency vs raider presence. Introduce **Shift+Space CC** if surrounded. |
| **Enemies** | **Scout + Raider** — slot spread visible. |
| **Combat lessons** | CC for space, not DPS; kill scout first or control raider while kiting. |
| **Relationship lessons** | Protection under mixed threat; Quality / Cooperation feedback (HUD or debug). |
| **Exploration** | Transition into main clearing. |

### Exploration break (~8–9 min)

| Aspect | Intent |
|--------|--------|
| **Gameplay** | **No combat.** Short walk, vista, ruin, or landmark. Dragon follows; tension drops. |
| **Enemies** | None. |
| **Combat lessons** | — |
| **Relationship lessons** | Calm between fights; Instability has room to matter on next engage. |
| **Exploration** | Reward curiosity — optional environmental detail, no quest log. |

### Two Raiders (~9–11 min)

| Aspect | Intent |
|--------|--------|
| **Gameplay** | Surround pressure with **familiar** enemies — tests CC and spacing without new mechanics. |
| **Enemies** | **Two Raiders** — surround and separation. |
| **Combat lessons** | Don't stand in the center; stagger windows; weapon choice felt (sword default). |
| **Relationship lessons** | Sustained fight; Sync/Instability move from outcome. |
| **Exploration** | Clearing as primary combat space. |

### Brute introduction (~11–12 min)

| Aspect | Intent |
|--------|--------|
| **Gameplay** | **One Brute** — solo teach. CC, spacing, patience; knockback resistance obvious. |
| **Enemies** | **Brute** — slow, tanky, dangerous wind-up. |
| **Combat lessons** | Timing over aggression; polearm/control affordance; cannot brute-force DPS. |
| **Relationship lessons** | **Protection** during slow attacks — dragon meaning without script. |
| **Exploration** | Arena supports kiting around obstacles. |

### Scout + Brute (~12–13 min)

| Aspect | Intent |
|--------|--------|
| **Gameplay** | **Priority puzzle** — scout punishes ignoring movement; brute punishes ignoring spacing. |
| **Enemies** | **Scout + Brute** |
| **Combat lessons** | Synthesis of Sections 3–4; assist on engaged target while managing brute approach. |
| **Relationship lessons** | Split ratings: messy win vs coordinated win feel different. |
| **Exploration** | — |

### Small climax (~13–14 min)

| Aspect | Intent |
|--------|--------|
| **Gameplay** | **Short mixed encounter** — e.g. Scout + Raider + Brute, or Scout + two Raiders, tuned to prior lessons. Full toolkit. |
| **Enemies** | Mix of taught archetypes — **no new roles**. |
| **Combat lessons** | Demonstrate mastery of slice combat. |
| **Relationship lessons** | Session arc: did Sync rise? Is strain manageable? |
| **Exploration** | — |

### Quiet ending (~14–15 min)

| Aspect | Intent |
|--------|--------|
| **Gameplay** | Calm outro — overlook, path forward **visible but closed**, or loop-back to clearing. |
| **Enemies** | None. |
| **Combat lessons** | — |
| **Relationship lessons** | Player imagines **next** fight with better cooperation. |
| **Exploration** | End on curiosity, not credits crawl. |

---

# Section 7 — Core Gameplay Loop

```
Explore
   ↓
Observe (threat, dragon position, bond state, enemy roles)
   ↓
Engage (positioning, facing, intent, prioritization)
   ↓
Fight (focused / CC, archetype-specific pressure, dragon assist/protect)
   ↓
Dragon reacts (assist, hesitate, protect — autonomy)
   ↓
Relationship changes (encounter resolve → Sync / Instability)
   ↓
Recover (calm walk, exploration break, future rest/decay)
   ↓
Continue exploring
```

### How steps reinforce each other

| Step | Reinforces |
|------|------------|
| **Explore** | Low pressure reveals dragon follow, environment, curiosity. |
| **Observe** | Scout vs brute silhouette and behavior — readable roles. |
| **Engage** | Prioritization sets up assists; facing matters for focused hits. |
| **Fight** | Archetype mix creates distinct decisions each encounter. |
| **Dragon reacts** | Partnership felt through threat-shaped behavior. |
| **Relationship changes** | Consequences batch at resolve; split ratings teach *danger ≠ teamwork*. |
| **Recover** | Exploration breaks prevent combat fatigue; strain can ease. |
| **Continue** | Higher Sync / lower Instability changes next fight subtly. |

---

# Section 8 — Feature Scope

### Required for the Vertical Slice

| Feature | Rationale |
|---------|-----------|
| Player movement + facing | Foundation for directional combat |
| Focused + CC melee (Combat Feel v1) | Core combat identity |
| **Three enemy archetypes (Scout, Raider, Brute)** | Role-based teaching — not HP variants |
| Dragon follow + combat behaviors | Partnership fantasy |
| Assist + protection (separate) | Cooperation without puppeting |
| Sync + Instability live from encounters | Relationship affects gameplay |
| Encounter tracking + resolve | Systemic consequences |
| **First handcrafted slice level** | Paced archetype introduction + exploration breaks |
| Minimal HUD (health, bond stats) | Player reads partnership state |
| Basic combat feedback (telegraphs, sparks) | Readability — already in prototype |
| Archetype-driven fifteen-minute flow | Section 6 pacing |
| Starting weapon identity | Sword default; polearm/dagger teach choice on repeat play |

### Nice to have (slice still ships without)

| Feature | Notes |
|---------|-------|
| Weapon pick at start | Debug 1/2/3 profiles exist — formalize choice |
| Simplified bond feedback in gameplay HUD | Last encounter Quality/Cooperation without F10 |
| Environmental storytelling props | Ruin, nest, banners — no quest system |
| Basic save at slice end | Checkpoint only |
| Natural Instability decay (out of combat) | Light tuning — framework documents intent |

### Explicitly deferred

| Feature | Why deferred |
|---------|--------------|
| **Inventory & equipment** | Weapon identity is profile-driven; gear systems distract from partnership loop |
| **Crafting & economy** | No economic loop to prove in slice |
| **Large / open world** | Breadth dilutes combat+relationship tuning |
| **Extensive dialogue & branching narrative** | Slice proves gameplay bond, not writing volume |
| **Advanced progression (leveling, perks)** | Character power must not mask cooperation design |
| **Multiple dragon species / personalities** | One dragon, one arc — prove depth before breadth |
| **Magic systems** | Melee + dragon cooperation is the core question |
| **Flight & mounted aerial combat** | Massive scope; ground partnership first |
| **Faction reputation & politics** | Full-game pillar; not needed to prove combat bond |
| **Race selection (Human / Elf / etc.)** | Defer until core loop validated |
| **Player dodge / i-frames** | Movement + CC handle spacing in Combat Feel v1 |
| **Bond Strength live progression** | Pattern pass not implemented — preview only |
| **Dragon health & combined harm** | Outcome rating revision blocked on dragon damage |
| **Full save/load** | Session persistence nice-to-have first |
| **Regional enemy variants (elite, corrupted, …)** | Post-slice; archetypes ≠ regional variants |
| **Final audio assets & attack animation** | Placeholder audio live ([`project_checkpoint_audio_feedback_pass1.md`](../checkpoints/project_checkpoint_audio_feedback_pass1.md)); final assets + animation in upcoming passes |

---

# Section 9 — Systems Currently Ready

Summarized from live checkpoints. These **support** the slice; content wrapping and archetypes remain.

### Combat Feel v1 (Passes 1–7)

Enemy slot spread, separation, focused + CC split, aim forgiveness, telegraphs, wind-up/recovery, target preview. **Supports:** intentional combat, positioning, readability.

### Weapon profile prototype (debug 1/2/3, Tuning Pass 1)

Dagger / sword / polearm with weapon-scaled CC. **Supports:** weapon identity vs archetype roles (precision vs control).

### Default enemy (Raider baseline)

Single `Enemy` tuning matches **Raider** role — Scout/Brute applied on slice via `VerticalSliceArchetypePresets`. **Supports:** archetype teaching on handcrafted level.

### Enemy archetypes (Scout / Raider / Brute)

Behavioral roles implemented for slice — see Section 3 and [`vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md).

### Event audio (placeholder)

Centralized `GameAudio` + six procedural WAVs — see [`project_checkpoint_audio_feedback_pass1.md`](../checkpoints/project_checkpoint_audio_feedback_pass1.md).

### Player-facing feedback (Polish 1A)

Encounter summary, relationship toasts, dragon chip, combat floaters — see [`project_checkpoint_vertical_slice_polish_1A.md`](../checkpoints/project_checkpoint_vertical_slice_polish_1A.md).

### Developer shell

F10 docked sidebar, full-viewport gameplay when F10 off — see [`project_checkpoint_developer_experience_pass1.md`](../checkpoints/project_checkpoint_developer_experience_pass1.md).

### Relationship framework (Milestone 8 + 9A)

Event bus, encounter tracker, split ratings, live Sync/Instability. **Supports:** living relationship.

### Dragon assistance & protection

Engagement-aligned assists; threat-driven protection. **Supports:** archetype-driven partnership moments (Brute wind-ups, Scout leakage).

### Playtest infrastructure

`TestWorld`, F10/F11, spawn keys. **Supports:** iteration until slice level replaces shell.

---

# Section 10 — Systems Still Needed

Major gaps before the slice is **player-complete**. Ordered by [**Section 12 implementation roadmap**](#section-12--vertical-slice-implementation-roadmap).

| Phase | System | Need |
|-------|--------|------|
| **1** | Handcrafted level Pass 2 | **Complete** |
| **1** | Slice spawn & encounter scripting | **Complete** — [`vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md) |
| **2** | Scout / Raider / Brute prototypes | **Complete** — playtest validation pending |
| **2** | Mixed-encounter tuning | **Complete** on slice — playtest validation pending |
| **3** | Event audio (placeholders) | **Complete** — Audio Feedback Pass 1 |
| **3** | Audio playtest validation | **Audio Feedback Pass 1A** — checklist pending |
| **3** | Player-facing relationship feedback | **Complete** — Polish Pass 1A |
| **3** | Animation polish (minimal) | **Player Animation Pass 1** — not started |
| **3** | Starting weapon (formal) | Move from debug hotkeys |
| **3** | Dev UI hidden for player builds | **Dragon Personality Pass 1** |
| **3** | Dragon personality communication | **Dragon Personality Pass 1** |
| **Later** | Death / retry flow | Game over → retry segment |
| **Later** | Basic save at slice end | Optional |
| **Later** | Final audio assets | Replace catalog placeholders |

**Not required for slice v1:** dodge, magic, inventory, Bond pattern pass, dragon health, races, flight.

---

# Section 11 — Handcrafted Level Goals

The first slice level is **not** a test arena with spawn keys. It is a **small, highly polished** space built to deliver Section 6 pacing.

### Primary purposes

| Goal | How the level supports it |
|------|---------------------------|
| **Teach mechanics naturally** | Encounters introduced in isolation then combined — no tutorial pop-ups required if space guides flow |
| **Demonstrate rider–dragon cooperation** | Sightlines for assists; threat moments for protection; calm paths for follow behavior |
| **Demonstrate weapon identity** | Arena sizes and archetype mix let sword / polearm / dagger feel different without text |
| **Introduce enemy archetypes** | One-way progression: Scout → Raider → mixes → Brute → climax — no dumping all roles at once |
| **Encourage exploration without overwhelm** | Short branches, one exploration break, landmarks — **intentionally small** geography |

### Design constraints

- **Small** — walkable in seconds between beats; no map UI required.
- **Highly polished** — collision, art readability, and encounter triggers tuned for the fifteen-minute arc.
- **Low complexity** — one biome, minimal interactables, no puzzles that compete with combat teaching.
- **Player opts in** — safe intro → visible danger → chosen engagement.

### Spatial beats (suggested)

1. Safe spawn / trail  
2. Scout arena (open)  
3. Raider arena or path encounter  
4. Mixed arena (choke into clearing)  
5. Exploration break vista (no enemies)  
6. Main clearing (two Raiders, later climax)  
7. Brute arena (obstacles for kiting)  
8. Quiet ending overlook  

Exact layout is implementation — beats are design requirements.

---

# Section 12 — Vertical Slice Implementation Roadmap

**Current planned milestones** before the slice is player-shippable. This is **not** the post-slice full-game roadmap (Section 15).

```
1. Vertical Slice Level Prototype — Pass 2  ← COMPLETE (P2.2)
           ↓
2. Enemy Archetype Prototype — Pass 1+1B  ← IMPLEMENTED (playtest pending)
           ↓
3. Combat Depth — Pass 1 Phase A+B        ← IMPLEMENTED (playtest pending)
           ↓
4. Vertical Slice Polish — Pass 1A        ← IMPLEMENTED (playtest pending)
           ↓
5. Vertical Slice UI Cleanup — Pass 1     ← IMPLEMENTED
           ↓
6. Developer Experience — Pass 1          ← IMPLEMENTED
           ↓
7. Audio Feedback — Pass 1                ← IMPLEMENTED (placeholder architecture)
           ↓
8. Documentation Cleanup — Pass 1         ← COMPLETE
           ↓
8b. Documentation Organization — Pass 1  ← COMPLETE
           ↓
9. Audio Feedback — Pass 1A               ← NEXT (playtest validation)
           ↓
10. Informal Playtest
           ↓
11. Dragon Personality — Pass 1
           ↓
12. Player Animation — Pass 1
           ↓
13. Structured Vertical Slice Playtest
           ↓
14. Documentation Cleanup — Pass 2        ← future
```

Detail: [`PROJECT_STATE.md`](../PROJECT_STATE.md) · [`vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md)

---

### Milestone 1 — Vertical Slice Level Prototype Pass 2

**Status: COMPLETE** (P2.1 — Quiet Grove south exits, full east wall)

**Purpose:** Transform the graybox from obvious test rooms into a **connected playable environment**.

**Focus:** navigation · readability · pacing · boundaries · environmental flow

**Delivered:** Variable-width spine, visible=collision walls, sealed grove with **two south exits**, location-shaped spaces, route guides. Detail: [`vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md).

---

### Milestone 2 — Enemy Archetype Prototype Pass 1 + 1B

**Status: IMPLEMENTED (Pass 1 + 1B) — playtest validation pending**

**Purpose:** Create **gameplay roles**, not stronger reskins. Behavior defines the archetype; stats support behavior.

| Archetype | Role | Pass 1 behavior | Pass 1B (commitment) |
|-----------|------|-----------------|----------------------|
| **Scout** | Skirmisher | Probe bursts, hit-and-run disengage | Always interruptible; 1.35× stagger |
| **Raider** | Baseline | Standard engage loop | Commits at 40% wind-up; no stun-lock |
| **Brute** | Control check | Slow advance, long reach, KB-resistant | Commits at 28% wind-up; 0.47 s player stagger |

**Pass 1B goals accomplished:** attack commitment windows, archetype interruption tuning, Raider 1v1 fairness, Brute point-blank reliability, improved Brute hit impact.

Detail: [`combat_feel_notes.md`](../notes/combat_feel_notes.md) → Pass 1 + Pass 1B.

**Not in scope:** full poise system, heavy attacks, dragon combo attacks, species art.

---

### Milestone 3 — Combat Depth Pass 1

**Status: PHASE A + B IMPLEMENTED — playtest validation pending · Phase C+ planned**

**Purpose:** Increase player **decision-making** — combat becomes less about attack spam and more about choosing the correct action.

Full design: [`combat_feel_notes.md`](../notes/combat_feel_notes.md) → Combat Depth Pass 1 Phase A.

#### Phase A — Movement Foundation (live)

| Feature | Status |
|---------|--------|
| **Combat Stance** (hold Ctrl) | **Live** — lock facing, strafe, backpedal |
| **Weapon movement identity** | **Live** — dagger 1.14× / sword 1.0× / polearm 0.84× |
| **Attack facing commitment** | **Live** — facing locked for full attack sequence |
| **Target Focus** (Caps Lock / Tab) | **Live** — OoT-style facing lock toward chosen enemy |
| **Movement states** | **Live** — Running, Combat Stance, Target Focus, Attacking, Staggered, Dead |
| **Debug readouts** | **Live** — BondTestHelpUI movement section |

#### Combat Stance (Phase A)

Holding **Ctrl** (`combat_stance`):

| Behavior | Detail |
|----------|--------|
| **Lock facing** | Facing direction fixed while stance held |
| **Strafe / backpedal** | World-space WASD; facing locked while Ctrl held |
| **Attack direction preserved** | Focused/CC use locked facing |

Foundation for future **shield gameplay** — stance is general-purpose rider control, not a shield-only mode.

#### Weapon movement identity (Phase A — live)

| Weapon | Move multiplier | Combat identity |
|--------|-----------------|-----------------|
| **Dagger** | **1.14×** | Fastest movement, precision |
| **Sword** | **1.00×** | Baseline, highest sustained DPS |
| **Polearm** | **0.84×** | Slowest, strongest control |

#### Attack commitment philosophy

Combat rewards **positioning, timing, spacing, and correct attack choice**. Phase A adds facing lock during attacks; Phase B+ may add extended recovery punish windows.

**Phase B — Target Focus (live):** Caps Lock toggles facing toward a chosen enemy; Tab cycles targets. Facing-only — not lock-on combat. See [`combat_feel_notes.md`](../notes/combat_feel_notes.md) → Combat Depth Pass 1 Phase B.

**Phase C+ (not yet):** shield block · enemy punish windows · extended recovery tuning.

**Does not ship** full Pass 1 until playtest validates control + focus feel.

---

### Subsequent — Vertical Slice Polish Pass 1A (implemented)

**Status: IMPLEMENTED — player feedback layer live**

**Purpose:** Make existing gameplay understandable without F10. Communicate outcomes, relationship direction, and dragon intent.

| Feature | Status |
|---------|--------|
| Encounter summary panel | **Live** |
| Relationship direction toasts | **Live** |
| Dragon status chip | **Live** |
| Combat hit/stagger/resist floaters | **Live** |
| Target Focus visual contrast | **Live** |

Detail: [`project_checkpoint_vertical_slice_polish_1A.md`](../checkpoints/project_checkpoint_vertical_slice_polish_1A.md)

### Audio Feedback Pass 1 (implemented)

**Status: IMPLEMENTED — architecture + placeholder wiring live**

**Purpose:** Centralized event-driven audio using six procedural placeholders. Reinforce existing visual/UI feedback without changing gameplay logic.

| Feature | Status |
|---------|--------|
| `GameAudio` autoload + event catalog | **Live** |
| Combat / UI / Dragon buses (future mix) | **Live** |
| Binder on existing signals | **Live** |
| Placeholder reuse policy | **Documented** |

Detail: [`project_checkpoint_audio_feedback_pass1.md`](../checkpoints/project_checkpoint_audio_feedback_pass1.md) · [`audio_placeholder_assets.md`](../audio/audio_placeholder_assets.md)

**Pass 1A (next validation):** Playtest checklist in audio checkpoint — see [`PROJECT_STATE.md`](../PROJECT_STATE.md).

**Dragon Personality Pass 1 (next implementation):** Dragon communication · hide dev UI in player builds.

### Vertical Slice UI Cleanup Pass 1 (implemented)

**Status: IMPLEMENTED — presentation only**

**Purpose:** Clean HUD layout, unified F10 Developer Mode, larger default window, transient area names, reduced dragon text noise.

| Change | Detail |
|--------|--------|
| **PlayerHud** | Unified top-left: HP + dragon status |
| **Area announce** | Transient center-top on zone enter |
| **Developer Mode** | F10 toggles help + debug overlays together |
| **Window** | **2560×1440** default; gameplay SubViewport fills shell when F10 off — see [`project_checkpoint_developer_experience_pass1.md`](../checkpoints/project_checkpoint_developer_experience_pass1.md) |
| **Dragon bubble** | Disabled; HUD + StatusVisual ring |

Detail: [`project_checkpoint_ui_cleanup_pass1.md`](../checkpoints/project_checkpoint_ui_cleanup_pass1.md)

### Developer Experience Pass 1 (implemented)

**Status: IMPLEMENTED — presentation / workflow only**

**Purpose:** Larger comfortable playtest window, docked developer workspace so tools never cover gameplay, shared playtest shell architecture.

| Change | Detail |
|--------|--------|
| **Default window** | **2560×1440** |
| **Reference world view** | 1920 units wide — camera zoom compensates for viewport width |
| **Developer Mode** | F10 docks help (below game) + debug (right); game viewport shrinks |
| **playtest_shell.gd** | Shared layout for TestWorld + Vertical Slice |

Detail: [`project_checkpoint_developer_experience_pass1.md`](../checkpoints/project_checkpoint_developer_experience_pass1.md)

### Subsequent — Player Polish Pass (animation & final audio)

After Pass 1A + Audio Pass 1 validate communication:

- Final audio assets (replace catalog entries) · minimal attack animation · hide remaining dev overlays in player builds

#### Why archetypes before polish (unchanged)

Polish locks timing to threat cadence — scout rush vs brute wind-up must exist first. See Pass 1 rationale in [`vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md).

---

### Legacy phase labels (historical)

Earlier v1.1 roadmap used “Phase 1 level → Phase 2 archetypes → Phase 3 polish.” **Pass 2** splits level work into Pass 1 + Pass 2; archetypes and combat depth are now explicit named milestones.

---

# Section 13 — Success Criteria

Experience-based — **not** code metrics.

| Criterion | Player signal |
|-----------|---------------|
| **Understands combat** | Uses focused vs CC appropriately; prioritizes scout in mixed fights |
| **Recognizes archetypes** | Describes scouts as fast/priority, brutes as spacing problems — unprompted |
| **Notices dragon helping** | Mentions assist or protection unprompted |
| **Feels weapon difference** | Describes sword vs polearm vs dagger differently vs brute/scout |
| **Combat feels satisfying** | Weight without sluggishness — after Phase 3 polish |
| **Relationship affects play** | Notices hesitation or cooperation changes across encounters |
| **Wants to continue** | Asks to replay or go further |
| **Dragon feels alive** | Partner/character — not "attack button" |

---

# Section 14 — Development Principles

1. **Every new feature must improve the Vertical Slice** — serve the fifteen-minute loop or partnership feel.

2. **Avoid feature creep** — Section 8 deferred list is the guardrail.

3. **Build depth before breadth** — three archetypes taught well beat ten stat variants.

4. **Archetypes before polish** — Section 12 order; do not audio-lock a level still using placeholder enemies.

5. **Player experience over feature count** — three stats and three roles that matter beat bloated systems.

6. **Emergent gameplay over scripted events** — enemy roles and dragon AI, not cutscenes.

7. **Preserve technical checkpoints** — update combat/relationship checkpoints when mechanics change; update **this document** when design intent changes.

8. **Do not break live relationship safeguards** — Bond protected at resolve, split ratings, disengage grace.

9. **Prototype in TestWorld, ship in SliceLevel** — systems iterate in shell; experience lives in handcrafted scene.

10. **Playtest the fifteen minutes repeatedly** — Section 6 timing is a variable.

11. **Every enemy teaches partnership** — Section 1 and Section 4; reject HP-only difficulty.

---

# Section 15 — Post–Vertical-Slice Roadmap

High-level **full-game** phases — not slice build order.

```
Complete Vertical Slice (prove core loop)
        ↓
Expand combat (dodge, dragon damage, more archetypes, regional variants)
        ↓
Expand relationship systems (Bond pattern pass, decay, resilience, dragon health)
        ↓
Expand world (regions, exploration events, save/load)
        ↓
Progression systems (leveling, equipment — region-tied scaling)
        ↓
Magic & advanced dragon combat
        ↓
Story, factions, races, politics
```

---

# Section 16 — Source of Truth

| Layer | Document |
|-------|----------|
| **Documentation hierarchy & agent onboarding** | [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md) · [`CURSOR_ONBOARDING.md`](../CURSOR_ONBOARDING.md) |
| **Vertical Slice design direction** | **`./vertical_slice_design_v1.md` (this document)** |
| **Live combat prototype** | `../checkpoints/project_checkpoint_combat_feel_v1.md` |
| **Live relationship / encounter resolve** | `../checkpoints/project_checkpoint_milestone9A.md` |
| **Relationship behavior catalog** | `./relationship_event_framework.md` |
| **Combat feel history & experiments** | `../notes/combat_feel_notes.md` |
| **High-level combat vision** | `./combat.md` |
| **Product systems map** | `./game_architecture.md` |

**Rule:** This document wins for **slice scope, pacing, archetypes, and build order**. Checkpoints win for **current numeric behavior** until amended.

---

# Appendix — Documentation Review

*Historical checkpoints are not rewritten by this pass.*

### Contradictions / outdated statements

| Topic | Documents | Status |
|-------|-----------|--------|
| **Implementation order** | Prior v1 doc: polish milestones listed before archetype clarity; combat_feel_v1 §7 lists audio before archetype validation | **Resolved in this doc** — Section 12: level → archetypes → polish. Checkpoints unchanged (historical). |
| **Archetype naming** | `combat_feel_notes.md`: Standard / Heavy / Beast; slice design: **Raider / Brute** | **Raider = default/Standard; Brute = Heavy-like.** Beast/ranged post-slice. Note in combat_feel_notes recommended. |
| **Enemy "variants"** | `game_architecture.md`, milestone 9A: variants = regional progression | **Compatible** — slice **archetypes** are roles; regional **variants** remain post-slice. |
| **Single enemy only** | `combat_feel_v1`: one archetype live | **Accurate for code** — design targets three roles; checkpoint valid until Phase 2 ships. |
| **Dodge, races, politics** | Older docs | Unchanged — still deferred per prior appendix. |
| **Weapon DPS text** | `combat_feel_v1` §4 vs Tuning Pass 1 | Unchanged — sword highest DPS live. |

### Recommended future cleanup

1. **`combat_feel_notes.md`** — Add pointer to Section 3 archetype names (Raider/Brute) vs Standard/Heavy table.  
2. **`project_checkpoint_combat_feel_v1.md` §7** — Add note: slice archetype order in `vertical_slice_design_v1.md` §12; checkpoint milestone list is pre-slice planning.  
3. **`combat.md`** — Optional one-line: slice enemy roles = Scout/Raider/Brute per vertical slice design.

### Slice readiness

**Level Pass 2 complete** — **Enemy Archetype Pass 1 + 1B implemented** — **Combat Depth Pass 1 Phase A + B live**; playtest before Phase C.

---

## Document history

| Version | Date | Scope |
|---------|------|-------|
| **v1** | 2026-05-29 | Initial Vertical Slice design constitution |
| **v1.1** | 2026-05-29 | Archetypes, pacing, implementation roadmap, level goals, enemy principles |
| **v1.2** | 2026-05-29 | Level Prototype Pass 1 begun |
| **v1.3** | 2026-05-29 | Roadmap: Level Pass 2, Enemy Archetype Pass 1, Combat Depth Pass 1 |
| **v1.4** | 2026-05-29 | Level P2.1 complete; Combat Depth Pass 1 expanded; Scout/Brute behavior goals |
| **v1.5** | 2026-05-29 | Enemy Archetype Pass 1 implemented — Scout/Raider/Brute behaviors |
| **v1.6** | 2026-05-29 | Enemy Archetype Pass 1B — attack commitment & interruption tuning |
| **v1.7** | 2026-05-29 | Combat Depth Pass 1 Phase A — movement foundation |
| **v1.8** | 2026-05-29 | Combat Depth Pass 1 Phase B — Target Focus System |
| **v1.9** | 2026-05-29 | Vertical Slice Polish Pass 1A begun — player feedback & communication |
| **v1.10** | 2026-05-29 | Vertical Slice UI Cleanup Pass 1 — HUD layout & Developer Mode |
| **v1.11** | 2026-05-29 | Developer Experience Pass 1 — docked workspace, 2560×1440 window |
| **v1.12** | 2026-07-06 | Documentation Cleanup Pass 1 — hierarchy, PROJECT_STATE, onboarding |
| **v1.13** | 2026-07-06 | PROJECT_STATE polish — active development homepage |
| **v1.14** | 2026-07-06 | Documentation Organization Pass 1 — docs folder structure |
