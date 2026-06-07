# Dragon Rider RPG — Milestone 8 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Main scene:** `res://scenes/world/TestWorld.tscn`  
**Prior checkpoint:** `docs/project_checkpoint_milestone7.md`  
**Design reference:** `docs/relationship_event_framework.md`

Milestone 8 adds **relationship observation infrastructure only**. Bond Strength, Sync, and Instability are **never modified** by this system.

---

## Milestone Summary

| Area | Status |
|------|--------|
| Relationship event bus + hooks | Done |
| Local encounter tracking | Done |
| Involved-enemy scoping | Done |
| Outcome-based resolution | Done |
| Encounter quality classifier | Done |
| Proposed deltas (preview only) | Done |
| Bond Debug UI (relationship section) | Done |
| Apply relationship deltas to stats | **Not started (M9)** |

---

## Architecture

```
Gameplay hooks → RelationshipSystem (autoload)
  → RelationshipEventBus
  → RelationshipEncounterTracker (counters + involved enemies)
  → EncounterQualityClassifier (label only)
  → ProposedDeltaGenerator (preview only)
  → Bond Debug UI (F10 window)
```

**Autoload:** `scripts/systems/relationship_system.gd`  
**Wired from:** `TestWorld` via `setup_from_scene()`

---

## Relationship Event Bus

- **`RelationshipEvent`** — stable `event_id` strings + payload (`enemy_instance_id`, `source_behavior`, `strike_kind`, etc.)
- **`RelationshipEventBus`** — emit + optional debug log; no stat writes
- **Hooks:** player melee hit, enemy damage/death/aggro, dragon strike hit/start, protection triggered, assist hesitate/cancel, commands, player critical HP/death

**Assist vs protection (separate):**
- Assist → `cooperative_assist` / `ASSIST`
- Protection → `defensive_protection` / `PROTECTION`
- One strike emits one success event, never both

Aggro/alert alone do **not** start encounters (telemetry only if encounter already active).

---

## Local Encounter Tracking

**Starts on meaningful combat engagement:**
- Player or enemy damage
- Protection triggered
- Assist attempt / hesitation

**Does not start on:** aggro alone, brief chase without combat events.

**Tracks one encounter at a time** with live counters in `RelationshipEncounterSummary`.

**Resolves only on meaningful outcomes:**
- Enemy defeated (involved enemy dies / all involved dead)
- Player death
- Fled / disengaged (after meaningful progress + grace expiry)

**Aborts (no last resolved / no proposed deltas):** tiny skirmishes (single hit, single protection, no meaningful progress) that disengage without resolve.

---

## Involved Enemy Tracking

- `involved_enemy_ids: Array[int]` on summary
- Enemies marked involved on combat events with their instance ID
- End checks and disengage logic use **involved enemies only** — not all scene enemies
- Deferred end check when an involved enemy dies

---

## Disengage / Re-engage Logic

| Constant | Value | Meaning |
|----------|-------|---------|
| `DISENGAGE_TIMEOUT` | 4 s | No involved enemy chasing → enter grace |
| `PLAYER_DISENGAGE_DISTANCE` | 400 | Player far from alive involved enemies |
| `PLAYER_FLEE_END_DELAY` | 1 s | Flee distance must hold this long |
| `DISENGAGE_GRACE_TIME` | 6 s | Window to resume same encounter |

**Flow:**
1. Enemy stops chasing (or player flees far enough) → **disengage grace** (not immediate resolve)
2. Sets `was_disengaged`, increments `disengage_count`, sets `excellent_disqualified`
3. Re-engage same **involved** enemy within 6 s → **resume same encounter**, keep counters, set `reengaged_after_disengage`
4. Grace expires → resolve **Fled / Disengaged** (or abort if no meaningful progress)
5. **Excellent never allowed** after any disengage in the same encounter

**Summary fields:** `was_disengaged`, `disengage_count`, `reengaged_after_disengage`, `excellent_disqualified`

---

## Encounter Summary System

**`RelationshipEncounterSummary`** — accumulated counters per encounter:

- Cooperation: assists, protections, cancels, hesitations, player hits
- Harm: `player_damage_taken`, `player_near_death_count`, `player_died`
- Outcome: `enemies_defeated`, `resolved_outcome`
- Disengage: fields above
- **Future placeholders:** `dragon_damage_taken`, `dragon_near_death_count`, `dragon_critical`, `dragon_died`

Helpers: `has_meaningful_combat_progress()`, `is_excellent_eligible()`, `refresh_excellent_disqualification()`

**`RelationshipSessionTracker`** — session quality history string only (no Bond evaluation).

---

## Encounter Quality Classifier

**`EncounterQualityClassifier`** — assigns one label at resolve time. No stat writes.

| Quality | Summary |
|---------|---------|
| **Excellent** | Flawless cooperation (see below) |
| **Good** | Enemy defeated; player + dragon both contributed; damage ≤30% ref HP; ≤1 cancel; no near-death |
| **Neutral** | Player-only kill, dragon-only kill, minor flee, unremarkable resolve |
| **Poor** | Heavy damage, near-death, messy victory, bad fled outcome |
| **Disastrous** | Player death (future: dragon death) |

### Final Excellent Requirements (all required)

