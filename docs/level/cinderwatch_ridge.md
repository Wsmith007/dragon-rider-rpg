# Cinderwatch Ridge -- Graybox Implementation Notes

**Scene (shell):** `res://scenes/world/Cinderwatch_Ridge.tscn`  
**Game root:** `res://scenes/world/CinderwatchRidgeGame.tscn`  
**Brief:** [`representative_area_brief.md`](../design/representative_area_brief.md)  
**Production:** [`exploration_framework.md`](../design/exploration_framework.md)  
**Constitution:** [`world_design_framework.md`](../design/world_design_framework.md)  
**Validation checkpoint:** [`project_checkpoint_cinderwatch_graybox_pass1.md`](../checkpoints/project_checkpoint_cinderwatch_graybox_pass1.md)  

**Status:** Graybox Pass 1 **implemented** -- experiential validation **FAILED** -- Identity and Access Correction required  

Launch: **Emberbound Playtest** -> **Cinderwatch Ridge**

`VerticalSlice_Level_P1` remains the combat teaching sandbox.

---

## Do not treat as approved

This graybox exists to expose problems. It is **not** an approved Representative Area and is **not** ready for Graybox Pass 2.

See the validation checkpoint for confirmed problems and next milestone naming.

---

## What exists (implementation inventory)

| Piece | Location |
|-------|----------|
| Shell | `scenes/world/Cinderwatch_Ridge.tscn` |
| Game | `scenes/world/CinderwatchRidgeGame.tscn` |
| Area logic | `scripts/world/cinderwatch_ridge.gd` |
| Geometry | `scripts/world/cinderwatch_graybox_geometry.gd` |
| Shell wiring | `scripts/world/cinderwatch_world_shell.gd` |
| Menu | LaunchMenu **Cinderwatch Ridge** |

### Landmarks / zones (as coded)

Western Approach, Scrub Flank, Broken Signal Span, Occupied Road, Hearth Grove, Ashroad Watch, Waystation Hold, Old Watch Gate, Ridge Outlook, Ember-scar Stone.

### Dragon staging

Temporary WAIT at span / stone (not validated as Core Memory success).

### Encounters

Scrub Ambush (Scout), Occupied Road (Raider), Waystation Hold (2x Raider), Old Watch Gate (Brute), Outlook Approach (Scout + Raider).

---

## Validation summary

> Cinderwatch Ridge Graybox Pass 1 is implemented but has not passed experiential validation.

Confirmed issues (detail in checkpoint): sandbox resemblance, weak ridge identity, Signal Span hard-blocker feel, unclear/inaccessible alternate routes, Core Memory not fairly judgeable until access/identity are fixed.

---

## Next milestone

**Cinderwatch Ridge -- Graybox Identity and Access Correction Pass**

Not Graybox Pass 2.

---

## Document history

| Date | Change |
|------|--------|
| 2026-07-26 | Graybox Pass 1 notes |
| 2026-07-26 | Identity Pass 4A attempt documented in prior draft |
| 2026-07-26 | Aligned to validation-failed checkpoint -- correction required |
