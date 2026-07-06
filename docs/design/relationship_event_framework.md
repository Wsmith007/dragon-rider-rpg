# Relationship Event Framework

**Status:** Living design document — distinguishes **implemented**, **planned**, and **future** behavior  
**Gameplay checkpoints:** `../historical/project_checkpoint_milestone7.md`, `../historical/project_checkpoint_milestone8.md` (historical), **`../checkpoints/project_checkpoint_milestone9A.md` (current live state)**  
**Agent entry:** [`PROJECT_STATE.md`](../PROJECT_STATE.md) · [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md)  
**Vertical Slice design:** `./vertical_slice_design_v1.md` (experience goals and slice scope)  
**Related:** `./bond_system.md`, `./dragon_ai.md`, `./game_architecture.md`

This document defines relationship events, stat ownership, encounter evaluation, and long-term progression philosophy. **Code is the source of truth for live behavior**; sections below are labeled by implementation status.

---

## Document Map

| Section | Status |
|---------|--------|
| **Current Implementation** | Live in prototype (Milestone 8 + 9A) |
| **Planned Revision** | Discussed design direction — **not implemented** |
| **Future Systems** | Design targets — **not implemented** |
| **Long-Term Progression Philosophy** | Design targets — guides world and scaling |
| **Reference sections (§1 onward)** | Event catalog, philosophy, and future modules |

---

# Current Implementation

**Status: IMPLEMENTED** — reflects live prototype behavior as of Milestone 9A. Do not infer future behavior from this section.

## Pipeline (live)

```
Gameplay hooks → RelationshipSystem (autoload)
  → RelationshipEventBus
  → RelationshipEncounterTracker (counters + involved enemies)
  → EncounterQualityClassifier (outcome/stress → Instability)
  → CooperationRatingClassifier (teamwork → Sync)
  → ProposedDeltaGenerator (deltas + Bond preview)
  → BondSystem.apply_sync_delta / apply_instability_delta (clamped 0–100)
  → Bond Debug UI (F10)
```

**Wired from:** `TestWorld` via `RelationshipSystem.setup_from_scene()`

**Safeguards (live):**

- One stat application per resolved `encounter_id` (`_applied_encounter_ids`)
- Sync and Instability clamped to 0–100 via `BondProfile` setters
- Minor skirmishes may **abort** without resolve or stat changes
- Bond Strength is **never written** at encounter resolve

## Encounter Quality (outcome / stress)

**Classifier:** `EncounterQualityClassifier`  
**Stat effect:** **Instability** (applied live at encounter resolve)

**Primary inputs today:** player damage taken, near-death events, death, resolve outcome (defeated / fled / death). Disengage/re-engage prevents **Excellent**. Assist cancellations do **not** affect Encounter Quality.

| Rating | Instability Δ (live) |
|--------|----------------------|
| **Excellent** | −2 |
| **Good** | −1 |
| **Neutral** | 0 |
| **Poor** | +2 |
| **Disastrous** | +4 |

**Classifier thresholds (live, player harm):**

- Reference max HP: 1000
- **Excellent:** enemy defeated; zero player damage; zero dragon damage (field ready); no near-death; no disengage/re-engage
- **Good:** enemy defeated; damage ≤ 30% ref HP; no near-death
- **Poor:** near-death, or damage ≥ 35% ref HP, or stressful flee with heavy harm
- **Neutral:** solo kills, minor flee, moderate strain between Good/Poor bands
- **Disastrous:** player death (dragon death field ready)

## Cooperation Rating (teamwork / execution)

**Classifier:** `CooperationRatingClassifier`  
**Stat effect:** **Sync** (applied live at encounter resolve)

**Primary inputs today:** successful assists/protections, assist cancellations, assist hesitations, player vs dragon contribution balance.

| Rating | Sync Δ (live) |
|--------|---------------|
| **Excellent** | +2 |
| **Good** | +1 |
| **Neutral** | 0 |
| **Poor** | −1 |
| **Disastrous** | −2 |

**Classifier rules (live summary):**

- **Neutral:** player-only kill or dragon-only kill (Sync unchanged)
- **Excellent:** both contributed; ≥1 dragon success; 0 cancels; 0 hesitations
- **Good:** both contributed; ≤1 cancel and ≤1 hesitation
- **Poor:** repeated cancels/hesitations or weak joint execution (e.g. ≥4 cancels)
- **Disastrous:** sustained failed cooperation with no successful joint actions (rare)

## Split behavior (live)

Outcome stress and teamwork are evaluated **independently**. Examples:

