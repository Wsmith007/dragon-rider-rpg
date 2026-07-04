# Dragon Rider RPG — Combat Feel v1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Main scene:** `res://scenes/world/TestWorld.tscn` (playtest shell with split layout)  
**Prior relationship checkpoint:** `docs/project_checkpoint_milestone9A.md` (relationship / bond — **not** combat prototype SoT)  
**Vertical Slice design:** `docs/vertical_slice_design_v1.md` (player experience, scope, success criteria — **not** mechanical SoT)  
**Combat design journal:** `docs/combat_feel_notes.md` (pass-by-pass history + future ideas)  
**High-level combat vision:** `docs/combat.md` (co-op philosophy, bond/sync/instability — partially ahead of prototype)

**Status:** Stable reference for the **current combat prototype** after Combat Feel Passes **1–7**.  
**Scope:** Rider melee, default enemy behavior, combat feedback, and playtest-tuned feel.  
**Not in scope:** Full weapons, equipment, enemy variants, leveling, progression, dragon combat expansion, magic.

**Post-v1 tuning (live):** Weapon Profile **Tuning Pass 1** refines Pass 1–2 debug profiles — sword highest DPS, weapon-scaled CC, polearm control focus. See `docs/combat_feel_notes.md` → Weapon Profile Prototype Tuning Pass 1.

---

## Milestone Summary

| Area | Status |
|------|--------|
| Enemy positioning & surround (Pass 1) | **Live** |
| Enemy speed / knockback / stagger (Pass 2) | **Live** |
| Focused + CC attack split (Pass 3) | **Live** |
| Aim forgiveness + CC role tuning (Pass 4) | **Live** |
| Attack telegraphs + hit confirmation (Pass 5) | **Live** |
| Attack commitment / wind-up / recovery (Pass 6) | **Live** |
| Likely-target preview (Pass 7) | **Live** |
| Weapon profile prototype (debug 1/2/3) | **Live** — Tuning Pass 1: focused + weapon-scaled CC |
| Weapon / equipment systems | **Not implemented** |
| Enemy archetype variants | **Not implemented** |
| Combat audio | **Not implemented** |
| Attack animations | **Not implemented** |
| Stamina / charge limits on CC | **Not implemented** |

---

## Section 1 — Combat Feel Summary

### Combat Feel Pass 1 — Enemy positioning & pressure

**Goal:** Make group fights readable without full squad AI.

| Change | Detail |
|--------|--------|
| **Slot spread** | `EnemyCombatSteering` — eight angular slots around player (instance-id hash) |
| **Separation** | Peer push when enemies within ~34 px |
| **Chase steering** | Enemies steer toward assigned slot, not player centroid (multi-enemy); solo chases direct |
| **ENGAGE pressure** | Micro-reposition while in attack range; attacks require clear line; no zero-velocity idle |
| **Collision** | Enemy-enemy collision disabled (`collision_mask = 1`) so steering can spread groups |
| **Hit feedback** | `CombatVisualFeedback` — brief white flash + small nudge on damage |

**Files:** `scripts/combat/enemy_combat_steering.gd`, `scripts/enemies/enemy.gd`, `scripts/combat/combat_visual_feedback.gd`

---

### Combat Feel Pass 2 — Movement tuning, knockback, stagger

**Goal:** Enemy movement and player hit reactions feel better in swarms.

| Change | Detail |
|--------|--------|
| **Enemy speed** | `chase_speed` **100** (was 130), `engage_reposition_speed` **48** (was 75) |
| **Steering stability** | Velocity + facing smoothing; ENGAGE hold when solo + in range |
| **Knockback** | **15 px** away from player on hit (player melee baseline) |
| **Stagger** | **0.3 s** — enemy frozen (no move, no attack) after knockback |
| **Future hook** | `knockback_resistance` export on `Enemy` for per-type tuning |

At this stage the player still used a **360° AoE** on Space; knockback/stagger made it read as space-creation.

---

### Combat Feel Pass 3 — Focused attack + CC split

**Goal:** Test directional primary attack vs separate crowd-control tool.

| Input | Attack |
|-------|--------|
| **Space** (also LMB / J) | **Focused** directional cone — primary damage |
| **Shift + Space** | **360° CC** — preserved Pass 1–2 circular hitbox behavior |

