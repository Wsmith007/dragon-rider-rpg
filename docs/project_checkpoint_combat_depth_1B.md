# Dragon Rider RPG — Combat Depth Pass 1B Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** `res://scenes/world/TestWorld.tscn` or `VerticalSlice_Level_P1.tscn` (F6)  
**Design journal:** [`combat_feel_notes.md`](combat_feel_notes.md) → Combat Depth Pass 1 Phase A + Phase B  
**Vertical slice design:** [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md) → Milestone 3  
**Prior combat reference:** [`project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md) (Passes 1–7 melee prototype)

**Status:** Stable reference for **Combat Depth Pass 1 Phase A + Phase B** — movement foundation and Target Focus.  
**Scope:** Combat Stance, weapon movement identity, attack facing commitment, Target Focus, debug readouts.  
**Not in scope:** shields, blocking, stamina, dodge rolls, camera lock-on, auto-hit, enemy rebalance, bond/sync/instability changes.

**Date:** 2026-05-29 · **Playtest validation:** pending

---

## Milestone Summary

| Feature | Status |
|---------|--------|
| Combat Stance (hold Ctrl) | **Live** |
| Weapon movement identity (dagger / sword / polearm) | **Live** |
| Attack facing commitment | **Live** |
| Target Focus (Caps Lock / Tab / Shift+Tab) | **Live** |
| Auto-retarget on focused enemy death | **Live** |
| Movement states + debug readouts | **Live** |
| Camera lock-on | **Not implemented** |
| Auto-hit / attack snap | **Not implemented** |
| Shield block / poise / punish windows | **Planned (Phase C+)** |

---

## Combat Stance

Combat Stance is a **general rider control mode** — not tied to shields or equipment. It is the long-term foundation for shields, bows, magic, spear bracing, and dragon combo abilities.

| Behavior | Detail |
|----------|--------|
| **Input** | **Hold Ctrl** (`combat_stance` — left or right Ctrl) |
| **Facing** | Current facing captured on press; held while Ctrl is held |
| **Movement** | World-space WASD (W north, S south, A west, D east); facing stays locked |
| **Release** | Returns to normal locomotion; visual facing lerps smoothly (`visual_facing_lerp_speed` ≈ 14) |
| **Attacks** | Focused and CC use locked stance facing (or attack-locked facing once a swing starts) |

**Why Ctrl:** LMB / Space / J attack; Shift+Space is CC; Q is dragon command. Bond debug uses **Ctrl+number** only — hold-Ctrl does not conflict.

### Weapon movement identity (Phase A)

Move speed is part of weapon identity on top of attack profiles:

| Weapon | Move multiplier | Effective speed (220 base) | Identity |
|--------|-----------------|----------------------------|----------|
| **Dagger** | 1.14× | ~251 px/s | Fastest — precision, reposition |
| **Sword** | 1.00× | 220 px/s | Baseline — sustained DPS |
| **Polearm** | 0.84× | ~185 px/s | Slowest — control, reach tradeoff |

Attack wind-up and recovery slowdowns stack multiplicatively on top of weapon move speed.

### Attack facing commitment

On attack start, `lock_attack_facing()` captures current combat facing. Facing does **not** follow velocity for the full attack sequence (wind-up → impact → recovery). Prevents mid-swing 180° snaps while keeping attacks responsive. Unlocks on attack completion or player stagger from enemy hits.

### Movement states

| State | When | Facing source |
|-------|------|---------------|
| **Running** | Default locomotion | Velocity when moving; last facing when idle |
| **Combat Stance** | Ctrl held | Locked stance direction |
| **Target Focus** | Caps Lock focus active | Tracked enemy |
| **Attacking** | Focused / CC sequence | Locked at attack start |
| **Staggered** | Enemy hit reaction | Frozen |
| **Dead** | HP depleted | Frozen |

State label priority for debug UI: Dead → Staggered → Attacking → Target Focus → Combat Stance → Running.

**Facing authority priority:** Attack lock → Target Focus → Combat Stance → velocity.

---

## Target Focus

**Purpose:** Ocarina-of-Time-style **Target Focus** — maintain player intent to face a chosen enemy while moving.

> *"I want to keep facing this enemy while I move."*

| Concept | Detail |
|---------|--------|
| **What it is** | Facing lock toward a **player-chosen** enemy |
| **What it is not** | Camera lock, auto-attack, hit guarantee, movement assist, Souls-style orbit lock |
| **Model** | Zelda / OoT — orbit and approach/retreat naturally because facing tracks the target |

Target Focus controls **facing only**. Attacks remain **physical** — weapon cone, range, half-angle, close-range forgiveness, and enemy positions still determine hits.

### Caps Lock toggle

| Input | Action |
|-------|--------|
| **Caps Lock** | Toggle focus — acquire best target if off; clear if on |

**On toggle ON (no current focus):**

1. Gather alive enemies within **320 px** (`FOCUS_RANGE`)
2. Score candidates: in-front preference (±75°), centered angle, distance
3. Lock best candidate; if none valid, toggle stays off (no-op)

**On toggle OFF:** Clears focus and sets `_focus_enabled = false`. The system will **not** auto-acquire again until the player toggles Caps Lock on.

Input action: `target_focus_toggle`.

### Tab / Shift+Tab cycling

While focus is active:

| Input | Action |
|-------|--------|
| **Tab** | Next valid target (`target_focus_next`) |
| **Shift + Tab** | Previous valid target (`target_focus_prev`) |

Valid enemies within range are sorted by **world angle** around the player (stable wrap order). Tab / Shift+Tab cycle forward/back. With only one valid enemy, Tab keeps the same target.

### Auto-retarget on enemy death

When focus is **enabled** (`_focus_enabled = true`), the system auto-retargets to the **nearest valid enemy** within 320 px when:

- Focused enemy **dies**
- Focused enemy **despawns** or becomes invalid
- Focused enemy moves **beyond 320 px** (nearest replacement if any)

**Initial acquire** (Caps Lock on) prefers enemies **in front** (scored). **Auto-retarget** uses **nearest distance only**.

Focus **clears** (no retarget) when:

- Player toggles Caps Lock off manually
- No valid enemies remain within range after a retarget attempt
- Player **dies**

Focus does **not** clear when: a wall blocks line of sight, the player misses, the dragon hits elsewhere, or the player takes damage.

---

## Interaction with weapon arcs

Target Focus does **not** change hit detection.

| System | Behavior with focus active |
|--------|----------------------------|
| **Focused attack cone** | Still uses weapon profile range, half-angle, close-range forgiveness |
| **Hit query** | Still tests enemy positions against cone geometry at impact frame |
| **Likely-target preview** (Pass 7 cyan ring) | Still shows who would be hit **if you attack now** — independent of focus choice |
| **Telegraphs** | Face locked target while focus active; wedge geometry unchanged |
| **F11 debug** | Yellow line = likely preview target; blue line = focused target |

Facing toward an enemy **helps** land hits but does **not** guarantee them. Wrong spacing, arc width, or enemy movement still causes misses.

---

## Interaction with Combat Stance

Both systems can be active simultaneously:

| System | Role |
|--------|------|
| **Combat Stance (Ctrl)** | Lock facing to a **direction**; world-space strafe/backpedal |
| **Target Focus** | Lock facing to an **enemy** |

**When both active:** Target Focus **wins** for facing — the rider continuously tracks the focused enemy. Combat Stance still applies **movement input semantics** (world-space WASD while Ctrl held). A single facing authority prevents jitter.

**During attacks:** Attack facing lock overrides both until the swing completes or the player is staggered.

**Practical roles:**

- **Stance alone** — hold a lane or direction while kiting without a clear single target
- **Focus alone** — orbit a chosen threat while moving freely (normal WASD facing rules when not in stance)
- **Both** — strafe/backpedal in stance while keeping eyes on one enemy

---

## No camera lock

Target Focus does **not**:

- Reparent or constrain the camera
- Orbit the camera around the player–target axis
- Zoom, frame, or soft-lock the view

Camera follow behavior is unchanged (`camera_follow.gd`). The player manually repositions the view by moving; focus only rotates the rider visual and attack facing.

---

## No auto-hit behavior

Target Focus does **not**:

- Auto-trigger attacks
- Snap attacks through defenders to the focused enemy
- Ignore cone angle or range checks
- Redirect CC or focused hits to the focused target if geometry says miss
- Assist movement toward the target (no magnetism, no strafe orbit assist)

Combat remains positioning-first: choose when to attack, which attack, and where to stand.

---

## Visual feedback

| Visual | Meaning |
|--------|---------|
| **Cyan ring** (Pass 7) | Likely hit if you attack **now** (cone logic) |
| **Bright blue ring** (Phase B) | Enemy **you chose** to face |
| **BondTestHelpUI** | Target focus active yes/no; focused target name + instance id |

---

## Current limitations

| Area | Limitation |
|------|------------|
| **Playtest** | Phase A + B implemented but not yet signed off in structured playtest |
| **Shields / block** | Combat Stance is movement-only — no raise/block/stamina |
| **Punish windows** | No extended recovery vulnerability tuning (Phase C+) |
| **Camera** | No lock-on camera — some players may want optional soft focus cam later |
| **Dragon integration** | Focus does not set dragon command target or assist target |
| **Magic / bow** | No reticle or aim-down-sights tied to focus |
| **Multi-floor / elevation** | 2D plane only — no vertical aim assist |
| **Focus range** | Hard 320 px cutoff — no falloff or partial tracking |
| **Acquire vs retarget** | Initial pick is front-biased; kill retarget is nearest-only — behavior differs by design |
| **Enemy AI** | Focus does not change enemy behavior; Scouts still skirmish, Brutes still commit |
| **Animation** | Facing is visual rotation lerp — no dedicated lock-on anim set |
| **Audio** | No focus acquire / retarget / clear cues |

**Intentionally unchanged:** bond, sync, instability, relationship, encounter scoring, dragon AI, enemy balance tables, weapon damage profiles, camera follow logic.

---

## Recommended next milestone

### Combat Depth Pass 1 Phase C+ (recommended)

Validate Phase A + B in playtest first, then:

1. **Shield block prototype** — raise/block while Combat Stance held; facing toward focused enemy when both active
2. **Enemy punish windows** — readable recovery gaps after whiff or heavy commit (especially vs Brute)
3. **Extended recovery tuning** — weapon-specific vulnerability after full attack cycle
4. **Focus polish (optional)** — acquire/retarget audio; optional camera bias (not full Souls lock)

### After Combat Depth validates

Per [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md):

- **Player Polish Pass** — combat audio, minimal attack animation, player-facing bond feedback, hide dev UI in player builds

### Playtest checklist (Phase A + B)

1. Combat Stance — strafe/backpedal without orbit-spinning; Ctrl comfortable alongside attacks  
2. Weapon move speeds — dagger / sword / polearm feel distinct  
3. Attack facing lock — no mid-swing 180° snaps  
4. Target Focus — easier to keep attention on one enemy without auto-combat feel  
5. Caps Lock — toggle and manual off behave predictably  
6. Tab cycling — stable order, wraps correctly in packs  
7. Auto-retarget — focused enemy death jumps to nearest; manual Caps Lock off does **not** re-acquire  
8. Weapon arcs — misses still happen at bad spacing; focus is help, not guarantee  
9. Stance + focus together — no facing jitter; stance movement still useful  
10. Brute / Scout encounters — focus helps readability without trivializing archetype threat  

---

## Implementation files

| File | Role |
|------|------|
| `scripts/player/player.gd` | Movement states, Combat Stance, facing priority, attack lock |
| `scripts/player/player_target_focus.gd` | Acquisition, cycling, validation, auto-retarget, input |
| `scripts/player/player_melee_attack.gd` | Attack facing lock; telegraph facing |
| `scripts/combat/combat_target_focus_indicator.gd` | Blue focus ring |
| `scripts/combat/combat_attack_telegraph.gd` | F11 focus debug line |
| `scripts/combat/weapon_profile_prototype.gd` | Weapon move speed multipliers |
| `scripts/ui/bond_test_help_ui.gd` | Live movement + focus readouts |
| `scenes/player/Player.tscn` | TargetFocus + indicator nodes |
| `project.godot` | `combat_stance`, `target_focus_toggle`, `target_focus_next`, `target_focus_prev` |

---

## Related documents

| Document | Use |
|----------|-----|
| [`combat_feel_notes.md`](combat_feel_notes.md) | Pass-by-pass journal with playtest questions |
| [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md) | Milestone 3 scope and slice roadmap |
| [`project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md) | Melee prototype Passes 1–7 reference |