| Scenario | Encounter Quality | Cooperation | Instability | Sync |
|----------|-------------------|-------------|-------------|------|
| Win, 0 damage, 4 cancels | Excellent | Poor | −2 | −1 |
| Win, heavy damage, strong assists | Poor | Good/Excellent | +2 | +1/+2 |
| Player-only kill | Good/Neutral | Neutral | −1/0 | 0 |
| Dragon-only kill | Good/Neutral | Neutral/Poor | −1/0 | 0 |
| Player death | Disastrous | (varies) | +4 | (varies) |

## Bond Strength (live — protected)

- **Sync changes are live** from Cooperation Rating at resolve.
- **Instability changes are live** from Encounter Quality at resolve.
- **Bond Strength is not modified** by encounter resolution.
- Debug UI may show a **Bond Δ preview** (e.g. −1 on Disastrous death) labeled **NOT APPLIED** — preview for a future pattern pass only.

## Key implementation files

| Component | Path |
|-----------|------|
| Orchestrator | `scripts/systems/relationship_system.gd` |
| Encounter quality | `scripts/relationship/encounter_quality_classifier.gd` |
| Cooperation rating | `scripts/relationship/cooperation_rating_classifier.gd` |
| Delta generation | `scripts/relationship/proposed_delta_generator.gd` |
| Encounter summary | `scripts/relationship/relationship_encounter_summary.gd` |
| Stat application | `scripts/bond/bond_system.gd` (`apply_sync_delta`, `apply_instability_delta`) |

---

# Planned Revision

**Status: DISCUSSED — NOT IMPLEMENTED** — intended direction for a future refactor of outcome/stress evaluation. Current code still uses **Encounter Quality** (Excellent … Disastrous) as documented in **Current Implementation**.

## Planned Outcome Rating Revision

**Working name:** Outcome Rating (may replace Encounter Quality naming)

Outcome Rating is intended to measure **encounter stress and danger** — not teamwork. Cooperation Rating would remain separate and continue driving Sync.

### Proposed ratings

| Outcome Rating | Meaning |
|----------------|---------|
| **Flawless** | No meaningful harm |
| **Safe** | Light harm |
| **Rough** | Moderate harm |
| **Severe** | Heavy harm |
| **Disastrous** | Extreme harm or near-death |

### Proposed harm bands (combined harm — see Future Systems)

Harm measured as **combined harm percentage** (player + dragon when dragon health exists):

| Band | Combined harm |
|------|----------------|
| **Flawless** | 0% |
| **Safe** | 1–25% |
| **Rough** | 26–50% |
| **Severe** | 51–75% |
| **Disastrous** | 76%+ combined harm **or** near-death |

*Until dragon health exists, design discussions may prototype bands using player harm only.*

### Proposed Instability deltas

| Outcome Rating | Instability Δ |
|----------------|---------------|
| Flawless | −2 |
| Safe | −1 |
| Rough | 0 |
| Severe | +2 |
| Disastrous | +4 |

### Philosophy

Instability measures **stress and strain**, not teamwork quality.

**Design goals:**

- Good experiences **reduce** strain (negative deltas)
- Average experiences **maintain** strain (zero delta at Rough)
- Bad experiences **increase** strain (positive deltas)
- Instability should **not** constantly trend upward or downward across normal play — recovery, neutral bands, and symmetric tuning should keep the stat in healthy operating ranges (see §9)

**Cooperation Rating is unchanged in this revision** — still drives Sync independently.

---

## Death Handling (planned revision)

**Status: DISCUSSED — NOT IMPLEMENTED**

### Current implementation

Death contributes to **Disastrous** Encounter Quality and applies Instability +4 at resolve. Bond preview may show −1 (not applied).

### Planned direction

Death should eventually become a **separate failure state**, not folded only into Outcome Rating tiers.

Potential future states:

- Player dies, dragon survives
- Dragon dies, player survives
- Both die

These should be handled with distinct narrative and relationship consequences, evaluated separately from routine Outcome Rating bands. Exact stat effects TBD; no implementation required in current prototype.

---

# Future Systems

**Status: DESIGN ONLY — NOT IMPLEMENTED**

## Future Dragon Health Integration

Outcome / stress evaluation should eventually use **Combined Harm**:

```
Combined Harm % = Player Harm % + Dragon Harm %
```

instead of player harm alone.

**Depends on:**

- Dragon health system (damage, near-death, death events)
- Summary fields already reserved: `dragon_damage_taken`, `dragon_near_death_count`, `dragon_critical`, `dragon_died`
- Planned events: `combat.enemy_damaged_dragon`, `combat.dragon_critical_hp`, `combat.dragon_death`
- Resolved outcomes: Dragon Injured, Dragon Death

When dragon health exists, flee/disengage Outcome Rating should also consider dragon harm and failed protection under fire.

## Other future relationship modules (not live)

