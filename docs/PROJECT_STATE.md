# Project State

**Active development homepage** — understand the project in ~2 minutes, then follow links for detail.

| | |
|--|--|
| **Engine** | Godot 4.6 · GDScript |
| **Playtest** | `TestWorld.tscn` (systems sandbox) · `VerticalSlice_Level_P1.tscn` (F6 — slice) |
| **Last updated** | 2026-07-06 (Documentation Organization Pass 1) |

**New developer path:** [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) → this file → [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md) → domain checkpoint for your task.

**Docs index:** [`README.md`](./README.md)

---

## Current Project Revision

**Documentation Organization Pass 1**

Reorganized `docs/` into subfolders (`design/`, `checkpoints/`, `level/`, `audio/`, `notes/`, `historical/`), updated links, added `README.md`, and added Standard Milestone Handoff workflow. **No gameplay changes.**

---

## Current Development Phase

**Vertical Slice — polish and validation**

Core systems are implemented. Work is shifting to **playtest validation** and **player-facing polish** before a structured fifteen-minute slice playtest.

Design intent: [`vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md)

---

## Current Milestone

**Documentation Organization Pass 1** — **complete** (documentation only)

---

## Current Focus

1. Prepare for **Audio Feedback Pass 1A** — validate implemented audio (see audio checkpoint)
2. Use reorganized docs + [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) Standard Milestone Handoff for future passes

---

## Next Planned Milestones

| Order | Milestone | What it is |
|-------|-----------|------------|
| 1 | **Audio Feedback Pass 1A** | Playtest validation of Audio Feedback Pass 1 (**next**) |
| 2 | **Informal Playtest** | Smoke test — systems + slice level |
| 3 | **Dragon Personality Pass 1** | Dragon communication + hide dev UI in player builds |
| 4 | **Player Animation Pass 1** | Minimal attack animation synced to combat timings |
| 5 | **Structured Vertical Slice Playtest** | Formal fifteen-minute arc evaluation |
| 6 | **Documentation Cleanup Pass 2** | Resolve moderate/major doc conflicts (future) |

Do not invent milestones beyond this sequence without updating this file and [`vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) §12.

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
| Melee combat (Passes 1–7) | [`project_checkpoint_combat_feel_v1.md`](./checkpoints/project_checkpoint_combat_feel_v1.md) |
| Combat Stance + Target Focus | [`project_checkpoint_combat_depth_1B.md`](./checkpoints/project_checkpoint_combat_depth_1B.md) |
| Sync / Instability / encounters | [`project_checkpoint_milestone9A.md`](./checkpoints/project_checkpoint_milestone9A.md) |
| Player HUD without F10 | [`project_checkpoint_vertical_slice_polish_1A.md`](./checkpoints/project_checkpoint_vertical_slice_polish_1A.md) |
| F10 sidebar + viewport | [`project_checkpoint_developer_experience_pass1.md`](./checkpoints/project_checkpoint_developer_experience_pass1.md) |
| Event audio | [`project_checkpoint_audio_feedback_pass1.md`](./checkpoints/project_checkpoint_audio_feedback_pass1.md) |
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
| F10 dev shell | Live | Developer Experience Pass 1 |
| Placeholder event audio | Live (Pass 1) | Audio Feedback Pass 1 — **Pass 1A validation next** |
| Attack animation | Not started | Player Animation Pass 1 |
| Dragon personality UI | Not started | Dragon Personality Pass 1 |
| Dev UI hidden (player build) | Not started | Dragon Personality Pass 1 |
| Bond Strength progression | Deferred | Milestone 9A |
| Death/retry, save | Deferred | Design §8 |

---

## Recently completed

Documentation Organization Pass 1 · Documentation Cleanup Pass 1 · Audio Feedback Pass 1 · Developer Experience Pass 1 · UI Cleanup Pass 1 · Polish Pass 1A · Combat Depth Phase A+B · Enemy Archetype Pass 1+1B · Level Pass 2 (P2.2) · Milestone 9A

Dates: see individual checkpoint headers.

---

## Known limitations

Pointers only — full detail in checkpoints and design §8.

- No inventory, dodge, magic, flight, or races in slice scope
- Bond Strength preview only at encounter resolve
- Placeholder audio (six WAVs); no attack animations yet
- F10 / F11 / spawn keys always visible — no player-build flag
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
