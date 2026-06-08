# Dragon Rider RPG — Milestone 9A Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Main scene:** `res://scenes/world/TestWorld.tscn` (playtest shell with split layout)  
**Prior checkpoint:** `docs/project_checkpoint_milestone8.md` (historical — observation only at M8)  
**Design reference:** `docs/relationship_event_framework.md` (v2.0 — **source of truth** for relationship behavior)

Milestone 9A adds **live Sync and Instability changes** from resolved encounters using a **split rating model**. Bond Strength remains **protected** from per-encounter resolution.

---

## Milestone Summary

| Area | Status |
|------|--------|
| Relationship event bus + hooks | Done (M8) |
| Local encounter tracking + involved enemies | Done (M8) |
| Outcome-based resolution + disengage grace | Done (M8) |
| Encounter Quality classifier (outcome/stress) | Done |
| Cooperation Rating classifier (teamwork) | Done (9A) |
| Live Sync application (Cooperation Rating) | **Done (9A)** |
| Live Instability application (Encounter Quality) | **Done (9A)** |
| Bond Strength at encounter resolve | **Protected — not applied** |
| Bond delta preview in debug UI | Done (preview only) |
| Per-encounter duplicate prevention | Done (9A) |
| Split playtest layout (gameplay / debug) | Done |
| Outcome Rating rename + combined harm bands | **Planned — not implemented** |
| Bond pattern pass / session Bond changes | **Future** |
| Bond resilience wiring | **Future** |
| Dragon health → combined harm | **Future** |

---

## Architecture (live)

```
Gameplay hooks → RelationshipSystem (autoload)
  → RelationshipEventBus
  → RelationshipEncounterTracker (counters + involved enemies)
  → EncounterQualityClassifier (outcome/stress → Instability Δ)
  → CooperationRatingClassifier (teamwork → Sync Δ)
  → ProposedDeltaGenerator (deltas + Bond preview)
  → BondSystem.apply_sync_delta / apply_instability_delta (clamped 0–100)
  → Bond Debug UI (F10, docked right panel)
```

**Autoload:** `scripts/systems/relationship_system.gd`  
**Wired from:** `TestWorld` via `RelationshipSystem.setup_from_scene()`

---

## Relationship Event Infrastructure

Same event bus and hooks as Milestone 8:

- **`RelationshipEvent`** — stable `event_id` strings + payload
- **`RelationshipEventBus`** — emit + optional debug log; **no mid-encounter stat writes**
- **Hooks:** player melee hit, enemy damage/death/aggro, dragon strike hit/start, protection triggered, assist hesitate/cancel, commands, player critical HP/death

**Assist vs protection (separate):**

- Assist → `cooperative_assist` / `ASSIST`
- Protection → `defensive_protection` / `PROTECTION`
- One strike emits one success event, never both

Aggro/alert alone do **not** start encounters.

---

## Local Encounter Tracking

**Starts on meaningful combat engagement:** damage, protection triggered, assist attempt/hesitation.

**Resolves on:** enemy defeated, player death, fled/disengaged (after meaningful progress + grace expiry).

**Aborts:** tiny skirmishes with no meaningful progress — no resolve, no stat changes.

**Involved enemy scoping:** `involved_enemy_ids` — disengage and end checks use involved enemies only.

**Disengage grace:** 4 s chase timeout / flee distance → 6 s grace window to resume same encounter; disengage prevents Excellent Quality.

See `docs/project_checkpoint_milestone8.md` for historical M8 detail on disengage constants and flow.

---

## Split Ratings (live)

### Encounter Quality → Instability

Measures **outcome stress / harm**, not teamwork. Classifier: `EncounterQualityClassifier`.

| Quality | Instability Δ |
|---------|---------------|
| Excellent | −2 |
| Good | −1 |
| Neutral | 0 |
| Poor | +2 |
| Disastrous | +4 |

**Live thresholds (player harm, ref HP 1000):**

- **Excellent:** enemy defeated; zero player/dragon damage; no near-death; no disengage/re-engage
- **Good:** enemy defeated; damage ≤ 30%; no near-death
- **Poor:** near-death or damage ≥ 35% or stressful flee with heavy harm
- **Neutral:** solo kills, minor flee, moderate strain between bands
- **Disastrous:** player death (dragon death field ready)

Assist cancellations do **not** affect Encounter Quality.

### Cooperation Rating → Sync

Measures **teamwork / execution**. Classifier: `CooperationRatingClassifier`.

| Rating | Sync Δ |
|--------|--------|
| Excellent | +2 |
| Good | +1 |
| Neutral | 0 |
| Poor | −1 |
| Disastrous | −2 |

**Live rules (summary):**

- Solo player or solo dragon kill → **Neutral** (Sync unchanged)
- Both contributed, clean execution → **Excellent** / **Good**
- Repeated cancels/hesitations → **Poor** without forcing Poor Quality

### Split examples

| Scenario | Quality | Cooperation | Instability | Sync |
|----------|---------|-------------|-------------|------|
| Win, 0 damage, 4 cancels | Excellent | Poor | −2 | −1 |
| Win, heavy damage, strong assists | Poor | Good/Excellent | +2 | +1/+2 |
| Player-only kill | Good/Neutral | Neutral | −1/0 | 0 |
| Player death | Disastrous | (varies) | +4 | (varies) |

---

## Bond Strength (protected)

- **Not modified** at encounter resolve
- Debug UI may show **Bond Δ preview** (e.g. −1 on Disastrous death) — **NOT APPLIED**
- Future Bond changes intended via **session/pattern evaluation**, not per-fight rolls
- See `docs/bond_system.md` and `docs/relationship_event_framework.md` §7.2 / Bond Strength guardrails

---

## Stat Application Safeguards

