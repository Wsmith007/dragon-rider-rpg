# Relationship Event Framework

**Status:** Design / planning only (Milestone 8 prep)  
**Source of truth for gameplay:** `docs/project_checkpoint_milestone7.md`  
**Related:** `docs/bond_system.md`, `docs/dragon_ai.md`

This document defines **what relationship events exist**, **which stats they should affect**, and **how updates should be batched and guarded**. It does **not** assign numeric values and does **not** change gameplay in the current prototype.

---

## 1. Relationship Philosophy

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
7. **Combat feeds Sync and Instability; patterns feed Bond** — see §2.1.

Stats are currently debug-adjusted only. This framework prepares automatic updates without implementing them.

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
- **Changes when:** Successful coordinated actions, clean command compliance, shared victories.
- **Should not:** Permanently collapse from a single bad moment (see §10).
- **Gameplay today:** Cooperative assist cooldown tiers.

### Instability (`instability`)

- **Identity:** Current emotional/magical strain on the bond.
- **Changes when:** Player harm, failed cooperation, hesitation/cancel, near-death, death, chaos.
- **Should fall:** Over time, after safe periods, at rest (future — not implemented).
- **Target operating bands:** see §9.
- **Gameplay today:** Assist hesitation and post-hesitation cancel only.

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

**Multi-stat rule (combat layer):** **Instability** resolves first (immediate feel), **Sync** second (encounter rollup). **Bond** is evaluated last at **session/pattern** layer via Encounter Quality and exploration/story — not from raw combat event counts.

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

Future type (design sketch — **not implemented**):

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

# Flags
var encounter_completed: bool = false
var encounter_failed: bool = false

