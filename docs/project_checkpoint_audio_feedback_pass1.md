# Dragon Rider RPG — Audio Feedback Pass 1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn` (F6)  
**Design constitution:** [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md)  
**Placeholder assets:** [`audio_placeholder_assets.md`](audio_placeholder_assets.md)  
**Player feedback layer:** [`project_checkpoint_vertical_slice_polish_1A.md`](project_checkpoint_vertical_slice_polish_1A.md)

**Status:** **IMPLEMENTED** — architecture + event wiring live; playtest validation pending  
**Scope:** Centralized audio manager, event catalog, placeholder playback — **no combat balance, AI, dragon behavior, or relationship math changes**  
**Date:** 2026-07-05

---

## Summary

Audio Feedback Pass 1 introduces a **centralized audio architecture** that answers one question per sound: *"What just happened?"* Gameplay code never references file paths. It requests named events; `GameAudio` resolves stream, bus, volume, pitch variation, and anti-spam cooldowns.

Six procedural placeholder WAV files are reused intentionally across many events. Final assets replace catalog entries only — not gameplay call sites.

---

## Audio philosophy

| Principle | Detail |
|-----------|--------|
| **Events, not files** | `GameAudio.play(GameAudioEvent.PLAYER_SWING)` — never `play("res://.../swing.wav")` |
| **Reinforce existing feedback** | Audio supports visuals and UI already shown (hit flash, floaters, encounter summary) |
| **Silence is valid** | No locomotion, idle, or telegraph-only sounds |
| **Subtle by default** | Negative dB offsets, short cooldowns, light pitch variation |
| **Placeholder reuse** | One swing WAV serves all weapons until per-weapon assets exist |

---

## Architecture

```
Gameplay systems (signals only)
        ↓
GameAudioBinder  — connects existing signals → events
        ↓
GameAudio (autoload)  — play(event), pools, cooldowns, buses
        ↓
GameAudioCatalog  — event → stream path, bus, volume, pitch, positional flag
        ↓
Preloaded placeholder WAVs (6 files)
```

### Files

| File | Role |
|------|------|
| `scripts/audio/game_audio.gd` | Autoload manager — preload, buses, player pools, `play()` |
| `scripts/audio/game_audio_event.gd` | `GameAudioEvent.Event` enum |
| `scripts/audio/game_audio_catalog.gd` | Event → placeholder mapping (swap point for final assets) |
| `scripts/audio/game_audio_binder.gd` | Signal wiring from game scene — no gameplay logic |
| `tools/generate_placeholder_audio.py` | Regenerate procedural placeholders |

### Autoload

`GameAudio` registered in `project.godot` alongside `BondSystem` and `RelationshipSystem`.

### Player pools

- **4× `AudioStreamPlayer`** — non-positional UI / encounter sounds  
- **8× `AudioStreamPlayer2D`** — combat and dragon sounds at world positions (reparented under game root when bound)

No `AudioStreamPlayer` nodes are scattered in combat scenes, enemies, or HUD.

### Audio buses (future volume groups)

Created at runtime if missing:

| Bus | Current use |
|-----|-------------|
| **Combat** | Swings, hits, damage, defeat, brute |
| **UI** | Target focus, encounter, relationship |
| **Dragon** | Assist, protection, wait ack |
| **Ambient** | Reserved |
| **Music** | Reserved |
| **Voice** | Reserved |

No settings menu in this pass — buses exist for future mixing.

### Binding lifecycle

`GameAudio.bind_game_root(game_root)` called from `test_world.gd` and `vertical_slice_world_shell.gd` after gameplay wiring (same pattern as `PlayerFeedbackUI.bind`). Rebind on Ctrl+Shift+R slice reload via `unbind` + `bind`.

---

## Event catalog

