# Dragon Rider RPG — Combat Stakes Pass 1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** LaunchMenu · `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn`  
**Design constitution:** [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md)  
**Related:** [`project_checkpoint_combat_feel_v1.md`](./project_checkpoint_combat_feel_v1.md) · [`project_checkpoint_vertical_slice_polish_1A.md`](./project_checkpoint_vertical_slice_polish_1A.md)  
**Documentation:** [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md)  
**Status:** **COMPLETE — validated damage/visual stakes; audio + swing + Brute impact fixed from playtest**  
**Date:** 2026-07-25

---

## Original Issues

- Player max HP **1000** made individual enemy hits (Scout **8**, Raider **12**, Brute **18**) feel like noise (~1% per hit).
- Low health had almost no emotional urgency beyond a relationship critical flag at 25%.
- Damage was hard to judge from the HUD (instant bar update, always-blue fill).
- Dragon had **no** survivability state for future knockout / rescue design.

Enemy role redesign and broad combat rebalancing are **out of scope**. This pass establishes readable danger and foundations.

---

## Initial ÷10 Experiment (first commit)

The first implementation scaled most combat numbers by approximately ÷10 for readable integers:

| Stat | Pre-pass | ÷10 experiment |
|------|----------|----------------|
| Player max HP | 1000 | **100** |
| Scout HP / damage | 85 / 8 | **9 / 1** |
| Raider HP / damage | 150 / 12 | **15 / 1** |
| Brute HP / damage | 280 / 18 | **28 / 2** |
| Weapon focused / CC | 18–29 / 8–12 | **2–3 / 1** |
| Dragon strike | 22 | **2** |

### Observed role-collapse

- Scout and Raider both dealt **1** → identical threat per hit (~100 hits to empty player HP).
- Brute only **2** → still ~50 hits; not an immediate threat.
- All crowd-control attacks collapsed to **1**.
- Dagger and polearm focused both **2**.
- Critical warning audio looped while remaining critical; HUD thresholds were hardcoded separately; feedback used `PROCESS_MODE_ALWAYS`.

The ÷10 pass kept numbers readable but did **not** create meaningful combat stakes.

---

## Revised Stakes Baseline (follow-up)

Keep player HP at **100**. Re-expand damage (and enemy HP) so roles are distinct. Do not blindly preserve old ratios if the old fight was too easy.

| Stat | Revised Pass 1 |
|------|----------------|
| Player max HP | **100** |
| Scout HP / damage | **24 / 6** |
| Raider HP / damage | **40 / 10** |
| Brute HP / damage | **72 / 18** |
| Default enemy HP / damage | **40 / 10** |
| Dagger focused / CC | **5 / 2** |
| Sword focused / CC | **8 / 4** |
| Polearm focused / CC | **6 / 3** |
| Dragon strike | **7** |
| Dragon survivability foundation HP | **40** (inert) |
| Encounter `REFERENCE_MAX_HP` | **100** |
| Encounter `MEANINGFUL_DAMAGE` | **6** |
| Debug F5–F7 step | **5** |

### Expected hits-to-defeat (code math; every hit lands; no heal)

| Matchup | Approx hits |
|---------|-------------|
| Scout → player (100 HP) | **~17** (100 / 6) |
| Raider → player | **10** (100 / 10) |
| Brute → player | **~6** (100 / 18) |
| Sword focused → Scout | **3** (24 / 8) |
| Sword focused → Raider | **5** (40 / 8) |
| Sword focused → Brute | **9** (72 / 8) |

Attack cadence / multi-enemy pressure still use existing timings and slice encounter layouts — this follow-up is numeric only.

Relationship critical ratio remains **≤ 25%** of max (`RELATIONSHIP_CRITICAL_HP_RATIO`).

---

## Critical Health Feedback

`CriticalHealthFeedback` is the **authoritative threshold source** (`wounded_ratio` / `critical_ratio` / `near_death_ratio`). `PlayerHud` calls `tier_for_ratio()` when bound.

| Tier | Ratio (of max) | Presentation |
|------|----------------|--------------|
| Healthy | > 50% | No vignette |
| Wounded | ≤ 50% | Soft red edge pulse |
| Critical | ≤ 25% | Stronger pulsing vignette + **one** transition warning |
| Near Death | ≤ 12% | Maximum vignette pulse + **one** stronger transition warning |

### Audio (transition-based)

- Enter Critical (from Healthy/Wounded): `PLAYER_CRITICAL_WARNING` once.
- Enter Near Death: `PLAYER_NEAR_DEATH_WARNING` once (distinct / louder placeholder).
- No continuous heartbeat timer while remaining in a tier.
- Re-entry after healing above a tier may play the warning again.
- Cooldown on GameAudio still prevents accidental stacking.

### Pause

`process_mode = PROCESS_MODE_PAUSABLE` — vignette pulse stops while the tree is paused. Overlay remains in the scene tree for visibility when appropriate.