- Focused: manual cone query, player facing, usually one target
- CC: `Area2D` circle, hits all enemies in range once per swing
- Independent cooldowns (initially same damage profile; split in Pass 4)

---

### Combat Feel Pass 4 — Aim forgiveness + CC philosophy

**Goal:** Focused attacks more reliable; CC is repositioning, not best DPS.

| Attack | Damage | Knockback | Stagger | Cooldown |
|--------|--------|-----------|---------|----------|
| **Focused** | 25 | 15 px | 0.3 s | 0.35 s |
| **CC** | 12 | 22 px | 0.6 s | 0.9 s |

**Aim forgiveness (no lock-on):**

- Base cone **70°** (±35°), range **44 px**
- Close-range forgiveness **100°** within **28 px**
- Soft aim assist: **20%** blend toward nearest enemy within **40 px** / **90°** of facing
- Primary target: most centered in cone, then closest; cleave only if lined up in strict cone

---

### Combat Feel Pass 5 — Attack telegraphs + hit confirmation

**Goal:** Player can see where attacks go and whether they connected.

| Layer | Focused | CC |
|-------|---------|-----|
| **Telegraph** | Cyan cone wedge + sweep line | Purple expanding ring |
| **Miss vs hit** | Dim vs bright cone; spark only on hit | Ring on swing; spark per enemy hit |
| **Enemy confirm** | Warmer, longer flash on player hits | Same |
| **Debug** | **F11** — cone, close wedge, CC radius overlay | Same |

---

### Combat Feel Pass 6 — Attack commitment & weight

**Goal:** Attacks feel deliberate, not instantaneous button presses.

**Sequence:** Input → **Wind-up** → **Impact** → **Recovery**

| Attack | Wind-up | Impact | Recovery | Move speed (wind-up / recovery) |
|--------|---------|--------|----------|--------------------------------|
| **Focused** | 0.10 s | instant hit query | 0.12 s | 55% / 70% |
| **CC** | 0.17 s | 0.10 s hitbox window | 0.20 s | 40% / 50% |

- Telegraph during wind-up; damage at impact (not on press)
- **Option A movement:** reduced speed during wind-up/recovery, not full lock
- Subtle **hit-stop** on connect: ~0.028 s real time at 0.75× time scale (once per attack if any hit)
- Telegraph shows strict cone + close-range forgiveness overlay (aligned with hit logic)

---

### Combat Feel Pass 7 — Target preview & readability

**Goal:** Answer *“If I press Space right now, who am I probably attacking?”*

- Subtle **pulsing cyan ring** (17 px) + center dot on likely primary focused target
- Uses **`_gather_focused_candidates()`** — same logic as focused impact (not a separate targeting system)
- Hidden during active attacks; no lock-on, cycling, or camera changes
- **F11** debug: yellow line + ring on likely target in addition to range overlays

**Known preview limitation:** Preview uses current facing; impact re-samples facing after wind-up — strafing during wind-up can change the hit.

---

## Section 2 — Current Player Combat

### Player movement & facing

| Property | Value |
|----------|-------|
| Move speed | **220 px/s** |
| Facing (moving) | Current velocity direction |
| Facing (idle) | Last movement direction (`_facing_direction`) |
| Visual | Polygon2D rotation follows facing |

**Script:** `scripts/player/player.gd`

---

### Focused attack (primary)

| Property | Value |
|----------|-------|
| **Input** | **Space**, **LMB**, **J** (`attack` action) |
| **Geometry** | Frontal cone — **70°** base (±35°), **100°** within **28 px** close range |
| **Range** | **44 px** from player center |
| **Damage** | **25** |
| **Knockback** | **15 px** (per-hit override) |
| **Stagger** | **0.3 s** on enemy |
| **Cooldown** | **0.35 s** (starts on press) |
| **Hit detection** | Manual query over `enemy` group (not Area2D) |
| **Target selection** | Soft-assisted facing → candidates in cone → sort by angle then distance → primary + optional lined-up cleave |
| **Wind-up / recovery** | 0.10 s / 0.12 s with move slowdown |

