# Dragon Rider RPG — Documentation

**Engine:** Godot 4.6 · GDScript

---

## Start here

Standard reading order for every new developer or Cursor chat:

1. [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) — workflow, handoff cadence, rules  
2. [`PROJECT_STATE.md`](./PROJECT_STATE.md) — current phase, milestone, roadmap  
3. [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md) — which document wins  
4. [`design/vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) — slice design constitution  
5. Relevant **checkpoint** for your task (see below)

---

## Current source of truth

| Layer | Location |
|-------|----------|
| Active homepage | [`PROJECT_STATE.md`](./PROJECT_STATE.md) |
| Authority rules | [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md) |
| Design constitution | [`design/vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) |
| Live checkpoints | [`checkpoints/`](./checkpoints/) |

---

## Folder map

```
docs/
├── README.md                      ← you are here
├── PROJECT_STATE.md               ← current milestone & roadmap
├── CURSOR_ONBOARDING.md           ← agent workflow
├── DOCUMENTATION_HIERARCHY.md       ← authority model
│
├── design/                        ← vision, constitution, frameworks
├── checkpoints/                   ← live system checkpoints (Level 2)
├── level/                         ← slice graybox & encounters
├── audio/                         ← placeholder asset policy
├── notes/                         ← working journals (Level 4)
└── historical/                    ← Milestones 5–8, early plans (Level 5)
```

---

## Common tasks — where to read

| Task | Read |
|------|------|
| What milestone are we on? | [`PROJECT_STATE.md`](./PROJECT_STATE.md) |
| Is this in slice scope? | [`design/vertical_slice_design_v1.md`](./design/vertical_slice_design_v1.md) |
| How does melee work? | [`checkpoints/project_checkpoint_combat_feel_v1.md`](./checkpoints/project_checkpoint_combat_feel_v1.md) |
| Combat Stance / Target Focus | [`checkpoints/project_checkpoint_combat_depth_1B.md`](./checkpoints/project_checkpoint_combat_depth_1B.md) |
| Sync / Instability | [`checkpoints/project_checkpoint_milestone9A.md`](./checkpoints/project_checkpoint_milestone9A.md) |
| Player HUD / feedback | [`checkpoints/project_checkpoint_vertical_slice_polish_1A.md`](./checkpoints/project_checkpoint_vertical_slice_polish_1A.md) |
| F10 / viewport | [`checkpoints/project_checkpoint_developer_experience_pass1.md`](./checkpoints/project_checkpoint_developer_experience_pass1.md) |
| Audio system | [`checkpoints/project_checkpoint_audio_feedback_pass1.md`](./checkpoints/project_checkpoint_audio_feedback_pass1.md) |
| Slice level layout | [`level/vertical_slice_level_p1.md`](./level/vertical_slice_level_p1.md) |
| Combat pass journal | [`notes/combat_feel_notes.md`](./notes/combat_feel_notes.md) |

---

## Historical docs warning

Files in [`historical/`](./historical/) describe **past prototype state**. Do not use for current behavior.

- Milestone 5–8 checkpoints  
- `project_checkpoint.md`  
- `vertical_slice_plan.md`  

For live relationship behavior, use [`checkpoints/project_checkpoint_milestone9A.md`](./checkpoints/project_checkpoint_milestone9A.md).

---

## Adding documentation

- New **checkpoint** → `checkpoints/project_checkpoint_<domain>_<pass>.md`  
- Update [`PROJECT_STATE.md`](./PROJECT_STATE.md) and [`DOCUMENTATION_HIERARCHY.md`](./DOCUMENTATION_HIERARCHY.md)  
- End milestones with a **Milestone Package** — see [`CURSOR_ONBOARDING.md`](./CURSOR_ONBOARDING.md) → Standard Milestone Handoff
