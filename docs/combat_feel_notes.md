# Combat Feel Notes

**Status:** Passes **1–7 are implemented** (prototype — not final). Sections below marked *future* or *design direction* are not live unless stated otherwise.  
**Current combat reference (live values & SoT):** [`docs/project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md)  
**Relationship / bond reference:** [`docs/project_checkpoint_milestone9A.md`](project_checkpoint_milestone9A.md)  
**High-level combat vision:** [`docs/combat.md`](combat.md)

This document is the **pass-by-pass journal** and design notebook. For a single stable summary of live combat, use **Combat Feel v1**.

**Live prototype (Passes 1–7):** Directional focused attack + Shift+Space CC, aim forgiveness, telegraphs, attack commitment, and likely-target preview — see checkpoint and pass sections below.

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

**Status: IMPLEMENTED · Cone/range/damage updated in Pass 4+ — see [`project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md)**

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

**Live (Passes 3–7):** focused primary + Shift+Space CC — see [`project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md).

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

> **Live behavior:** [`project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md) · **Weapon plan:** [Weapon Identity Direction](#weapon-identity-direction)

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

Default prototype values live on `Enemy` exports (`chase_speed`, `engage_reposition_speed`). Future archetypes override per scene/type — **not implemented as variants yet**.

| Archetype | Speed feel | Notes |
|-----------|------------|-------|
| **Heavy** | Slow | Strong; high `knockback_resistance` |
| **Scout** | Fast | Fragile |
| **Standard** | Medium | Current default tuning |
| **Beast** | Fast bursts | Lower steering control; short engage reposition |

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

See [`project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md) for full values.

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
3. Sword / polearm arc prototypes (still no equipment system)
4. Enemy attack wind-up visual
5. Sprite animation synced to Pass 6 wind-up / impact / recovery
6. Audio pass for hit / hurt / miss / wind-up feedback
7. Color-blind safe telegraph + preview variants if readability issues found
8. Preview-at-impact hint during focused wind-up (optional)

---

## Explicitly not planned here

Leveling, equipment, magic systems, dragon health, Outcome Rating revision, enemy scaling, bosses, advanced CC — see [`project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md) limitations and [`project_checkpoint_milestone9A.md`](project_checkpoint_milestone9A.md) for relationship scope.

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
| Pass 3 dir. | Weapon Identity Direction (dagger/sword/polearm) — design only |
| **v1 checkpoint** | [`project_checkpoint_combat_feel_v1.md`](project_checkpoint_combat_feel_v1.md) — combat prototype SoT |