# Future (Milestone 8+)
# var encounter_quality: EncounterQuality  # set by evaluator, not counters alone
```

**Lifecycle:**

1. **Start** — first enemy aggro or player enters combat zone.
2. **Record** — `RelationshipEventBus` (future) increments counters; no stat writes.
3. **End** — last enemy dead, player leaves, death, or flee.
4. **Classify** — `RelationshipUpdateEvaluator` assigns **Encounter Quality** (§7).
5. **Evaluate** — quality + summary + anti-farm rules → proposed **Sync/Instability** deltas (Milestone 9+).
6. **Pattern pass** — session tracker updates encounter-quality history → proposed **Bond** deltas (Milestone 9+).
7. **Apply** — `BondSystem` applies clamped changes (Milestone 9+).

**Encounter completion (conceptual — via Encounter Quality, not raw counts):**

- **Excellent / Good** → Sync ↑, Instability ↓; Bond unchanged until session pattern
- **Neutral** → minor Sync/Instability drift
- **Poor / Disastrous** → Instability ↑, Sync ↓; Bond may move only if pattern trend worsens

---

## 7. Encounter Quality System

### What it is

**Encounter Quality** is a single classification assigned when an encounter ends. It summarizes **how the fight felt for the relationship** — not a sum of raw event counts applied directly to stats.

Future enum (no formulas yet):

| Quality | Meaning |
|---------|---------|
| **Excellent** | Strong cooperation, low harm, clean resolution |
| **Good** | Solid teamwork with minor strain |
| **Neutral** | Unremarkable; neither bonding nor damaging |
| **Poor** | Frequent failures, heavy damage, or messy resolution |
| **Disastrous** | Death, abort, or relationship-breaking chaos |

### Why it exists

1. **Balancing surface** — designers tune Sync/Instability per quality tier, not per assist click.
2. **Anti-farming** — quality caps how much one encounter can matter regardless of event spam.
3. **Bond protection** — Bond reads **patterns of quality over sessions**, not individual Excellent rolls.
4. **Player clarity** — future UI can show “We fought well together” vs opaque stat math.

### Potential inputs (evaluator inputs — not formulas)

- `successful_assists`, `successful_protections`
- `assist_cancellations`, `assist_hesitations`
- `player_damage_taken`, `player_near_death_count`, `player_died`
- `enemies_defeated`, `encounter_completed`, `encounter_failed`
- `commands_obeyed` vs `commands_delayed`

### How future systems use it

| System | Use |
|--------|-----|
| **Sync / Instability update** | Primary delta driver at encounter end |
| **Bond pattern tracker** | Streak of Good/Excellent → slow Bond ↑; streak of Poor/Disastrous → Bond ↓ |
| **Communication (future)** | Optional tone modifier after Poor/Disastrous |
| **Bond resilience (§11)** | High Bond dampens Instability gain from Poor; low Bond amplifies it |

**Goal:** Future balancing operates primarily on **Encounter Quality**, with raw counters feeding the classifier only.

---

## 8. Anti-Farming Philosophy

Documented rules for future implementation — **not active today**.

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
| `assist_cancellations` | Max instability events counted (e.g. 6) |
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

Design intent for where Instability should **spend most of its time** once the update loop exists. **Not gameplay values today.**

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
| Single bad encounter (Poor quality) | **Small** Sync reduction |
| Single failure (one cancel, one death) | Minimal or no Sync loss if encounter otherwise Good |
| Repeated Poor/Disastrous encounters | **Meaningful** Sync reduction |
| Recovery | Sync restores faster than it falls (asymmetric gain/loss) |

### Relationship to other stats

- **Instability** absorbs short-term shock; Sync should not mirror every Instability spike.
- **Bond Strength** (future sync floor) sets how low Sync can fall — high Bond prevents total coordination collapse.
- **Encounter Quality** is the primary Sync adjustment surface at encounter end.

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

### Connection to Encounter Quality

- Evaluator produces base Sync/Instability deltas from quality tier.
- **Resilience pass** multiplies Instability deltas and pattern-based Bond deltas by Bond tier.
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

### Proposed modules (Milestone 8+)

| Module | Responsibility |
|--------|----------------|
| `RelationshipEvent` | Enum / resource: `event_id`, timestamp, payload |
| `RelationshipEventBus` | Emit and subscribe; no stat writes |
| `RelationshipEncounterTracker` | Builds `RelationshipEncounterSummary` |
| `EncounterQualityClassifier` | Summary → Excellent … Disastrous (no stat writes in M8) |
| `RelationshipSessionTracker` | Encounter quality history; Bond pattern input |
| `RelationshipUpdateEvaluator` | Quality + resilience + rules → proposed deltas |
| `BondSystem.apply_relationship_deltas()` | Clamp and write `BondProfile` (Milestone 9+) |

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

### Milestone 8 scope (recommended)

1. Implement `RelationshipEvent` + `RelationshipEventBus` (emit only, debug log).
2. Implement `RelationshipEncounterTracker` (counters only).
3. Implement `EncounterQualityClassifier` stub (label only, debug log).
4. Implement `RelationshipSessionTracker` stub (quality history only).
5. Wire combat/command hooks to bus **without changing stats**.
6. **Milestone 9:** numeric deltas, resilience pass, apply to `BondProfile`, tune bands (§9) and Sync asymmetry (§10).

### Milestone 8 — encounter resolution (implemented, observation only)

**Tracking vs resolution**

- **Current encounter** begins on meaningful combat engagement (damage, protection triggered, assist attempt/hesitation).
- **Resolved encounter** is produced only when a meaningful outcome occurs.
- Minor skirmishes (single hit, single protection, brief chase) may **abort** tracking with no last-resolved snapshot and no proposed deltas.

**Resolved outcome values**

| Outcome | When |
|---------|------|
| **Enemy Defeated** | Involved enemy dies / all involved enemies dead |
| **Player Death** | Player dies during encounter |
| **Fled / Disengaged** | Timeout or flee **after** meaningful combat progress |
| **Unresolved** | Reserved — minor disengage aborts instead of resolving |
| **Dragon Injured / Dragon Death** | Future — see §6.1 |
| **Enemy Escaped** | Future — major combat then successful escape |

**Proposed deltas (preview only)**

- Generated only for resolved outcomes with non-neutral quality (or Poor/Disastrous on fled).
- Bond Strength, Sync, and Instability are **never** written in Milestone 8.

**Assist vs protection**

- **Assist** — cooperative strike while player is engaging (`strike_kind=ASSIST`, `cooperative_assist`).
- **Protection** — defensive response to threat (`strike_kind=PROTECTION`, `defensive_protection`).
- A single strike emits **one** success event; never both assist and protection for the same hit.

**Disengage grace (6s)**

- When involved enemies stop chasing for 4s (or player flees far enough), the encounter enters **disengage grace** instead of resolving immediately.
- Counters are preserved; `was_disengaged` and `excellent_disqualified` are set.
- Re-engaging the same involved enemy within 6s **resumes** the same encounter (`reengaged_after_disengage = true`).
- After grace expires, resolve as **Fled / Disengaged** (or abort if no meaningful progress).
- **Excellent is never allowed** after any disengage in the same encounter.

**Excellent quality (rare — flawless)**

Requires **all** of: enemy defeated, player hit landed, dragon assist/protection success, **zero** player damage, **zero** dragon damage (future), zero cancels, zero near-death, no disengage/re-engage, not dragon-only kill. Any player or dragon harm caps the result at **Good** (if other Good rules pass) or lower.

Summary fields: `was_disengaged`, `disengage_count`, `reengaged_after_disengage`, `excellent_disqualified`.

### 6.1 Future — dragon as combat target (hooks only)

Not implemented in Milestone 8. Reserved summary fields:

- `dragon_damage_taken`, `dragon_near_death_count`, `dragon_critical`, `dragon_died`

Future events (planned):

- `combat.enemy_damaged_dragon`
- `combat.dragon_critical_hp`
- `combat.dragon_death`

Future resolved outcomes:

- **Dragon Injured** — critical injury threshold crossed
- **Dragon Death** — bond/sync/instability consequences for failing to protect the dragon

When dragon health exists, fled/disengage quality should also consider dragon harm and failed protection under fire.

### References

- Bond tiers: `scripts/bond/bond_resilience.gd`
- Active stat effects: `docs/project_checkpoint_milestone7.md`
- Dragon state flow: ALERT → PROTECTING → ASSISTING (separate systems)

---

## Document History

| Version | Scope |
|---------|--------|
| 1.0 | Initial event economy design — no gameplay implementation |
| 1.1 | Bond combat/pattern split, Encounter Quality, Instability bands, Sync philosophy, Bond resilience integration |
| 1.2 | Milestone 8 outcome-based resolution, assist/protection separation, dragon damage placeholders |
| 1.3 | Stricter Excellent rules, disengage grace / re-engage same encounter |
| 1.4 | Excellent requires zero player/dragon damage (flawless cooperation) |