| System | Purpose |
|--------|---------|
| **Bond pattern pass** | Session quality trends → Bond Strength (not per-fight) |
| **Bond resilience pass** | `BondResilience` scales Instability impact and Sync floor |
| **Anti-farming caps** | Diminishing returns per encounter (§8) |
| **Natural Instability decay** | Out-of-combat drift toward Normal band (§12) |
| **Exploration / story events** | Session-level Bond sources (§3 C/D) |
| **Immediate event pings** | Optional real-time Instability bumps before resolve (§5) |

---

# Long-Term Progression Philosophy

**Status: DESIGN TARGET** — guides world design and scaling; not fully implemented in the test prototype.

## Parallel progression axes

| Axis | Role |
|------|------|
| **Character Level** | Personal power — rider combat capability |
| **Relationship Stats** | Rider/dragon **effectiveness together** — Bond, Sync, Instability |
| **World Regions** | Difficulty and content progression |
| **Enemy Variants** | Strength and behavior progression within regions |

Relationship progression should remain **as important as character progression**. The bond is not a side stat — it shapes cooperation, strain, communication, and resilience.

## Enemy scaling philosophy

Enemy scaling should primarily come from:

- **Region difficulty** — later regions introduce tougher baseline threats
- **Enemy type** — role and kit differences
- **Enemy variants** — elite, corrupted, aged, faction-specific versions

**Avoid** full player-level scaling that negates returning to earlier areas.

Returning to earlier regions should **demonstrate growth** — the rider–dragon pair should feel stronger and more coordinated without invalidating prior zones through invisible level scaling.

## Relationship vs combat power

Bond Strength, Sync, and Instability describe **partnership quality and strain**. They are not disguised combat stats. High Bond improves cooperation affordances and (future) resilience — not raw damage spikes. See `./bond_system.md` and `./game_architecture.md`.

---

## Design Notes — Why Outcome and Cooperation Were Split

**Encounter Quality (Outcome / stress)** measures **danger and harm** → drives **Instability**.

**Cooperation Rating** measures **teamwork and execution** → drives **Sync**.

This separation prevents teamwork failures (cancels, hesitations, solo kills) from automatically being treated as dangerous encounters, and prevents bloody but coordinated fights from being scored as cooperation failures.

**Bond Strength** remains a **long-term resilience / trust** stat fed by patterns over sessions — not by individual encounter Sync/Instability rolls.

---

# Reference: Relationship Philosophy

The core loop (design target):

```
Player intent → Bond system → Dragon interpretation → Dragon action → Relationship update
```

Relationship stats are **not combat power**. They describe the **quality and strain** of the rider–dragon partnership:

| Stat | Speed | Role |
|------|-------|------|
| **Bond Strength** | Slowest | Long-term depth, trust, loyalty, resilience |
| **Sync** | Medium | Current cooperation and coordination |
| **Instability** | Fastest | Present strain, fear, confusion, overload |

**Design principles:**

1. **Bond Strength changes rarely** — earned through sustained positive history, lost through serious breaches.
2. **Sync changes through cooperation** — assists, protection, shared success.
3. **Instability rises quickly under stress** and should **fall naturally** when safe (future recovery systems).
4. **Events are signals, not rewards** — the system reacts to meaning, not repetition.
5. **Encounter summaries prevent farming** — many combat events roll up at encounter end; caps and diminishing returns apply.
6. **Bond resilience (future)** — high Bond Strength reduces instability impact and improves recovery; it does not block events.
7. **Combat feeds Sync and Instability at encounter resolve; patterns feed Bond** — see **Current Implementation** and §2.1.

Sync and Instability are **live** from resolved encounters (Milestone 9A). Bond Strength remains pattern-only. Debug keys still allow manual stat adjustment for testing.

---

## 2. Stat Identities

### Bond Strength (`bond_strength`)

- **Identity:** Relationship depth and resilience.
- **Changes when:** Major trust-building or trust-breaking **patterns** accumulate over time — not individual combat actions.
- **Should not:** Spike from routine combat actions, assists, kills, or single encounter outcomes.
- **Should not:** Function as a disguised combat stat.
- **Gameplay today:** Alert range, protection radius, command delay, communication clarity.
- **Future:** Sync floors, instability resistance/recovery multipliers (`BondResilience` helpers exist, not wired).

### Sync (`sync`)

- **Identity:** How effectively rider and dragon cooperate **right now** and **recently**.
- **Changes when:** Cooperation Rating at encounter resolve (live); also successful coordinated actions in design intent.
- **Should not:** Permanently collapse from a single bad moment (see §10).
- **Gameplay today:** Cooperative assist cooldown tiers; **Sync Δ applied live** from Cooperation Rating at encounter resolve.

### Instability (`instability`)

- **Identity:** Current emotional/magical strain on the bond.
- **Changes when:** Harm, near-death, death, stressful outcomes (via Encounter Quality at resolve).
- **Should fall:** Over time, after safe periods, at rest (future decay — not implemented).
- **Target operating bands:** see §9.
- **Gameplay today:** Assist hesitation and post-hesitation cancel (gameplay); **Instability Δ applied live** from Encounter Quality at encounter resolve.

