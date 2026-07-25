# Project State

**Active development homepage** — understand the project in ~2 minutes, then follow links for detail.

| | |
|--|--|
| **Engine** | Godot 4.6 · GDScript |
| **Playtest** | `TestWorld.tscn` (systems sandbox) · `VerticalSlice_Level_P1.tscn` (F6 — slice) |
| **Last updated** | 2026-07-24 (Dragon Personality Pass 1 — behavioral communication) |

**New developer path:** [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) → this file → [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md) → domain checkpoint for your task.

**Docs index:** [`README.md`](./README.md)

---

## Current Project Revision

**Combat Audio Pass 1 — complete**

---

## Current Development Phase

**Vertical Slice — polish and validation**

Core systems are implemented. Work focuses on **Structured Vertical Slice Playtest** readiness.

Design intent: [`vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md)

---

## Current Milestone

**Structured Vertical Slice Playtest** — formal fifteen-minute arc evaluation

**Previous:** Combat Audio Pass 1 — [`project_checkpoint_combat_audio_pass1.md`](./checkpoints/project_checkpoint_combat_audio_pass1.md)

---

## Current Focus

1. Run the **Structured Vertical Slice Playtest**
2. Capture findings in [`playtest_observation_log.md`](./notes/playtest_observation_log.md)
3. Address only **low-risk readability** fixes that fit the documented roadmap

---

## Next Planned Milestones

| Order | Milestone | What it is |
|-------|-----------|------------|
| 1 | **Structured Vertical Slice Playtest** | Formal fifteen-minute arc evaluation (**current**) |
| 2 | **Documentation Cleanup Pass 2** | Resolve moderate/major doc conflicts (future) |

Do not invent milestones beyond this sequence without updating this file and [`vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) §12.

### Next milestone candidates (after playtest — not started)

Planning notes only; pick based on playtest findings:

- **Hit feedback polish** — hit-stop, recoil, stagger, particles, camera shake
- **Combat interaction depth** — enemy reactions, block/shield, material hit responses
- **Weapon expansion** — new identities with audio profiles (staff, axe, club, hammer, spear)
- **Enemy combat readability** — windups, attack tells, weapon-specific behavior

---

## What this project is

Dragon Rider RPG proves whether **rider–dragon partnership** is fun in combat. The vertical slice is a ~15-minute handcrafted level teaching Scout / Raider / Brute roles, directional melee, dragon assist/protection, and live Sync/Instability from encounter resolve.

`TestWorld` = systems sandbox. `VerticalSlice_Level_P1` = player-facing teaching arc.

---

## Where to read next

| I need to know… | Read |
|-----------------|------|
| Docs folder map | [`README.md`](./README.md) |
| Authority rules when docs disagree | [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md) |
| Agent / Cursor workflow | [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) |
| Slice scope, pacing, defer list | [`vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) |
| **Playtest observations** | [`playtest_observation_log.md`](./notes/playtest_observation_log.md) |
| Melee combat (Passes 1–7) | [`project_checkpoint_combat_feel_v1.md`](./checkpoints/project_checkpoint_combat_feel_v1.md) |
| Combat Stance + Target Focus | [`project_checkpoint_combat_depth_1B.md`](./checkpoints/project_checkpoint_combat_depth_1B.md) |
| Sync / Instability / encounters | [`project_checkpoint_milestone9A.md`](./checkpoints/project_checkpoint_milestone9A.md) |
| Player HUD without F10 | [`project_checkpoint_vertical_slice_polish_1A.md`](./checkpoints/project_checkpoint_vertical_slice_polish_1A.md) |
| Dragon communication + behavioral personality | [`project_checkpoint_dragon_personality_pass1.md`](./checkpoints/project_checkpoint_dragon_personality_pass1.md) |
| Player combat animation | [`project_checkpoint_player_animation_pass1.md`](./checkpoints/project_checkpoint_player_animation_pass1.md) |
| **Combat audio (swing + impact)** | [`project_checkpoint_combat_audio_pass1.md`](./checkpoints/project_checkpoint_combat_audio_pass1.md) |
| Event audio architecture | [`project_checkpoint_audio_feedback_pass1.md`](./checkpoints/project_checkpoint_audio_feedback_pass1.md) |
| F10 sidebar + viewport | [`project_checkpoint_developer_experience_pass1.md`](./checkpoints/project_checkpoint_developer_experience_pass1.md) |
| Graybox level + encounters | [`vertical_slice_level_p1.md`](./level/vertical_slice_level_p1.md) |

---

## Systems at a glance

| Area | Status | Detail in |
|------|--------|-----------|
| Rider melee + weapon profiles | Live | Combat Feel v1 |
| Combat Stance + Target Focus | Live | Combat Depth 1B |
| Scout / Raider / Brute | Live on slice | Level doc · design §3 |
| Dragon assist / protection | Live | Milestone 9A · `dragon_ai.md` |
| Sync + Instability at resolve | Live | Milestone 9A |
| Handcrafted slice level | Live | `level/vertical_slice_level_p1.md` |
| Player feedback (no F10) | Live | Polish 1A |
| F10 dev shell | Live (gated) | Developer Experience |
| Placeholder event audio | **Pass 1A complete** | Audio Feedback Pass 1 |
| **Combat audio (swing + impact)** | **Pass 1 complete** | Combat Audio Pass 1 |
| Player combat animation | **Pass 1 complete** | Player Animation Pass 1 |
| Dragon personality (behavioral) | **Pass 1 complete** — ambient bubbles rejected | Dragon Personality Pass 1 |
| Dev UI hidden (player build) | **Pass 1 complete** | `developer_tools_enabled` / DeveloperInput |
| Bond Strength progression | Deferred | Milestone 9A |
| Death/retry, save | Deferred | Design §8 |

---

## Recently completed

Combat Audio Pass 1 · Player Animation Pass 1 · Dragon Personality Pass 1 · Informal Playtest · Audio Feedback Pass 1A · Documentation Organization Pass 1 · Documentation Cleanup Pass 1 · Audio Feedback Pass 1 · Developer Experience Pass 1 · UI Cleanup Pass 1 · Polish Pass 1A · Combat Depth Phase A+B · Enemy Archetype Pass 1+1B · Level Pass 2 (P2.2) · Milestone 9A

Dates: see individual checkpoint headers.

---

## Known limitations

Pointers only — full detail in checkpoints and design §8.

- No inventory, dodge, magic, flight, or races in slice scope
- Bond Strength preview only at encounter resolve
- Swing whooshes and melee impacts are **placeholder/processed** assets until Audio Pass 2
- Sword impact has one unique variation until `hit_sword_02` is replaced with a distinct recording
- Placeholder polygon rider art
- Player builds require `gameplay/developer_tools_enabled = false` in export — not yet a preset template
- Structured fifteen-minute playtest not yet run as formal gate

---

## Documentation debt (Pass 2)

Tracked conflicts — not blockers for onboarding. See [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) §5.

| Severity | Examples |
|----------|----------|
| **Moderate** | Combat Feel v1 §3 still centers default enemy narrative; `combat_feel_notes` journal size |
| **Major** | Combat Feel v2 or addendum; Outcome Rating rename vs live labels; full-game docs vs slice defer list |

---

## Related

- [`README.md`](./README.md) — docs folder map  
- [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) — standard agent workflow  
- [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md) — which document wins  
- [`vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) — design constitution  
- [`playtest_observation_log.md`](./notes/playtest_observation_log.md) — playtest journal
