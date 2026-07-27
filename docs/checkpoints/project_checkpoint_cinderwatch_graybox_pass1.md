# Cinderwatch Ridge Graybox Pass 1 -- Validation Checkpoint

**Status:** IMPLEMENTED -- experiential validation **FAILED** -- correction required  
**Date:** 2026-07-26  
**Pass:** Exploration & Dungeon Pass 1 / Graybox Pass 1 (checkpoint wrap-up)  
**Engine:** Godot 4.6 - GDScript  

**Agent entry:** [`PROJECT_STATE.md`](../PROJECT_STATE.md)  
**Brief (authoritative fiction):** [`representative_area_brief.md`](../design/representative_area_brief.md)  
**Production:** [`exploration_framework.md`](../design/exploration_framework.md)  
**Constitution:** [`world_design_framework.md`](../design/world_design_framework.md)  
**Level notes:** [`cinderwatch_ridge.md`](../level/cinderwatch_ridge.md)

---

## Original Objective

Graybox Pass 1 was intended to prove that Cinderwatch Ridge could already feel like a memorable Emberbound place before art and polish.

Specifically:

| Goal | Intent |
|------|--------|
| **Place identity** | Ridge road, watch infrastructure, history -- not a combat classroom |
| **Natural navigation** | Landmarks, terrain, sightlines -- not UI or corridor labels |
| **Core Memory staging** | Dragon shared observation at the Broken Signal Span |
| **Dragon partnership** | Exploration presence, not combat-only utility |
| **Contextual encounters** | Occupy / guard / hunt -- not arena spawns |
| **Sandbox distinction** | Visually and structurally distinct from `VerticalSlice_Level_P1` |

Success criterion (Exploration Framework / brief): a first-time player can walk the graybox and say *"I understand what kind of place this is."*

---

## What Was Implemented

Factually present in the repository:

### Launch and scenes

| Item | Path |
|------|------|
| Launch menu entry | `scenes/LaunchMenu.tscn` + `scripts/ui/LaunchMenu.gd` -- **Cinderwatch Ridge** |
| Navigation constant | `scripts/core/playtest_navigation.gd` -- `CINDERWATCH_RIDGE_SCENE` |
| Playtest shell | `scenes/world/Cinderwatch_Ridge.tscn` |
| Gameplay root | `scenes/world/CinderwatchRidgeGame.tscn` |
| Shell wiring | `scripts/world/cinderwatch_world_shell.gd` |
| Area logic | `scripts/world/cinderwatch_ridge.gd` |
| Geometry | `scripts/world/cinderwatch_graybox_geometry.gd` |

### Landmarks and structure (as coded)

- Western Approach / ridge road ribbon  
- Scrub Flank  
- Broken Signal Span (ravine/void treatment attempted)  
- Ashroad Watch (tower / knoll representation)  
- Hearth Grove (refuge bowl, heal / safe zone)  
- Waystation Hold (scavenger props + Raider occupation)  
- Old Watch Gate (Brute)  
- Ridge Outlook (destination haze)  
- Ember-scar Stone (dragon staging)  

### Dragon staging

Temporary command WAIT at the span (and stone): toast / hold / recall. **Not** a permanent exploration AI system.

### Encounters (contextual labels)

| Encounter | Verb / role |
|-----------|-------------|
| Scrub Ambush | Hunt / Scout |
| Occupied Road | Occupy / Raider |
| Waystation Hold | Occupy / 2x Raider |
| Old Watch Gate | Guard / Brute |
| Outlook Approach | Patrol / Scout + Raider |

### Supporting documentation (planning)

- `docs/design/world_design_framework.md`  
- `docs/design/representative_area_brief.md`  
- `docs/design/exploration_framework.md`  
- `docs/level/cinderwatch_ridge.md`  

Combat sandbox preserved: `VerticalSlice_Level_P1` remains launchable separately.

---

## Initial Validation Result

> **Cinderwatch Ridge Graybox Pass 1 is implemented but has not passed experiential validation.**

The Area is playable as a separate scene from the combat sandbox, but it does **not** yet achieve the intended Area identity or access clarity required by the Representative Area Brief and Exploration Framework.

A terrain-first revision was attempted in-tree after the first graybox; that revision does **not** constitute a passed Identity Pass and must not be treated as approval.

---

## Confirmed Problems

Recorded from first review (do not soften):

1. **First visual impression is too similar to the combat sandbox.**  
2. **The Area reads as a game level** more than a believable ridge location.  
3. **Terrain and elevation do not create a sufficiently distinct spatial identity** (ridge road, exposed elevation, long sightlines remain unconvincing).  
4. **Broken Signal Span behaves like a hard blocker** -- wall / level-boundary feel rather than historical collapse with readable alternate access.  
5. **Intended alternate route is not sufficiently clear or accessible.**  
6. **Large portions of the intended experience cannot currently be reached or understood naturally.**  
7. **Core Memory cannot be judged fairly** until basic area access and spatial identity are corrected.

---

## What Has Still Been Proven

Useful outcomes despite failed validation:

- The project can host a **separate exploration Area** alongside the combat sandbox.  
- Cinderwatch can be **launched independently** from the playtest menu.  
- The **combat sandbox remains preserved** (`VerticalSlice_Level_P1`).  
- Approved design docs remain **authoritative** (World Design Framework, Representative Area Brief, Exploration Framework).  
- The graybox **exposes exactly the failure modes** the exploration review process was meant to catch (identity, access, sandbox resemblance).  
- Temporary dragon WAIT staging and encounter-context vocabulary are **retainable concepts** for the correction pass (revise as needed; do not treat as validated).

---

## Current Status

> **Cinderwatch Ridge Graybox Pass 1 -- Implemented, validation failed, correction required.**

Do **not** mark:

- Exploration & Dungeon Pass 1 complete  
- Cinderwatch complete or approved  
- Graybox Pass 1 approved  
- Representative Area Brief fulfilled  
- Area ready for Graybox Pass 2  

---

## Next Milestone

**Cinderwatch Ridge -- Graybox Identity and Access Correction Pass**

Goals:

1. Rebuild or substantially revise spatial identity.  
2. Differentiate the Area from the combat sandbox at first glance.  
3. Correct Broken Signal Span blockage / boundary feel.  
4. Make intended playable routes accessible and readable.  
5. Establish ridge-road terrain, elevation, landmarks, and sightlines.  
6. Revalidate first impression **before** content expansion or polish (before Graybox Pass 2).  

Do not begin that milestone in this checkpoint wrap-up.

---

## Related documents

| Document | Role after this checkpoint |
|----------|----------------------------|
| This file | Validation authority for Pass 1 outcome |
| [`cinderwatch_ridge.md`](../level/cinderwatch_ridge.md) | Implementation notes -- must agree validation failed |
| [`PROJECT_STATE.md`](../PROJECT_STATE.md) | Active homepage -- correction pass next |
| [`representative_area_brief.md`](../design/representative_area_brief.md) | Fiction still authoritative; not fulfilled by current graybox |

---

## Document history

| Date | Change |
|------|--------|
| 2026-07-26 | Validation checkpoint -- Pass 1 implemented; experiential validation failed; correction required |