---

## 2.1 Bond Strength Refinement — Combat vs Patterns

**Core rule:**

| Layer | Affects |
|-------|---------|
| **Combat events** (routine) | **Sync**, **Instability** |
| **Patterns** (aggregated history) | **Bond Strength** |

**Combat** = individual assists, protections, damage ticks, kills, command obeyed in a single encounter.

**Patterns** = sustained positive encounter history, session summaries, long-term companionship, exploration milestones, story events, bonding moments, repeated trust-building behavior, and **Encounter Quality** trends over time.

Bond Strength should **primarily** come from:

- Sustained positive **encounter history** (e.g. streak of Good/Excellent encounters)
- **Session summaries** (end of play session or rest)
- **Long-term companionship** (exploration time together rollups)
- **Exploration milestones** (area completion, discoveries)
- **Story events** (bonding moments, major victories, betrayal)
- **Repeated trust-building behavior** (consistent command obedience over sessions — not per-command)

Bond Strength should **not** come from:

- A single assist success
- A single protection success
- A single enemy defeat
- Raw encounter completion counters alone

**Exception (pattern-level, not event-level):** Catastrophic outcomes (death, betrayal) may affect Bond through **session/pattern evaluation** or **Disastrous Encounter Quality** — not through stacking routine combat events.

---

## 3. Event Categories

Events are grouped for ownership and batching rules. Each event has a stable **`event_id`** for logging, caps, and encounter aggregation.

### A) Combat Events

| `event_id` | Description | Timing (see §5) |
|------------|-------------|-----------------|
| `combat.assist_succeeded` | Dragon cooperative strike landed / completed | Encounter |
| `combat.assist_canceled` | Instability or AI canceled assist | Encounter (+ optional immediate instability ping) |
| `combat.assist_hesitated` | Dragon entered hesitation before assist | Encounter |
| `combat.protection_triggered` | Protection strike began (defensive) | Encounter |
| `combat.protection_succeeded` | Protection strike completed effectively | Encounter |
| `combat.alert_entered` | Dragon entered ALERT state | Encounter (log only; low stat weight) |
| `combat.player_damaged` | Player took damage | Encounter |
| `combat.player_critical_hp` | Player crossed critical HP threshold | Immediate + encounter |
| `combat.player_death` | Player died | Immediate |
| `combat.enemy_defeated` | Single enemy killed | Encounter |
| `combat.encounter_completed` | All threats in encounter resolved | Encounter (summary evaluation) |
| `combat.encounter_failed` | Player fled / wiped / aborted | Encounter |

### B) Command Events

| `event_id` | Description | Timing |
|------------|-------------|--------|
| `command.wait_issued` | Player requested WAIT | Encounter |
| `command.recall_issued` | Player requested RECALL | Encounter |
| `command.obeyed` | Wait/recall executed after delay | Encounter |
| `command.delayed` | Command pending due to Bond Strength delay | Encounter (log only; no stat weight) |
| `command.pending_canceled` | Double-Q canceled pending command | Encounter (neutral) |
| `command.refused` | Future: dragon refuses command | Immediate (future) |

### C) Exploration Events

| `event_id` | Description | Timing |
|------------|-------------|--------|
| `explore.time_together` | Sustained travel with dragon following | Session rollup |
| `explore.area_entered` | Entered new region | Session |
| `explore.area_completed` | Cleared or finished area objective | Session |
| `explore.travel_milestone` | Distance or time milestone | Session |
| `explore.discovery` | Found POI, lore, or secret | Session |

### D) Future Story Events

| `event_id` | Description | Timing |
|------------|-------------|--------|
| `story.major_victory` | Boss or narrative win | Immediate + session |
| `story.betrayal` | Rider broke dragon trust | Immediate + session |
| `story.dragon_injury` | Dragon harmed or captured | Immediate + session |
| `story.bonding_moment` | Scripted positive beat | Immediate + session |
| `story.narrative_choice` | Player choice with bond consequence | Immediate + session |
| `story.faction_shift` | Political alignment change | Session |

---

## 4. Event Ownership

**Legend:** ● primary · ○ secondary · — no direct effect (may still appear in encounter log)  
**Bond column:** direct event effect only. Bond changes from **patterns** (§2.1, §7) are separate.

### A) Combat — stat ownership