- One application per resolved `encounter_id`
- Sync and Instability clamped 0–100 via `BondProfile` setters
- Debug keys (Ctrl+1/3/5 etc.) still allow manual adjustment for testing
- Aborted encounters apply nothing

---

## Debug UI & Playtest Layout

**F10** — toggles docked **Debug Panel** (right column); gameplay expands to full width when hidden.

**Layout (live):**

- Default window: **1600×900**
- Gameplay SubViewport: **~1200×900** (left) — world, camera, in-game HUD, help panel
- Debug panel: **~400px** (right) — `BondDebugUI` (scrollable)

**Relationship section shows:**

- Current encounter counters + live Cooperation estimate
- Last resolved: Encounter Quality, Cooperation Rating, Applied Sync Δ, Applied Instability Δ
- Bond Δ preview (NOT APPLIED)
- Session quality history (Encounter Quality labels only)
- Recent event log

**Help panel:** bottom-left inside gameplay viewport — bond test keys + live stat readouts.

---

## Key Files

| Component | Path |
|-----------|------|
| Orchestrator | `scripts/systems/relationship_system.gd` |
| Events / bus | `scripts/relationship/relationship_event.gd`, `relationship_event_bus.gd` |
| Encounter tracker | `scripts/relationship/relationship_encounter_tracker.gd` |
| Encounter summary | `scripts/relationship/relationship_encounter_summary.gd` |
| Encounter quality | `scripts/relationship/encounter_quality_classifier.gd` |
| Cooperation rating | `scripts/relationship/cooperation_rating_classifier.gd` |
| Deltas | `scripts/relationship/proposed_delta_generator.gd`, `proposed_relationship_deltas.gd` |
| Session history | `scripts/relationship/relationship_session_tracker.gd` |
| Stat application | `scripts/bond/bond_system.gd` |
| Playtest shell | `scenes/world/TestWorld.tscn`, `TestWorldGame.tscn` |
| Debug UI | `scripts/ui/bond_debug_ui.gd`, `scenes/ui/BondDebugUI.tscn` |
| Framework doc | `docs/relationship_event_framework.md` |

---

## Known Limitations

- **Player harm only** for Encounter Quality — dragon damage fields reserved, not wired
- **No Outcome Rating rename** — still Excellent/Good/Neutral/Poor/Disastrous (planned Flawless/Safe/Rough/Severe)
- **No combined harm bands** — planned when dragon health exists
- **Death = Disastrous Quality** — separate failure states planned (player/dragon/both die)
- **No Bond pattern pass** — Bond preview only
- **No anti-farming caps** on encounter deltas
- **No Bond resilience pass** — sync floor, instability resistance/recovery helpers exist but not wired
- **No natural Instability decay** out of combat
- **No exploration/story relationship events** applied
- **No save/load** for bond or session history
- Single test scene; no regional progression yet

---

## Planned Revision (not implemented)

**Outcome Rating** — rename/refocus Encounter Quality using **combined harm bands**:

| Band | Combined harm | Instability Δ (proposed) |
|------|---------------|--------------------------|
| Flawless | 0% | −2 |
| Safe | 1–25% | −1 |
| Rough | 26–50% | 0 |
| Severe | 51–75% | +2 |
| Disastrous | 76%+ or near-death | +4 |

Cooperation Rating and Sync deltas unchanged. See `docs/relationship_event_framework.md` → **Planned Revision**.

**Death handling (planned):** separate failure states outside routine outcome bands.

---

## Future Systems (not implemented)

- Dragon health + combined harm for outcome evaluation
- Bond pattern evaluation across sessions → Bond Strength
- `BondResilience` wiring (sync floor, instability resistance/recovery)
- Anti-farming / diminishing returns per encounter
- Natural Instability decay toward Normal band (16–35)
- Exploration and story events (session-level Bond)
- Enemy escape / dragon injured resolved outcomes

See `docs/relationship_event_framework.md` → **Future Systems**.

---

## Long-Term Progression Philosophy

| Axis | Role |
|------|------|
| **Character Level** | Personal power |
| **Relationship Stats** | Rider/dragon effectiveness together |
| **World Regions** | Difficulty progression |
| **Enemy Variants** | Strength progression within regions |

- Enemy scaling from **region, type, and variant** — not full player-level scaling
- Returning to earlier areas should **demonstrate growth**
- Relationship progression as important as character progression

See `docs/relationship_event_framework.md` → **Long-Term Progression Philosophy** and `docs/game_architecture.md`.

---

## Known Stable Systems (M7 + M8 + 9A)

- Player, dragon, bond tiers, alert/protect/assist, communication, enemies
- Relationship pipeline: events → track → classify (both ratings) → apply Sync/Instability
- Outcome-gated resolution; involved-enemy scoping; disengage grace
- Assist/protection separation; Bond protected at resolve
- Split playtest layout; F10 debug panel

---

## Recommended Next Milestone (9B+)

1. **Bond pattern pass** — session quality/cooperation trends → Bond Strength (with clamps)
2. **Outcome Rating revision** — combined harm bands when dragon health ready
3. **Wire Bond resilience** — sync floor, instability resistance/recovery into delta pass
4. **Anti-farming** — per-encounter caps (see framework §8)
5. **Dragon as combat target** — health, events, combined harm
6. **Natural Instability decay** — out-of-combat drift toward Normal band
7. **Save/load** — persist bond + relationship session history
8. **Regional progression** — world regions and enemy variants per progression philosophy

---

## Controls

| Action | Input |
|--------|--------|
| Toggle debug panel | **F10** |
| Spawn enemy nearby | **F1** |
| Spawn 3 enemies | **Shift+F1** |

(See M7 checkpoint for movement, combat, bond test keys, health keys.)
