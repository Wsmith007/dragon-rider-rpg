# Dragon Rider RPG — Placeholder Swing Audio Improvement Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn` (F6)  
**Audio architecture:** [`project_checkpoint_audio_feedback_pass1.md`](./project_checkpoint_audio_feedback_pass1.md)  
**Prior polish:** [`project_checkpoint_combat_audio_polish_pass1.md`](./project_checkpoint_combat_audio_polish_pass1.md)  
**Documentation:** [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md)  
**Status:** **SUPERSEDED** for swing assets — user recordings integrated via Combat Audio Polish Pass 1 (2026-07-06). Procedural approach retained in generator for reference only.

---

## Scope

Replace **only** placeholder swing sounds so combat communicates **air movement** rather than percussion. This is a **presentation polish** milestone before the Structured Vertical Slice Playtest.

**In scope:**

- New procedural per-weapon swing WAVs (`swing_dagger`, `swing_sword`, `swing_polearm`)
- Catalog path constants and stream selection for weapon swings
- Regenerator updates in `tools/generate_placeholder_audio.py`

**Not in scope:**

- Hit, dragon, UI, or encounter sounds
- `GameAudio`, event enums, binder routing, or gameplay events
- Audio Pass 2 (recorded production assets)
- Combat timing, damage, or animation changes

---

## Why the Previous Placeholder Was Replaced

The original `swing.wav` was a **short broadband noise burst** with a sharp attack. In repeated playtesting it was consistently read as **percussion or snare drum**, not weapon motion.

Combat Audio Polish Pass 1 layered pitch and volume per weapon on that single file. Pitch shifting could not fix the problem because the **transient character** still communicated impact/drum, not air.

The issue was reclassified as an **asset quality** problem, not an implementation problem.

---

## Design Philosophy

Swing sounds must communicate **air movement**, not **impact**.

| Weapon | Duration | Spectral character | Intended read |
|--------|----------|-------------------|---------------|
| **Dagger** | ~52 ms | Highest HP cutoff, brightest transient | Shortest, quickest, crisp air swish |
| **Sword** | ~88 ms | Mid band, balanced sweep | Fuller medium air movement |
| **Polearm** | ~138 ms | Lowest HP cutoff, longest decay | Deepest, heaviest momentum |

These remain **placeholders** — good enough for playtest communication, not final production quality.

Legacy `swing.wav` now mirrors `swing_sword.wav` for `PLAYER_SWING`, `PLAYER_CC`, and `ATTACK_MISS` event paths that still reference the original constant.

---

## Placeholder Generation Approach

`tools/generate_placeholder_audio.py` — `_air_swish()`:

1. White noise (deterministic per-weapon seed)
2. One-pole **high-pass** + **low-pass** filtering (weapon-specific cutoffs)
3. Optional brightness via differentiated noise (dagger emphasis)
4. Soft attack + **exponential decay** envelope (no percussive click)
5. Optional descending-frequency sweep mixed into noise (whoosh motion)

Non-swing placeholders (`impact`, `ui_soft`, `defeat`, `dragon_soft`, `heavy_thud`) are regenerated unchanged from prior tonal/noise recipes.

**Policy:** Self-contained procedural generation only — no downloaded assets, no licensing concerns.

---

## Catalog Changes (Only)

`scripts/audio/game_audio_catalog.gd`:

- `PLACEHOLDER_SWING_DAGGER`, `PLACEHOLDER_SWING_SWORD`, `PLACEHOLDER_SWING_POLEARM`
- `_weapon_swing_stream()` selects stream by `WeaponProfilePrototype.Id`
- Pitch tuning reduced (~0.94–1.06) — timbre differentiation lives in WAVs
- `unique_stream_paths()` includes all three new files

`get_weapon_swing_playback()` and CC step lifts from Combat Audio Polish Pass 1 are **unchanged in behavior** — only the underlying stream path differs per weapon.

---

## Files Modified

| File | Change |
|------|--------|
| `tools/generate_placeholder_audio.py` | `_air_swish()` + per-weapon swing generators |
| `assets/audio/placeholders/swing.wav` | Regenerated (sword alias) |
| `assets/audio/placeholders/swing_dagger.wav` | **New** |
| `assets/audio/placeholders/swing_sword.wav` | **New** |
| `assets/audio/placeholders/swing_polearm.wav` | **New** |
| `scripts/audio/game_audio_catalog.gd` | Per-weapon swing stream paths + reduced pitch spread |
| `docs/audio/audio_placeholder_assets.md` | Nine-file policy, swing mapping |
| `docs/checkpoints/project_checkpoint_placeholder_swing_audio_improvement.md` | This checkpoint |

**Unchanged:** `game_audio.gd`, `game_audio_binder.gd`, `game_audio_event.gd`, hit/dragon/UI WAVs, gameplay scripts.

---

## Validation Checklist

- [ ] Swing no longer resembles percussion (TestWorld + slice)
- [ ] Dagger feels quickest / brightest
- [ ] Sword feels balanced / medium
- [ ] Polearm feels longest / heaviest
- [ ] Hit sounds still function
- [ ] Dragon sounds still function
- [ ] UI sounds still function
- [ ] CC triple-swing sequence still fires with building energy

---

## Validation Results

| Check | Result |
|-------|--------|
| Only swing WAVs + catalog paths changed | **PASS** |
| Non-swing placeholders untouched in generator recipes | **PASS** |
| Procedural duration ordering dagger < sword < polearm | **PASS** (52 / 88 / 138 ms) |
| Spectral ordering dagger brightest → polearm deepest | **PASS** (HP 2200 / 900 / 280 Hz) |
| `GameAudio` / binder / events unchanged | **PASS** |
| Live auditory playtest | **Pending manual run** |

---

## Future Replacement Path (Audio Pass 2)

1. Record or license per-weapon swing whooshes (and optionally a dedicated CC finisher).
2. Drop files into `assets/audio/` (or a production subfolder).
3. Update **only** `PLACEHOLDER_SWING_*` constants in `game_audio_catalog.gd` (or swap to a data-driven catalog).
4. Re-run playtest — no gameplay or `GameAudio` API changes required.

Optional: retire `swing.wav` alias once all legacy event paths use weapon-specific streams.

---

## Remaining Limitations

- Still synthetic noise — lacks mic-recorded spatial richness and material character (blade vs haft).
- CC sequence reuses weapon stream + pitch/volume lifts; no separate CC finisher WAV yet.
- `ATTACK_MISS` still uses generic `swing.wav` at heavy attenuation.
- No bus-level EQ per weapon (catalog volume/pitch only).

---

## Related Documentation

| Document | Relationship |
|----------|----------------|
| [`project_checkpoint_audio_feedback_pass1.md`](./project_checkpoint_audio_feedback_pass1.md) | Authoritative `GameAudio` architecture |
| [`project_checkpoint_combat_audio_polish_pass1.md`](./project_checkpoint_combat_audio_polish_pass1.md) | CC sequence + animation alternation (still live) |
| [`audio_placeholder_assets.md`](../audio/audio_placeholder_assets.md) | Regeneration and file mapping |