HUD bar: color follows shared tiers; fill width tweens on change (~0.14 s); prior tween killed before a new one.

---

## Damage Readability

- HP label remains `"current / max HP"` with rounded ints.
- Bar fill animates on damage/heal.
- Bar color communicates danger without extra widgets.
- Existing player red hit flash retained (no new floaters).

---

## Dragon Survivability Foundation (inert)

`DragonSurvivability` on `Dragon.tscn` remains **config + stubs only**:

| Concept | Pass 1 |
|---------|--------|
| `max_health` / `current_health` | Config present (default **40**) |
| States `ACTIVE` / `KNOCKED_OUT` | Enum + signal; no auto transition |
| `receive_damage` / `begin_rescue` | Stubs — **no callers** in current gameplay |
| Sync / Instability on KO | Exported; **not applied** |

No knockout, revival, rescue, Sync, or Instability gameplay in this pass.

### Future dragon survivability roadmap

1. Route selected enemy / hazard damage into `DragonSurvivability.receive_damage`.
2. At zero HP → `KNOCKED_OUT`: pause aggressive assist/protect; apply Sync penalty + Instability bump.
3. Player-initiated rescue interaction → revive with partial HP.
4. HUD chip shows dragon HP / KO state.
5. Optional Bond-gated revive speed / KO resistance.

---

## Deferred Systems

- Full combat rebalance / enemy AI redesign
- Dedicated heartbeat / breathing audio assets
- Screen desaturation / camera shake
- Dragon knockout + rescue loop
- Death / retry flow
- Inventory, dialogue, menus

---

## Live Validation (developer playtest)

Confirmed by developer:

- [x] Damage baseline feels better; weapon identities remain distinct
- [x] Critical-health **visual** feedback (color + stronger pulse as HP drops) works
- [x] Existing dragon behavior did not regress
- [ ] Low-health **audio** — initially **failed** (inaudible); corrected in validation fix below
- [x] Swing whoosh felt too loud — reduced in validation fix
- [x] Brute impact feel — small stun/knockback bump in validation fix

Not claimed validated without further in-editor confirmation after this fix:

- Audible Critical / Near Death transition warnings after catalog fix
- Brute heavier hit-stun feel in multi-enemy fights

---

## Validation Fix — Critical Audio Root Cause

**Symptom:** Vignette tiers changed, but no warning was audible.

**Cause:** `PLAYER_CRITICAL_WARNING` / `PLAYER_NEAR_DEATH_WARNING` used `heavy_thud.wav` (source peak ~0.28) at **−10 / −4 dB** with pitch **~0.55 / ~0.48** on the **Combat** bus as positional SFX. Under louder weapon swings the cue was effectively silent.

**Fix:**

- Route warnings as **non-positional UI** bus cues (status, not world SFX).
- Raise catalog gain (Critical **+4 dB**, Near Death **+7 dB**) with near-normal pitch so the quiet placeholder reads clearly without looping.
- Still transition-only (no heartbeat loop).

---

## Validation Fix — Swing Volume

Centralized `SWING_VOLUME_TRIM_DB := -3.0` on weapon whoosh / swing / miss catalog paths only. Impacts unchanged. Hits remain more prominent than empty swings.

---

## Validation Fix — Brute Hit Impact

Archetype preset only (Scout/Raider unchanged):

| | Before | After |
|--|-------:|------:|
| `player_hit_knockback` | 32 | **40** |
| `player_hit_stagger` | 0.47 s | **0.62 s** |

Uses existing `apply_combat_hit_reaction` — no combat redesign.

---

## Implementation Files

| File | Role |
|------|------|
| `scripts/player/player.gd` | Player max HP 100 |
| `scripts/world/vertical_slice_archetype_presets.gd` | Enemy HP/damage + Brute hit reaction |
| `scripts/enemies/enemy.gd` | Default enemy HP/damage |
| `scripts/combat/weapon_profile_prototype.gd` | Weapon damage scale |
| `scripts/player/player_melee_attack.gd` | Default melee damage |
| `scripts/dragon/dragon_strike_behavior.gd` | Strike damage |
| `scripts/relationship/encounter_quality_classifier.gd` | Reference HP |
| `scripts/relationship/relationship_encounter_summary.gd` | Meaningful damage |
| `scripts/ui/health_debug_controls.gd` | Debug step 5 |
| `scripts/ui/player_hud.gd` | Bar tween + shared-tier colors |
| `scripts/ui/critical_health_feedback.gd` | Vignette + transition warnings |
| `scripts/audio/game_audio_event.gd` / catalog / service | Critical + near-death warning events; swing trim |
| `scripts/dragon/dragon_survivability.gd` | KO foundation (inert until Survivability Pass 1) |

---

## Final Status

**IMPLEMENTED** — Combat Stakes Pass 1 complete after validation fixes. Damage/visual stakes confirmed in playtest; critical audio + swing trim + Brute impact adjusted from that feedback. Dragon survivability gameplay is a **separate** milestone.
