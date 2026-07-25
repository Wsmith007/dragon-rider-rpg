# Dragon Rider RPG — Player Animation Pass 1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn` · LaunchMenu  
**Design constitution:** [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md)  
**Combat reference:** [`project_checkpoint_combat_feel_v1.md`](./project_checkpoint_combat_feel_v1.md) · [`project_checkpoint_combat_depth_1B.md`](./project_checkpoint_combat_depth_1B.md)  
**Documentation:** [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md)  
**Status:** **COMPLETE**  
**Date:** 2026-07-24  
**Validated:** Developer manual playtest — weapon identity, idle/rest, focused, CC, facing, and polearm visibility signed off

---

## Scope

Player Animation Pass 1 adds **minimal, presentation-only** idle, walk, and attack motion so combat feels more physical and weapons read more clearly at a glance.

**In scope:**

- Procedural animation driven by existing `MeleeAttack` signals and exported timings
- Per-weapon visual silhouette (dagger / sword / polearm)
- `VisualPivot` → `SpinLayer` hierarchy for facing + CC spin + weapon motion

**Not in scope:**

- Sprite sheets, AnimationPlayer libraries, combo chains, blending trees
- Gameplay timing, damage, hitbox, or balance changes
- Idle variants, breathing systems, facial animation

---

## Design Philosophy

- **Gameplay wins** — animation reads from live `focused_windup`, `focused_recovery`, `crowd_control_*` exports; no duplicate combat clocks.
- **Intentionally simple** — tweens + `_process` bob; no animation framework.
- **Weapon identity through motion** — arc size, body lean, blade length, and walk cadence differ per profile.
- **Immediate response** — attack motion begins on `attack_swing_started` the same frame combat does.
- **Local space convention** — in `VisualPivot` space, **-Y = forward** (attack direction), **+X = right-hand hold**.

---

## Final Behavior (Pass 1)

| Behavior | Result |
|----------|--------|
| Weapon identity | Dagger / sword / polearm each read distinctly in idle and attack |
| Idle / rest | Bottom-right rest pose; walk/idle bob per weapon |
| Focused attack | Rest → front → windup → strike sweep → recovery |
| CC attack | Prep to front → full 360° `SpinLayer` spin with weapon forward → recovery |
| Facing / movement | `VisualPivot` facing owned by `player.gd`; motion remains readable |
| Polearm visibility | Convex gold trapezoid silhouette — acceptable and signed off |

---

## Implementation Summary

| Component | Role |
|-----------|------|
| `player_combat_animation.gd` | Idle/walk bob; focused 5-phase and CC spin tweens synced to `MeleeAttack` |
| `player_weapon_visual_style.gd` | Per-weapon polygons, rest/front offsets, arc constants |
| `Player.tscn` | `VisualPivot` → `SpinLayer` → body + `WeaponPivot`/`WeaponBlade` |
| `player.gd` | Facing rotation applied to `VisualPivot` (gameplay unchanged) |
| `player_engagement.gd` | Body visual path updated for new hierarchy |
| `vertical_slice_level_p1.gd` | Restart modulate path → `VisualPivot/SpinLayer/Visual` |

**Signals used:** `attack_swing_started`, `attack_swing_finished`, `weapon_profile_changed`, `movement_state_changed`

**Not modified:** Hit detection, cooldowns, damage values, movement speed formulas, telegraphs, enemy AI, dragon behavior, audio.

### Focused attack visual phases

| Phase | Visual | Timing source |
|-------|--------|---------------|
| 1 Rest | Bottom-right | Start |
| 2 Bring forward | Center/front | `focused_windup × bring_forward_ratio` (~32%) |
| 3 Windup | One arc side | Remaining windup |
| 4 Strike | Opposite arc side | 0.04s visual snap at impact |
| 5 Recovery | Front → rest | `focused_recovery` |

### CC attack visual phases

