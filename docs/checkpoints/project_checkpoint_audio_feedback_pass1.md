# Dragon Rider RPG — Audio Feedback Pass 1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn` (F6)  
**Design constitution:** [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md)  
**Placeholder assets:** [`audio_placeholder_assets.md`](../audio/audio_placeholder_assets.md)  
**Player feedback layer:** [`project_checkpoint_vertical_slice_polish_1A.md`](./project_checkpoint_vertical_slice_polish_1A.md)

**Status:** **IMPLEMENTED** — architecture + event wiring live · **Pass 1A VALIDATED** (2026-07-06)  
**Scope:** Centralized audio manager, event catalog, placeholder playback — **no combat balance, AI, dragon behavior, or relationship math changes**  
**Date:** 2026-07-05 (Pass 1) · 2026-07-06 (Pass 1A validation)  
**Documentation:** [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md)

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

Likely eventual splits documented in [`audio_placeholder_assets.md`](../audio/audio_placeholder_assets.md).

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
| **Pass 1A** | **Complete** — see [Pass 1A validation](#pass-1a-validation-2026-07-06) |
| **Dragon Personality Pass 1** | Dragon personality voice lines (separate from presence cues) |
| **Pass 2** | Per-weapon swings, distinct UI stingers, mix pass |
| **Pass 3** | Ambient zone beds, music stub, volume settings menu |
| **Polish** | Attack animation sync, hitstop audio lockstep |

---

## Playtest checklist (Pass 1A)

| # | Check | Result |
|---|-------|--------|
| 1 | Focused swing — wind-up sound; impact on connect; faint miss on whiff | **PASS** |
| 2 | CC swing — lower pitch than focused; hits on connect (cooldown limits spam) | **PASS** |
| 3 | Brute hit on player — heavy thud; brute resist — higher-pitch variant | **PASS** |
| 4 | Target focus — soft blips on acquire / switch / clear | **PASS** |
| 5 | Encounter end — subtle stinger with summary panel | **PASS** |
| 6 | Relationship toast — improved vs strained audibly distinct (pitch) | **PASS** |
| 7 | Dragon assist / protect / wait — subtle, state-edge triggered | **PASS** |
| 8 | Silence during exploration and follow — no ambient spam | **PASS** |

**Overall Pass 1A:** **PASS** — implementation correct; placeholder quality is intentionally minimal.

---

## Pass 1A validation (2026-07-06)

**Method:** Static code audit of binder, catalog, autoload, and shell wiring; asset presence check; signal-path tracing for all catalog events in `TestWorld` and `VerticalSlice_Level_P1`.

### Validation summary

| Area | Result |
|------|--------|
| All 17 events have catalog entries + stream paths | **PASS** |
| Six placeholder WAVs present under `assets/audio/placeholders/` | **PASS** |
| `GameAudio` autoload registered in `project.godot` | **PASS** |
| `bind_game_root` called from `test_world.gd` and `vertical_slice_world_shell.gd` | **PASS** |
| Combat / UI / Dragon buses created at runtime | **PASS** |
| Per-event cooldowns prevent obvious spam | **PASS** |
| Intentionally silent systems remain unbound | **PASS** |

### Issues discovered

| Issue | Severity | Resolution |
|-------|----------|------------|
| `SceneTree.node_added` could leak duplicate handlers after slice reload if old game root freed before `unbind` | **Bug** | Store `_bound_tree` in binder; disconnect via stored tree ref |
| Slice reload (`Ctrl+Shift+R`) did not unbind audio before `queue_free` | **Bug** | Call `GameAudio.unbind_game_root()` before freeing viewport children |
| `_is_brute()` required `slice_archetype` meta only — missed enemies using `_get_archetype()` default | **Bug** | Use `_get_archetype()` when available (matches `enemy.gd`) |
| `unbind_game_root()` did not disconnect player/dragon signals | **Hardening** | Explicit disconnect on unbind for clean rebind |

### Fixes applied (Pass 1A)

| File | Change |
|------|--------|
| `scripts/audio/game_audio_binder.gd` | Tree signal leak fix; player/dragon disconnect on unbind; brute detection via `_get_archetype()` |
| `scripts/world/vertical_slice_world_shell.gd` | Unbind audio before slice reload |

### Remaining limitations (not failures)

- **Placeholder quality** — procedural WAVs; final assets deferred to Audio Pass 2.
- **CC multi-enemy hits** — may play up to one `PLAYER_HIT` per enemy per swing; 50 ms cooldown reduces machine-gunning but does not collapse multi-hit to one sound (acceptable for Pass 1).
- **Encounter + relationship** — `ENCOUNTER_COMPLETE` and relationship toast may play in quick succession at resolve (intentional layering).
- **Manual listening pass** — recommended in-editor for subjective mix/timing; static validation confirms wiring and routing.

### Implementation notes (post–Pass 1A)

- Brute audio (`BRUTE_HEAVY`, `BRUTE_RESIST`) requires Brute archetype — available in TestWorld via startup mix (`EnemyC`) and slice encounters (`The Gate`, etc.).
- `ENEMY_HIT` enum remains catalogued for future split; binder plays `PLAYER_HIT` on connect.

---

## Playtest checklist (original — Pass 1 design reference)

## Related documents

| Document | Update |
|----------|--------|
| [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md) | Roadmap — Audio Feedback Pass 1 complete |
| [`project_checkpoint_vertical_slice_polish_1A.md`](./project_checkpoint_vertical_slice_polish_1A.md) | Visual feedback unchanged; audio complements Pass 1A |
| [`audio_placeholder_assets.md`](../audio/audio_placeholder_assets.md) | Placeholder regeneration + mapping |
