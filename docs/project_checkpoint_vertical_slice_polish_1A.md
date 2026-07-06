# Dragon Rider RPG — Vertical Slice Polish Pass 1A Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn` (F6)  
**Design constitution:** [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md)  
**Relationship pipeline:** [`project_checkpoint_milestone9A.md`](project_checkpoint_milestone9A.md)  
**Combat depth reference:** [`project_checkpoint_combat_depth_1B.md`](project_checkpoint_combat_depth_1B.md)

**Status:** **IN PROGRESS — Pass 1A implemented** (player feedback layer live; playtest validation pending)  
**UI Cleanup:** [`project_checkpoint_ui_cleanup_pass1.md`](project_checkpoint_ui_cleanup_pass1.md) — HUD layout, Developer Mode, area announce (Pass 1)  
**Scope:** Player communication only — no gameplay, balance, AI, or relationship math changes.  
**Date:** 2026-05-29

---

## Goals

Vertical Slice Polish Pass 1A makes **existing gameplay understandable** to a first-time player without opening the F10 debug panel.

The player should understand:

- **What happened** — encounter ended, hit landed, enemy staggered or resisted
- **Why it happened** — outcome stress vs teamwork are communicated separately
- **What the dragon is doing** — Following, Waiting, Protecting, Assisting
- **How well they worked together** — direction of relationship change, not raw formulas

**Not in scope:** audio, animations, dragon dialogue, new combat mechanics, shield systems, hiding dev UI (Pass 1B+).

---

## Milestone Summary

| Part | Feature | Status |
|------|---------|--------|
| 1 | Encounter summary panel (~2.6 s) | **Live** |
| 2 | Relationship stat-change toasts | **Live** |
| 3 | Dragon status chip | **Live** |
| 4 | Target Focus readability (visual only) | **Live** |
| 5 | Combat floating feedback (Hit / Staggered / Resisted / Retreating) | **Live** |
| 6 | HUD review + player layer added | **Live** |
| 7 | F10 information audit | **Documented below** |

---

## Implemented Player Feedback

### Encounter summary (Part 1)

Center-screen panel on **`RelationshipSystem.encounter_result_ready`**. Visible ~**2.6 seconds** with fade in/out.

| Line | Source | Player text examples |
|------|--------|----------------------|
| Title | Fixed | **Encounter Complete** |
| Outcome | `EncounterQualityClassifier` (unchanged logic) | Flawless / Clean / Fair / Rough / Dangerous Outcome |
| Teamwork | `CooperationRatingClassifier` | Excellent Teamwork / Poor Coordination / Independent Fight |
| Relationship | Applied Sync + Instability deltas | Relationship Improved / Strained / Steady / Partnership Stronger |

No raw percentages, encounter IDs, or internal counters.

**Label mapping:** `scripts/ui/player_feedback_labels.gd` → `PlayerFeedbackLabels`

### Relationship feedback (Part 2)

On **`RelationshipSystem.relationship_stats_applied`**, a short toast below the top HUD shows direction only when deltas are non-zero:

- `↑ Sync` / `↓ Sync`
- `↑ Instability` / `↓ Instability`

Uses existing applied deltas from `ProposedDeltaGenerator.get_stat_deltas()` — **no new calculations**.

### Dragon status (Part 3)

Subtle chip below player HP (`Dragon: Following`).

| Internal `DragonState` | Player label |
|------------------------|--------------|
| FOLLOWING, ALERT | Following |
| WAITING | Waiting |
| PROTECTING | Protecting |
| ASSISTING | Assisting |
| HESITATING | Hesitating |

Updates on `dragon.state_changed`. Does not expose radii, delays, command queue, or threat distances.

### Target Focus readability (Part 4)

Visual-only tweaks — **mechanics unchanged**:

| Visual | Change |
|--------|--------|
| **Blue focus ring** | Dark outer outline + slightly thicker arc for contrast on busy backgrounds |
| **Cyan likely-target preview** | Lighter, thinner ring — reads as “preview” vs “chosen lock” |

Distinction preserved: blue = player-chosen focus; cyan = likely hit if you attack now.

### Combat readability (Part 5)

Screen-space floaters on `MeleeAttack.attack_hit` (observation only — reads enemy state after hit resolves):

| Floater | When |
|---------|------|
| **Hit!** | Any successful player melee hit |
| **Staggered** | Enemy reports `is_staggered()` after hit |
| **Resisted** | Brute archetype, no stagger after hit |
| **Retreating** | Scout archetype, not engaging after hit |

Existing telegraphs, hit sparks, and flash feedback unchanged.

---

## HUD Layout (Part 6)

| Element | Location | Audience |
|---------|----------|----------|
| **Player HP** | Top-left | Player |
| **Dragon status chip** | Top-left, below HP | Player |
| **Encounter summary** | Center (transient) | Player |
| **Relationship toast** | Upper-center (transient) | Player |
| **Combat floaters** | At hit world position | Player |
| **Off-screen enemy arrows** | Screen edges | Player |
| **Help panel (BondTestHelpUI)** | Developer Mode (F10) — bottom-left overlay | **Dev** |
| **Debug panel (BondDebugUI)** | Developer Mode (F10) — right overlay | **Dev** |
| **F11 telegraph overlay** | Toggle only (F11) | **Dev** |