**Script:** `scripts/player/player_melee_attack.gd`

---

### Crowd-control attack (repositioning)

| Property | Value |
|----------|-------|
| **Input** | **Shift + Space** (`crowd_control_attack` action) |
| **Geometry** | **360°** circle, **28 px** radius (`Area2D` hitbox on player) |
| **Damage** | **12** |
| **Knockback** | **22 px** (per-hit override) |
| **Stagger** | **0.6 s** on enemy |
| **Cooldown** | **0.9 s** |
| **Hits** | All valid enemies in range once per swing |
| **Wind-up / impact / recovery** | 0.17 s / 0.10 s active hitbox / 0.20 s with heavier move slowdown |

**Philosophy:** Create space when surrounded — not the best damage option.

---

### Aim forgiveness (focused)

| Mechanism | Value |
|-----------|-------|
| Soft assist blend | **20%** toward nearest enemy in **40 px** / **90°** |
| Close-range arc | **100°** within **28 px** |
| Cleave | Second target only if inside strict **70°** of base facing |
| Lock-on | **None** |

---

### Target preview (Pass 7)

| Property | Behavior |
|----------|----------|
| Visual | 17 px pulsing ring + 3 px dot under enemy |
| Logic | `get_likely_focused_target()` → top of `_gather_focused_candidates()` |
| Active when | Not attacking; valid candidate exists |
| Script | `scripts/combat/combat_focused_target_preview.gd` |

---

### Telegraph & hit confirmation

| System | Behavior |
|--------|----------|
| **Wind-up telegraph** | Dim pulsing cone (focused) or inner ring (CC) |
| **Impact telegraph** | Bright cone / expanding ring; hit vs miss color |
| **Hit spark** | Warm ring at contact point |
| **Enemy flash** | `queue_player_hit_confirm()` — warmer, slightly longer than default |
| **Hit-stop** | Brief global time scale dip on any player melee connect |
| **Debug F11** | Strict cone, close wedge, CC radius, likely-target line |

**Script:** `scripts/combat/combat_attack_telegraph.gd`

---

### Player combat architecture (files)

```
Player (CharacterBody2D)
├── MeleeAttack (player_melee_attack.gd)
│   ├── Telegraph (combat_attack_telegraph.gd)
│   ├── TargetPreview (combat_focused_target_preview.gd)
│   └── Hitbox (Area2D — CC only)
├── Engagement (player_engagement.gd — dragon assist targeting)
└── CombatVisualFeedback (player damage flash only)
```

---

## Section 3 — Current Enemy Combat

### Default prototype enemy (`Enemy.tscn` / `enemy.gd`)

| Property | Value |
|----------|-------|
| Max health | **150** |
| Detection / lose radius | **220** / **320** px |
| Chase speed | **100** px/s |
| Engage reposition speed | **48** px/s |
| Attack range | **36** px |
| Attack damage | **12** |
| Attack cooldown | **1.0** s |
| Engage windup | **0.45** s |
| Slot standoff | **34** px |
| Knockback resistance | **1.0** (default) |

### State machine

```
IDLE → CHASE (player in detection) → ENGAGE (in attack range)
     ← lose radius / no player
```

### Chase behavior

- Multi-enemy: steer toward **slot position** around player + separation from peers
- Solo: direct chase toward player
- Smoothed velocity and facing (`steer_smoothing`, `facing_smoothing`)

### Engage behavior

- Light reposition toward slot / separation when blocked
- **Solo hold:** when alone, in range, and clear line — minimal movement (pressure without orbit spam)
- Attack only with **clear line** to player (no shooting through stacked ally)
- Wind-up (`engage_windup`) before damage

### Surround & separation (`EnemyCombatSteering`)

- **8 slots** around player (hash from instance id)
- **Separation radius ~34 px** — push away from nearby enemies
- Chase targets slot; engage creeps / separates as needed

### Hit reactions

- `CombatVisualFeedback` on enemy: flash + `apply_hit_reaction()`
- Default scene values: **15 px** nudge, **0.3 s** stagger — **overridden** by player attack type via `override_next_hit_reaction()`
- During stagger: zero velocity, no attacks until `_stagger_remaining` expires
- Knockback applied instantly; direction away from player

