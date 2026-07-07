# weapon_impact_library_v1

Processed melee impact placeholders for Emberbound / Dragon Rider RPG.

**Source:** User-recorded sword ping hits, packaged and renamed on import.  
**Import:** `python tools/import_weapon_impact_library_v1.py`

## Files

| File | Audio profile | Used by |
|------|---------------|---------|
| `hit_dagger_01.wav` | `hit_dagger` | Dagger identity |
| `hit_sword_01.wav` | `hit_sword` | Sword identity (variation 1) |
| `hit_sword_02.wav` | `hit_sword` | Sword identity (variation 2) |
| `hit_polearm_01.wav` | `hit_polearm` | Polearm identity |

## Architecture

Combat requests impact audio via `WeaponAudioProfile` using the attacker's **weapon identity**, not reach class.

- Reach class → gameplay range / arc (`WeaponReachClass`)
- Weapon identity → dagger, sword, polearm (`WeaponIdentity`)
- Audio profile → variation arrays (`WeaponAudioProfile`)

Add future weapons by dropping WAVs into this folder and extending `WeaponAudioProfile.PROFILE_STREAMS`.

## Notes

- Swing/whoosh sounds live in `assets/audio/placeholders/swing_*.wav` — unchanged by this library.
- `impact.wav` in placeholders is retained only for non-melee `PLAYER_DAMAGED` feedback.