| Event | Bond | Sync | Instability | Notes |
|-------|------|------|-------------|-------|
| Assist succeeded | — | ● | ○ | Coordination reward; no Bond |
| Assist canceled | — | ○ | ● | Strain from failed cooperation |
| Assist hesitated | — | ○ | ● | Minor strain signal |
| Protection triggered | — | ○ | ○ | Awareness, not yet success |
| Protection succeeded | — | ● | ○ | Defensive teamwork; no Bond |
| Alert entered | — | — | — | Telemetry only |
| Player damaged | — | ○ | ● | Rider harm increases strain |
| Player critical HP | — | ○ | ● | Serious stress; Bond via pattern if repeated |
| Player death | — | ○ | ● | Catastrophic strain; Bond via session/pattern |
| Enemy defeated | — | ● | ○ | Shared win; Sync only |
| Encounter completed | — | ● | ○ | Sync rollup; Bond via Encounter Quality (§7) |
| Encounter failed | — | ○ | ● | Failure stress; Bond via pattern if trend |

### B) Command — stat ownership

| Event | Bond | Sync | Instability | Notes |
|-------|------|------|-------------|-------|
| Wait / recall issued | — | — | — | Neutral intent |
| Command obeyed | — | ● | ○ | Reliable partnership |
| Command delayed | — | — | — | Log only; Bond delay is already a Bond effect |
| Pending canceled | — | — | — | Neutral |
| Command refused (future) | — | ○ | ● | Strain; Bond via session pattern |

### C) Exploration — stat ownership

| Event | Bond | Sync | Instability | Notes |
|-------|------|------|-------------|-------|
| Time together | ● | ○ | ○ | Primary Bond source (session) |
| Area completed | ● | ○ | ○ | Shared journey |
| Travel milestone | ● | — | ○ | Slow Bond growth |
| Discovery | ● | ○ | — | Bond + optional Sync |

### D) Story — stat ownership

| Event | Bond | Sync | Instability | Notes |
|-------|------|------|-------------|-------|
| Major victory | ● | ● | ○ | Bond + Sync; session weight |
| Betrayal | ● | ○ | ● | Trust breach |
| Dragon injury | ● | ○ | ● | Protective failure feelings |
| Bonding moment | ● | ○ | ○ | Primary Bond vehicle |
| Narrative choice | ● | ○ | ○ | Designer-authored |
| Faction shift | ○ | — | ○ | Context-dependent |

**Multi-stat rule (combat layer):** **Instability** is driven by **Encounter Quality** (outcome/stress). **Sync** is driven by **Cooperation Rating** (teamwork/execution). **Bond** is evaluated last at **session/pattern** layer — not from individual encounter stat rolls.

---

## 5. Immediate vs Encounter-Based Events

### Immediate events (apply or queue as soon as fired)

High emotional weight or safety-critical — player should feel consequence without waiting for encounter end:

| Event | Why immediate |
|-------|----------------|
| `combat.player_critical_hp` | Panic / strain spike |
| `combat.player_death` | Catastrophic breach |
| `story.betrayal` | Narrative irreversible |
| `story.dragon_injury` | Emotional shock |
| `story.bonding_moment` | Scripted beat |
| `story.narrative_choice` | Choice consequence |
| `command.refused` (future) | Clear feedback |

*Optional immediate ping:* `combat.assist_canceled` → small Instability bump now; encounter cap still applies to total.

### Encounter-based events (accumulate in summary; evaluate at `encounter_completed`)

Routine combat and command actions — prevents per-swing farming:

| Event group |
|-------------|
| Assist succeeded / hesitated / canceled (counts) |
| Protection triggered / succeeded (counts) |
| Player damaged (total damage or hit count) |
| Enemy defeated (count) |
| Command obeyed (counts) |
| Alert entered (duration or count, log only) |

### Session-based events (evaluate on rest, save, or area transition)

Exploration, Bond growth, and pattern tracking:

| Event group |
|-------------|
| Time together |
| Travel milestones |
| Area entered / completed |
| Discovery |
| Faction shift |
| Encounter Quality history (§7) |
| Bond pattern evaluation (§2.1) |

---

## 6. Encounter Summary Concept

**Status: IMPLEMENTED** — `RelationshipEncounterSummary` in `scripts/relationship/relationship_encounter_summary.gd`

```gdscript
# RelationshipEncounterSummary — accumulated during one combat encounter
class_name RelationshipEncounterSummary

var encounter_id: String
var started_at: float

# Counters
var successful_assists: int = 0
var assist_hesitations: int = 0
var assist_cancellations: int = 0
var protection_triggers: int = 0
var successful_protections: int = 0
var enemies_defeated: int = 0
var player_damage_taken: float = 0.0
var player_near_death_count: int = 0
var player_died: bool = false
var commands_obeyed: int = 0
var commands_delayed: int = 0

# Dragon harm placeholders (future dragon health)
var dragon_damage_taken: float = 0.0
var dragon_near_death_count: int = 0
var dragon_critical: bool = false
var dragon_died: bool = false

# Disengage tracking
var was_disengaged: bool = false
var disengage_count: int = 0
var reengaged_after_disengage: bool = false
var excellent_disqualified: bool = false

# Resolve flags
var encounter_completed: bool = false
var encounter_failed: bool = false
var resolved_outcome: ResolvedOutcome
```

