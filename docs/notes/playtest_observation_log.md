# Playtest Observation Log

**Status:** Active — structured vertical slice playtest next; informal playtest complete  
**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest scenes:** `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn` (F6)  
**Authority:** Level 4 working journal — verify against Level 2 checkpoints before implementing  
**Homepage:** [`PROJECT_STATE.md`](../PROJECT_STATE.md)

---

## Purpose

Standard capture format for vertical slice playtest feedback. Each entry records what the player experienced, why it may have happened, a recommended response, and an explicit decision.

**Do not treat this log as mechanical source of truth.** Implementation follows [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) and domain checkpoints.

---

## Entry template

```
### Observation #N — (short title)

**Date:** YYYY-MM-DD · **Milestone:** … · **Scene:** TestWorld | VerticalSlice_Level_P1

**Observation:**  
What the player experienced.

**Analysis:**  
Why it may have happened (code/design reference if known).

**Recommendation:**  
Possible solution(s).

**Decision:** Implement Now | Future Polish | Future System | Reject | Needs More Testing
```

---

## Observations

### Observation #1 — Encounter summary blocks center view

**Date:** 2026-07-06 · **Milestone:** Informal Playtest · **Scene:** VerticalSlice_Level_P1 (expected in TestWorld too)

**Observation:**  
Encounter completion popup appears directly in the center of the screen. Player feedback: *"It feels a little in the way."*

**Analysis:**  
Polish Pass 1A places `EncounterSummaryPanel` at viewport center (`anchors_preset = 8`, 50% vertical anchor) in `scenes/ui/PlayerFeedbackUI.tscn`. Panel is ~384×184 px, visible ~2.6 s. Relationship toasts already use upper-center (`offset_top = 118`). Center placement maximizes readability for outcome text but overlaps the combat focal point where the player and nearest enemies typically are.

**Recommendation:**  
Trial upper-third placement (e.g. anchor vertical ~0.32–0.38) so summary remains readable without covering the player. Compare against area announce (top-center) and relationship toast positions to avoid stacking collisions. Low-risk presentation-only change in `PlayerFeedbackUI.tscn` / polish pass.

**Decision:** **Future Polish** — validate offset with a second playtest before moving; not in Informal Playtest implementation scope unless a quick A/B confirms improvement.

---

### Observation #2 — CC preview does not communicate weapon arc identity

**Date:** 2026-07-06 · **Milestone:** Informal Playtest · **Scene:** TestWorld · **Weapons:** Dagger / Sword / Polearm (debug 1/2/3)

**Observation:**  
Crowd-control preview indicator does not visually communicate weapon arcs equally well. Dagger feels appropriate; sword should read as a wider attack arc; polearm should read as the widest arc.

**Analysis:**  
Gameplay CC hitbox is a **circle** around the player (`crowd_control_radius` scales by profile: dagger **22**, sword **28**, polearm **36** in `weapon_profile_prototype.gd`). Telegraph draws a **360° pulsing circle** only (`combat_attack_telegraph.gd` → `_draw_crowd_control_telegraph`). Radius differences exist but are subtle (~29% dagger→sword, ~29% sword→polearm). Player expectation references **directional arc** language (like focused cone telegraphs), which CC preview does not use. Focused attack cones share the same half-angle across weapons today — only CC radius differentiates weapons visually.

**Recommendation:**  
**Combat Readability Polish** (not balance): add weapon-scaled CC telegraph shape — e.g. forward-facing arc wedge or ellipse whose angular width scales with weapon identity (dagger narrow, sword medium, polearm wide) while keeping live hitbox unchanged until a deliberate combat pass. Optional: stronger radius contrast or windup/impact ring styling per weapon. Document in combat feel / polish checkpoint before implementation.

**Decision:** **Future Polish** — readability improvement; defer until post–Informal Playtest or a dedicated combat readability pass.

---

### Observation #3 — Placeholder audio lacks action-specific identity

**Date:** 2026-07-06 · **Milestone:** Informal Playtest (post Audio Pass 1A sign-off)

**Observation:**  
Placeholder audio is functioning but generic — similar hit sounds, similar dragon sounds, shared procedural effects across events.

**Analysis:**  
Expected by design. Audio Feedback Pass 1 ships six procedural WAVs reused across the event catalog (`game_audio_catalog.gd`, [`audio_placeholder_assets.md`](../audio/audio_placeholder_assets.md)). Pass 1A validated **routing, timing, and mix readability** — not final sound identity. Per-weapon and per-action splits are documented for **Audio Feedback Pass 2**.

**Recommendation:**  
Replace catalog stream mappings incrementally in Audio Pass 2 (per-weapon swings, distinct hit layers, dragon assist vs protect motifs). No asset work during Informal Playtest.

**Decision:** **Future System** (Audio Pass 2 per roadmap) — **Reject** asset replacement now.

---

## Milestone cross-reference

| Milestone | Role for this log |
|-----------|-------------------|
| **Informal Playtest** | Complete — observations #1–#3 captured |
| **Combat Foundation** | Developer playtesting complete (stakes / survivability / identity) |
| **Structured Vertical Slice Playtest** (next) | Formal fifteen-minute evaluation — extend this log |
| **Audio Feedback Pass 2** | Placeholder asset replacement (Obs #3) |

---

## Related documents

| Document | Role |
|----------|------|
| [`PROJECT_STATE.md`](../PROJECT_STATE.md) | Current milestone |
| [`project_checkpoint_vertical_slice_polish_1A.md`](../checkpoints/project_checkpoint_vertical_slice_polish_1A.md) | Encounter summary / HUD feedback |
| [`project_checkpoint_combat_feel_v1.md`](../checkpoints/project_checkpoint_combat_feel_v1.md) | Melee telegraphs / weapon profiles |
| [`project_checkpoint_audio_feedback_pass1.md`](../checkpoints/project_checkpoint_audio_feedback_pass1.md) | Audio architecture + Pass 1A sign-off |