> **UI Cleanup Pass 1:** Help and debug panels no longer occupy permanent layout space. See [`project_checkpoint_ui_cleanup_pass1.md`](project_checkpoint_ui_cleanup_pass1.md).

**Review notes:**

- Bond/Sync/Instability **numbers** remain in BondTestHelpUI (Developer Mode) — not duplicated in player HUD.
- **PlayerHud** unified top-left: HP bar + dragon status.
- **Area announce** replaces permanent zone label (slice level).

---

## F10 Debug Panel Audit (Part 7)

| F10 item | Classification |
|----------|----------------|
| Encounter Complete + Outcome + Teamwork + Relationship direction | **Promoted** → encounter summary |
| Applied Sync / Instability direction | **Promoted** → relationship toast |
| Dragon state (simplified) | **Promoted** → dragon status chip |
| Bond Strength / Sync / Instability raw values | **Developer-only** |
| Encounter counters (assists, cancels, damage, IDs) | **Developer-only** |
| Involved enemy count, disengage flags, excellent-eligible | **Developer-only** |
| Last resolved debug summary strings | **Developer-only** |
| Bond Δ preview (NOT APPLIED) | **Developer-only** |
| Session quality history, recent event log | **Developer-only** |
| Protection radius, alert range, threat distance | **Developer-only** |
| Command delay, pending command internals | **Developer-only** |
| Bond tier progress, future resilience stats | **Developer-only** |
| Dragon Thought / communication catalog debug | **Developer-only** (world bubble remains separate) |
| F11 range cones / focus debug lines | **Developer-only** |
| BondTestHelpUI movement/focus readouts | **Developer-only** |
| Spawn keys (F1), bond cheats (Ctrl+numbers) | **Developer-only** |

---

## Implementation Files

| File | Role |
|------|------|
| `scripts/ui/player_feedback_labels.gd` | Player-facing label mapping from existing classifiers/deltas |
| `scripts/ui/player_feedback_ui.gd` | Encounter panel, toasts, dragon chip, combat floaters |
| `scenes/ui/PlayerHud.tscn` | Unified top-left HUD (replaces separate HP + dragon chip) |
| `scripts/ui/player_hud.gd` | HP + dragon status bind |
| `scripts/ui/developer_mode_controller.gd` | F10 Developer Mode overlays |
| `scripts/world/test_world.gd` | Binds feedback UI in TestWorld shell |
| `scripts/world/vertical_slice_world_shell.gd` | Binds feedback UI in slice shell |
| `scenes/world/TestWorldGame.tscn` | Instanced PlayerFeedbackUI |
| `scenes/world/VerticalSliceLevelP1Game.tscn` | Instanced PlayerFeedbackUI |
| `scripts/combat/combat_target_focus_indicator.gd` | Focus ring contrast (visual) |
| `scripts/combat/combat_focused_target_preview.gd` | Preview ring contrast (visual) |

**Intentionally unchanged:** `RelationshipSystem`, classifiers, `BondSystem`, dragon AI, enemy AI, combat math, Target Focus logic, camera, movement.

---

## Remaining Polish Work

### Pass 1A (this milestone)

- [ ] Playtest: first-time player understands encounter outcome without F10
- [ ] Playtest: dragon status chip matches perceived behavior
- [ ] Playtest: floaters not cluttered in multi-enemy fights
- [ ] Tune summary/toast timing if fights feel back-to-back

### Pass 1B — Dragon Personality (recommended next)

- Dragon dialogue / communication bubble tied to partnership moments (not debug catalog dumps)
- Hide BondTestHelpUI + F10 panel behind debug flag in player builds
- Optional: qualitative Sync/Instability strip (no numbers) when out of combat

### Later polish

- Combat audio · minimal attack animation · Outcome Rating rename (Flawless/Safe/Rough) when design revision lands
- Death / retry flow · save at slice end

---

## Playtest Checklist (Pass 1A)

1. Finish an encounter — summary appears ~2–3 s with readable outcome + teamwork + relationship direction  
2. Win cleanly with dragon help — “Relationship Improved” / “Excellent Teamwork” feel fair  
3. Win alone or with cancels — teamwork and relationship lines differ appropriately  
4. Hit a Brute mid-commit — “Resisted” appears without opening F10  
5. Stagger a Raider — “Staggered” floater appears  
6. Dragon protects / assists — status chip updates to Protecting / Assisting  
7. Blue focus ring vs cyan preview — still distinguishable in combat  
8. F10 still available for developers — not required for basic understanding  

---

## Related Documents

| Document | Update |
|----------|--------|
| [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md) | Roadmap — Pass 1A begun |
| [`combat_feel_notes.md`](combat_feel_notes.md) | Pointer to player feedback layer |