| Event | Trigger | Placeholder |
|-------|---------|-------------|
| `PLAYER_SWING` | Focused attack wind-up | `swing.wav` |
| `PLAYER_CC` | CC attack wind-up | `swing.wav` (lower pitch) |
| `PLAYER_HIT` | Player melee connects | `impact.wav` |
| `ATTACK_MISS` | Swing completes with no hits | `swing.wav` (very quiet) |
| `PLAYER_DAMAGED` | Player health decreases | `impact.wav` (lower pitch) |
| `ENEMY_DEFEATED` | `enemy_died` | `defeat.wav` |
| `BRUTE_HEAVY` | Brute `attacked_player` | `heavy_thud.wav` |
| `BRUTE_RESIST` | Brute hit without stagger | `heavy_thud.wav` (higher pitch) |
| `TARGET_FOCUS_ON` | Caps Lock acquire | `ui_soft.wav` |
| `TARGET_FOCUS_SWITCH` | Tab / Shift+Tab cycle | `ui_soft.wav` |
| `TARGET_FOCUS_OFF` | Focus cleared | `ui_soft.wav` |
| `ENCOUNTER_COMPLETE` | `encounter_result_ready` | `ui_soft.wav` |
| `RELATIONSHIP_IMPROVED` | Positive applied deltas | `ui_soft.wav` |
| `RELATIONSHIP_STRAINED` | Negative applied deltas | `ui_soft.wav` |
| `DRAGON_ASSIST` | State → `ASSISTING` | `dragon_soft.wav` |
| `DRAGON_PROTECT` | State → `PROTECTING` | `dragon_soft.wav` |
| `DRAGON_WAIT` | Wait command acknowledged | `dragon_soft.wav` |

`ENEMY_HIT` is defined in the catalog (same mapping as `PLAYER_HIT`) for future split; binder currently plays `PLAYER_HIT` on connect.

---

## Gameplay wiring (observation only)

| System | Connection |
|--------|------------|
| `player_melee_attack.gd` | New signals `attack_swing_started` / `attack_swing_finished` (timing only) |
| `Player` | `player_damaged` |
| `PlayerTargetFocus` | `focus_changed` |
| `Enemy` | `enemy_died`, `attacked_player` (+ dynamic bind for spawned enemies) |
| `Dragon` | `state_changed`, `CommandBehavior.wait_position_set` |
| `RelationshipSystem` | `encounter_result_ready`, `relationship_stats_applied` |

**Not modified:** damage formulas, AI states, cooperation math, weapon profiles, movement, Target Focus rules.

---

## Placeholder policy

- **Six files only** in `assets/audio/placeholders/`  
- Regenerate via `python tools/generate_placeholder_audio.py`  
- **Do not** add per-weapon or per-enemy placeholder files in this pass  

---

## Future replacement strategy

1. Author or license final WAV/OGG assets.  
2. Update **one row** in `GameAudioCatalog.get_playback()` (stream path, volume, pitch range).  
3. Playtest — no gameplay file changes required.  
4. When ready, split shared placeholders (e.g. separate `PLAYER_HIT` from `ENEMY_HIT` streams).  

Likely eventual splits documented in [`audio_placeholder_assets.md`](audio_placeholder_assets.md).

---

## Intentionally silent

- Player / enemy locomotion and idle  
- Dragon follow / alert movement (no personality dialogue)  
- Scout retreat movement alone  
- Attack telegraphs with no connect  
- Area announce text  
- HUD numeric updates  
- F10 debug / help panels  
- Bond cheat keys, spawn keys  

---

## Remaining audio work

| Milestone | Scope |
|-----------|--------|
| **Pass 1B+** | Dragon personality voice lines (separate from presence cues) |
| **Pass 2** | Per-weapon swings, distinct UI stingers, mix pass |
| **Pass 3** | Ambient zone beds, music stub, volume settings menu |
| **Polish** | Attack animation sync, hitstop audio lockstep |

---

## Playtest checklist

1. Focused swing — quiet noise at wind-up; impact on connect; optional faint miss on whiff  
2. CC swing — distinct pitch from focused; impact on hit (not machine-gun on multi-hit)  
3. Brute hit on player — heavy thud; brute resist — lighter clang variant  
4. Target focus — soft UI blips on acquire / switch / clear  
5. Encounter end — subtle stinger with summary panel  
6. Relationship toast — improved vs strained audibly distinct (pitch)  
7. Dragon assist / protect / wait — subtle, not constant  
8. Silence during exploration and follow — no ambient spam  

---

## Related documents

| Document | Update |
|----------|--------|
| [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md) | Roadmap — Audio Feedback Pass 1 complete |
| [`project_checkpoint_vertical_slice_polish_1A.md`](project_checkpoint_vertical_slice_polish_1A.md) | Visual feedback unchanged; audio complements Pass 1A |
| [`audio_placeholder_assets.md`](audio_placeholder_assets.md) | Placeholder regeneration + mapping |
