# Dragon Rider RPG — Combat Stakes Pass 1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** LaunchMenu · `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn`  
**Design constitution:** [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md)  
**Related:** [`project_checkpoint_combat_feel_v1.md`](./project_checkpoint_combat_feel_v1.md) · [`project_checkpoint_vertical_slice_polish_1A.md`](./project_checkpoint_vertical_slice_polish_1A.md)  
**Documentation:** [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md)  
**Status:** **IMPLEMENTED — baseline stakes + critical feedback + dragon survivability foundation**  
**Date:** 2026-07-25

---

## Original Issues

- Player max HP **1000** made individual enemy hits (Scout **8**, Raider **12**, Brute **18**) feel like noise (~1% per hit).
- Low health had almost no emotional urgency beyond a relationship critical flag at 25%.
- Damage was hard to judge from the HUD (instant bar update, always-blue fill).
- Dragon had **no** survivability state for future knockout / rescue design.

Enemy role redesign and broad combat rebalancing are **out of scope**. This pass establishes readable danger and foundations.

---

## Health Philosophy (Pass 1)

Prefer **small, readable integers** while preserving approximate relative ratios (~÷10).

### Proposed then implemented baseline

| Stat | Before | After |
|------|--------|-------|
| Player max HP | 1000 | **100** |
| Scout HP / damage | 85 / 8 | **9 / 1** |
| Raider HP / damage | 150 / 12 | **15 / 1** |
| Brute HP / damage | 280 / 18 | **28 / 2** |
| Sword focused / CC | 29 / 12 | **3 / 1** |
| Dagger focused / CC | 18 / 8 | **2 / 1** |
| Polearm focused / CC | 19 / 10 | **2 / 1** |
| Dragon strike | 22 | **2** |
| Encounter `REFERENCE_MAX_HP` | 1000 | **100** |
| Encounter `MEANINGFUL_DAMAGE` | 20 | **2** |
| Debug F5–F7 step | 10 | **5** |

Hits to empty player HP (no heal): Scout **100**, Raider **100**, Brute **50**. Individual hits are now ~1–2% of pool and visually obvious.

Relationship critical ratio remains **≤ 25%** of max (`RELATIONSHIP_CRITICAL_HP_RATIO`).

---

## Critical Health Feedback

`CriticalHealthFeedback` (`scripts/ui/critical_health_feedback.gd`) — full-screen vignette CanvasLayer.

| Tier | Ratio (of max) | Presentation |
|------|----------------|--------------|
| Healthy | > 50% | No vignette |
| Wounded | ≤ 50% | Soft red edge |
| Critical | ≤ 25% | Stronger pulsing vignette + soft warning cue |
| Near Death | ≤ 12% | Maximum vignette pulse + faster cue |

Thresholds are `@export` on the overlay (not magic numbers buried in HUD).

Audio: `GameAudioEvent.Event.PLAYER_CRITICAL_WARNING` uses placeholder `heavy_thud.wav` at low volume / pitch as a temporary heartbeat stand-in until a dedicated asset exists.

HUD bar: color shifts by the same ratio bands; fill width tweens on change (~0.14 s).

---

## Damage Readability

- HP label remains `"current / max HP"` with rounded ints.
- Bar fill animates on damage/heal.
- Bar color communicates danger without extra widgets.
- Existing player red hit flash retained (no new floaters).

---

## Dragon Survivability Foundation (no knockout gameplay yet)

`DragonSurvivability` node on `Dragon.tscn` (`scripts/dragon/dragon_survivability.gd`):

| Concept | Pass 1 |
|---------|--------|
| `max_health` / `current_health` | Config present (default **40**) |
| States `ACTIVE` / `KNOCKED_OUT` | Enum + signal; no auto transition |
| `receive_damage` / `begin_rescue` | Stubs for future wiring |
| Sync penalty / instability on KO | Exported amounts; **not applied** yet |

### Future dragon survivability roadmap

1. Route selected enemy / hazard damage into `DragonSurvivability.receive_damage`.
2. At zero HP → `KNOCKED_OUT`: pause aggressive assist/protect; apply Sync penalty + Instability bump.
3. Player-initiated rescue interaction (approach + hold / interact) → revive with partial HP.
4. HUD chip shows dragon HP / KO state.
5. Optional Bond-gated revive speed / KO resistance.

**Not in this pass:** revival gameplay, rescue prompts, Sync/Instability application, dragon HP HUD.

---

## Deferred Systems

- Full combat rebalance / enemy AI redesign
- Dedicated heartbeat / breathing audio assets
- Screen desaturation / camera shake
- Dragon knockout + rescue loop
- Death / retry flow
- Inventory, dialogue, menus

---

## Implementation Files

| File | Role |
|------|------|
| `scripts/player/player.gd` | Player max HP 100 |
| `scripts/world/vertical_slice_archetype_presets.gd` | Enemy HP/damage baseline |
| `scripts/enemies/enemy.gd` | Default enemy HP/damage |
| `scripts/combat/weapon_profile_prototype.gd` | Weapon damage scale |
| `scripts/player/player_melee_attack.gd` | Default melee damage |
| `scripts/dragon/dragon_strike_behavior.gd` | Strike damage |
| `scripts/relationship/encounter_quality_classifier.gd` | Reference HP |
| `scripts/relationship/relationship_encounter_summary.gd` | Meaningful damage |
| `scripts/ui/health_debug_controls.gd` | Debug step 5 |
| `scripts/ui/player_hud.gd` | Bar tween + danger colors |
| `scripts/ui/critical_health_feedback.gd` | Vignette + warning pulse |
| `scenes/ui/CriticalHealthFeedback.tscn` | Overlay scene |
| `scripts/dragon/dragon_survivability.gd` | KO foundation |
| `scenes/dragon/Dragon.tscn` | Survivability node |
| `scenes/world/TestWorldGame.tscn` / `VerticalSliceLevelP1Game.tscn` | Overlay instance |
| Audio event/catalog/service | `PLAYER_CRITICAL_WARNING` |

---

## Playtest Checklist

- [ ] Scout / Raider / Brute hits visibly move the HP bar
- [ ] At ≤50% / ≤25% / ≤12% vignette intensity steps correctly
- [ ] Healing / F5 clears vignette when above thresholds
- [ ] Combat, dragon AI, and developer shortcuts still work
- [ ] No knockout / revival behavior appears yet

---

## Final Status

**IMPLEMENTED** for Pass 1 goals: readable health baseline, critical feedback, damage readability, dragon survivability foundation. Further enemy balance waits until these systems are felt in play.
