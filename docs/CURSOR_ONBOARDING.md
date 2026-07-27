# Cursor Onboarding

**Purpose:** Standard onboarding for every new Cursor chat and developer on Dragon Rider RPG  
**Engine:** Godot 4.6 - **Language:** GDScript  
**Start here:** [`PROJECT_STATE.md`](./PROJECT_STATE.md) -- active development homepage

---

## 1. Documents to read

### Always read (in order)

1. [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) -- this file  
2. [`PROJECT_STATE.md`](./PROJECT_STATE.md) -- active homepage: phase, milestone, focus, roadmap  
3. [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md) -- authority rules  
4. [`vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) -- slice design constitution  
5. [`world_design_framework.md`](./design/world_design_framework.md) -- world / exploration constitution (when designing places, Areas, dungeons, traversal)  

### Read for the task domain

| Task type | Add these checkpoints |
|-----------|----------------------|
| Combat / melee / enemies | `checkpoints/project_checkpoint_combat_feel_v1.md`, `checkpoints/project_checkpoint_combat_depth_1B.md` |
| World / Areas / exploration design | `design/world_design_framework.md`, `design/exploration_framework.md`, `design/representative_area_brief.md` |
| Relationship / bond | `checkpoints/project_checkpoint_milestone9A.md`, `design/relationship_event_framework.md` (Current Implementation only) |
| Player UI / feedback | `checkpoints/project_checkpoint_vertical_slice_polish_1A.md` |
| Dev shell / F10 / viewport | `checkpoints/project_checkpoint_developer_experience_pass1.md` |
| Audio | `checkpoints/project_checkpoint_audio_feedback_pass1.md`, `audio/audio_placeholder_assets.md` |
| Slice level / encounters (combat sandbox) | `level/vertical_slice_level_p1.md` |
| Cinderwatch Ridge / exploration Area | `level/cinderwatch_ridge.md`, `checkpoints/project_checkpoint_cinderwatch_graybox_pass1.md`, `design/representative_area_brief.md` |
| Informal playtest | `notes/playtest_observation_log.md` |

### Supporting context (as needed)

`notes/combat_feel_notes.md`, `design/combat.md`, `design/dragon_ai.md`, `design/game_architecture.md`, `design/technical_architecture.md`

### Do not use as current behavior

`historical/` -- Milestone 5-8 checkpoints, `project_checkpoint.md`, `vertical_slice_plan.md` -- **historical only** unless explicitly investigating history.

---

## 2. Reading order summary

```
Onboarding -> Project State -> Hierarchy -> Design Constitution
                    v
            Domain checkpoint(s)
                    v
            Supporting docs (if needed)
```

**Do not** read historical milestones before current checkpoints.

---

## 3. How to summarize the project

After reading, provide a concise summary covering:

1. **Current Project Revision** and **development phase** -- from `PROJECT_STATE.md`  
2. **Current milestone** and **current focus** -- from `PROJECT_STATE.md`  
3. **Source-of-truth docs** -- hierarchy Level 1-2 for the task  
4. **Systems at a glance** -- live vs deferred (pointers only)  
5. **Next planned milestone** -- from roadmap unless user overrides  
6. **Doc conflicts noticed** -- if any remain after hierarchy rules  

Keep summaries **short**. Link to checkpoints for detail.

**Wait for user instruction** before code changes unless the user explicitly requests implementation in the same message.

---

## 4. How to determine source of truth

Use [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md) conflict rules:

| Question type | Wins |
|---------------|------|
| Slice scope / pacing / defer list | `design/vertical_slice_design_v1.md` |
| World / Area / exploration philosophy | `design/world_design_framework.md` |
| Area authoring / graybox / review | `design/exploration_framework.md` |
| Live melee numbers / pass behavior | `checkpoints/project_checkpoint_combat_feel_v1.md` |
| Stance / Target Focus | `checkpoints/project_checkpoint_combat_depth_1B.md` |
| Sync / Instability / encounter resolve | `checkpoints/project_checkpoint_milestone9A.md` |
| Event catalog philosophy | `design/relationship_event_framework.md` |
| Audio events / wiring | `checkpoints/project_checkpoint_audio_feedback_pass1.md` |
| F10 / viewport / window | `checkpoints/project_checkpoint_developer_experience_pass1.md` |
| Player-facing HUD feedback | `checkpoints/project_checkpoint_vertical_slice_polish_1A.md` |
| Graybox layout / encounters (combat sandbox) | `level/vertical_slice_level_p1.md` |
| Cinderwatch validation / next correction | `checkpoints/project_checkpoint_cinderwatch_graybox_pass1.md` |

**Code overrides stale docs** -- update the checkpoint after verifying in repo.

---

## 5. How to identify outdated documentation

Signs a doc may be stale:

- Window size **1600×900** or permanent **1200+400 split** -> superseded by Developer Experience Pass 1 (**2560×1440**, F10 docked **420px** sidebar)  
- References to `developer_mode_controller.gd` -> superseded by `playtest_shell.gd`  
- "Combat audio: Not implemented" in Combat Feel v1 -> superseded by Audio Feedback Pass 1 (placeholder architecture live)  
- "Enemy archetype variants: Not implemented" in Combat Feel v1 -> superseded by archetype Pass 1 on slice level  
- "Combat Depth: not implemented" in level doc roadmap table -> superseded by Combat Depth 1B  
- Overlay help/debug "bottom-left / right" in Polish 1A -> superseded by docked right sidebar (Developer Experience)  
- Milestone 8 or earlier for **live Sync/Instability** -> use Milestone 9A  

When unsure: check [`PROJECT_STATE.md`](./PROJECT_STATE.md) -> **Documentation debt** and this section.

---

## 6. Rules for future documentation updates

1. **Documentation-only milestones** may touch `docs/` only -- no gameplay/scene/script changes unless the milestone says otherwise.  
2. **One checkpoint per domain per pass** -- e.g. `project_checkpoint_audio_feedback_pass1.md`.  
3. **Update `PROJECT_STATE.md`** when a milestone completes or roadmap shifts.  
4. **Update `DOCUMENTATION_HIERARCHY.md`** when adding or retiring a checkpoint.  
5. **Do not rewrite historical checkpoints** -- add a supersession banner and link forward.  
6. **Modern docs describe current behavior**; historical docs describe past state.  
7. **Cross-link** instead of duplicating tables across docs.  
8. **Design constitution** changes only for slice *intent* changes, not numeric tuning.  
9. Prefer amending the **owning checkpoint** over scattering notes in journals.  
10. After implementation milestones: update checkpoint + `PROJECT_STATE` + relevant section of `design/vertical_slice_design_v1.md` roadmap.  
11. New checkpoints live in `docs/checkpoints/`; design docs in `docs/design/`.

---

## Standard Milestone Handoff

Every milestone should end with a reusable **Milestone Package** containing:

1. **Milestone Review** -- what was done, pass/fail, files touched, limitations  
2. **Next Milestone** -- name and one-line goal from `PROJECT_STATE.md` roadmap  
3. **Copyable Cursor Prompt** -- ready to paste into a new Cursor chat  
4. **Copyable GPT Handoff Prompt** -- ready to paste into GPT for planning/review  

### Cadence (GPT ↔ Cursor)

```
User provides current project state or Cursor implementation report
        v
GPT reviews milestone status
        v
GPT recommends next roadmap milestone (from PROJECT_STATE.md)
        v
GPT produces copyable Cursor prompt
        v
Cursor implements (reads onboarding -> PROJECT_STATE -> checkpoints)
        v
User provides Cursor implementation report
        v
GPT reviews implementation
        v
GPT produces next Cursor prompt + GPT handoff prompt
```

**Formatting rule:** Cursor prompts and GPT handoff prompts must always appear in **copyable plain-text fenced code blocks** (triple backticks), not inline prose.

### Milestone Package template

```
## Milestone Review
(summary)

## Next Milestone
(name + goal)

## Cursor Prompt
(copyable block)

## GPT Handoff Prompt
(copyable block)
```

---

## 7. Rules for milestone checkpoints

Checkpoints should include:

- **Status** (IMPLEMENTED / IN PROGRESS / PLANNED)  
- **Scope** and explicit **not in scope**  
- **Playtest checklist** when behavior is player-facing  
- **Related documents** table with supersession notes  
- **Implementation files** (when code exists) -- paths only, no behavior duplication from code  

Naming: `project_checkpoint_<domain>_<pass>.md`

When a checkpoint is partially superseded (e.g. Milestone 9A layout), **banner the section** -- do not delete historical content.

---

## 8. Expected workflow

```
New Cursor chat
      v
Read onboarding -> PROJECT_STATE -> hierarchy -> domain checkpoints
      v
Summarize project (wait for instruction unless implementation requested)
      v
Receive milestone / task
      v
Implement (gameplay milestones only -- respect scope guards)
      v
Explain what changed and why
      v
Update documentation (checkpoint + PROJECT_STATE + hierarchy if needed)
      v
Git commit (when user requests)
      v
Begin next milestone in a fresh Cursor chat (recommended for large passes)
```

### Scope guards (default)

- **Do not** change combat balance, relationship math, or AI unless the milestone requires it.  
- **Do not** commit unless the user asks.  
- **Prototype in TestWorld, ship experience in slice level** -- per design constitution.  
- **Preserve relationship safeguards** -- Bond protected at resolve, split ratings, disengage grace.

---

## 9. Planned roadmap

Authoritative sequence lives in [`PROJECT_STATE.md`](./PROJECT_STATE.md) -> **Next Planned Milestones**. Do not invent beyond:

```
Combat Foundation chapter        <- complete
  (Combat Audio - Combat Stakes - Dragon Survivability - Enemy Combat Identity)
        v
World Design Framework (+ Rev 1A) <- complete
        v
Representative Area Design Brief <- complete (Cinderwatch Ridge)
        v
Exploration Framework Pass 1     <- complete
        v
Cinderwatch Ridge Graybox Pass 1 <- implemented; validation FAILED
        v
Cinderwatch Identity and Access Correction <- next
        v
Documentation Cleanup Pass 2     (future)
```

Post-slice systems (Bond pattern pass, Combat Depth Phase C+, full-game pillars) are in checkpoints and [`vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) Sec. 15 -- not the immediate sequence unless `PROJECT_STATE.md` is updated.

---

## Quick links

- [`PROJECT_STATE.md`](./PROJECT_STATE.md) -- **active development homepage**  
- [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md) -- authority rules  
- [`vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) -- design constitution
