# Placeholder Audio Assets

**Status:** Temporary — for audio timing and architecture validation only  
**Implemented:** Audio Feedback Pass 1 — see [`project_checkpoint_audio_feedback_pass1.md`](../checkpoints/project_checkpoint_audio_feedback_pass1.md)  
**Location:** `assets/audio/placeholders/`  
**Generator:** `tools/generate_placeholder_audio.py`

---

## Purpose

These six WAV files are **procedurally generated placeholders**. They exist so the project can test:

- When sounds should fire relative to gameplay events
- Centralized audio routing (buses, catalogs, replacement workflow)
- Volume and pitch variation without committing to final sound design

They are **not** final assets. Multiple unrelated gameplay events intentionally share the same placeholder file. That reuse is expected until real sounds are authored or licensed.

**Policy:** Do not download sound libraries, search for temp assets, or add dozens of one-off placeholders. Regenerate or replace through the catalog only.

---

## Files

| File | Character | Intended use (placeholder) |
|------|-----------|----------------------------|
| `swing.wav` | Short noise burst | Player attack wind-up / swing start |
| `impact.wav` | Mid thud tone | Hits, enemy hurt, player damage |
| `ui_soft.wav` | Quiet high tone | UI confirmations, focus changes, encounter toasts |
| `defeat.wav` | Descending tone | Enemy defeated |
| `dragon_soft.wav` | Soft low tone | Subtle dragon presence (assist, protection, wait ack) |
| `heavy_thud.wav` | Low thud | Brute heavy impact, stagger resist feedback |

---

## Regenerating

From the repository root:

```bash
python tools/generate_placeholder_audio.py
```

Requirements:

- Python 3 with standard library only (`wave`, `math`, `random`, `struct`, `os`)
- No pip packages

The script uses a **fixed RNG seed** for `swing.wav` noise so every developer gets identical output. Tonal files are fully deterministic.

Running the script **overwrites** all six files in `assets/audio/placeholders/`.

---

## Gameplay event mapping (Audio Feedback Pass 1 — live)

These mappings define how placeholders are reused until final assets exist. Event names match `GameAudioEvent.Event` in `scripts/audio/game_audio_event.gd`.

### `swing.wav`

| Event | Notes |
|-------|--------|
| `FOCUSED_ATTACK_SWING` → `PLAYER_SWING` | Focused melee wind-up |
| `CROWD_CONTROL_ATTACK_SWING` → `PLAYER_CC` | CC swing (lower pitch via catalog) |
| `ATTACK_MISS` | Optional quiet miss (heavily attenuated) |

### `impact.wav`

| Event | Notes |
|-------|--------|
| `PLAYER_HIT_SUCCESS` | Player melee connects |
| `ENEMY_HIT` | Enemy receives player damage |
| `PLAYER_DAMAGED` | Player takes damage (lower pitch via catalog) |

### `ui_soft.wav`

| Event | Notes |
|-------|--------|
| `TARGET_FOCUS_ACQUIRED` | Caps Lock focus on |
| `TARGET_FOCUS_SWITCHED` | Tab / Shift+Tab cycle |
| `TARGET_FOCUS_LOST` | Focus cleared |
| `ENCOUNTER_COMPLETE` | Encounter summary panel |
| `RELATIONSHIP_IMPROVED` | Positive relationship toast |
| `RELATIONSHIP_STRAINED` | Negative relationship toast |

### `defeat.wav`

| Event | Notes |
|-------|--------|
| `ENEMY_DEFEATED` | Enemy `enemy_died` |

### `dragon_soft.wav`

| Event | Notes |
|-------|--------|
| `DRAGON_ASSIST` | Cooperative assist begins |
| `DRAGON_PROTECTION` | Protection intercept begins |
| `DRAGON_WAIT_ACK` | Wait command acknowledged |

### `heavy_thud.wav`

| Event | Notes |
|-------|--------|
| `BRUTE_HEAVY_IMPACT` | Brute attack lands on player |
| `BRUTE_STAGGER_RESISTED` | Brute resists player stagger |

---

## Future replacement strategy

Replace **one catalog entry at a time** in `scripts/audio/game_audio_catalog.gd` (or successor data file). Call sites reference `GameAudioEvents.Event`, not raw file paths.

| Placeholder | Likely future replacements |
|-------------|------------------------------|
| `swing.wav` | Per-weapon swing layers (dagger / sword / polearm), separate CC whoosh |
| `impact.wav` | Flesh hit, armor hit, player hurt grunt layer |
| `ui_soft.wav` | Distinct focus on/off, encounter resolve stinger, relationship up/down motifs |
| `defeat.wav` | Enemy death crumble / dissolve per archetype (may still share a base) |
| `dragon_soft.wav` | Wing flap, breath, protect shell — kept subtle |
| `heavy_thud.wav` | Brute slam impact, metal-on-stone resist clang |

**Intentionally silent (for now):** locomotion, idle dragon follow, scout retreat-only movement, telegraph wind-up visuals without connect, area announce text, HUD updates, bond debug panel.

---

## Related documents

| Document | Role |
|----------|------|
| `../checkpoints/project_checkpoint_audio_feedback_pass1.md` | Audio architecture checkpoint |
| [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) | Documentation authority |
| `scripts/audio/game_audio_catalog.gd` | Stream paths and bus routing |
| `tools/generate_placeholder_audio.py` | Asset regeneration |
