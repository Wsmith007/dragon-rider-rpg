# Documentation Hierarchy

**Status:** Permanent reference — update when checkpoints are added or superseded  
**Engine:** Godot 4.6 · **Language:** GDScript  

**Entry points:** [`PROJECT_STATE.md`](./PROJECT_STATE.md) (active homepage) · [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) (agent workflow)

This document defines **which docs are authoritative** and **how to resolve disagreements**. For current phase, milestone, and roadmap, read `PROJECT_STATE.md` first.

---

## Folder layout

| Folder | Contents |
|--------|----------|
| **Root** | `PROJECT_STATE.md`, `CURSOR_ONBOARDING.md`, `DOCUMENTATION_HIERARCHY.md`, `README.md` |
| **`design/`** | Design constitution, frameworks, full-game vision |
| **`checkpoints/`** | Live system checkpoints (Level 2) |
| **`level/`** | Slice graybox and encounter layout |
| **`audio/`** | Placeholder audio asset policy |
| **`notes/`** | Working journals (Level 4) |
| **`historical/`** | Milestones 5–8 and early plans (Level 5) |

New checkpoints go in `checkpoints/`. See [`README.md`](./README.md) for the full map.

---

## Level 1 — Project Constitution

| Document | Role |
|----------|------|
| [`vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) | **Design constitution** for the first playable version — scope, pacing, archetypes, success criteria, slice build order |

**Wins for:** slice intent, feature scope, deferred features, fifteen-minute flow, enemy archetype *roles*, implementation roadmap *direction*.

**Does not win for:** live numeric tuning, exact AI constants, or code behavior — use Level 2 checkpoints.

---

## Level 2 — Current System Checkpoints

Checkpoints describe **live or recently shipped behavior**. Each checkpoint owns its domain.

### Combat

| Document | Owns |
|----------|------|
| [`project_checkpoint_combat_feel_v1.md`](./checkpoints/project_checkpoint_combat_feel_v1.md) | Rider melee Passes 1–7, default enemy prototype combat, telegraphs, aim forgiveness |

**Scope note:** Written at Combat Feel v1 baseline. For **post-v1** systems, also read Combat Depth and Audio checkpoints below.

| Document | Owns |
|----------|------|
| [`project_checkpoint_combat_depth_1B.md`](./checkpoints/project_checkpoint_combat_depth_1B.md) | Combat Stance, weapon movement identity, attack facing commitment, Target Focus |

### Relationship

| Document | Owns |
|----------|------|
| [`project_checkpoint_milestone9A.md`](./checkpoints/project_checkpoint_milestone9A.md) | Live Sync/Instability application, split ratings, encounter resolve safeguards |
| [`relationship_event_framework.md`](./design/relationship_event_framework.md) | Event catalog, stat ownership, encounter philosophy — **Current Implementation** section is live; **Planned/Future** sections are not |

### Developer Experience

| Document | Owns |
|----------|------|
| [`project_checkpoint_developer_experience_pass1.md`](./checkpoints/project_checkpoint_developer_experience_pass1.md) | F10 docked sidebar, SubViewport sync, window defaults, playtest shell layout |

**Supersedes** layout/dev-panel details in [`project_checkpoint_ui_cleanup_pass1.md`](./checkpoints/project_checkpoint_ui_cleanup_pass1.md) and debug-layout sections in Milestone 9A.

### Player Polish

| Document | Owns |
|----------|------|
| [`project_checkpoint_vertical_slice_polish_1A.md`](./checkpoints/project_checkpoint_vertical_slice_polish_1A.md) | Player-facing feedback without F10 — encounter summary, toasts, dragon chip, combat floaters |

**Supersedes** player-communication details in older polish notes. Dev panel placement: see Developer Experience checkpoint.

| Document | Owns |
|----------|------|
| [`project_checkpoint_dragon_personality_pass1.md`](./checkpoints/project_checkpoint_dragon_personality_pass1.md) | Behavioral personality (ambient bubbles rejected); future player-initiated dialogue deferred |

| Document | Owns |
|----------|------|
| [`project_checkpoint_player_animation_pass1.md`](./checkpoints/project_checkpoint_player_animation_pass1.md) | Minimal idle / walk / attack presentation synced to MeleeAttack timings |

| Document | Owns |
|----------|------|
| [`project_checkpoint_ui_cleanup_pass1.md`](./checkpoints/project_checkpoint_ui_cleanup_pass1.md) | HUD layout philosophy, PlayerHud, area announce — **historical for window/shell layout** |

### Audio

| Document | Owns |
|----------|------|
| [`project_checkpoint_audio_feedback_pass1.md`](./checkpoints/project_checkpoint_audio_feedback_pass1.md) | `GameAudio` architecture, event catalog, binder wiring, buses |
| [`project_checkpoint_combat_audio_pass1.md`](./checkpoints/project_checkpoint_combat_audio_pass1.md) | Combat Audio Pass 1 — swing whooshes, `weapon_impact_library_v1`, weapon audio profiles |
| [`project_checkpoint_combat_audio_polish_pass1.md`](./checkpoints/project_checkpoint_combat_audio_polish_pass1.md) | Redirect → Combat Audio Pass 1 |
| [`audio_placeholder_assets.md`](./audio/audio_placeholder_assets.md) | Placeholder WAV policy, regeneration, catalog mapping |
| [`../assets/audio/weapon_impact_library_v1/README.md`](../assets/audio/weapon_impact_library_v1/README.md) | Melee impact library v1 — profiles and import |

### Level & slice content

| Document | Owns |
|----------|------|
| [`vertical_slice_level_p1.md`](./level/vertical_slice_level_p1.md) | Graybox layout, named encounters, route connectivity |

### Future checkpoints

When a new pass ships, add a `project_checkpoint_<domain>_<pass>.md` at Level 2. Update [`PROJECT_STATE.md`](./PROJECT_STATE.md) and this file.

---

## Level 3 — Supporting Design Documents

High-level vision and cross-cutting design. **Not mechanical source of truth** unless no checkpoint exists.

| Document | Role |
|----------|------|
| [`combat.md`](./design/combat.md) | Combat philosophy, rider–dragon co-op vision |
| [`dragon_ai.md`](./design/dragon_ai.md) | Dragon autonomy, priorities, emotional design |
| [`relationship_event_framework.md`](./design/relationship_event_framework.md) | Full event economy (see Level 2 for live slice) |
| [`game_architecture.md`](./design/game_architecture.md) | Full-game systems map — politics, races, regions |
| [`technical_architecture.md`](./design/technical_architecture.md) | Code organization, future managed layers |
| [`vertical_slice_level_p1.md`](./level/vertical_slice_level_p1.md) | Also listed at Level 2 for layout/encounters |

---

## Level 4 — Working Notes

Pass-by-pass journals, experiments, and brainstorming. **Historical and forward-looking** — verify against Level 2 before implementing.

| Document | Role |
|----------|------|
| [`combat_feel_notes.md`](./notes/combat_feel_notes.md) | Combat pass journal — archetype naming (Standard/Heavy) vs slice names (Raider/Brute) |
| [`playtest_observation_log.md`](./notes/playtest_observation_log.md) | Informal + structured playtest observations (Level 4) |

Future brainstorming and design journals belong at this level.

---

## Level 5 — Historical Documents

Describe **what existed when the checkpoint was written**. Do not edit to match current behavior except for **supersession banners** and cross-links.

| Document | Era |
|----------|-----|
| [`project_checkpoint_milestone5.md`](./historical/project_checkpoint_milestone5.md) | Early prototype |
| [`project_checkpoint_milestone6.md`](./historical/project_checkpoint_milestone6.md) | Early prototype |
| [`project_checkpoint_milestone7.md`](./historical/project_checkpoint_milestone7.md) | Bond tiers, dragon behaviors |
| [`project_checkpoint_milestone8.md`](./historical/project_checkpoint_milestone8.md) | Encounter tracking (pre–live Sync/Instability) |
| [`project_checkpoint.md`](./historical/project_checkpoint.md) | Early project snapshot |
| [`vertical_slice_plan.md`](./historical/vertical_slice_plan.md) | Early slice planning — superseded by `vertical_slice_design_v1.md` |

**Milestone 9A** ([`checkpoints/project_checkpoint_milestone9A.md`](./checkpoints/project_checkpoint_milestone9A.md)) remains **Level 2** for relationship mechanics. Its **Debug UI & Playtest Layout** section is **historical** — superseded by Developer Experience Pass 1.

---

## Conflict Resolution Rules

When two documents disagree, apply in order:

1. **Level beats lower level** — Constitution beats checkpoint only for *slice scope and intent*; checkpoint beats constitution for *live mechanics*.
2. **Newer checkpoint beats older checkpoint** in the same domain — e.g. Developer Experience Pass 1 beats Milestone 9A layout notes.
3. **Domain owner wins** — Audio conflicts → `project_checkpoint_audio_feedback_pass1.md`; relationship math → Milestone 9A + framework **Current Implementation**.
4. **Code wins over all docs** if docs are stale — then **update the checkpoint**, do not silently trust the doc.
5. **Historical docs never override Level 1–2** — add a supersession note instead of rewriting history.

### Quick reference

| Question | Read first |
|----------|------------|
| Is this in slice scope? | `design/vertical_slice_design_v1.md` |
| How does melee work? | `checkpoints/project_checkpoint_combat_feel_v1.md` + `checkpoints/project_checkpoint_combat_depth_1B.md` |
| How do Sync/Instability change? | `checkpoints/project_checkpoint_milestone9A.md` |
| How does audio fire? | `checkpoints/project_checkpoint_audio_feedback_pass1.md` |
| Weapon swing / impact / audio profiles | `checkpoints/project_checkpoint_combat_audio_pass1.md` |
| Where is F10 / viewport? | `checkpoints/project_checkpoint_developer_experience_pass1.md` |
| What does the player see without F10? | `checkpoints/project_checkpoint_vertical_slice_polish_1A.md` |
| Dragon communication / behavioral personality | `checkpoints/project_checkpoint_dragon_personality_pass1.md` |
| Player attack animation | `checkpoints/project_checkpoint_player_animation_pass1.md` |
| What's the graybox route? | `level/vertical_slice_level_p1.md` |
| What was true in Milestone 8? | `historical/project_checkpoint_milestone8.md` (historical only) |

---

## Maintaining This Hierarchy

- New milestone shipped → add/update Level 2 checkpoint, update [`PROJECT_STATE.md`](./PROJECT_STATE.md) (revision, milestone, roadmap).
- Design intent change → update `vertical_slice_design_v1.md`.
- Experiment or playtest notes → `combat_feel_notes.md` or new Level 4 journal.
- Retired checkpoint → move reference to Level 5; add supersession banner at top.
- Never delete historical checkpoints — link forward instead.

See [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) → **Rules for documentation updates**.
