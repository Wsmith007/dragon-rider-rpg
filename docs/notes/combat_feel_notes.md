# Combat Feel Notes

**Status:** Passes **1–7 are implemented** (prototype — not final). Sections below marked *future* or *design direction* are not live unless stated otherwise.  
**Documentation hierarchy:** [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md)  
**Current combat reference (live values & SoT):** [`../checkpoints/project_checkpoint_combat_feel_v1.md`](../checkpoints/project_checkpoint_combat_feel_v1.md)  
**Combat Depth Pass 1 (Phase A + B):** [`../checkpoints/project_checkpoint_combat_depth_1B.md`](../checkpoints/project_checkpoint_combat_depth_1B.md)  
**Relationship / bond reference:** [`../checkpoints/project_checkpoint_milestone9A.md`](../checkpoints/project_checkpoint_milestone9A.md)  
**High-level combat vision:** [`../design/combat.md`](../design/combat.md)

This document is the **pass-by-pass journal** and design notebook. For a single stable summary of live combat, use **Combat Feel v1**.

**Live prototype (Passes 1–7):** Directional focused attack + Shift+Space CC, aim forgiveness, telegraphs, attack commitment, and likely-target preview — see checkpoint and pass sections below.

**Weapon Profile Prototype Tuning Pass 1 (live):** Refined identities — sword highest DPS, dagger fastest/lowest DPS, polearm control — see [Weapon Profile Prototype Tuning Pass 1](#weapon-profile-prototype-tuning-pass-1).

**Vertical Slice Level P1 Fix Pass (2026-05-29):** Corridor layout fix, archetype readability, enemy attack telegraph/lunge, brute player knockback/stagger — see [Vertical Slice Level P1 Fix Pass](#vertical-slice-level-p1-fix-pass).

**Vertical Slice Level Pass 2 (2026-05-29):** Connected route — **complete.** See [Vertical Slice Level Pass 2](#vertical-slice-level-pass-2).

**Enemy Archetype Prototype Pass 1 (2026-05-29):** Scout / Raider / Brute behavioral roles — see [Enemy Archetype Prototype Pass 1](#enemy-archetype-prototype-pass-1). **Pass 1B complete** — see [Pass 1B](#enemy-archetype-prototype-pass-1b).

**Combat Depth Pass 1 Phase A (2026-05-29):** Movement foundation — **IMPLEMENTED** — see [Combat Depth Pass 1 Phase A](#combat-depth-pass-1-phase-a).

**Combat Depth Pass 1 Phase B (2026-05-29):** Target Focus System — **IMPLEMENTED** — see [Combat Depth Pass 1 Phase B](#combat-depth-pass-1-phase-b).

**Vertical Slice Polish Pass 1A (2026-05-29):** Player feedback & communication — **IMPLEMENTED** (playtest pending) — see [`project_checkpoint_vertical_slice_polish_1A.md`](../checkpoints/project_checkpoint_vertical_slice_polish_1A.md).

---

## Enemy Archetype Prototype Pass 1

**Status: IMPLEMENTED — playtest validation pending**

Design reference: [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md) Section 3.

**Principle:** Behavior defines the archetype. Statistics support behavior — not the other way around.

Each archetype answers:

1. **What lesson does this enemy teach?**
2. **What gameplay problem does it create?**
3. **What weakness can the player eventually exploit?**

### Scout — Skirmisher

| | |
|--|--|
| **Personality** | Impatient · opportunistic · evasive |
| **Lesson** | Positioning |
| **Problem** | Constant angular pressure |
| **Player decision** | *"Can I keep up?"* |

**Implemented behavior:**

- **Orbit chase** — tangential steering (`circle_bias` 0.58) instead of beeline rush  
- **Strafe engage** — circles in melee range; does not stand still trading hits  
- **DISENGAGE state** — after each attack, bursts away (0.72 s at 255 px/s) then re-engages  
- **Quick strike** — 0.28 s wind-up, 0.95 s cooldown (long reposition between hits)  
- **Low HP / low damage** — threat from movement, not stats  

**Visual:** small orange silhouette, gold accent.

**Future evolution:** punish during retreat window; precision hit vulnerability — not fully implemented.

### Raider — Baseline Fighter

| | |
|--|--|
| **Personality** | Disciplined · committed · confident |
| **Lesson** | Core melee combat loop |
| **Problem** | Direct sustained pressure |
| **Player decision** | *"Can I fight well?"* |

**Implemented behavior:**

- Unchanged prototype AI — IDLE → CHASE → ENGAGE with slot spread and engage reposition  
- Reference cadence for balancing Scout and Brute  
- No DISENGAGE / RECOVER states  

**Visual:** default red silhouette — neutral baseline.

### Brute — Control Check

| | |
|--|--|
| **Personality** | Relentless · intimidating · patient |
| **Lesson** | Space management |
| **Problem** | Cannot simply knock back and ignore |
| **Player decision** | *"Can I control space?"* |

**Implemented behavior:**

- **Slow approach** — 68 px/s chase, 30 px/s engage reposition  
- **Long wind-up** — 0.72 s telegraphed strike  
- **RECOVER state** — 0.58 s stillness after attack + 0.42 s bonus cooldown  
- **Knockback resistance** — focused hits (≤26 px) apply **zero** knockback; CC reduced to 35% before resistance (4.5×)  
- **Player impact** — 32 px knockback + 0.32 s stagger on hit  

**Visual:** large dark maroon silhouette.

**Deferred to next iteration:** full immunity to all knockback; heavy attacks; dragon combo interactions.

### Attack windows by archetype (Tuning Pass 1)

| Archetype | Wind-up | Strike | Recovery / reposition |
|-----------|---------|--------|------------------------|
| **Scout** | 0.24 s (quick) | 0.09 s lunge | 0.28 s sidestep + probe bursts + 0.62 s cooldown |
| **Raider** | 0.45 s | 0.11 s lunge | 1.0 s cooldown (baseline) |
| **Brute** | 0.72 s (committed) | 0.15 s lunge, **50 px** reach | No post-attack freeze — resumes advance immediately |

**Design philosophy:** Scout controls **tempo** · Raider controls **combat** · Brute controls **space**.

### Archetype Tuning Pass (playtest response)

**Scout — persistent skirmisher (probe model)**

- Replaced orbit steering with **probe bursts** — short directional feints near attack range  
- Stays within ~0.58–1.05× attack range; closes aggressively if too far  
- Abrupt direction changes every ~0.14–0.24 s; faster steering blend  
- **Probe pressure:** after 1.4 s without attacking, relaxed cooldown; after 2.2 s, forces commit  
- Loop: approach → probe → commit → attack → brief sidestep → probe again  

**Brute — relentless space control**

- Removed RECOVER state and bonus cooldown — advances during attack cooldown  
- **50 px attack range** + 28 px lunge — still threatens after moderate CC knockback  
- Wind-up (0.72 s) remains the primary player reaction window  
- Loop: slow advance → committed strike → resume advance  

### Implementation files

| File | Role |
|------|------|
| `scripts/enemies/enemy.gd` | DISENGAGE / RECOVER states, archetype movement routing, brute knockback filter |
| `scripts/combat/enemy_combat_steering.gd` | Scout orbit chase, disengage, strafe engage |
| `scripts/world/vertical_slice_archetype_presets.gd` | Per-archetype stats + behavior exports |
| `scripts/world/vertical_slice_encounter.gd` | Spawns enemies with preset applied |

### Playtest questions (before Combat Depth Pass 1)

1. Does the Scout feel like it is **looking for openings** rather than slugging?  
2. Does the Scout teach **prioritization** in mixed fights (Crossroads, Fork, Last Stand)?  
3. Does the Raider still feel like the **fair baseline** reference?  
4. Does the Brute punish **panic focused spam** without feeling like a HP sponge?  
5. Does CC on the Brute create **some** space but less than on Raiders?  
6. Do players describe the three roles **differently** unprompted?  
7. Does difficulty feel behavioral — not primarily HP/damage inflation?

### Intentionally not modified

Bond · Sync · Instability · relationship · encounter tracking · dragon relationship logic · weapons · combat stance · player controls.

---

## Enemy Archetype Prototype Pass 1B

**Status: IMPLEMENTED — playtest validation pending**

**Purpose:** Improve combat readability and reduce attack-spam dominance. Combat should feel like two opponents **committing to actions**, not repeatedly cancelling each other. Pass 1B adds **player-side timing** and **point-blank Brute fixes** on top of enemy commitment tuning from Pass 1.

**Design philosophy:** Scout controls **tempo** · Raider controls **combat** · Brute controls **space**.

### Player attack wind-up (Pass 1B)

Focused attacks already used a wind-up → impact → recovery pipeline (`player_melee_attack.gd` awaits `focused_windup` before `_apply_focused_hits()`). Pass 1B **slightly lengthens** per-weapon wind-ups so damage/knockback still land **after** the telegraph, not on button press:

| Weapon | Wind-up (was → now) | Notes |
|--------|---------------------|-------|
| **Dagger** | 0.06 s → **0.09 s** | Still fastest; minimal commit |
| **Sword** | 0.11 s → **0.14 s** | Default slice weapon; knockback 25 → **21** |
| **Polearm** | 0.15 s → **0.18 s** | Longest reach, longest commit |

Wind-up still slows movement via `focused_windup_move_speed`; recovery unchanged in feel. Goal: responsive but not instant repeated control.

### Normal attack control tuning (Pass 1B)

Repeated focused hits no longer **always** fully suppress Raiders:

| Rule | Behavior |
|------|----------|
| **`scale_incoming_player_hit()`** | Archetype-aware knockback scaling before hit reaction |
| **Raider pre-commit** | Focused knockback × **0.78** |
| **Raider knockback immunity** | **0.20 s** window after a knockback; further hits × **0.38** knockback |
| **Raider committed** | Knockback × **0.12** — swing finishes |
| **Brute** | Normal focused knockback largely ignored (`≤26 px → 0`; else × **0.35**); committed × **0.08** |
| **Scout** | Unchanged — easy to interrupt (no commit) |

Stagger/interrupt logic remains in `apply_hit_reaction()` (Pass 1B enemy-side). Knockback stacking reduced via state, not RNG.

### Attack commitment (enemy-side)

Once an enemy passes **`attack_commit_ratio`** through its wind-up (or enters **LUNGE**), the swing is **committed** — it plays to completion unless the enemy dies.

| Phase | Meaning |
|-------|---------|
| **Pre-commit wind-up** | Vulnerable to full interrupt + stagger |
| **Post-commit wind-up / lunge** | Swing finishes; stagger freeze skipped |

No random chance — commitment is purely timing/state based.

### Interruption by archetype

| Archetype | When struck | Commit threshold | Stagger on hit |
|-----------|-------------|------------------|----------------|
| **Scout** | Always interruptible | Never commits (always cancellable) | **1.35×** — fragile, frequently staggered |
| **Raider** | Interruptible **before** 40% wind-up | 40% of 0.45 s (~0.18 s) | **1.0×** baseline; **0.18×** during committed swing |
| **Brute** | Interruptible **before** 28% wind-up | 28% of 0.72 s (~0.20 s) | **0.55×** pre-commit; **immune** during committed swing |

**Raider player read:** *"I interrupted him before he committed."* — not luck.

**Brute player read:** Point-blank spam no longer permacancels — committed swings finish; **0.47 s** player stagger (knockback unchanged at 32 px).

### Brute point-blank overlap / freeze fix (Pass 1B)

| Issue | Root cause | Fix |
|-------|------------|-----|
| **Player embeds in Brute** | Both bodies used **14 px** radius; Brute visual is 1.55× but collision was not | Brute **`body_collision_radius` 22 px** via preset |
| **Brute lunge away from player** | Zero-distance `direction_to` failed → lunge defaulted to `Vector2.RIGHT` | **`_direction_to_player()`** falls back to facing when positions overlap |
| **Brute stops attacking** | Pre-commit cancels + stagger blocked wind-up; overlap broke range checks | Commitment + overlap-aware **`_is_player_in_attack_range()`** / **`_is_in_attack_range()`** |
| **Player spam hits miss at overlap** | `_gather_focused_candidates` skipped `distance < 0.001` | Point-blank enemies always valid focused targets |
| **Bodies slide together** | Knockback used raw `global_position +=` | **Collision-aware knockback** (`move_and_collide`) on enemy + player separation pass |
| **Lunge at overlap** | Forward lunge pushed bodies apart unpredictably | Skip lunge translation when already overlapping; still resolve hit |

**Separation:** Player `_resolve_enemy_body_overlap()` after `move_and_slide()`; enemy `_resolve_player_body_overlap()` when not attacking (Brute nudges less — holds ground).

### Root cause fixes (playtest — earlier Pass 1B)

| Issue | Cause | Fix |
|-------|-------|-----|
| **Raider stun-lock** | Every player hit applied 0.3 s stagger + `_cancel_attack()` — faster than Raider wind-up | Commitment window; committed swings ignore stagger freeze; reduced knockback stacking |
| **Brute stops at point-blank** | Same cancel + stagger blocked `_process_attack_phase` every frame | Brute commits early; committed phase ignores stagger freeze and cancel; overlap/range fixes above |

### Implementation

- `weapon_profile_prototype.gd` — focused wind-up bumps; sword knockback 21  
- `player_melee_attack.gd` — calls `scale_incoming_player_hit()`; point-blank hit detection  
- `player.gd` — `_resolve_enemy_body_overlap()`  
- `enemy.gd` — `_is_attack_committed()`, archetype-aware `apply_hit_reaction()`, `scale_incoming_player_hit()`, overlap/range helpers, collision-aware knockback  
- `vertical_slice_archetype_presets.gd` — `attack_commit_ratio`, `hit_stagger_multiplier`, Brute `player_hit_stagger` 0.47, `body_collision_radius` 22  

### Playtest questions (Pass 1B → Combat Depth Pass 1)

1. Can Raiders ** reliably attack** in 1v1 without feeling stun-locked?  
2. Does interrupting a Raider **before** commit feel intentional and fair?  
3. Does the Brute **finish swings** at point-blank while still being punishable pre-commit?  
4. Does Brute stagger feel **dangerous** but not unfair (~0.47 s)?  
5. Does the Scout still feel **agile and precision-rewarding** when staggered more easily?  
6. Does combat feel like **timing and commitment** — not attack-button suppression?  
7. Does **slight player wind-up** feel responsive but stop spam dominance?  
8. Can the player **not** clip inside the Brute while holding forward + attacking?

### Remaining combat-depth concerns (post Pass 1B)

- No poise meter UI — commitment is inferred from telegraph timing  
- CC still strong vs Scouts/Raiders — intentional but may need tiering later  
- Multi-enemy slot steering untested with new knockback immunity  
- Weapon stance / shield / dragon systems still out of scope  
- Brute may need a dedicated point-blank attack anim (currently same lunge, translation skipped at overlap)

### Future work (not Pass 1B)

- Full poise / stats system  
- Brute heavy attacks and dragon combo counters  
- Weapon-specific interrupt tiers  

---

## Combat / Navigation Stability Pass

**Status: IMPLEMENTED — playtest validation pending**

**Purpose:** Fix three playtest blockers — attack spam still too fast, dragon/enemies stuck on walls, Brute point-blank embed/freeze.

### 1. Player attack spam tuning

**Pipeline unchanged:** wind-up → impact (`_apply_focused_hits`) → optional hit-stop → recovery → **then** cooldown starts. Cooldown no longer begins at button press, so mashing Space during recovery does not queue early hits.

**Timing per weapon (Stability Pass):**

| Weapon | Wind-up | Recovery | Post-recovery cooldown | ~Min cycle* | Identity |
|--------|---------|----------|------------------------|-------------|----------|
| **Dagger** | 0.10 s | 0.14 s | 0.36 s | **~0.60 s** | Fastest |
| **Sword** | 0.15 s | 0.20 s | 0.52 s | **~0.87 s** | Medium |
| **Polearm** | 0.20 s | 0.28 s | 0.82 s | **~1.30 s** | Slowest / strongest control |

\*Excludes hit-stop (~0.028 s). Damage/knockback still only at impact after wind-up. `_attack_active` blocks overlapping attack coroutines.

**Previous (Pass 1B) → Stability:** dagger cycle ~0.24 s → ~0.60 s; sword ~0.38 s → ~0.87 s; polearm ~0.68 s → ~1.30 s.

### 2. Wall stuck / navigation

**Root causes:**

| Actor | Cause |
|-------|--------|
| **Enemies** | Velocity steered straight into wall corners; `move_and_slide` returned near-zero displacement with no fallback |
| **Dragon** | Follow/alert velocity into geometry; post-move enemy separation used `global_position +=` (could push into walls) |
| **Dragon assist/protection** | Strike approach reused blocked paths; no recovery after slide failure |

**Fixes (lightweight — no pathfinding):**

- New `CharacterWallRecovery` — wall slide from last collision normal, stuck timer (~0.34 s), tangent unstick fallback  
- **Enemies** — all chase/engage movement via `move_with_recovery()`  
- **Dragon** — single collision-aware move pass + stuck timer; separation nudges use `move_and_collide`  
- **Dragon follow** — `DragonEnemyAvoidance` reads prior-frame slide collision to bias velocity along walls toward goal  
- Explicit `collision_mask = 1` (walls) on dragon `_ready()`

### 3. Brute point-blank overlap / freeze (Stability Pass)

**Root cause (embed):** When player/enemy centers overlapped, `_resolve_enemy_body_overlap()` used **`get_facing_direction()`** as push vector — i.e. **toward** the Brute while the player held forward. `global_position +=` bypassed collision and caused embedding past the silhouette border.

**Fixes:**

| Fix | Detail |
|-----|--------|
| **Push direction** | Always push **away** from enemy center; if overlap, use **`-facing`** (backward from movement intent) |
| **Collision-aware separation** | Player + enemy overlap uses `CharacterWallRecovery.nudge_with_collision()` — no raw teleports |
| **Brute holds ground** | Brute nudges self less during attacks; player receives full separation push |
| **Attack during overlap** | Brute pre-commit hits at point-blank apply micro-stagger only — **do not cancel** wind-up (committed logic unchanged) |
| **Range / LOS** | Overlap bypasses strict LOS block; `_is_in_attack_range()` used for engage state transitions |

### Implementation

- `weapon_profile_prototype.gd` — cooldown/recovery/wind-up bumps  
- `player_melee_attack.gd` — cooldown starts after recovery  
- `character_wall_recovery.gd` — shared wall slide + stuck recovery  
- `enemy.gd`, `dragon.gd`, `dragon_enemy_avoidance.gd`, `player.gd` — navigation + overlap fixes  

### Remaining limitations

- No full navmesh — extreme concave corners may still slow actors briefly  
- Brute uses same attack anim at overlap (translation skipped, hit still resolves)  
- Dragon strike approach does not yet run full wall-recovery (follow/return paths do)  

### Playtest checklist

1. Dagger still feels fastest; polearm clearly slowest  
2. Raider 1v1 at The Crossing — enemy gets attack windows  
3. Dragon follows through Quiet Grove / Hold gate passages without permanent stick  
4. Brute at The Gate — hold forward + spam attack: no embed, Brute keeps swinging  
5. Narrow wall corners — enemies slide around within ~0.35 s  

---

## Dragon Navigation Stability Pass

**Status: v4 DIRECT FOLLOW — breadcrumbs disabled**

See [`dragon_ai.md`](../design/dragon_ai.md). Breadcrumb follow reverted (unstable near corners). Direct follow + rare catch-up/teleport when **far** and stuck. **F12** debug.

---

## Combat Depth Pass 1 Phase A

**Status: IMPLEMENTED — playtest validation pending**

**Purpose:** Improve player **control** during combat. Movement becomes another combat decision — where to stand, where to face, when to attack — without constantly turning to maintain pressure.

Design reference: [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md) Section 12, Milestone 3.

**Scope:** Combat Stance · weapon movement identity · attack facing commitment · movement state polish · debug readouts.

**Not in scope:** shields · blocking · stamina · dodge rolls · enemy rebalance.

---

### Combat Stance philosophy

Combat Stance is a **general rider control mode** — not shield-specific. It is the long-term foundation for shields, bows, magic, spear bracing, and dragon combo abilities (future milestones).

| Behavior | Detail |
|----------|--------|
| **Input** | **Hold Ctrl** (`combat_stance` action) — left or right Ctrl |
| **Lock facing** | Current facing captured on press; held while Ctrl held |
| **Strafe / backpedal** | World-space WASD (W north, S south, A west, D east); facing stays locked |
| **Attack direction** | Focused/CC use locked stance facing or attack-locked facing |
| **Release** | Returns to normal world-space movement; visual facing lerps smoothly |

**Why Ctrl:** LMB/Space/J attack; Shift+Space is CC; Q is dragon command. Ctrl alone is unused — bond debug uses **Ctrl+number** combos only, so hold-Ctrl does not conflict.

**Transitions:** Visual rotation uses angle lerp (`visual_facing_lerp_speed` ≈ 14) — no snap on enter/exit.

---

### Weapon movement identity (Phase A — live)

Player **move speed** is now part of weapon identity on top of existing attack profiles:

| Weapon | `move_speed_multiplier` | Effective speed (220 base) | Identity |
|--------|-------------------------|----------------------------|----------|
| **Dagger** | **1.14** | ~251 px/s | Fastest — precision, reposition |
| **Sword** | **1.00** | 220 px/s | Baseline — sustained DPS default |
| **Polearm** | **0.84** | ~185 px/s | Slowest — control, reach tradeoff |

Applied via `WeaponProfilePrototype` → `Player.set_weapon_move_multiplier()`. Attack wind-up/recovery slowdowns stack multiplicatively.

---

### Movement state design

Explicit states in `player.gd`:

| State | When | Facing source |
|-------|------|---------------|
| **Running** | Default locomotion | Velocity direction when moving; last facing when idle |
| **Combat Stance** | Ctrl held | Locked stance facing |
| **Attacking** | Focused/CC wind-up → recovery | Locked at attack start |
| **Staggered** | Enemy hit reaction | Frozen — no move |
| **Dead** | HP depleted | Frozen |

Priority: Dead → Staggered → Attacking → Combat Stance → Running.

---

### Attack commitment (Phase A)

Pass 6 established wind-up / impact / recovery. Phase A adds **facing commitment**:

- On attack start, `lock_attack_facing()` captures current combat facing
- Facing **does not** follow velocity during the full attack sequence
- Prevents instant 180° rotation mid-swing while keeping attacks responsive
- Unlock on attack completion or knockback stagger
- Works with Combat Stance — stance facing feeds attack lock if attacking from stance

Wind-up/recovery move slowdowns unchanged per weapon profile.

---

### Future shield foundation

Combat Stance is intentionally **not** named or tied to shield equipment. Future Phase B+ can add:

- Shield raise/block while stance held
- Stamina or poise costs
- Stance-specific animations

Phase A proves the movement/facing layer first.

---

### Debug UI (Phase A)

`BondTestHelpUI` — **Movement (live)** section:

- Current movement state
- Facing (compass label)
- Combat stance on/off
- Total move speed modifier (weapon × attack phase)

Help text: `Hold Ctrl — Combat stance (locked facing)`.

---

### Implementation files

| File | Role |
|------|------|
| `scripts/player/player.gd` | Movement states, stance, facing lock, weapon speed, visual lerp |
| `scripts/player/player_melee_attack.gd` | Attack facing lock/unlock; weapon speed on profile apply |
| `scripts/combat/weapon_profile_prototype.gd` | `move_speed_multiplier` per weapon |
| `project.godot` | `combat_stance` → Ctrl (left + right) |
| `scripts/ui/bond_test_help_ui.gd` | Live movement debug readouts |
| `scenes/ui/BondTestHelpUI.tscn` | Movement section layout |

---

### Playtest questions (Phase A → Phase B)

1. Does Combat Stance feel **natural** for maintaining pressure without orbit-spinning?
2. Can you **strafe and backpedal** while keeping attacks aimed correctly?
3. Do weapon move speeds feel **noticeably different** without frustration?
4. Does attack facing lock stop **mid-swing 180° snaps** without sluggishness?
5. Are stance enter/exit transitions **smooth** (no jitter)?
6. Does polearm slowness reinforce **control/reach** identity?
7. Does dagger speed reinforce **precision/reposition** identity?
8. Is Ctrl comfortable alongside movement and attacks?

### Intentionally not modified

Bond · Sync · Instability · relationship · encounter tracking · dragon AI · enemy tuning · shields · blocking · stamina · dodge · weapon profiles · damage values.

---

## Combat Depth Pass 1 Phase B

**Status: IMPLEMENTED — playtest validation pending**

**Purpose:** Ocarina-of-Time-style **Target Focus** — maintain player intent to face a chosen enemy while moving. **Not** Souls-style lock-on or auto-combat.

> *"I want to keep facing this enemy while I move."*

---

### Target Focus philosophy

| Concept | Detail |
|---------|--------|
| **What it is** | Facing lock toward a **player-chosen** enemy |
| **What it is not** | Camera lock, auto-attack, hit guarantee, movement assist |
| **Zelda / OoT model** | You orbit and approach/retreat naturally because facing tracks the target |
| **Souls lock-on** | **Not implemented** — no camera orbit, no attack snap-through |

Target Focus controls **facing only**. Attacks remain **physical** — cone, range, weapon profile, enemy positions determine hits.

---

### Keyboard controls

| Input | Action |
|-------|--------|
| **Caps Lock** | Toggle focus — acquire best target if none; clear if focused |
| **Tab** | Next valid target (while focus active) |
| **Shift + Tab** | Previous valid target (while focus active) |

No mouse buttons. Input actions: `target_focus_toggle`, `target_focus_next`, `target_focus_prev`.

---

### Target acquisition

On Caps Lock with **no** current focus:

1. Gather alive enemies within **320 px**
2. Score by: in-front preference (±75°), centered angle, distance
3. Lock best candidate

If none valid: no-op (optional debug log).

---

### Target cycling

While focus active:

- Valid enemies sorted by **world angle** around player (stable order)
- Tab / Shift+Tab wrap forward/back
- Single enemy: Tab keeps same target

---

### Auto-unlock and auto-retarget

Focus **clears** when:

- Player toggles **Caps Lock** off (manual — no auto-acquire afterward)
- No valid enemies remain within range after a retarget attempt
- Player **dies**

Focus **auto-retargets** to the **nearest valid enemy** within range when:

- Focused enemy **dies**
- Focused enemy **despawns** or becomes invalid
- Focused enemy moves **beyond 320 px** (nearest replacement if any)

Manual Caps Lock off sets `_focus_enabled = false` — death handlers will not re-acquire until the player toggles focus on again.

Initial Caps Lock acquire still prefers enemies **in front**; auto-retarget on kill uses **nearest distance** only.

Focus does **not** clear when: blocker in the way, miss, dragon hits elsewhere, player takes damage.

---

### Combat Stance interaction

| System | Role |
|--------|------|
| **Combat Stance (Ctrl)** | Lock facing to a **direction** |
| **Target Focus** | Lock facing to an **enemy** |

**When both active:** Target Focus **wins** for facing (tracks enemy continuously). Combat Stance still applies for movement input semantics; no jitter — single facing authority with priority: **Attack lock > Target Focus > Combat Stance > velocity**.

---

### Target preview vs Target Focus

| Visual | Meaning |
|--------|---------|
| **Cyan ring** (Pass 7 preview) | Likely hit if you attack **now** (cone logic) |
| **Bright blue ring** (Phase B) | Enemy **you chose** to face |

F11 debug: **yellow** line = likely preview target; **blue** line = focused target.

Telegraphs face locked target while focus active; hit query unchanged.

---

### Future integrations (not implemented)

- Shield facing toward focused enemy
- Dragon command target
- Magic / bow aiming reticle

---

### Implementation files

| File | Role |
|------|------|
| `scripts/player/player_target_focus.gd` | Acquisition, cycling, validation, input |
| `scripts/combat/combat_target_focus_indicator.gd` | Blue ring + marker |
| `scripts/player/player.gd` | Facing priority, movement state |
| `scenes/player/Player.tscn` | TargetFocus + indicator nodes |
| `project.godot` | Input actions |
| `scripts/combat/combat_attack_telegraph.gd` | F11 focus line |
| `scripts/ui/bond_test_help_ui.gd` | Live focus readouts |

---

### Playtest questions (Phase B)

1. Does Target Focus make it easier to keep attention on one enemy?
2. Does movement around a focused enemy feel natural?
3. Does it feel like help without becoming auto-combat?
4. Do weapon arcs and positioning still matter?
5. Does target cycling behave predictably?
6. Does Combat Stance still have a separate useful role?
7. Does Target Focus help against Brutes and Scouts?

---

## Combat Depth Pass 1 (overview)

**Status: Phase A + Phase B IMPLEMENTED — playtest validation pending · Phase C+ planned**

**Checkpoint:** [`project_checkpoint_combat_depth_1B.md`](../checkpoints/project_checkpoint_combat_depth_1B.md)

**Purpose:** Increase player **decision-making**. Combat should become less about repeatedly attacking and more about choosing the correct action — positioning, timing, spacing, and attack choice over attack spam.

Design reference: [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md) Section 12, Milestone 3.

Phase A (movement foundation) and Phase B (Target Focus) are documented above. Remaining Pass 1 scope (future phases):


## Vertical Slice Level Pass 2

**Status: COMPLETE (P2.1 grove fix) — Phase 1 layout signed off**

Documentation: [`vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md)

- Variable-width spine (wide → choke → junction → choke → destination)
- Wall segments drawn == collision; grove sealed with **full east wall** and **two south exits only**
- Route polylines: Crossroads → grove → SW exit back to Crossroads or SE exit to Hold
- Encounter trigger positions updated on spine

**Not changed:** combat, enemy AI, relationship, dragon, weapons.

---

## Vertical Slice Level P1 Fix Pass

**Status: IMPLEMENTED — slice level + global enemy attack readability**

Documentation: [`../level/vertical_slice_level_p1.md`](../level/vertical_slice_level_p1.md)

### Level boundary / flow fix

**Problem:** Zone tints drew ten disconnected boxes, but collision used one short outer rectangle (y ±300). Quiet Grove (y ≈ −520) was **outside** north collision — nearly inaccessible.

**Fix:** `vertical_slice_graybox_geometry.gd` builds a **connected east–west corridor** (y −108…108) plus **north grove wing** with a gap in the north corridor wall. Walls match playable space. Route line + START/END markers added.

### Archetype readability (slice presets)

| Archetype | Chase | Visual |
|-----------|-------|--------|
| **Scout** | **225** px/s (~player 220, dagger-feel pursuit) | 0.62× scale, orange, narrow polygon, gold accent |
| **Raider** | **108** px/s (sword-match baseline) | Default size, standard red |
| **Brute** | **68** px/s (slow, polearm-feel spacing) | 1.55× scale, dark maroon, wide polygon, dark accent |

Applied via `VerticalSliceArchetypePresets` — does not change AI state machine.

### Enemy attack telegraph + lunge (all enemies)

`enemy.gd` — same state machine, new attack **phase** inside ENGAGE:

1. **Wind-up** — `engage_windup` duration, pulsing warm flash, zero velocity  
2. **Lunge** — short forward burst (`attack_lunge_distance` / `attack_lunge_duration`)  
3. **Hit** — damage if still in range; red flash on connect  

Exports: `attack_lunge_distance`, `attack_lunge_duration`, `player_hit_knockback`, `player_hit_stagger`.

### Brute player hit prototype

`player.gd` — `apply_combat_hit_reaction(from_position, knockback, stagger)`:

- **Brute preset:** 32 px knockback, **0.32 s** stagger (movement/attack lock)  
- **Raider / Scout / default:** 0 knockback, 0 stagger  

Relationship systems untouched — only player movement interrupt.

### Help UI

`BondTestHelpUI.tscn` — scrollable full controls: movement, combat, dragon Q, weapons 1–3, Shift+R / Ctrl+Shift+R, F10/F11, F1/Shift+F1, Ctrl+1–6 bond, F5–F7 health.

---

## Weapon Profile Prototype Tuning Pass 1 (implemented — debug only)

**Status: PROTOTYPE · IDENTITY REFINEMENT · NOT EQUIPMENT**

Refines Pass 2 values from playtest feedback. **Sword = highest DPS**, **dagger = fastest / lowest sustained DPS**, **polearm = control / medium DPS**.

### Active weapon identities

| Weapon | Role | Identity |
|--------|------|----------|
| **Dagger** | Precision | Fastest cycle, smallest arc/reach, **lowest DPS**, weakest CC |
| **Sword** | Damage / balanced | **Highest DPS**, moderate arc/reach/CC — general-purpose default |
| **Polearm** | Control | Longest reach, strongest spacing/CC, **medium DPS**, slowest cycle — choose for control, not damage |

### Focused values (Tuning Pass 1)

| Stat | Dagger | Sword | Polearm |
|------|--------|-------|---------|
| Damage | **18** | **29** | **19** |
| Arc | **45°** | **100°** | **140°** (was 150°) |
| Range | **40 px** | **52 px** | **72 px** |
| Cooldown | **0.24 s** | **0.38 s** | **0.68 s** |
| Wind-up | **0.06 s** | **0.11 s** | **0.15 s** |
| Recovery | **0.08 s** | **0.13 s** | **0.21 s** |
| ~DPS (dmg/cd) | **~75** (lowest) | **~76** (highest) | **~28** (medium) |

### CC values (Tuning Pass 1)

| Stat | Dagger | Sword | Polearm |
|------|--------|-------|---------|
| Damage | **8** | **12** | **10** |
| Radius | **22 px** | **28 px** | **36 px** |
| Knockback | **14 px** | **24 px** | **35 px** |
| Stagger | **0.5 s** | **0.6 s** | **0.7 s** |
| Cooldown | **0.75 s** | **0.95 s** | **1.35 s** |

CC remains repositioning — not primary damage. Polearm creates the most space; dagger the least.

### CC scaling philosophy

- **Reach** scales with weapon length (22 → 28 → 36 px)
- **Knockback/stagger** strongest on polearm
- **Cooldown** longest on polearm — deliberate space tool
- **Damage** stays low on all profiles

### Debug UI

BondTestHelpUI shows cooldown summary + one-line stats:  
`F: 18 dmg · 45° · 40px  |  CC: 22px · 14 kb`

### Playtest goals

1. Does **sword** feel like the natural damage default?
2. Does **dagger** feel fast but **weak in sustained fights**?
3. Is **polearm 140°** arc right for control without feeling too wide?
4. Does **polearm 0.68 s** cadence feel deliberate, not spammy?
5. Does **weapon CC** reinforce reach/control identity?
6. Is polearm chosen for **spacing**, not DPS?

### Intentionally not implemented

Inventory, equipment, loot, leveling, magic, enemy variants, relationship/dragon/enemy AI changes.

---

## Weapon Profile Prototype Pass 2 (implemented — debug only)

**Status: PROTOTYPE · NOT EQUIPMENT · FOCUSED + CC PER WEAPON**

Pass 2 tunes Pass 1 profiles from playtest feedback and adds **weapon-scaled CC** (range, knockback, damage, cooldown).

### Changes from Pass 1

| Weapon | Focused changes | CC changes |
|--------|-----------------|------------|
| **Dagger** | Lower damage (**21**), faster cadence (**0.24** cd), faster wind-up/recovery | Smallest radius (**24**), lowest damage (**9**), fastest CC cd (**0.85**) |
| **Sword** | Unchanged baseline | Medium profile (~Pass 4 global values) |
| **Polearm** | Narrower arc (**150°**), slower cadence (**0.58** cd), slower recovery | Largest radius (**34**), strongest knockback (**32**), slowest CC cd (**1.2**) |

### Hotkeys (unchanged)

| Key | Profile |
|-----|---------|
| **1** | Dagger |
| **2** | Sword |
| **3** | Polearm |

Help UI shows: `Dagger  F 0.24s / CC 0.85s` (focused / CC cooldowns).

### Focused attack values (Pass 2)

| Stat | Dagger | Sword | Polearm |
|------|--------|-------|---------|
| Arc | **45°** | **100°** | **150°** (was 165°) |
| Range | **40 px** | **52 px** | **72 px** |
| Damage | **21** (was 24) | **25** | **20** |
| Knockback | 15 px | 25 px | 35 px |
| Cooldown | **0.24 s** (was 0.30) | 0.35 s | **0.58 s** (was 0.48) |
| Wind-up | **0.07 s** | 0.10 s | 0.14 s |
| Recovery | **0.09 s** | 0.12 s | **0.18 s** |

### CC values per weapon (Pass 2)

| Stat | Dagger | Sword | Polearm |
|------|--------|-------|---------|
| Damage | **9** | **12** | **11** |
| Radius | **24 px** | **28 px** | **34 px** |
| Knockback | **16 px** | **24 px** | **32 px** |
| Stagger | **0.55 s** | **0.6 s** | **0.65 s** |
| Cooldown | **0.85 s** | **0.95 s** | **1.2 s** |
| Wind-up | **0.14 s** | 0.17 s | **0.19 s** |
| Recovery | **0.16 s** | 0.20 s | **0.23 s** |

### CC philosophy (weapon-scaled)

- CC remains **repositioning**, not primary DPS
- **Reach scales with weapon length** — polearm pushes farthest, dagger shortest
- **Dagger:** quick emergency space, weakest push
- **Sword:** balanced CC baseline
- **Polearm:** best space creation, slowest commitment

All values live in `WeaponProfilePrototype.PROFILES` for easy tuning.

### Playtest questions (Pass 2)

1. Does dagger **spam** feel better at 0.24 s cooldown?
2. Is dagger damage (**21**) still satisfying on single targets?
3. Is polearm arc (**150°**) still wide enough for control?
4. Does polearm **0.58 s** focused cadence feel appropriately slow?
5. Does **weapon-scaled CC** read clearly (short vs long reach)?
6. Is polearm CC the best **space tool** without dominating damage?
7. Should sword CC stay the **baseline** for future weapons?

### Intentionally not implemented

- Inventory, equipment, persistence
- CC stamina/charges
- Enemy variants, relationship/dragon changes

---

## Weapon Profile Prototype Pass 1 (implemented — superseded by Pass 2 for values)

**Status: IMPLEMENTED · Pass 2 updated tuning + weapon CC**

Pass 1 introduced debug profiles (focused only). **Pass 2** adds CC scaling and cadence/arc tuning below is **historical Pass 1**.

### Hotkeys

| Key | Profile |
|-----|---------|
| **1** | Dagger |
| **2** | Sword |
| **3** | Polearm |

Prints `Weapon Profile: <name>` to console. **BondTestHelpUI** shows current profile.

### Profile values (focused attack)

| Stat | Dagger | Sword | Polearm |
|------|--------|-------|---------|
| Arc (total) | **45°** | **100°** | **165°** |
| Range | **40 px** | **52 px** | **72 px** |
| Damage | **24** | **25** | **20** |
| Knockback | **15 px** | **25 px** | **35 px** |
| Stagger | 0.3 s | 0.3 s | 0.3 s |
| Cooldown | **0.30 s** | **0.35 s** | **0.48 s** |
| Wind-up | **0.08 s** | **0.10 s** | **0.14 s** |
| Recovery | **0.10 s** | **0.12 s** | **0.16 s** |

Close-range forgiveness and soft-assist scale per profile. Telegraphs use live `focused_range` / arc exports.

### Design intent

| Profile | Role | Expected feel |
|---------|------|----------------|
| **Dagger** | Precision | Fast, short, single-target; weak in groups |
| **Sword** | Balanced | 1–3 enemies in front; general purpose |
| **Polearm** | Control | Long reach, wide arc, strong knockback; lowest DPS |

### Implemented

- `WeaponProfilePrototype` data + `PlayerMeleeAttack.apply_weapon_profile()`
- Keys **1 / 2 / 3** (`_unhandled_input`, ignored while attacking)
- Help UI readout + console log
- Telegraph / preview / hit query use applied exports

### Intentionally not implemented

- Inventory, equipment slots, pickups, persistence
- Weapon-specific CC
- Stat scaling, leveling, crafting, durability
- Enemy variants, dragon combat changes

### Playtest questions

1. Does dagger feel **precise and fast**?
2. Does sword feel **balanced**?
3. Does polearm feel like a **control** weapon?
4. Does polearm feel **too safe**?
5. Does dagger feel **too weak against groups**?
6. Does sword feel like a useful **middle ground**?
7. Does weapon identity emerge **without inventory/equipment**?
8. Should CC eventually become **weapon-specific**?

---

## Combat Feel Pass 7 (implemented)

**Status: IMPLEMENTED · Target readability — not lock-on**

Pass 7 helps answer: *“If I press Space right now, who am I probably attacking?”* No hard lock-on, cycling, or camera changes.

### Target preview philosophy

- **Readability aid only** — does not steer attacks, facing, or camera
- **Subtle** — small pulsing ring + dot under the likely primary target
- **Live** — updates every frame as player moves/faces
- **Hidden during attacks** — preview off while wind-up/recovery active
- **Single target** — shows primary focused candidate only (not cleave extras)

### How the likely target is selected

Uses **`_gather_focused_candidates()`** — the same function as focused impact damage:

1. Player **base facing** + position
2. **Soft aim assist** facing (20% blend toward nearest enemy in front arc)
3. Enemies in **44 px** range inside forgiveness cone (70° / 100° within 28 px)
4. Sort by **most centered in cone**, then **closest**
5. Top candidate = preview target

Preview calls `PlayerMeleeAttack.get_likely_focused_target()` — not a separate targeting system.

### Preview vs actual hit (known limitation)

| Match | Detail |
|-------|--------|
| **Same logic** | Cone, forgiveness, soft assist, sort order |
| **Timing gap** | Preview uses **current** facing; impact samples facing again after **0.10 s** wind-up |
| **Movement** | Strafing during wind-up can change who gets hit |
| **Cleave** | Preview shows **primary only**; lined-up second targets not marked |

Document this during playtests — preview means *“right now”*, not *“guaranteed at impact”* if you keep moving.

### Why hard lock-on was avoided

- Pass 3–6 goal is **manual directional** combat with forgiveness, not tab-target
- Lock-on hides positioning skill and fights dragon co-op readability
- Preview teaches cone targeting without forcing aim

### Visual (`CombatFocusedTargetPreview`)

| Element | Behavior |
|---------|----------|
| Ring | **17 px** radius, cyan, gentle pulse |
| Marker | **3 px** center dot |
| z-index | Below attack telegraph, above floor |

### F11 debug enhancement

When **F11** overlay is on, also shows:

- **Yellow line** from player to likely target
- **Brighter ring** on likely target
- Existing green/magenta cone + CC radius unchanged

### Future targeting considerations (not implemented)

- Optional “learning mode” idle cone outline
- Weapon-specific preview shapes
- Cleave secondary markers (polearm)
- Audio ping on target change — likely too noisy

### Playtest questions (Pass 7)

1. Does the preview make focused attacking **easier to understand**?
2. Does it help **without feeling like lock-on**?
3. Does it choose the enemy the player **expects**?
4. Does it stay **readable when surrounded**?
5. Does it avoid **visual clutter**?
6. Does **manual aiming still matter**?

### Pass 7 observations to capture during testing

- Preview target vs actual hit when strafing through wind-up
- Wrong-target moments in tight clusters
- Whether pulse is too subtle or too loud in packs
- If players treat preview as guaranteed lock

---

## Combat Feel Pass 6 (implemented)

**Status: IMPLEMENTED · Prototype timing — not final · no damage balance changes**

Pass 6 makes attacks feel **deliberate** without slowing overall combat. Damage values, AI, and weapon systems unchanged.

### Attack commitment philosophy

Each attack is a short sequence:

**Input → Wind-up → Impact → Recovery**

- **Wind-up:** telegraph visible; player slightly slowed
- **Impact:** damage / CC pulse occurs here (not on button press)
- **Recovery:** brief follow-through; still slightly slowed
- Goal: *“I performed an attack”* not *“I pressed a damage button”*

### Focused attack timing (live)

| Phase | Duration | Movement speed |
|-------|----------|----------------|
| Wind-up | **0.10 s** | **55%** |
| Impact | instant query | full speed moment |
| Recovery | **0.12 s** | **70%** |

Telegraph: pulsing dim cone during wind-up → impact flash (hit/miss) with close-range overlay.

### CC attack timing (live)

| Phase | Duration | Movement speed |
|-------|----------|----------------|
| Wind-up | **0.17 s** | **40%** |
| Impact | **0.10 s** hitbox window | full speed moment |
| Recovery | **0.20 s** | **50%** |

Telegraph: small pulsing inner ring during wind-up → full expanding purple ring on impact.

CC is **heavier** than focused (longer wind-up/recovery, more movement penalty).

### Movement during attacks (Option A — chosen)

**Reduced move speed during wind-up and recovery** — player can still reposition.

Why Option A over brief impact lock:

- Keeps combat **responsive** while selling commitment
- Allows micro-positioning during wind-up
- Avoids stuttery full stops that feel sluggish in top-down swarms
- Simple multiplier on `Player.move_speed` — no animation lock pipeline

### Hit feel (subtle)

| Effect | Value |
|--------|-------|
| Hit-stop | **~0.028 s** real time at **0.75×** time scale (once per attack if any hit lands) |
| Player hit flash | Slightly warmer / longer confirm flash (Pass 5 baseline bumped) |
| Contact spark | Slightly larger / longer spark on impact |

No damage numbers. No screen shake.

### Telegraph alignment (Pass 6)

Focused telegraph now shows **both**:

- **Strict cone** (70° @ 44 px) — primary wedge
- **Close-range forgiveness overlay** (100° within 28 px) — lighter inner wedge

Matches actual hit logic from Pass 4. F11 debug overlay shows both cones.

### Future animation integration (not implemented)

- Sprite wind-up / swing / recovery poses synced to these timings
- Weapon-specific wind-up lengths
- CC charge pose + release animation
- Per-weapon telegraph art replacing `_draw()` wedges

### Playtest questions (Pass 6)

1. Do attacks feel **more deliberate**?
2. Do attacks still feel **responsive**?
3. Does focused attack timing feel good?
4. Does CC feel **appropriately heavier**?
5. Does movement remain **comfortable** during wind-up/recovery?
6. Does combat feel **more satisfying** overall?

### Pass 6 observations to capture during testing

- Wind-up too long vs too short for focused / CC
- Whether 55% / 70% move speed feels right
- Hit-stop noticeable without feeling sluggish
- Facing drift during wind-up (impact uses current facing at impact frame)
- Whether CC wind-up telegraphs “creating space” clearly enough

---

## Combat Feel Pass 5 (implemented — visuals; timing layered by Pass 6)

**Status: IMPLEMENTED · Pass 6 added wind-up/impact/recovery phases on top of these visuals**

Pass 5 added attack-area telegraphs and hit confirmation. **Telegraph timing is phase-based after Pass 6** — see [Combat Feel Pass 6](#combat-feel-pass-6-prototype--live) for wind-up vs impact durations; do not use single “~0.18 s fade” as current behavior.

### Attack telegraph philosophy

- **Subtle, brief, readable** — prototype clarity over flash
- **Swing vs hit** must be visually distinct (miss = dim arc; hit = brighter arc + spark + enemy confirm flash)
- **Focused vs CC** must look different at a glance (cone vs expanding ring)
- No damage numbers, screen shake, or large VFX

### Focused attack telegraph (`CombatAttackTelegraph`)

| Element | Behavior |
|---------|----------|
| Cone wedge | **70°** arc at **44 px**, aligned to **player facing** (not soft-assist) |
| **Wind-up** (Pass 6) | Pulsing dim cone — **0.10 s** |
| **Impact** (Pass 6) | Bright/dim cone + sweep — **~0.18 s** fade |
| Miss | Dim gray-blue fill + faint edge |
| Hit | Brighter cyan fill + stronger edge |
| Sweep line | Short center slash extending through cone |
| Hit spark | Warm ring at contact — **~0.16 s** |

Telegraph uses **base facing** so misses reflect player aim; soft-assist remains invisible on the hit query only.

### CC attack telegraph

| Element | Behavior |
|---------|----------|
| Expanding ring | **28 px** radius pulse from player center |
| Color | Purple tint (distinct from focused cyan) |
| **Wind-up** (Pass 6) | Small pulsing inner ring — **0.17 s** |
| **Impact** (Pass 6) | Full expanding ring — **~0.24 s** |
| Hit spark | Same contact spark on each enemy hit |

Communicates **space-creation**, not primary strike.

### Hit confirmation

| Layer | Change |
|-------|--------|
| Enemy flash | Player hits use **warmer, slightly longer** flash via `CombatVisualFeedback.queue_player_hit_confirm()` |
| Contact spark | Brief ring at hit position (focused + CC) |
| Miss | Dim telegraph only — no spark, no confirm flash |

Enemy-enemy or non-player damage still uses the default white flash.

### Debug range overlay (debug-only)

- **F11** toggles persistent **focused cone + CC radius** overlay on the player
- Green cone = focused strict arc; light blue inner wedge = close forgiveness; magenta circle = CC radius
- **Pass 7:** yellow line + ring on **likely focused target** when overlay enabled
- Prints `[DEBUG] Combat range overlay: ON/OFF` to console
- Not tied to combat balance — tuning aid only

### Playtest questions (Pass 5)

1. Can the player **immediately tell** where the focused attack is aimed?
2. Can the player **immediately tell** where the CC attack reaches?
3. Are **misses** easier to understand?
4. Are **successful hits** easier to recognize?
5. Do the visuals **improve combat learning**?
6. Do visuals stay **readable during large fights** (Shift+F1 packs)?

### Pass 5 observations to capture during testing

- Cone too subtle vs too loud in crowded fights
- Miss color distinct enough from hit color
- CC ring readable when overlapping focused cone cooldown spam
- Whether F11 overlay helps tuning or should move to debug panel
- Spark size/visibility on dark backgrounds

### Future visual combat feedback (not implemented)

- Enemy attack wind-up tint
- Directional contact sparks (along knockback vector)
- ~~Hit-stop on heavy hits~~ → **Pass 6** subtle global hit-stop on player melee connect
- Audio stingers for hit / miss / CC
- Optional arc outline while idle (learning mode)
- Color-blind safe telegraph variants

---

## Combat Feel Pass 4 (implemented)

**Status: IMPLEMENTED · Prototype tuning — not weapon system · no lock-on**

Pass 4 refines Pass 3 based on playtesting: CC should create **space**, not compete on damage; focused attacks should feel **more reliable** without becoming omnidirectional or lock-on combat.

### Attack profiles (live values)

| Attack | Input | Damage | Knockback | Stagger | Cooldown |
|--------|-------|--------|-----------|---------|----------|
| **Focused** | Space / LMB / J | **25** | **15 px** | **0.3 s** | **0.35 s** |
| **Crowd control** | Shift + Space | **12** | **22 px** | **0.6 s** | **0.9 s** |

CC hits all enemies in the 28 px radius (unchanged geometry). Per-hit knockback/stagger overrides come from `player_melee_attack.gd` via `CombatVisualFeedback.override_next_hit_reaction()`.

### CC attack philosophy

- CC is a **repositioning and survival** tool — “I need space,” not “this is my strongest attack”
- Lower damage (**12** vs **25** focused) makes spamming CC inefficient for kills
- Stronger knockback (**22 px**) and longer stagger (**0.6 s**) push enemies back harder
- Longer cooldown (**0.9 s**) prevents CC from replacing focused strikes in normal fights
- No stamina/charges yet — cooldown is the only limiter in this prototype

### Focused attack aim forgiveness (no lock-on)

Pass 4 keeps **manual facing** and **directional combat**. It does **not** add target lock, camera lock, enemy cycling, or large-angle snap.

| Mechanism | Value | Purpose |
|-----------|-------|---------|
| Wider base cone | **70°** total (±35°) | Slightly more forgiving than Pass 3 (60°) |
| Close-range cone | **100°** within **28 px** | Enemies hugging the player are easier to hit |
| Range | **44 px** | Small reach bump for melee reliability |
| Soft aim assist | **20%** blend toward nearest enemy within **40 px** / **90°** of facing | Helps when target is already reasonably in front |
| Target priority | Closest-to-center in cone wins | Usually **one** enemy; extras only if also inside strict 70° cone (lined up) |

Soft assist only nudges the **hit query**, not movement or camera. Player still chooses direction manually.

### Why lock-on was not implemented

- Pass 3 goal is testing **positional skill**, not tab-target combat
- Lock-on hides facing/readability problems instead of fixing them
- Dragon assist already uses engagement/facing — hard lock-on could fight co-op readability
- Lightweight forgiveness is enough to test “reliable directional” feel before any targeting UI

### Future targeting considerations (not implemented)

- ~~Optional **reticle / arc telegraph** for learning cone shape~~ → **Pass 5** brief swing telegraph (not idle reticle)
- Weapon-specific arcs without changing assist architecture
- Cleave caps per weapon (polearm) — still no Souls-style lock
- Relationship-gated CC wind-up (instability) — future milestone

### Playtest questions (Pass 4)

1. Does focused attacking feel **easier and more reliable**?
2. Do attacks still feel **directional** (not random or omnidirectional)?
3. Does the player feel **in control** of targeting?
4. Does CC feel like a **repositioning tool**?
5. Is CC still **useful** without being the strongest damage option?
6. Does the player **naturally switch** between focused and CC when surrounded?

### Pass 4 observations to capture during testing

- False hits from soft assist (does it ever feel like auto-aim?)
- Whether 70° / close 100° is too wide or still too tight
- Whether CC 0.9 s cooldown feels fair when surrounded
- DPS gap: is 12 damage too weak for CC or appropriately punishing?
- Whether lined-up multi-hit on strict cone feels intentional

---

## Combat Feel Pass 3 (implemented — superseded by Passes 4–7 for values)

**Status: IMPLEMENTED · Cone/range/damage updated in Pass 4+ — see [`project_checkpoint_combat_feel_v1.md`](../checkpoints/project_checkpoint_combat_feel_v1.md)**

Pass 3 introduced the **focused vs CC input split** (historical Pass 3 geometry below).

| Input | Attack | Behavior |
|-------|--------|----------|
| **Space** (also LMB / J) | **Focused attack** | ~60° frontal cone, 42 px range, dagger-style |
| **Shift + Space** | **Crowd-control attack** | 360° AoE, 28 px radius (Pass 2 behavior preserved) |

Both attacks shared **25 damage**, **15 px knockback**, **0.3 s stagger** in Pass 3 only. **Pass 4** split profiles — see [Combat Feel Pass 4](#combat-feel-pass-4-prototype--live).

### Why Pass 3 was introduced

- Pass 2 CC values feel good but **360° on Space** read as crowd-control, not a primary strike
- Design direction ([Weapon Identity Direction](#weapon-identity-direction)) calls for **focused primary** + **limited 360° tool**
- Pass 3 is an **experiment** to answer playtest questions before weapon equipment exists

### Focused attack prototype (`player_melee_attack.gd`)

- Queries enemies in **`enemy`** group each swing
- Uses `Player.get_facing_direction()` — movement direction when moving, else **last facing** when idle
- **Half-angle:** 30° each side (**60° total** cone)
- **Range:** 42 px from player center
- Usually **one** target; two only if tightly aligned in cone

### Crowd-control attack

- Same circular `Area2D` hitbox as Pass 1–2 (radius 28 px)
- Hits **all** enemies in range once per swing
- Intended when **surrounded** — compare vs focused primary

### Future weapon integration (not implemented)

| Weapon | Planned focused profile | 360° CC |
|--------|-------------------------|---------|
| Dagger | Pass 3 cone (baseline) | Optional limited spin |
| Sword | Wider arc, ~25 px knockback | Shared CC action |
| Polearm | Wide arc, long reach, ~35 px knockback | Shared CC action |

Equipment, inventory, and per-weapon stats remain future milestones.

### Playtest questions (evaluate now)

1. Does **directional** combat feel better than omnidirectional primary?
2. Does the player feel **more in control** of targets?
3. Does the **focused attack** feel satisfying on single enemies?
4. Does **Shift + Space** feel like a useful **emergency space** tool?
5. Does combat become **more tactical** when surrounded (focused vs CC choice)?
6. Does **player positioning and facing** matter more?

### Pass 3 observations to capture during testing

- False misses when strafing vs standing still (facing stability)
- Whether 60° / 42 px feels too narrow or too wide
- Whether independent 0.35 s cooldowns help or hurt comparison
- Whether LMB should remain focused-only (current: yes)
- Dragon assist alignment with new facing (observe only — no AI changes)

---

## Combat Feel Pass 2 (implemented)

| Area | Implementation |
|------|----------------|
| Enemy speed | Default `chase_speed` 100, `engage_reposition_speed` 48 (down from 130 / 75) |
| Steering stability | Velocity + facing smoothing; ENGAGE hold when solo + in range; reduced slot orbit |
| Knockback | Enemy knockback **15 px** (~3× Pass 1) away from player on hit |
| Stagger | **0.3 s** freeze on enemy after knockback — no move, no attack |
| Future speed types | `knockback_resistance` + speed exports documented for per-enemy-type overrides |

**Historical:** At Pass 2 the player still used a **360° AoE on Space**. Knockback/stagger values (**15 px / 0.3 s**) became the dagger-tier baseline. **Pass 3** moved 360° to **Shift+Space** and made **Space** focused directional — see [Combat Feel Pass 3](#combat-feel-pass-3-prototype--live).

---

## Weapon Identity Direction

**Status: DESIGN DIRECTION — NOT FINAL · WEAPONS NOT IMPLEMENTED**

Pass 3 implements a **dagger-style focused cone** and **Shift+Space 360° CC** as prototypes only. **Pass 4** tuned CC damage/cooldown and added aim forgiveness. Tables below remain the long-term weapon plan.

### Weapon design philosophy

| Axis | Role in identity |
|------|------------------|
| **Attack speed** | Dagger fastest → polearm slowest |
| **Attack arc** | Narrow cone → wide frontal sweep |
| **Attack reach** | Short → long hitbox offset / range |
| **Knockback** | Low spacing pressure → high space creation |
| **Crowd-control** | Precision single-target → group control |

**Damage tier (sustained DPS, design intent):**

| Weapon | DPS / role |
|--------|------------|
| **Dagger** | Highest sustained DPS — precision tradeoff |
| **Sword** | Balanced — general purpose |
| **Polearm** | Lowest sustained DPS — best **control**, not best damage |

> **Important:** Polearm must not automatically deal the most damage. Its advantages are **reach, arc, knockback, spacing, and crowd management**.

---

### Dagger

**Role:** Precision weapon.

| Characteristic | Direction |
|----------------|-----------|
| Attack speed | Fastest |
| Reach | Shortest |
| Frontal arc | Smallest |
| Knockback | Lowest |
| Sustained DPS | Highest |
| Best against | Individual enemies |

**Basic attack (future):**

- Very small frontal cone
- Usually **one** target; second target only if perfectly aligned

**Prototype target values (future):**

- Knockback ≈ **15 px**
- Stagger ≈ **0.3 s** (short)

**Design goal:** Reward precision and aggressive close positioning.

*Pass 4 live: focused **15 px / 0.3 s**; CC **22 px / 0.6 s** on Shift+Space.*

---

### Sword

**Role:** Balanced weapon.

| Characteristic | Direction |
|----------------|-----------|
| Attack speed | Moderate |
| Reach | Moderate |
| Frontal arc | Moderate |
| Knockback | Moderate |
| Sustained DPS | Balanced |
| Best against | Mixed encounters |

**Basic attack (future):**

- Frontal arc
- Can hit **multiple enemies** standing close together
- General-purpose weapon

**Prototype target values (future):**

- Knockback ≈ **25 px**
- Stagger ≈ **0.3 s** (short)

**Design goal:** Balanced offense and crowd management.

---

### Polearm

**Role:** Control weapon.

| Characteristic | Direction |
|----------------|-----------|
| Attack speed | Slowest |
| Reach | Longest |
| Frontal arc | Widest |
| Knockback | Strongest |
| Sustained DPS | Lowest |
| Best against | Groups / spacing |

**Basic attack (future):**

- Large frontal arc
- Controls groups; can hit **several enemies in front** of the player

**Prototype target values (future):**

- Knockback ≈ **35 px**
- Stagger ≈ **0.3 s** (short)

**Design goal:** Create space and manage groups — **not** maximize damage.

---

### Future attack structure

**Live (Passes 3–7):** focused primary + Shift+Space CC — see [`project_checkpoint_combat_feel_v1.md`](../checkpoints/project_checkpoint_combat_feel_v1.md).

**Future (weapons / resources):**

| Attack | Role | Direction |
|--------|------|-----------|
| **Focused attack** | Primary | Directional; per-weapon arc/reach; precision DPS |
| **360° CC attack** | Repositioning | Space when surrounded; stronger knockback/stagger than focused; lower damage; eventually stamina/charges per weapon |

**360° CC (future constraints beyond live prototype):**

- Per-weapon profiles and resource limits (stamina, charges) — live prototype uses **cooldown only**
- Relationship-gated wind-up under high instability (future)

**Focused attack (future per weapon):**

- Arc, reach, speed, and knockback vary by equipped weapon
- Dragon assist continues to follow **player facing** and weapon arc

---

### Rider / dragon interaction notes (future)

Different weapons may naturally encourage different co-op rhythms — **observations only**, not implemented:

| Weapon | Rider style (observed direction) | Dragon relationship (future consideration) |
|--------|----------------------------------|--------------------------------------------|
| **Dagger** | Close-range aggression | Greater reliance on **protection** under pressure |
| **Sword** | Flexible positioning | Balanced assist windows |
| **Polearm** | Space control at range | More openings for **dragon assists** while rider controls front arc |

These are design hypotheses for later tuning — not stat or AI changes today.

---

## Combat Feel Pass 1 (implemented)

Lightweight prototype changes for playtest readability and group threat:

| Area | Implementation |
|------|----------------|
| Enemy spread | `EnemyCombatSteering` — slot targets around player + peer separation |
| ENGAGE pressure | Micro-reposition while engaging; attack only with clear line; no full stop |
| Enemy-enemy collision | Disabled (mask = player only) so steering can spread groups |
| Hit feedback | `CombatVisualFeedback` — brief flash; enemy nudge away from player |

**Out of scope for Pass 1:** balance, attack redesign, weapons, dragon damage.

---

## Attack design direction

> **Live behavior:** [`project_checkpoint_combat_feel_v1.md`](../checkpoints/project_checkpoint_combat_feel_v1.md) · **Weapon plan:** [Weapon Identity Direction](#weapon-identity-direction)

**Implemented (Passes 3–7):**

| Input | Attack | Role |
|-------|--------|------|
| **Space / LMB / J** | Focused directional cone | Primary damage |
| **Shift + Space** | 360° circular CC | Repositioning / create space |

**Historical:** Passes 1–2 used **360° AoE on Space** only. Pass 3 split inputs; Pass 4 tuned CC vs focused stats; Passes 5–7 added telegraphs, commitment, and target preview.

**Still future (not implemented):**

- Per-weapon frontal arcs (sword cleave, polearm reach)
- CC stamina/charges beyond cooldown
- Magic, dodge i-frames, dash strikes
- Weapon length affecting arc/reach on equipment change

### Stagger philosophy (live + future)

- **Live:** short stagger on player hits (focused **0.3 s**, CC **0.6 s** on enemies)
- **Future:** poise meter, crit stagger, boss phases — not implemented

---

## Enemy speed by type (future)

**Vertical Slice archetypes:** [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md) Section 3 defines **Scout**, **Raider**, **Brute** as gameplay roles. See [Combat Depth Pass 1 — Enemy archetype direction](#enemy-archetype-direction-scout--brute) for updated Scout/Brute behavior goals.

Default prototype values live on `Enemy` exports (`chase_speed`, `engage_reposition_speed`). Slice presets in `vertical_slice_archetype_presets.gd` — **AI behaviors not yet archetype-specific**.

| Archetype | Role | Speed feel (presets) | Behavior direction |
|-----------|------|----------------------|-------------------|
| **Scout** | Skirmisher / guerrilla | Fast (225 px/s) | Hit-and-run, flank, reposition — avoid toe-to-toe |
| **Raider** | Baseline | Medium (108 px/s) | Standard combat loop reference |
| **Brute** | Control check | Slow (68 px/s) | KB-resistant, close-range threat, punish positioning |
| **Beast** | — | Fast bursts | Post-slice |

---

## Enemy positioning & surround (future)

### Implemented (Pass 1 baseline)

- Eight angular slots around the player (instance-id hash)
- Separation push when peers within ~34 px
- Chase steers toward slot, not player centroid
- Engage creeps toward slot while on cooldown

### Future ideas

- **Dynamic slot claiming** — occupied slots reassigned to open angles
- **Role bias** — some enemies prefer rear arcs vs flanks (still lightweight)
- **Leader / flank tags** — simple enum, not full tactics tree
- **Obstacle-aware spread** — cheap ray or tile checks before slot pick
- **Pack cohesion** — loose follow of a “anchor” enemy without pathfinding
- **Surround telegraph** — subtle ground marker on slot approach (readability)

---

## Directional attacks

### Current behavior (live — Passes 3–7)

See [`project_checkpoint_combat_feel_v1.md`](../checkpoints/project_checkpoint_combat_feel_v1.md) for full values.

| Input | Timing (Pass 6) | Visual (Pass 5–7) |
|-------|-----------------|-------------------|
| **Space / LMB / J** | 0.10 s wind-up → impact → 0.12 s recovery | Wind-up cone → impact cone + spark; likely-target ring (Pass 7) |
| **Shift + Space** | 0.17 s wind-up → 0.10 s impact → 0.20 s recovery | Inner ring → expanding CC ring |

Detail: [Combat Feel Pass 6](#combat-feel-pass-6-prototype--live), [Pass 7](#combat-feel-pass-7-prototype--live).

### Design archive (pre-implementation options)

These informed Pass 3 — **directional arc is now live** as the default rider melee.

### Option 1 — Single-target melee

| | |
|--|--|
| **Advantages** | Clear focus fire; rewards positioning; easier to read; fits dragon assist targeting |
| **Disadvantages** | Slower clears vs swarms; needs strong target acquisition UX |
| **Difficulty** | Low — pick nearest/facing enemy in range |
| **Fit** | Strong for relationship-forward co-op where player + dragon each have roles |

### Option 2 — Directional arc attack

| | |
|--|--|
| **Advantages** | Rewards facing; enables skill expression; natural multi-hit only when lined up |
| **Disadvantages** | Needs facing clarity (sprite, telegraph); assist engagement must agree on “forward” |
| **Difficulty** | Medium — arc overlap test or rotated shape |
| **Fit** | **Best long-term fit** for top-down action with movement-based facing already on player |

### Option 3 — Limited cleave (1 primary + N secondary)

| | |
|--|--|
| **Advantages** | Swarm moments without full AoE spam; tunable cap (e.g. 2 targets) |
| **Disadvantages** | Harder to communicate; edge cases on who is “primary” |
| **Difficulty** | Medium |
| **Fit** | Good compromise if swarms stay common after Pass 1 steering |

**Outcome:** Pass 3 implemented **Option 2 (directional arc)** as default with **Shift+Space** for limited 360° CC — not a spammable omnidirectional basic attack.

---

## Weapon arcs & reach (future)

> Superseded in detail by [Weapon Identity Direction](#weapon-identity-direction). Summary:

- Dagger — shortest reach, narrowest cone
- Sword — moderate reach and arc
- Polearm — longest reach, widest arc; control over damage
- Wind-up telegraph scaled with reach
- Dragon assist aligns to player facing arc, not omnidirectional hitbox

---

## Weapon categories (future)

> **See [Weapon Identity Direction](#weapon-identity-direction)** for the current three-weapon playtest direction (dagger / sword / polearm). Legacy buckets below may expand later:

| Category | Feel | Notes |
|----------|------|-------|
| **Dagger** | Fast, narrow arc, low knockback, high DPS | Precision |
| **Sword** | Moderate speed/arc/reach | General purpose |
| **Polearm** | Slow, wide arc, long reach, strong knockback, low DPS | Control / spacing — not highest damage |
| **Dual / off-hand** | Combo windows | Late progression |

---

## Spin / crowd-control attacks

**Live:** **Shift + Space** — 360° **28 px** radius, lower damage than focused, stronger knockback/stagger, **0.9 s** cooldown. See [Combat Feel Pass 4](#combat-feel-pass-4-prototype--live).

**Future:**

- Stamina/charges per weapon (cooldown-only today)
- Distinct animation + SFX
- High instability wind-up (relationship tie-in)

---

## Charge-based abilities (future)

- Rider dash strike with i-frames window (future dodge synergy)
- Dragon parallel “rush” only as story/bond unlock — not Pass 2 default
- Charge must telegraph direction; blocked by terrain in real levels

---

## Stagger systems (future)

- **Pass 2 (live on enemies):** brief stagger after player hit — movement + attack blocked ~0.3 s
- Future: enemy poise meter separate from HP for heavy hits
- Stagger opens brief assist window (dragon AI readability)
- Bosses may use multi-phase stagger thresholds

---

## Stun systems (future)

- Hard stun sparingly (elite attacks, dragon breath, items)
- Soft stun = stagger + slow move speed
- Relationship: failed protection under stun pressure → Instability (when dragon health exists)

---

## Hit feedback

### Implemented (Passes 2–6)

- White flash + knockback + stagger on enemy hit (values overridden per attack type)
- **Pass 5–6:** warmer player-hit confirm flash, contact spark, brief hit-stop on connect
- Red flash on player damage
- No screen shake

### Future candidates

- Directional spark along knockback vector
- Enemy knockback scaled by damage tier
- Player edge vignette on damage (subtle)
- Audio: hit / hurt / kill stingers
- Damage number floaters (optional, off by default)

---

## Combat readability

### Implemented (Passes 5–7)

- Attack wind-up / impact telegraphs (cone vs CC ring)
- Hit vs miss visual distinction + contact sparks
- Likely-target preview ring (focused primary)
- **F11** debug: cone, close forgiveness, CC radius, likely target

### Future candidates

- Player wind-up tint on sprite (animation pass)
- Enemy attack wind-up visual (`engage_windup`)
- Threat indicator on enemies in ENGAGE with clear line
- Off-screen indicator polish
- Color-blind safe telegraph + preview variants

---

## Enemy AI pressure (future)

### Pass 1 (live)

- ENGAGE no longer zero-velocity idle
- Blocked allies seek separation and slot reposition
- Attacks require clear line (no shooting through stacked ally)

### Pass 2 (live)

- Slower default chase / engage speeds
- ENGAGE hold for solo fights; smoother steering + facing
- Stronger knockback stagger on player hits

### Pass 3+ candidates
- **Swap aggressor** — back-row enemy steps in when front ally blocks too long (simple state flip)
- **Ranged skirmisher** archetype (separate enemy script, later)
- Still **no** full tactical squad AI

---

## Combat Feel Pass 8 (recommended next)

1. CC resource limit beyond cooldown (charges/stamina) once Pass 4/6 questions answered
2. Tune soft-assist strength from playtest (or remove if it feels like auto-aim)
3. ~~Sword / polearm arc prototypes~~ → **Weapon Profile P1** debug profiles (1/2/3) — playtest and tune
4. Weapon-specific CC prototype (after profile playtest)
5. Enemy attack wind-up visual
6. Sprite animation synced to Pass 6 wind-up / impact / recovery
7. Audio pass for hit / hurt / miss / wind-up feedback
8. Color-blind safe telegraph + preview variants if readability issues found
9. Preview-at-impact hint during focused wind-up (optional)

---

## Explicitly not planned here

Leveling, equipment, magic systems, dragon health, Outcome Rating revision, enemy scaling, bosses, advanced CC — see [`project_checkpoint_combat_feel_v1.md`](../checkpoints/project_checkpoint_combat_feel_v1.md) limitations and [`project_checkpoint_milestone9A.md`](../checkpoints/project_checkpoint_milestone9A.md) for relationship scope.

---

## Document history (combat feel)

| Version | Scope |
|---------|--------|
| Pass 1 | Enemy spread, ENGAGE pressure, basic hit flash |
| Pass 2 | Speed tuning, steering stability, 15 px knockback, 0.3 s stagger |
| Pass 3 | Focused cone (Space) + 360° CC (Shift+Space) — **prototype testing** |
| Pass 4 | CC reposition tuning + focused aim forgiveness — **prototype tuning** |
| Pass 5 | Attack telegraphs, hit sparks, confirm flash, F11 debug overlay — **prototype visuals** |
| Pass 6 | Wind-up / impact / recovery, move slowdown, hit-stop, telegraph alignment — **prototype timing** |
| Pass 7 | Likely-target preview ring + shared selection logic — **prototype readability** |
| Weapon P1 | Debug weapon profiles (1/2/3) — focused attack only — **prototype** |
| Weapon P2 | Profile tuning + weapon-scaled CC — **prototype** |
| Weapon T1 | Identity refinement (sword DPS, polearm control) — **prototype** |
| Pass 3 dir. | Weapon Identity Direction (dagger/sword/polearm) — design only |
| **v1 checkpoint** | [`project_checkpoint_combat_feel_v1.md`](../checkpoints/project_checkpoint_combat_feel_v1.md) — combat prototype SoT |
| **Combat Depth P1A** | Combat Stance, weapon move speed, attack facing lock — **implemented** |
| **Combat Depth P1B** | Target Focus System — **implemented** |
| **Archetype P1** | Scout DISENGAGE/probe, Raider baseline, Brute RECOVER/knockback filter — **implemented** |
| **Archetype P1B** | Attack commitment, interruption tuning, Brute stagger 0.47 s — **implemented** |
| **Level P2.1** | Quiet Grove east wall + two south exits — layout complete |