**Lifecycle:**

1. **Start** — first enemy aggro or player enters combat zone.
2. **Record** — `RelationshipEventBus` increments encounter counters; no mid-encounter stat writes.
3. **End** — last enemy dead, player leaves, death, or flee.
4. **Classify** — assign **Encounter Quality** (outcome/stress) and **Cooperation Rating** (teamwork).
5. **Evaluate** — quality → Instability delta; cooperation → Sync delta; anti-farm rules (future).
6. **Pattern pass** — session tracker updates encounter-quality history → proposed **Bond** deltas (future).
7. **Apply** — `BondSystem` applies clamped Sync/Instability changes (Bond unchanged per encounter).

**Encounter completion (via split ratings — not raw counts):**

- **Excellent Quality** → Instability ↓ (stress relief); Sync unchanged unless Cooperation also strong
- **Excellent Cooperation** → Sync ↑; Instability unchanged unless Quality also clean
- **Neutral** on either axis → no delta from that axis
- **Poor Quality** → Instability ↑; **Poor Cooperation** → Sync ↓
- **Disastrous Quality** (death) → large Instability ↑; Bond preview only until pattern pass

A fight may be **Excellent Quality** with **Poor Cooperation** or **Poor Quality** with **Excellent Cooperation**. See **Current Implementation** for live deltas and examples.

---

## 7. Encounter Quality & Cooperation Rating (reference)

> **Live behavior:** See **Current Implementation** at the top of this document.  
> **Planned rename/refactor:** See **Planned Revision** (Outcome Rating bands).

This section summarizes the **implemented** split for quick reference within the event catalog.

### Encounter Quality → Instability (live)

| Quality | Instability Δ |
|---------|---------------|
| Excellent | −2 |
| Good | −1 |
| Neutral | 0 |
| Poor | +2 |
| Disastrous | +4 |

### Cooperation Rating → Sync (live)

| Rating | Sync Δ |
|--------|--------|
| Excellent | +2 |
| Good | +1 |
| Neutral | 0 |
| Poor | −1 |
| Disastrous | −2 |

### Bond Strength (live — protected)

- Bond **not applied** at encounter resolve; preview only in debug UI.
- Session/pattern evaluation and Bond resilience remain **future** (§11).

> **Note on §4 event ownership:** Individual events (e.g. assist canceled) describe *design intent* for which stats they relate to. **Live prototype** batches routine combat into encounter resolve: Instability from Encounter Quality, Sync from Cooperation Rating — not per-event stat writes.

## 8. Anti-Farming Philosophy

**Status: FUTURE — NOT IMPLEMENTED** — documented rules for a future pass.

### Diminishing returns

| Pattern | Rule |
|---------|------|
| Repeated assists in one encounter | Each additional assist contributes less Sync after cap (e.g. first 3 full weight, then 50%, then 25%) |
| Repeated protection triggers | Same diminishing curve; protection is defensive, not a Sync engine |
| Enemy defeats | Cap Sync per encounter from kills alone; excess kills grant nothing |

### Per-encounter caps

| Metric | Cap intent |
|--------|------------|
| `successful_assists` | Max countable assists per encounter (e.g. 5) |
| `successful_protections` | Max countable protections (e.g. 4) |
| `enemies_defeated` | Max kill-based Sync events (e.g. 8) |
| `assist_cancellations` | Max cooperation penalty events counted (e.g. 6) |
| Net Sync gain | Hard ceiling per encounter |
| Net Instability gain | Hard ceiling per encounter |
| Encounter Quality | Best achievable quality capped by repeated identical farming |

### Exploit prevention

| Exploit | Mitigation |
|---------|------------|
| Kiting one weak enemy for assists | Assist cooldown + encounter assist cap + engagement requirement |
| Triggering protection without threat | Protection requires valid threat priority (already in AI); no summary credit without `protection_succeeded` |
| Standing in safe zone farming “time together” | Session rollup requires movement + no combat + minimum distance |
| Command delay farming | `command.delayed` has zero stat weight |
| Death/revive looping | `player_death` once per encounter; Bond via session cooldown on pattern penalties |
| Excellent-quality farming | Repeated Excellent in one session → diminishing Bond pattern gain |

### Bond Strength guardrails

- Bond **never** increases from combat event counters or single Encounter Quality alone.
- Bond changes require **session rollups**, **story events**, **exploration milestones**, or **sustained quality patterns** (e.g. N Good+ encounters across sessions).
- Bond **may** decrease only when **Disastrous** quality or story breaches form a **pattern** — not from one messy fight.

---

## 9. Instability Target Bands

