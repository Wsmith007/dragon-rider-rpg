# Project State

**Active development homepage** -- understand the project in ~2 minutes, then follow links for detail.

| | |
|--|--|
| **Engine** | Godot 4.6 - GDScript |
| **Playtest** | `TestWorld.tscn` (systems) - `VerticalSlice_Level_P1.tscn` (combat sandbox) - `Cinderwatch_Ridge.tscn` (exploration graybox -- **not approved**) |
| **Last updated** | 2026-07-26 (Cinderwatch Graybox Pass 1 validation checkpoint) |

**New developer path:** [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) -> this file -> [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md) -> domain checkpoint for your task.

**Docs index:** [`README.md`](./README.md)

---

## Current Project Revision

**Exploration & Dungeon Pass 1 -- Cinderwatch Graybox Pass 1 (validation failed)**

Exploration planning documents are complete. Cinderwatch Ridge exists as a **playable first graybox** launched separately from the combat sandbox. **First experiential validation failed.** The Area is not approved and is not ready for Graybox Pass 2.

---

## Current Development Phase

**Vertical Slice -- Exploration era (correction pending)**

Combat Foundation remains a stable foundation. Exploration constitutions (World Design Framework, Exploration Framework, Representative Area Brief) remain authoritative. Cinderwatch implementation must be corrected before further expansion.

> **Combat should serve exploration rather than exploration serving combat.**

Design intent: [`vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) - World: [`world_design_framework.md`](./design/world_design_framework.md) - Production: [`exploration_framework.md`](./design/exploration_framework.md) - Brief: [`representative_area_brief.md`](./design/representative_area_brief.md)

---

## Current Milestone

**Cinderwatch Ridge Graybox Pass 1 -- Implemented, validation failed, correction required**

**Checkpoint:** [`project_checkpoint_cinderwatch_graybox_pass1.md`](./checkpoints/project_checkpoint_cinderwatch_graybox_pass1.md)

**Previous:** Exploration Framework Pass 1 - Representative Area Brief - World Design Framework Rev 1A - Combat Foundation

---

## Current Focus

1. Do **not** treat Cinderwatch as complete or Pass-2-ready  
2. Next work is **Graybox Identity and Access Correction** (see below)  
3. Keep `VerticalSlice_Level_P1` as combat regression sandbox  

---

## Next Planned Milestones

| Order | Milestone | What it is |
|-------|-----------|------------|
| 1-3 | World Design / Brief / Exploration Framework | **complete** (docs) |
| 4 | **Cinderwatch Graybox Pass 1** | Implemented -- **validation failed** |
| 5 | **Cinderwatch Ridge -- Graybox Identity and Access Correction Pass** | Fix identity, span access, routes (**next**) |
| 6 | **Graybox Pass 2** | Only after correction revalidation |
| 7 | **Documentation Cleanup Pass 2** | Future |

Do **not** skip to Graybox Pass 2.

### Confirmed problems (first review)

- First impression too similar to combat sandbox  
- Weak ridge / elevation identity  
- Broken Signal Span feels like a hard wall / level boundary  
- Alternate routes unclear or inaccessible  
- Large portions of intended experience unreachable or unclear  
- Core Memory not fairly judgeable until access/identity are fixed  

Detail: validation checkpoint.

---

## What this project is

Emberbound (Dragon Rider RPG) proves whether **rider-dragon partnership** is fun -- first in combat, then as a pair moving through a **persistent world of meaningful places**.

`TestWorld` = systems sandbox. `VerticalSlice_Level_P1` = combat teaching sandbox. `Cinderwatch_Ridge` = exploration graybox under correction (not approved).

---

## Where to read next

| I need to know... | Read |
|-----------------|------|
| Docs folder map | [`README.md`](./README.md) |
| Authority rules when docs disagree | [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md) |
| Agent / Cursor workflow | [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) |
| Slice scope, pacing, defer list | [`vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) |
| World / Areas / exploration philosophy | [`world_design_framework.md`](./design/world_design_framework.md) |
| How to author / review Areas | [`exploration_framework.md`](./design/exploration_framework.md) |
| Representative Area fiction (Cinderwatch) | [`representative_area_brief.md`](./design/representative_area_brief.md) |
| **Cinderwatch validation checkpoint** | [`project_checkpoint_cinderwatch_graybox_pass1.md`](./checkpoints/project_checkpoint_cinderwatch_graybox_pass1.md) |
| Cinderwatch implementation notes | [`cinderwatch_ridge.md`](./level/cinderwatch_ridge.md) |
| Combat sandbox graybox | [`vertical_slice_level_p1.md`](./level/vertical_slice_level_p1.md) |
| Playtest observations | [`playtest_observation_log.md`](./notes/playtest_observation_log.md) |

---

## Systems at a glance

| Area | Status | Detail in |
|------|--------|-----------|
| Combat Foundation (stakes, survivability, identity, audio) | Live / complete chapter | Combat checkpoints |
| World Design Framework | Rev 1A constitution | `design/world_design_framework.md` |
| Exploration Framework | Pass 1 complete (docs) | `design/exploration_framework.md` |
| Representative Area brief | Complete (docs) -- **not fulfilled by graybox** | `design/representative_area_brief.md` |
| **Cinderwatch Ridge graybox** | **Implemented -- validation failed** | checkpoint + `level/cinderwatch_ridge.md` |
| Vertical Slice P1 | Live combat sandbox | `level/vertical_slice_level_p1.md` |

---

## Recently completed

**Cinderwatch Graybox Pass 1 checkpoint** -- implemented; validation failed; correction required  

**Exploration planning triad** -- World Design Framework, Representative Area Brief, Exploration Framework  

**Combat Foundation chapter** -- Enemy Combat Identity, Dragon Survivability, Combat Stakes, Combat Audio  

---

## Known limitations

- Cinderwatch does not yet satisfy Representative Area Brief identity/access goals  
- Broken Signal Span access/identity problems block fair Core Memory evaluation  
- No inventory, dodge, magic, flight, or races in slice scope  
- Structured fifteen-minute combat playtest still a future gate on P1  

---

## Related

- [`README.md`](./README.md)  
- [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md)  
- [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md)  
- [`project_checkpoint_cinderwatch_graybox_pass1.md`](./checkpoints/project_checkpoint_cinderwatch_graybox_pass1.md)  
- [`world_design_framework.md`](./design/world_design_framework.md)  
- [`exploration_framework.md`](./design/exploration_framework.md)  
- [`representative_area_brief.md`](./design/representative_area_brief.md)  
- [`cinderwatch_ridge.md`](./level/cinderwatch_ridge.md)  
