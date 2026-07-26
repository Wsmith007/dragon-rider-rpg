# Dragon Rider RPG — Audio Feedback Pass 1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn` (F6)  
**Design constitution:** [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md)  
**Placeholder assets:** [`audio_placeholder_assets.md`](../audio/audio_placeholder_assets.md)  
**Player feedback layer:** [`project_checkpoint_vertical_slice_polish_1A.md`](./project_checkpoint_vertical_slice_polish_1A.md)

**Status:** **IMPLEMENTED** — Pass 1 **complete** · Pass 1A **COMPLETE** (2026-07-06 user sign-off)  
**Scope:** Centralized audio manager, event catalog, placeholder playback — **no combat balance, AI, dragon behavior, or relationship math changes**  
**Date:** 2026-07-05 (Pass 1) · 2026-07-06 (Pass 1A validation + fixes + mix balance + **final playtest sign-off**)  
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

**SubViewport requirement:** Gameplay runs inside `GameplayViewport` (`playtest_shell.gd`). Positional `AudioStreamPlayer2D` nodes are reparented under the game root in that viewport. The SubViewport must have `audio_listener_enable_2d = true` or combat/dragon audio is silent while UI (non-positional) audio still plays.

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
| `DRAGON_ASSIST` | `StrikeBehavior.strike_started` (ASSIST) | `dragon_soft.wav` |
| `DRAGON_PROTECT` | `StrikeBehavior.strike_started` (PROTECTION) | `dragon_soft.wav` |
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
| `Dragon` | `StrikeBehavior.strike_started`, `CommandBehavior.wait_position_set` |
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
| **Pass 1A** | **Complete** — see [Pass 1A sign-off](#pass-1a-sign-off-2026-07-06) |
| **Dragon Personality Pass 1** | Dragon personality voice lines (separate from presence cues) |
| **Pass 2** | Per-weapon swings, distinct UI stingers, mix pass |
| **Pass 3** | Ambient zone beds, music stub, volume settings menu |
| **Polish** | Attack animation sync, hitstop audio lockstep |

---

## Playtest checklist (Pass 1A)

| # | Check | Result (final playtest 2026-07-06) |
|---|-------|-------------------------------------|
| 1 | Focused swing — wind-up; impact on connect; faint miss on whiff | **PASS** |
| 2 | CC swing — lower pitch than focused; hits on connect | **PASS** |
| 3 | Brute hit on player — heavy thud; brute resist variant | **PASS** (when Brute present) |
| 4 | Target focus — soft blips on acquire / switch / clear | **PASS** |
| 5 | Encounter end — subtle stinger with summary panel | **PASS** |
| 6 | Relationship toast — improved vs strained audibly distinct | **PASS** |
| 7 | Dragon assist / protect / wait — noticeable during gameplay | **PASS** |
| 8 | Silence during exploration and follow — no ambient spam | **PASS** |

**Overall Pass 1A:** **COMPLETE** — placeholder audio architecture validated in live playtest (`TestWorld` + `VerticalSlice_Level_P1`). Asset identity deferred to Audio Pass 2.

---

## Pass 1A validation (2026-07-06 — initial, superseded)

**Method:** Static code audit of binder, catalog, autoload, and shell wiring; asset presence check; signal-path tracing for all catalog events in `TestWorld` and `VerticalSlice_Level_P1`.

**Outcome:** Incorrectly marked **PASS**. Static tracing confirmed signal wiring and catalog entries but did not reproduce runtime playback inside the Developer Experience `SubViewport` shell.

### Validation summary (static only)

| Area | Result |
|------|--------|
| All 17 events have catalog entries + stream paths | **PASS** |
| Six placeholder WAVs present under `assets/audio/placeholders/` | **PASS** |
| `GameAudio` autoload registered in `project.godot` | **PASS** |
| `bind_game_root` called from `test_world.gd` and `vertical_slice_world_shell.gd` | **PASS** |
| Combat / UI / Dragon buses created at runtime | **PASS** |
| Per-event cooldowns prevent obvious spam | **PASS** |
| Intentionally silent systems remain unbound | **PASS** |
| **Positional audio audible during gameplay** | **FAIL** (missed) |

### Issues discovered (initial pass)

| Issue | Severity | Resolution |
|-------|----------|------------|
| `SceneTree.node_added` could leak duplicate handlers after slice reload if old game root freed before `unbind` | **Bug** | Store `_bound_tree` in binder; disconnect via stored tree ref |
| Slice reload (`Ctrl+Shift+R`) did not unbind audio before `queue_free` | **Bug** | Call `GameAudio.unbind_game_root()` before freeing viewport children |
| `_is_brute()` required `slice_archetype` meta only — missed enemies using `_get_archetype()` default | **Bug** | Use `_get_archetype()` when available (matches `enemy.gd`) |
| `unbind_game_root()` did not disconnect player/dragon signals | **Hardening** | Explicit disconnect on unbind for clean rebind |

### Fixes applied (Pass 1A initial)

| File | Change |
|------|--------|
| `scripts/audio/game_audio_binder.gd` | Tree signal leak fix; player/dragon disconnect on unbind; brute detection via `_get_archetype()` |
| `scripts/world/vertical_slice_world_shell.gd` | Unbind audio before slice reload |

---

## Pass 1A follow-up investigation (2026-07-06)

**Trigger:** Real playtest contradicted initial PASS. Player-reported symptoms:

| Audible | Not audible |
|---------|-------------|
| Lock-on engage / disengage / switch | Player weapon swing |
| Encounter completed | Player weapon hit |
| | Enemy combat sounds |
| | Dragon assist / protection / wait |

### Root cause

**`GameplayViewport` (`SubViewport`) had `audio_listener_enable_2d = false` (Godot default).**

Developer Experience Pass 1 renders all gameplay inside a `SubViewport`. `GameAudio` routes UI events through non-positional `AudioStreamPlayer` nodes on the autoload (main tree) — these played correctly. Combat and dragon events use `AudioStreamPlayer2D`, reparented under the game root inside the `SubViewport` for world positions. Without a 2D audio listener on that viewport, **all positional playback was silent** even though signals fired and `play()` ran successfully.

This explains the split symptom exactly: UI bus events audible; Combat and Dragon bus events inaudible.

### Why initial validation missed it

1. **Static audit only** — traced signals, catalog, and `bind_game_root` calls but never executed audio inside the shell `SubViewport`.
2. **No runtime listening pass** — checklist marked PASS from code inspection.
3. **Assumed `AudioStreamPlayer2D` on game root equals audible** — missed Godot's SubViewport listener requirement ([Using Viewports](https://docs.godotengine.org/en/stable/tutorials/rendering/viewports.html) — *"don't forget to enable"* 2D listener on viewports used for world display).

Signal wiring, binder discovery, cooldowns, buses, and placeholder assets were **correct**. The failure was **viewport audio routing**, not missing gameplay signals.

### Fixes applied (follow-up)

| File | Change |
|------|------|
| `scripts/world/playtest_shell.gd` | Set `_game_viewport.audio_listener_enable_2d = true` in `_ready()` |
| `scenes/world/TestWorld.tscn` | `audio_listener_enable_2d = true` on `GameplayViewport` |
| `scenes/world/VerticalSlice_Level_P1.tscn` | `audio_listener_enable_2d = true` on `GameplayViewport` |

No changes to `GameAudio`, catalog, binder signal names, or gameplay emitters were required.

### Pipeline verification (post-fix, static)

| Stage | Combat / dragon events | UI events |
|-------|------------------------|-----------|
| Gameplay action emits signal | ✓ `attack_swing_started`, `attack_hit`, `state_changed`, etc. | ✓ `focus_changed`, `encounter_result_ready` |
| `GameAudioBinder` connected | ✓ | ✓ |
| `GameAudio.play()` called | ✓ | ✓ |
| Stream preloaded | ✓ six WAVs | ✓ |
| Player type | `AudioStreamPlayer2D` → Combat / Dragon bus | `AudioStreamPlayer` → UI bus |
| Parent node | Game root inside `SubViewport` | `GameAudio` autoload |
| Viewport listener | **Now enabled** | N/A (non-positional) |

### Remaining limitations (not failures)

- **Placeholder quality** — procedural WAVs; final assets deferred to Audio Pass 2.
- **CC multi-enemy hits** — may play up to one `PLAYER_HIT` per enemy per swing; 50 ms cooldown reduces machine-gunning but does not collapse multi-hit to one sound (acceptable for Pass 1).
- **Encounter + relationship** — `ENCOUNTER_COMPLETE` and relationship toast may play in quick succession at resolve (intentional layering).
- **Manual listening pass** — **required** to mark Pass 1A PASS after this fix; automated headless audio validation not run in this session.
- **Enemy generic hit sounds** — `ENEMY_HIT` catalogued for future split; binder plays `PLAYER_HIT` on connect (no separate enemy-hit sting).

### Implementation notes (post–follow-up)

- Brute audio (`BRUTE_HEAVY`, `BRUTE_RESIST`) requires Brute archetype — available in TestWorld via startup mix (`EnemyC`) and slice encounters (`The Gate`, etc.).
- `ENEMY_HIT` enum remains catalogued for future split; binder plays `PLAYER_HIT` on connect.
- Dragon wait audio fires on `CommandBehavior.wait_position_set` — only when player issues wait command; follow/alert movement remains intentionally silent.

---

## Pass 1A final follow-up (2026-07-06)

**Trigger:** Post–SubViewport-fix playtest — swings and UI audible; hits extremely quiet; dragon completely silent.

### Issue 1 — Hit sounds too quiet

| Factor | Finding |
|--------|---------|
| Intentional? | Partially — catalog had `PLAYER_HIT` at -5 dB vs `PLAYER_SWING` at -8 dB (hit was already configured louder). |
| Bug? | **Distance attenuation** — hits played at `enemy.global_position` while swings at player/listener anchor; `AudioStreamPlayer2D.attenuation = 1.0` reduced hit level in typical melee spacing. |
| Tuning | **Placeholder timbre** — `impact.wav` is a narrow 180 Hz sine; `swing.wav` is broadband noise. Same peak amplitude reads quieter to the ear. |
| Fix | `attenuation = 0.0` on world players (top-down slice); hit position lerped 35% from player toward enemy; catalog `PLAYER_HIT` -5 → **-1 dB** (documented sine-vs-noise compensation). |

### Issue 2 — Dragon audio silent

| Stage | Before fix | After fix |
|-------|------------|-----------|
| Gameplay trigger | Strike begins (`try_begin_assist` / `try_begin_protection`) | Same |
| Signal | `state_changed` edge → `ASSISTING` / `PROTECTING` | **`StrikeBehavior.strike_started`** (authoritative) |
| Binder | Edge detection on `state_changed` | `_on_dragon_strike_started(kind)` |
| Catalog | `dragon_soft.wav` @ -12 to -16 dB; source level **0.06** vs swing **0.14** | Compensated to -5 / -3 / -8 dB |
| Root cause | Wrong signal for audio moment + placeholder level far below swing + distance attenuation | Repaired |

**Why `state_changed` was insufficient:** HUD and communication systems consume `state_changed` successfully, but audio used edge detection on combat states that can align poorly with the moment the player sees/hears the strike begin. `strike_started` fires exactly when `DragonStrikeBehavior` commits to a strike — matching player expectation.

### Mix adjustments (Pass 1A final)

| Event | Was | Now | Rationale |
|-------|-----|-----|-----------|
| `PLAYER_HIT` | -5 dB | **-1 dB** | Narrowband placeholder + prior distance attenuation |
| `DRAGON_ASSIST` | -12 dB | **-5 dB** | `dragon_soft.wav` source 0.06 vs swing 0.14 |
| `DRAGON_PROTECT` | -10 dB | **-3 dB** | Same |
| `DRAGON_WAIT` | -16 dB | **-8 dB** | Same (still subtle) |
| World `AudioStreamPlayer2D` | `attenuation = 1.0` | **`0.0`** | Top-down slice — no distance falloff for event cues |

### Files modified (final follow-up)

| File | Change |
|------|--------|
| `scripts/audio/game_audio.gd` | World player `attenuation = 0.0` |
| `scripts/audio/game_audio_catalog.gd` | Hit + dragon catalog level normalization |
| `scripts/audio/game_audio_binder.gd` | Dragon → `strike_started`; hit listener-anchor lerp |

### Dragon audio diagnostic matrix (post-fix, static)

| Event | Gameplay triggered | Signal fired | Binder receives | GameAudio plays | Expected audible |
|-------|-------------------|--------------|-----------------|-----------------|------------------|
| Player swing | ✓ wind-up | ✓ `attack_swing_started` | ✓ | ✓ `PLAYER_SWING` | ✓ (confirmed) |
| Player hit | ✓ connect | ✓ `attack_hit` | ✓ | ✓ `PLAYER_HIT` | ✓ (re-test after mix) |
| Enemy hit | ✓ same | ✓ `attack_hit` | ✓ | ✓ `PLAYER_HIT` | ✓ (re-test after mix) |
| Dragon assist | ✓ strike begin | ✓ `strike_started`(ASSIST) | ✓ | ✓ `DRAGON_ASSIST` | Re-test |
| Dragon protect | ✓ strike begin | ✓ `strike_started`(PROTECTION) | ✓ | ✓ `DRAGON_PROTECT` | Re-test |
| Dragon wait | ✓ wait command | ✓ `wait_position_set` | ✓ | ✓ `DRAGON_WAIT` | Re-test (command only) |

---

## Pass 1A mix balance follow-up (2026-07-06)

**Trigger:** Live playtest after routing fixes — swings, lock-on, and encounter complete clearly audible; hits, enemy feedback, and dragon cues present but too soft to register during combat.

### Mix issue

| Factor | Finding |
|--------|---------|
| Bus routing | Not the cause — Combat / Dragon / UI buses all send to Master at default 0 dB. |
| Cooldowns | Not suppressing primary events — 50 ms hit / 350 ms dragon cooldowns are shorter than attack cadence. |
| Pitch | Lower pitch ranges on dragon/protect reduced perceived presence; tightened toward 1.0 for dragon events. |
| Placeholder amplitude | **Primary cause** — `dragon_soft.wav` generated at **0.06** vs `swing.wav` **0.14**; narrowband sines (`impact`, `dragon_soft`) read **6–10 dB quieter** than broadband noise at equal catalog dB. |
| Prior balance | Swings were tuned for readability first; hits/dragon inherited conservative “subtle by default” offsets from Pass 1 philosophy. |

### Catalog tuning (Pass 1A mix balance)

Priority: **encounter > hit / enemy feedback > dragon > swing > lock-on UI**

| Event | Before | After | Δ |
|-------|--------|-------|---|
| `ENCOUNTER_COMPLETE` | -10 dB | **-10 dB** | — (reference) |
| `PLAYER_HIT` / `ENEMY_HIT` | -1 dB | **+4 dB** | +5 |
| `PLAYER_DAMAGED` | -6 dB | **-1 dB** | +5 |
| `BRUTE_HEAVY` | -2 dB | **+1 dB** | +3 |
| `BRUTE_RESIST` | -10 dB | **-6 dB** | +4 |
| `ENEMY_DEFEATED` | -4 dB | **-2 dB** | +2 |
| `DRAGON_ASSIST` | -5 dB | **+2 dB** | +7 |
| `DRAGON_PROTECT` | -3 dB | **+3 dB** | +6 |
| `DRAGON_WAIT` | -8 dB | **-2 dB** | +6 |
| `PLAYER_SWING` | -8 dB | **-10 dB** | -2 (lighter) |
| `PLAYER_CC` | -6 dB | **-8 dB** | -2 |
| Lock-on UI (`TARGET_FOCUS_*`) | unchanged | unchanged | — |

All changes in `game_audio_catalog.gd` only — no asset or architecture changes.

### Validation status

| Scene | Status |
|-------|--------|
| `TestWorld` | Mix applied — **user listening pass pending** |
| `VerticalSlice_Level_P1` | Mix applied — **user listening pass pending** |

### Remaining placeholder limitations

- Procedural timbre still differs from final assets — Pass 2 replaces streams, not catalog philosophy.
- Dragon wait only fires on explicit wait command.
- No separate generic enemy-attack sting (non-Brute) — only `PLAYER_DAMAGED` and `BRUTE_HEAVY`.

---

## Pass 1A sign-off (2026-07-06)

**Reviewer:** Live user playtest (Informal Playtest transition)

### Final validation

| Area | Result |
|------|--------|
| Weapon swings clearly audible | **PASS** |
| Combat hit sounds clearly audible | **PASS** |
| Dragon assist / protect / wait clearly audible | **PASS** |
| Lock-on audio | **PASS** |
| Encounter completion audio | **PASS** |
| Both scenes (`TestWorld`, `VerticalSlice_Level_P1`) | **PASS** |
| Placeholder generic timbre acceptable for Pass 1A | **PASS** (identity deferred to Pass 2) |

### Pass 1A journey (summary)

1. Initial static validation — **incorrect PASS** (SubViewport listener missed).  
2. Follow-up — SubViewport `audio_listener_enable_2d`, dragon `strike_started` binding.  
3. Mix balance — catalog normalization for hit / enemy / dragon readability.  
4. **Final user playtest — PASS.** Milestone closed.

### Deferred to Audio Pass 2

Per-weapon streams, distinct hit layers, dragon motif splits — see [`playtest_observation_log.md`](../notes/playtest_observation_log.md) Observation #3.

---

## Related documents

| Document | Update |
|----------|--------|
| [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md) | Roadmap — Audio Feedback Pass 1 + 1A complete |
| [`project_checkpoint_vertical_slice_polish_1A.md`](./project_checkpoint_vertical_slice_polish_1A.md) | Visual feedback unchanged; audio complements Pass 1A |
| [`audio_placeholder_assets.md`](../audio/audio_placeholder_assets.md) | Placeholder regeneration + mapping |
| [`playtest_observation_log.md`](../notes/playtest_observation_log.md) | Informal playtest observations |