Design intent for where Instability should **spend most of its time**. Live encounter deltas apply today; passive decay toward these bands is **not implemented**.

| Range | Band | Character |
|-------|------|-----------|
| 0–15 | **Very Calm** | Rare peak; brief recovery target, not a permanent idle state |
| 16–35 | **Normal** | Default healthy baseline after recovery |
| 36–60 | **Noticeable Strain** | Active combat, mistakes, tension — common during play |
| 61–85 | **Dangerous Strain** | Serious pressure; hesitation/cancel more likely |
| 86–100 | **Crisis** | Brief spikes only; should not be sustained |

### Design goals

- Players should spend **most gameplay** in **16–35** (Normal) or **36–60** (Noticeable Strain).
- The system should **not** naturally sit at **0–10** — zero instability means no tension; recovery should target Normal, not absolute zero.
- The system should **not** become **trapped at 70–100** — recovery, encounter quality, and Bond-modulated decay must pull Instability down after fights.
- Crisis spikes are allowed; **sustained Crisis is a design failure** to tune against.

Future tuning levers: decay rate, Encounter Quality Instability deltas, `get_instability_recovery_rate(bond_strength)`, `get_instability_resistance(bond_strength)`.

---

## 10. Sync Philosophy

Sync represents **learned cooperation** — it should be **easier to gain than to lose**.

### Rationale

- Cooperation is built over many successful moments; one bad fight should not erase progress.
- Sync is the “skill floor” of the partnership — it should feel rewarding to maintain.
- Loss of Sync should signal **sustained** problems, not a single cancel or bad encounter.

### Design guidance (no numbers yet)

| Situation | Intended Sync behavior |
|-----------|------------------------|
| Repeated successful cooperation | Builds Sync steadily (with encounter caps) |
| Single bad encounter (Poor Cooperation) | **Small** Sync reduction (live: −1 Poor, −2 Disastrous cooperation) |
| Single failure (one cancel, otherwise Good cooperation) | Minimal Sync loss |
| Repeated Poor/Disastrous cooperation | **Meaningful** Sync reduction |
| Recovery | Sync restores faster than it falls (asymmetric gain/loss) |

### Relationship to other stats

- **Instability** absorbs short-term shock; Sync should not mirror every Instability spike.
- **Bond Strength** (future sync floor) sets how low Sync can fall — high Bond prevents total coordination collapse.
- **Encounter Quality** is the primary **Instability** adjustment surface at encounter end.
- **Cooperation Rating** is the primary **Sync** adjustment surface at encounter end.

---

## 11. Bond Resilience Integration (Future)

**Not implemented.** Documents how Bond Strength should eventually influence relationship **outcomes**, not combat power.

Bond Strength = **resilience** — the depth of trust that buffers the relationship against stress.

### Outcome modulation (conceptual)

| Bond level | Effect on relationship outcomes |
|------------|--------------------------------|
| **Low Bond** | Negative encounters (Poor/Disastrous quality) have **stronger** Instability impact; Sync losses linger; pattern penalties reach Bond faster |
| **High Bond** | Negative encounters have **weaker** Instability impact; Sync recovers faster; Bond resists erosion from isolated bad fights |

### Connection to existing helpers (`BondResilience`)

| Helper | Future role in relationship updates |
|--------|-------------------------------------|
| `get_instability_resistance(bond_strength)` | Scales Instability **gain** from Poor/Disastrous encounters |
| `get_instability_recovery_rate(bond_strength)` | Scales passive and post-encounter Instability **decay** |
| `get_sync_floor(bond_strength)` | Minimum Sync after losses |
| `get_bond_tier()` / progress | Gates how fast Bond rises from positive patterns |

### Connection to encounter evaluation

- **Encounter Quality** produces base Instability deltas (live).
- **Cooperation Rating** produces base Sync deltas (live).
- **Resilience pass (future)** multiplies Instability deltas and pattern-based Bond deltas by Bond tier.
- Same Disastrous encounter hurts a fragile bond more than a deep bond — without preventing the event.

---

## 12. Natural Recovery Philosophy

**Not implemented.** Design intent for Instability (primary) and optionally Sync:

| Recovery channel | Effect |
|------------------|--------|
| **Time decay** | Instability drifts down out of combat toward **Normal band (16–35)** |
| **Bond-modulated decay** | `get_instability_recovery_rate(bond_strength)` multiplies decay |
| **Safe encounter complete** | Bonus Instability reduction on Good/Excellent quality |
| **Rest points / camps** | Larger Instability drop; small Sync stabilize |
| **Exploration without combat** | Slow Instability decay; Bond pattern drift up (session) |

Sync recovery:

- Asymmetric: regains faster than it falls (§10).
- Stabilizes toward a floor influenced by Bond (`get_sync_floor`, future).

