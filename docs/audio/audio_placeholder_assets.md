# Placeholder Audio Assets

**Status:** Temporary — for audio timing and architecture validation only  
**Implemented:** Audio Feedback Pass 1 — see [`project_checkpoint_audio_feedback_pass1.md`](../checkpoints/project_checkpoint_audio_feedback_pass1.md)  
**Swing improvement:** [`project_checkpoint_placeholder_swing_audio_improvement.md`](../checkpoints/project_checkpoint_placeholder_swing_audio_improvement.md) (procedural — superseded)  
**Live swing assets / Combat Audio Pass 1:** [`project_checkpoint_combat_audio_pass1.md`](../checkpoints/project_checkpoint_combat_audio_pass1.md)  
**Melee impacts:** `assets/audio/weapon_impact_library_v1/` · [`README.md`](../../assets/audio/weapon_impact_library_v1/README.md)  
**Location:** `assets/audio/placeholders/`  
**Generator (non-swing):** `tools/generate_placeholder_audio.py`  
**Swing import:** `tools/import_user_swing_placeholders.py` · sources in `tools/user_swing_sources/`

---

## Purpose

These WAV files are **procedurally generated placeholders**. They exist so the project can test:

- When sounds should fire relative to gameplay events
- Centralized audio routing (buses, catalogs, replacement workflow)
- Volume and pitch variation without committing to final sound design

They are **not** final assets. Multiple unrelated gameplay events intentionally share some placeholder files. That reuse is expected until real sounds are authored or licensed.

**Policy:** Do not download sound libraries, search for temp assets, or add dozens of one-off placeholders. Regenerate or replace through the catalog only.

---

## Files

| File | Character | Intended use (placeholder) |
|------|-----------|----------------------------|
| `swing_dagger.wav` | User-recorded air swish (~0.35 s) | Dagger focused / CC swings |
| `swing_sword.wav` | User-recorded air swish (~0.26 s) | Sword focused / CC swings |
| `swing_polearm.wav` | User-recorded air swish (~0.44 s) | Polearm focused / CC swings |
| `swing.wav` | Copy of sword swish | Legacy event paths (`PLAYER_SWING`, `PLAYER_CC`, `ATTACK_MISS`) |
| `impact.wav` | Soft procedural tone | `PLAYER_DAMAGED` only (not melee connects) |
| `ui_soft.wav` | Quiet high tone | UI confirmations, focus changes, encounter toasts |
| `defeat.wav` | Descending tone | Enemy defeated |
| `dragon_soft.wav` | Soft low tone | Subtle dragon presence (assist, protection, wait ack) |
| `heavy_thud.wav` | Low thud | Brute heavy impact, stagger resist feedback |

### Swing placeholders (user-recorded)

Swing files come from **user M4A recordings** (see `tools/user_swing_sources/README.txt`). Import via:

```bash
python tools/import_user_swing_placeholders.py
```

Light cleanup on import: silence trim, 4 ms fades, peak normalize to ~26 000.

| Weapon | Duration | Read |
|--------|----------|------|
| Dagger | ~0.35 s | Quick user swish |
| Sword | ~0.26 s | Balanced user swish |
| Polearm | ~0.44 s | Longest user swish |

CC attacks replay the focused swing three times with catalog pitch/volume lifts — combo WAVs in `user_swing_sources/` are reference only.

Procedural `_air_swish()` generation was superseded; `generate_placeholder_audio.py` no longer overwrites swing files.

---

## Regenerating

**Non-swing placeholders** from the repository root:

```bash
python tools/generate_placeholder_audio.py
```

**Swing placeholders** (user-recorded — do not use procedural generator):

```bash
python tools/import_user_swing_placeholders.py
```

Requirements:

- Python 3 with standard library only (`wave`, `math`, `random`, `struct`, `os`)
- No pip packages

Running `generate_placeholder_audio.py` **overwrites** the five tonal/non-swing files only. Swing files are preserved unless you re-run the import script.

---

## Gameplay event mapping (live)

Event names match `GameAudioEvent.Event` in `scripts/audio/game_audio_event.gd`.

### Weapon swings (`get_weapon_swing_playback`)

| Profile | Stream | Notes |
|---------|--------|-------|
| Dagger | `swing_dagger.wav` | Via `GameAudio.play_weapon_swing` / CC sequence |
| Sword | `swing_sword.wav` | Default profile |
| Polearm | `swing_polearm.wav` | |

### `swing.wav` (legacy event paths)

| Event | Notes |
|-------|--------|
| `PLAYER_SWING` | Generic swing event (sword alias) |
| `PLAYER_CC` | CC swing event (sword alias; weapon-specific CC uses helpers) |
| `ATTACK_MISS` | Optional quiet miss (heavily attenuated) |

### `impact.wav`

| Event | Notes |
|-------|--------|
| `PLAYER_DAMAGED` | Generic hurt when player health drops (not melee connect SFX) |

Melee connects use `weapon_impact_library_v1` via `WeaponAudioProfile` — see Combat Audio Pass 1 checkpoint.

### `ui_soft.wav`

| Event | Notes |
|-------|--------|
| `TARGET_FOCUS_ON` | Caps Lock focus on |
| `TARGET_FOCUS_SWITCH` | Tab / Shift+Tab cycle |
| `TARGET_FOCUS_OFF` | Focus cleared |
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
| `DRAGON_WAIT` | Wait command acknowledged |

### `heavy_thud.wav`

| Event | Notes |
|-------|--------|
| `BRUTE_RESIST` | Brute resists player stagger |

`BRUTE_HEAVY` is no longer used for enemy attack connects — enemy melee impacts use weapon audio profiles.

---

## Future replacement strategy

Replace **catalog stream paths** in `scripts/audio/game_audio_catalog.gd`. Call sites reference `GameAudioEvent.Event` or weapon helpers — not raw file paths.

| Placeholder | Likely future replacements |
|-------------|------------------------------|
| `swing_dagger.wav` | Recorded dagger whoosh |
| `swing_sword.wav` | Recorded sword whoosh |
| `swing_polearm.wav` | Recorded polearm / staff whoosh |
| `swing.wav` | Retire or point at sword default |
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
| `../checkpoints/project_checkpoint_placeholder_swing_audio_improvement.md` | Swing placeholder replacement rationale |
| [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) | Documentation authority |
| `scripts/audio/game_audio_catalog.gd` | Stream paths and bus routing |
| `tools/generate_placeholder_audio.py` | Asset regeneration |
