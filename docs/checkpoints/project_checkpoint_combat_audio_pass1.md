# Dragon Rider RPG — Combat Audio Pass 1 Checkpoint

**Also filed as:** Combat Audio Polish Pass 1 (same milestone)  
**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn` (F6)  
**Audio architecture:** [`project_checkpoint_audio_feedback_pass1.md`](./project_checkpoint_audio_feedback_pass1.md)  
**Documentation:** [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md)  
**Status:** **COMPLETE**  
**Date:** 2026-07-06

---

## Milestone Summary

Combat Audio Pass 1 delivers playable melee audio for the vertical slice:

- **User-recorded swing whooshes** per weapon (dagger / sword / polearm), separate from impacts
- **Processed weapon impacts** in `weapon_impact_library_v1`
- **Weapon audio profiles** decoupled from reach class and enemy archetype
- **Consistent player + enemy impact routing** through `WeaponIdentity` → `WeaponAudioProfile`
- **CC swing sequence**, volume trims, swing ducking on impact, and animation alternation polish

Ready for future weapons (staff, axe, club, hammer, magical) by extending profile arrays only.

---

## Swing Audio (Whoosh)

| Weapon | Asset | Source |
|--------|-------|--------|
| Dagger | `assets/audio/placeholders/swing_dagger.wav` | `tools/user_swing_sources/` |
| Sword | `assets/audio/placeholders/swing_sword.wav` | User recordings |
| Polearm | `assets/audio/placeholders/swing_polearm.wav` | User recordings |

Import: `python tools/import_user_swing_placeholders.py`

CC uses three timed plays of the weapon swing with catalog pitch/volume lifts (not combo WAV files).

---

## Melee Impact Audio (`weapon_impact_library_v1`)

| Profile | Files | Weapon identity |
|---------|-------|-----------------|
| `hit_dagger` | `hit_dagger_01.wav` | Dagger · Scout |
| `hit_sword` | `hit_sword_01.wav`, `hit_sword_02.wav` | Sword · Raider |
| `hit_polearm` | `hit_polearm_01.wav` | Polearm · Brute |

**Locations:** `assets/audio/weapon_impact_library_v1/` · `tools/weapon_impact_library_v1/`  
**Import:** `python tools/import_weapon_impact_library_v1.py`

### Architecture

| Layer | Script | Responsibility |
|-------|--------|----------------|
| Reach class | `weapon_reach_class.gd` | Range, arc, spacing (gameplay) |
| Weapon identity | `weapon_identity.gd` | Dagger, sword, polearm, … |
| Audio profile | `weapon_audio_profile.gd` | Impact variation arrays |

Combat calls `GameAudio.play_weapon_impact(identity, position)`. Enemies use `get_weapon_identity()` from equipped weapon meta — **not** hardcoded archetype audio.

### Playback rules

- Impact on successful damage only (`attack_hit`, `attacked_player`)
- One impact per player attack
- Random variation; max 2 consecutive repeats of same index
- Active swings ducked ~12% during impact
- `impact.wav` placeholder reserved for `PLAYER_DAMAGED` only

---

## Validation Checklist

| Check | Result |
|-------|--------|
| Player dagger → `hit_dagger` profile | **PASS** (code) |
| Player sword → `hit_sword` random variation | **PASS** (code) |
| Player polearm → `hit_polearm` profile | **PASS** (code) |
| Scout → dagger profile via weapon identity | **PASS** (code) |
| Raider → sword profile via weapon identity | **PASS** (code) |
| Brute → polearm profile via weapon identity | **PASS** (code) |
| Impact only on successful hits | **PASS** (code) |
| No impact on miss (`ATTACK_MISS` only) | **PASS** (code) |
| Swings independent from impacts | **PASS** (code) |
| No synthesized melee hit on connect | **PASS** (`PLAYER_HIT`/`ENEMY_HIT` empty in catalog) |
| Reach / identity / audio profile separated | **PASS** (code) |
| Future weapons = profile array only | **PASS** (design) |
| Live playtest sign-off | **Pending manual run** |

---

## Key Files

| Area | Files |
|------|-------|
| Impact library | `assets/audio/weapon_impact_library_v1/*` |
| Swing placeholders | `assets/audio/placeholders/swing_*.wav` |
| Profiles | `weapon_reach_class.gd`, `weapon_identity.gd`, `weapon_audio_profile.gd` |
| Audio service | `game_audio.gd`, `game_audio_catalog.gd`, `game_audio_binder.gd` |
| Equipment | `weapon_profile_prototype.gd`, `vertical_slice_archetype_presets.gd`, `enemy.gd` |
| Import tools | `import_user_swing_placeholders.py`, `import_weapon_impact_library_v1.py` |

---

## Known Follow-ups

- `hit_sword_01` and `hit_sword_02` are identical until a distinct second sword variation is supplied
- `BRUTE_HEAVY` event remains in catalog but enemy attacks use weapon impacts
- Production Audio Pass 2 can swap WAV paths without combat refactors

---

## Next Milestone Candidates (not started)

Documented for planning only — **do not implement yet**:

1. **Hit feedback polish** — hit-stop tuning, recoil, stagger feel, particles, camera shake  
2. **Combat interaction depth** — enemy reactions, shield/block, armor/material hit responses  
3. **Weapon system expansion** — short/medium/long framework, staff/axe/club/hammer/spear with unique audio profiles  
4. **Enemy combat readability** — clearer windups, attack tells, weapon-specific behavior  

**Immediate next gate:** Structured Vertical Slice Playtest (see [`PROJECT_STATE.md`](../PROJECT_STATE.md)).

---

## Related Documentation

| Document | Role |
|----------|------|
| [`project_checkpoint_audio_feedback_pass1.md`](./project_checkpoint_audio_feedback_pass1.md) | Base `GameAudio` architecture |
| [`audio_placeholder_assets.md`](../audio/audio_placeholder_assets.md) | Non-impact placeholder policy |
| [`assets/audio/weapon_impact_library_v1/README.md`](../../assets/audio/weapon_impact_library_v1/README.md) | Impact library reference |