### Philosophy

Enemies should **pressure positioning** and **surround** without full tactical AI. Steering creates readable groups; ENGAGE adds threat without zero-velocity turrets. Player knockback/stagger creates brief spacing windows for focused strikes or CC.

**Not changed in Combat Feel Passes:** enemy AI logic, dragon AI, relationship hooks.

---

## Section 4 — Combat Design Philosophy

Discovered through Passes 1–7 playtesting and documented in `combat_feel_notes.md`:

### Directional combat

- Primary attack is **focused and frontal** — player chooses facing
- Omnidirectional damage moved to **dedicated CC action**, not basic attack
- Soft forgiveness and preview aid aim without lock-on

### Readability over complexity

- Telegraphs, hit sparks, target preview, and F11 debug overlays teach cone/radius
- Short stagger over hard stun; no damage numbers in prototype
- Visual distinction: focused (cyan cone) vs CC (purple ring)

### Positioning matters

- Slot spread and separation reward movement and facing
- Close-range forgiveness helps melee range without removing skill
- CC exists for **“I need space”** moments when surrounded

### Crowd control vs focused damage

| Role | Tool |
|------|------|
| **Kill / primary pressure** | Focused attack — higher damage, faster cooldown |
| **Create space / survive** | CC — lower damage, stronger knockback/stagger, longer cooldown |

### Weapon identity (design direction — not live stats)

Identity comes from **reach, speed, arc, knockback, and control** — **not damage alone**.

- **Dagger:** precision, fast, narrow, high sustained DPS
- **Sword:** balanced arc and reach
- **Polearm:** control, reach, knockback — **not** highest damage

Current prototype uses a **single global profile** approximating dagger-tier focused + shared CC.

### Rider / dragon co-op (unchanged by combat feel passes)

- Dragon assist uses `PlayerEngagement` (recent hit + facing alignment)
- Bond / Sync / Instability affect **assist and protection**, not melee geometry
- Relationship encounter resolve remains per Milestone 9A

---

## Section 5 — Documented Future Direction

**Status: DESIGN DIRECTION ONLY — NOT IMPLEMENTED**

Summarized from `combat_feel_notes.md` → Weapon Identity Direction. Do not treat as live behavior.

### Weapons (future)

| Weapon | Role | Focused attack (future) | CC (future) |
|--------|------|-------------------------|-------------|
| **Dagger** | Precision | Smallest arc, shortest reach, fastest, highest DPS | Optional limited spin |
| **Sword** | Balanced | Moderate arc/reach, small cleave | Shared CC action |
| **Polearm** | Control | Wide arc, long reach, strong knockback, **lowest** sustained DPS | Shared CC action |

### Attack roles (future)

| Attack type | Role |
|-------------|------|
| **Focused / frontal** | Primary attack — precision, positioning |
| **360° / spin** | Crowd-control tool — space creation, limited resource (cooldown/charges/stamina) |

### Rider / dragon (future combat expansion)

- Dragon combat damage, aerial combat, combo sync — see `combat.md` long-term goals
- Assist alignment to player facing arc (not omnidirectional hitbox)
- Stagger windows for assist readability
- Dragon health → combined harm for encounter quality (Milestone 9A planned, not live)

---

## Section 6 — Known Limitations

| Limitation | Notes |
|------------|-------|
| **No weapon system** | One global focused + CC profile on all swings |
| **No equipment** | No gear modifying reach, arc, or damage |
| **No enemy variants** | Single `Enemy` archetype; speed exports exist for future override |
| **No dragon health** | Player harm only for encounter quality |
| **No magic** | Melee prototype only |
| **No attack animations** | Timing and `_draw()` telegraphs only |
| **No audio feedback** | Silent hits, wind-ups, misses |
| **No stamina / charges** | CC limited by cooldown only |
| **No progression integration** | Combat stats not tied to leveling |
| **Global hit-stop** | Briefly affects entire simulation, not player-only |
| **Preview vs impact gap** | Facing can change during focused wind-up |
| **No dodge / i-frames** | Movement only |
| **Single test scene** | `TestWorld` playtest shell |
| **combat.md gap** | High-level doc does not list Space / Shift+Space or pass-specific behavior |