| Phase | Visual | Timing source |
|-------|--------|---------------|
| Prep | Rest → front | `crowd_control_windup × 25%` |
| Spin | Full 360° on `SpinLayer`, weapon forward | Remaining windup + `crowd_control_impact_duration` |
| Recovery | Front → rest | `crowd_control_recovery` |

### Weapon identity (visual)

| Weapon | Blade read | Notes |
|--------|------------|-------|
| **Dagger** | Short, bright silver | Narrower arcs, snappier bob |
| **Sword** | Medium silver | Default silhouette |
| **Polearm** | Long gold convex shaft | Higher contrast; signed off readable |

---

## Files Modified

| File | Change |
|------|--------|
| `scripts/player/player_combat_animation.gd` | **New** — presentation tweens + idle/walk |
| `scripts/player/player_weapon_visual_style.gd` | **New** — per-weapon visual styles |
| `scenes/player/Player.tscn` | Visual hierarchy + script wiring + flash path |
| `scripts/player/player.gd` | Rotate `VisualPivot` instead of body polygon |
| `scripts/player/player_engagement.gd` | Updated body visual path |
| `scripts/world/vertical_slice_level_p1.gd` | Restart visual path (+ remove redundant Shift+R now owned by DeveloperInput) |

`CombatVisualFeedback` keeps default `../Visual`; `Player.tscn` overrides `visual_path` to `../VisualPivot/SpinLayer/Visual`.

---

## Playtest Checklist

- [x] Polearm visible at idle, focused, and CC (weapon 3)
- [x] Focused reads: rest → front → windup → sweep → recovery
- [x] CC reads as full 360° spin with weapon carried forward
- [x] Dagger / sword feel distinct and readable
- [x] Works facing multiple directions + with target focus
- [x] Walk/idle bob still visible per weapon
- [x] Hit timing and responsiveness unchanged
- [x] Hit flash / stagger / death still target body polygon
- [x] Nothing feels distracting or broken (developer sign-off)

---

## Validation Results

| Check | Result |
|-------|--------|
| Polearm convex polygon + explicit profile match | **PASS** |
| Focused 5-phase + CC spin layer wired | **PASS** |
| No changes to `player_melee_attack.gd` | **PASS** |
| Live Godot re-playtest (developer) | **PASS** — 2026-07-24 |

---

## Remaining Limitations

- CC spin rotates `SpinLayer` only — `VisualPivot` facing still owned by `player.gd`
- Placeholder polygon art — not final sprite shafts
- Focused strike snap remains a short visual-only beat (0.04s)

---

## Final Pass 1 Status

**COMPLETE** — developer-validated. Distinct weapon identities, idle/rest, focused and CC attacks, facing, and polearm visibility are signed off.

---

## Historical notes (resolved during Pass 1)

Earlier playtest iterations found: weapons reading behind the body (+Y blade geometry), missing polearm (non-convex polygon), and collapsed swing phases. Follow-up fixes 1–2 addressed rest anchors, forward (−Y) geometry, convex polearm silhouette, 5-phase focused motion, and CC `SpinLayer` spin. Those issues are closed.

---

## Future Animation Opportunities

- Sprite-based rider art replacing placeholder polygons
- `AnimationPlayer` migration once final art exists
- Directional attack variants (4/8-way)
- Shield-block pose when Combat Depth Phase C ships
- Mount/dismount and dragon-synced motion
- Hit-react animation on player beyond modulate + stagger freeze

---

## Related Documentation

| Document | Relationship |
|----------|----------------|
| [`project_checkpoint_combat_feel_v1.md`](./project_checkpoint_combat_feel_v1.md) | Attack timing authority |
| [`project_checkpoint_combat_depth_1B.md`](./project_checkpoint_combat_depth_1B.md) | Stance / focus — animation respects locked facing |
| [`project_checkpoint_vertical_slice_polish_1A.md`](./project_checkpoint_vertical_slice_polish_1A.md) | Combat floaters unchanged |
| [`PROJECT_STATE.md`](../PROJECT_STATE.md) | Systems table — Player Animation Pass 1 complete |