- Enemy defeated
- Player contributed (≥1 attack landed)
- Dragon contributed (≥1 assist or protection success)
- **`player_damage_taken == 0`** — any player damage → Excellent impossible
- **`dragon_damage_taken == 0`** (future-ready) — any dragon damage → Excellent impossible
- `assist_cancellations == 0`
- `player_near_death_count == 0`
- Player did not die; dragon did not die (future)
- No disengage / re-engage (`was_disengaged`, `reengaged_after_disengage`)
- `excellent_disqualified == false`

Any harm caps result at **Good** (if Good rules pass) or lower. Good/Neutral/Poor/Disastrous rules unchanged from M8 tuning pass.

**Resolved outcomes:** Enemy Defeated, Player Death, Fled / Disengaged, Unresolved (abort). Future: Dragon Injured, Dragon Death, Enemy Escaped.

---

## Proposed Deltas — NOT APPLIED

**`ProposedDeltaGenerator`** + **`ProposedRelationshipDeltas`** produce preview values only.

- Shown in debug UI as **PROPOSED ONLY — NOT APPLIED**
- Generated only for resolved encounters where quality warrants a preview (e.g. Good+, Poor/Disastrous on fled)
- Neutral player-only kills and minor outcomes → no proposed deltas
- **Bond Strength, Sync, Instability are never written in Milestone 8**

Example preview tiers (not applied):

| Quality | Sync Δ | Instability Δ | Bond Δ |
|---------|--------|---------------|--------|
| Excellent | +2 | −1 | 0 |
| Good | +1 | −1 | 0 |
| Poor | −1 | +2 | 0 |
| Disastrous | −2 | +3 | −1 (pattern preview) |

---

## Debug UI

**F10** — `scenes/ui/BondDebugUI.tscn` (separate resizable window)

**Relationship section (top):**
- **Current Encounter** — live tracking counters; `Encounter Active: YES (grace)` during disengage grace
- **Last Resolved Encounter** — outcome, quality, summary, disengage fields
- **Excellent Eligible: YES/NO** — live check via `is_excellent_eligible()`
- **Proposed Relationship Changes** — only when preview applies; labeled NOT APPLIED
- **Recent Events** — `event_id | source_behavior | strike_kind | enemy_id`
- Session quality history

**Bond Debug section (bottom):** dragon behavior stats, tiers, planned resilience helpers (unchanged from M7).

**Help panel (bottom-left):** bond test keys + live Bond/Sync/Instability next to Ctrl+1/3/5.

**Spawn debug:** F1 / Shift+F1 spawn enemies.

---

## Key Files

| Component | Path |
|-----------|------|
| Orchestrator (autoload) | `scripts/systems/relationship_system.gd` |
| Events | `scripts/relationship/relationship_event.gd` |
| Event bus | `scripts/relationship/relationship_event_bus.gd` |
| Encounter tracker | `scripts/relationship/relationship_encounter_tracker.gd` |
| Encounter summary | `scripts/relationship/relationship_encounter_summary.gd` |
| Quality classifier | `scripts/relationship/encounter_quality_classifier.gd` |
| Proposed deltas | `scripts/relationship/proposed_delta_generator.gd`, `proposed_relationship_deltas.gd` |
| Session history | `scripts/relationship/relationship_session_tracker.gd` |
| Debug UI | `scripts/ui/bond_debug_ui.gd`, `scenes/ui/BondDebugUI.tscn` |
| Event framework doc | `docs/relationship_event_framework.md` |

---

## Known Stable Systems (M7 + M8)

- All M7 gameplay: player, dragon, bond tiers, alert/protect/assist, communication, enemies
- Relationship observation pipeline end-to-end (events → track → classify → preview)
- Outcome-gated resolution (no proposals from tiny interactions)
- Involved-enemy scoping and disengage grace / re-engage continuity
- Assist/protection event separation
- Bond debug + help UI readouts

---

## Known Limitations

- **No stat application** — observation only
- **No dragon health** — dragon damage/death fields are placeholders
- **No enemy escape outcome** — placeholder enum only
- **No anti-farming caps** on proposed deltas (designed in framework doc, not coded)
- **No Bond pattern evaluation** across sessions
- Resilience helpers still not wired (sync floor, instability resistance/recovery)
- Single test scene; stats adjusted via debug keys only
- Encounter quality tuned for prototype; numeric deltas are placeholders for M9

---

## Recommended Milestone 9

1. **Apply relationship deltas** — wire `ProposedDeltaGenerator` → `BondSystem` with clamps + `BondResilience`
2. **Bond pattern pass** — session quality trends → Bond Strength (not per-fight spam)
3. **Anti-farming** — per-encounter caps, diminishing returns (see `relationship_event_framework.md`)
4. **Dragon as combat target** — health, events, Dragon Injured/Death outcomes
5. **Enemy escape outcome** — major combat then successful flee
6. **Wire resilience helpers** — sync floor, instability resistance/recovery into gameplay
7. **Save/load** — persist bond + relationship session history

---

## Controls (additions since M7)

| Action | Input |
|--------|--------|
| Toggle Bond & Relationship Debug | **F10** |
| Spawn enemy nearby | **F1** |
| Spawn 3 enemies | **Shift+F1** |

(See M7 checkpoint for movement, combat, bond test keys, health keys.)