Bond recovery:

- Never instant from a single good fight or single Excellent quality.
- Gradual increase from positive **session patterns**, exploration, and story events.
- Resilience reduces how much Instability/quality patterns erode Bond over time.

---

## 13. Future Implementation Notes

### Proposed modules

| Module | Status | Responsibility |
|--------|--------|----------------|
| `RelationshipEvent` | **Implemented** | `event_id`, payload |
| `RelationshipEventBus` | **Implemented** | Emit and subscribe |
| `RelationshipEncounterTracker` | **Implemented** | Builds `RelationshipEncounterSummary` |
| `EncounterQualityClassifier` | **Implemented** | Outcome/stress → Instability |
| `CooperationRatingClassifier` | **Implemented** | Teamwork → Sync |
| `ProposedDeltaGenerator` | **Implemented** | Deltas + Bond preview |
| `RelationshipSessionTracker` | **Implemented** | Quality history (Bond input future) |
| `BondSystem.apply_sync_delta` / `apply_instability_delta` | **Implemented** | Clamp and write `BondProfile` |
| `RelationshipUpdateEvaluator` | Future | Resilience + anti-farm pass |
| Bond pattern pass | Future | Session trends → Bond Strength |

### Hook points (existing prototype)

| System | Events to emit (future) |
|--------|-------------------------|
| `dragon_cooperation_behavior.gd` | assist hesitated, canceled, succeeded |
| `dragon_protection_behavior.gd` | protection triggered |
| `dragon_strike_behavior.gd` | strike finished (assist/protection success) |
| `dragon_command_behavior.gd` | command obeyed, delayed, canceled |
| `dragon_threat_behavior.gd` | alert entered (optional) |
| `player` health | damaged, critical, death |
| `enemy.gd` | defeated |
| `TestWorld` / future zones | encounter start/end, exploration |

### Milestone 8 — encounter resolution (**implemented**)

See **Current Implementation** for live pipeline, deltas, and safeguards.

**Tracking vs resolution**

- **Current encounter** begins on meaningful combat engagement (damage, protection triggered, assist attempt/hesitation).
- **Resolved encounter** is produced only when a meaningful outcome occurs.
- Minor skirmishes may **abort** tracking with no last-resolved snapshot and no stat changes.

**Resolved outcome values**

| Outcome | When |
|---------|------|
| **Enemy Defeated** | Involved enemy dies / all involved enemies dead |
| **Player Death** | Player dies during encounter |
| **Fled / Disengaged** | Timeout or flee **after** meaningful combat progress |
| **Unresolved** | Reserved — minor disengage aborts instead of resolving |
| **Dragon Injured / Dragon Death** | Future — see **Future Systems** |
| **Enemy Escaped** | Future |

**Bond preview (live — not applied)**

- Generated for some resolved outcomes (e.g. Disastrous death may show Bond −1 preview).
- Bond Strength is **never written** at encounter resolve.

**Assist vs protection**

- **Assist** — cooperative strike while player is engaging (`strike_kind=ASSIST`, `cooperative_assist`).
- **Protection** — defensive response to threat (`strike_kind=PROTECTION`, `defensive_protection`).
- A single strike emits **one** success event; never both assist and protection for the same hit.

**Disengage grace (6s)**

- When involved enemies stop chasing for 4s (or player flees far enough), the encounter enters **disengage grace** instead of resolving immediately.
- Counters are preserved; `was_disengaged` and `excellent_disqualified` are set.
- Re-engaging the same involved enemy within 6s **resumes** the same encounter (`reengaged_after_disengage = true`).
- After grace expires, resolve as **Fled / Disengaged** (or abort if no meaningful progress).
- **Excellent Quality** is never allowed after any disengage in the same encounter.

Summary fields: `was_disengaged`, `disengage_count`, `reengaged_after_disengage`, `excellent_disqualified`.

### Dragon as combat target (future)

See **Future Systems → Future Dragon Health Integration**.

### References

- Bond tiers: `scripts/bond/bond_resilience.gd`
- Active stat effects: `../historical/project_checkpoint_milestone7.md`
- Dragon state flow: ALERT → PROTECTING → ASSISTING (separate systems)

---

## Document History

| Version | Scope |
|---------|--------|
| 1.0 | Initial event economy design — no gameplay implementation |
| 1.1 | Bond combat/pattern split, Encounter Quality, Instability bands, Sync philosophy, Bond resilience integration |
| 1.2 | Milestone 8 outcome-based resolution, assist/protection separation, dragon damage placeholders |
| 1.3 | Stricter Excellent rules, disengage grace / re-engage same encounter |
| 1.5 | Split Encounter Quality (Instability) vs Cooperation Rating (Sync); live stat application |
| 2.0 | Current Implementation / Planned Revision / Future Systems / Progression Philosophy sections |
