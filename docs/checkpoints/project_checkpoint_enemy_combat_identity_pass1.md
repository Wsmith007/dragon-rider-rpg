# Dragon Rider RPG — Enemy Combat Identity Pass 1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** LaunchMenu · `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn`  
**Related:** [`project_checkpoint_dragon_survivability_pass1.md`](./project_checkpoint_dragon_survivability_pass1.md) · [`project_checkpoint_enemy_archetype_pass1.md`](./project_checkpoint_enemy_archetype_pass1.md)  
**Documentation:** [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md)  
**Status:** **IMPLEMENTED — source validated; live playtest required**  
**Date:** 2026-07-25

---

## Goals

Make Scout / Raider / Brute immediately readable through **visible weapons** and give Brute one **charged rush** special without redesigning enemy AI.

---

## Enemy Weapon Identities

| Archetype | Weapon | Construction |
|-----------|--------|--------------|
| Scout | Dagger | Small close-body blade polygon |
| Raider | Sword | Medium practical blade |
| Brute | Warhammer | Heavy head silhouette (not polearm) |

Placeholder procedural polygons via `EnemyWeaponVisualStyle`, parented under `Visual/WeaponPivot/WeaponBlade` so facing rotation carries the weapon.

- Idle rest offset/angle per style
- Windup / strike pose during normal attacks
- Rush windup pulls warhammer back further
- Hitboxes remain AI/range driven — visuals do not define damage

Final art / skeletal animation deferred.

---

## Brute Charged Rush

### Activation

- Archetype Brute only
- Focus distance in **[88, 195]**
- Rush cooldown ready (**5.5 s**)
- Clear attack line to focus
- Active player or valid (non-KO) dragon target

### Telegraph (`RUSH_WINDUP` ~0.78 s)

- Crouch / scale posture change
- Darken modulate
- Warhammer pull-back pose
- `BRUTE_HEAVY` audio cue

### Rush (`RUSH` ~0.48 s @ 340 speed)

- Brief dash with limited turn correction (`rush_turn_rate` 1.1)
- Contact resolves once (player or dragon)
- Miss / timeout → recovery
- Wall collision ends rush

### Contact

| | Value |
|--|------:|
| Damage | Brute damage × **1.15** |
| Knockback | **58** |
| Stagger | **0.78 s** |
| Recovery | **0.9 s** (miss slightly longer) |

Normal Brute melee unchanged.

---

## Audio

| Event | Mapping |
|-------|---------|
| Rush charge | Existing `BRUTE_HEAVY` |
| Rush whoosh | Existing `PLAYER_SWING` placeholder (documented temporary) |
| Impacts | Existing player-damaged / heavy paths |

Does **not** change player `SWING_VOLUME_TRIM_DB = -3.0`.

---

## Deferred

- Final weapon art / animation
- Dedicated Brute rush whoosh asset
- Scout/Raider specials
- Complex aggro tables

---

## Manual Validation Checklist

- [ ] Scout dagger / Raider sword / Brute warhammer visible and face correctly
- [ ] Weapons animate on windup/lunge; cleanup on death
- [ ] Brute rush only at medium range; readable charge; dodgeable
- [ ] Hit applies once; miss recovers; cooldown respected
- [ ] Dragon can be rush target; KO dragon ignored
- [ ] Scout/Raider unchanged; soft targeting + interact revive still work
- [ ] No debugger errors

---

## Implementation Files

| File | Role |
|------|------|
| `scripts/enemies/enemy_weapon_visual_style.gd` | Placeholder weapon polygons |
| `scripts/enemies/enemy.gd` | Weapon attach + rush phases |
| `scripts/world/vertical_slice_archetype_presets.gd` | Apply weapon on spawn |

---

## Final Status

**IMPLEMENTED** for Pass 1 identity goals. Live developer playtest still required.