---

## Section 7 — Next Logical Milestones

Listed for planning only — **not implemented**.  
**Vertical Slice build order** (level → archetypes → polish): [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md) Section 12. Slice enemy roles: Scout / Raider / Brute (Section 3).

### 1. Weapon Profile Prototype

Split focused/CC parameters by weapon class (dagger / sword / polearm) **without** full equipment/inventory. Test arc, reach, and timing differences using export profiles or scene variants.

### 2. Enemy Variant Prototype

Scout / Raider / Brute **archetypes** (slice design) — gameplay roles using `chase_speed`, `engage_reposition_speed`, and `knockback_resistance` overrides. See [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md) Section 3. *(Checkpoint label "Heavy / scout / beast" predates Raider/Brute naming.)*

### 3. Combat Audio Pass

Distinct SFX for focused swing, CC pulse, hit, miss, stagger, and wind-up. Low-cost readability win after visual passes.

### 4. Animation Pass

Sprite wind-up / swing / recovery synced to Pass 6 timings. Replace or supplement `_draw()` telegraphs with character animation.

### 5. Dragon Combat Expansion

Dragon damage, strike telegraphs, health integration, combined harm for encounter quality. Co-op readability with focused player facing.

### 6. Progression Integration

Link character level / stats to combat capabilities without breaking the directional + CC split established in Combat Feel v1.

---

## Section 8 — Source of Truth

### Primary combat prototype reference

**`docs/project_checkpoint_combat_feel_v1.md`** (this document) is the **primary reference** for:

- Live player melee behavior (focused + CC)
- Combat feel passes 1–7 summary and current values
- Enemy prototype combat behavior and philosophy
- Known limitations before weapon/equipment/progression work

### Related documents

| Document | Role |
|----------|------|
| **`docs/combat_feel_notes.md`** | Pass-by-pass journal, playtest questions, weapon identity design notes, future ideas — **supplements** this checkpoint; may contain historical or forward-looking sections |
| **`docs/combat.md`** | High-level combat vision (rider–dragon co-op, bond/sync/instability philosophy) — **not** pass-level mechanical SoT |
| **`docs/project_checkpoint_milestone9A.md`** | Relationship / bond / encounter resolve SoT — **orthogonal** to combat feel; still authoritative for Sync/Instability application |
| **`docs/game_architecture.md`** | Product-level systems map |
| **`docs/technical_architecture.md`** | Code organization; notes `CombatSystem` as future/managed layer |

### Key implementation files

| File | Responsibility |
|------|----------------|
| `scripts/combat/weapon_profile_prototype.gd` | Debug weapon profile data (Dagger / Sword / Polearm) |
| `scripts/player/player_melee_attack.gd` | Focused + CC attacks, timing, profiles, aim forgiveness |
| `scripts/player/player.gd` | Movement, facing, attack move-speed multiplier |
| `scripts/combat/combat_attack_telegraph.gd` | Wind-up/impact telegraphs, sparks, F11 overlay |
| `scripts/combat/combat_focused_target_preview.gd` | Likely-target ring |
| `scripts/combat/combat_visual_feedback.gd` | Hit flash, knockback, stagger, player hit confirm |
| `scripts/combat/enemy_combat_steering.gd` | Slot spread, separation, engage chase |
| `scripts/enemies/enemy.gd` | Enemy state machine, attacks, stagger |
| `scenes/player/Player.tscn` | Player scene graph |
| `scenes/enemies/Enemy.tscn` | Default enemy scene |
| `project.godot` | Input actions: `attack`, `crowd_control_attack` |

### When to update this checkpoint

Create **Combat Feel v2** (or amend v1) when:

- Weapon profiles ship (even prototype-only)
- Equipment modifies combat stats
- Enemy variants change default pressure model
- Major attack timing or geometry changes occur
- Dragon combat damage/health integrates with player combat loop

Until then, **Combat Feel v1** is the stable baseline for weapon experimentation and downstream systems.

---

## Document history

| Version | Date | Scope |
|---------|------|-------|
| **v1** | 2026-05-29 | Checkpoint after Combat Feel Passes 1–7; documentation only |
