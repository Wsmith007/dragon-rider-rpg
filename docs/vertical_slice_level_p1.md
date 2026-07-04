# Vertical Slice Level — Prototype

**Scene:** `res://scenes/world/VerticalSlice_Level_P1.tscn`  
**Game root:** `res://scenes/world/VerticalSliceLevelP1Game.tscn`  
**Design reference:** [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md) Section 6, 12  
**Status:** Graybox — **Pass 2 complete** (P2.2 connectivity — Phase 1 layout signed off)

TestWorld remains the permanent systems sandbox.

---

## Development roadmap (next three milestones)

| # | Milestone | Status | Purpose |
|---|-----------|--------|---------|
| **1** | **Level Prototype Pass 2** | **Complete** (P2.2) | Connected environment — navigation, boundaries, pacing, flow |
| **2** | **Enemy Archetype Prototype Pass 1** | **Implemented** | Behavioral Scout / Raider / Brute roles |
| **3** | **Combat Depth Pass 1** | Documented only | Combat Stance + movement identity — **not implemented** |

Detail in [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md) Section 12.

---

## Purpose

Prove the fifteen-minute teaching arc in a **handcrafted space**. Each named encounter teaches **one primary lesson** through experience — not tutorials.

---

## Pass 2 layout philosophy

Pass 1 proved encounters and pacing hooks. **Pass 2** reshapes the graybox from **adjacent labeled boxes** into **one connected route**:

| Principle | Pass 2 approach |
|-----------|-----------------|
| **Connected place** | Variable-width spine + grove wing — not ten equal rooms |
| **Visible = physical** | Every drawn wall segment has matching `StaticBody2D` collision |
| **Location identity** | Wide clearing, narrow choke, junction, secluded grove, gate pinch, open outlook |
| **Natural guidance** | Route polylines + wall shape — minimize “where do I go?” |
| **Graybox only** | Shape, spacing, visibility — no art pass |

### Route shape (Pass 2 — P2.2 final)

```
START ── clearing ── ambush ── crossing ── crossroads ═══ quiet grove ═══╗
                              │              ↑ north entry (SW gap)      ║
                              │              ↓ two south exits           ║
                              │         SW exit → crossroads             ║
                              │         SE exit → hold (quieter path)    ║
                              │                                          ║
                              ├──[ gate ]── hold ── gate ── fork ── last stand ── END
                              └── main route (direct, intentional choke)
```

### Dual-route philosophy (Crossroads → Hold)

After **The Crossroads**, the player chooses:

| Route | Path | Feel |
|-------|------|------|
| **Direct** | East through **Crossroads → Hold gate** (x 48…92, y ±40) | Main combat route — intentional choke into The Hold |
| **Quiet** | North into **Quiet Grove** → southeast exit → The Hold | Secluded detour — peaceful connector, rejoins east of the gate |

Both routes reach **The Hold** naturally. The grove is not a combat room — it is optional pacing relief and a readable alternate path.

**Quiet Grove connectivity (P2.2 final):**

| Exit | Location (south lip) | Connects to |
|------|----------------------|-------------|
| **Southwest** | x −95…45 | **The Crossroads** — rejoin main route west of the gate |
| **Southeast** | x 165…265 | **The Hold** — drops into spine east of gate via matching north-wall gap |

**North spine wall** now has **three segments** (not one wide eastern gap):

- Wall west of grove SW entry  
- **Gap** x −95…45 — Crossroads ↔ grove SW  
- **Wall** x 45…165 — closes undifferentiated openness  
- **Gap** x 165…265 — grove SE ↔ Hold (**second exit made walkable**)  
- **Wall** x 265…east — outer spine continues  

**Crossroads → Hold gate:** Vertical pillars at x 48 and x 92 with an ~80 px central opening (y −40…40). Replaces the previous “entire boundary open” feel.

**East wall of grove:** Full height — no opening. No out-of-bounds access from the east.

---

## Named spaces (Pass 2)

| Space | Shape intent | Gameplay role |
|-------|--------------|---------------|
| **The Clearing** | Wide open start | Safe introduction — START marker |
| **The Ambush** | Narrow choke | First combat — pressure in tight space |
| **The Crossing** | Medium path | Baseline duel room |
| **The Crossroads** | Wide junction + north spur + **Hold gate** | Mixed fight; branch to grove or direct choke into Hold |
| **The Quiet Grove** | Sealed bowl, north entry + **two south exits** | **Safe rest** — full heal on entry; enemies cannot follow |
| **The Hold** | Wide arena | Sustained surround — reachable via **main gate** or **grove SE exit** |
| **The Gate** | Narrow choke | Space lesson before Brute |
| **The Fork** | Medium path | Scout + Brute synthesis |
| **The Last Stand** | Wide arena | Climax mix |
| **The Outlook** | Wide calm end | Destination — END marker |

Encounters unchanged from Pass 1 — only **trigger positions** moved to match new spine.

---

## Pass 2 boundary improvements

### What caused remaining Pass 1.1 issues

| Issue | Cause |
|-------|--------|
| **Grove shortcuts** | Partial east grove wall + wide north-wall gap let players slip around the bowl |
| **Visible ≠ collision** | Zone tint **rectangles** looked like walls; actual collision was separate thin segments with **gaps at corners** |
| **Out-of-bounds** | Ground `ColorRect` extended beyond outer collision; dark margin was walkable |
| **Box row feel** | Each zone drew bordered rectangles — read as disconnected test chambers |

### Pass 2 corrections

- **Single wall list** — `_build_wall_segments()` defines every collider; `_draw()` renders the **same** rects in wall color  
- **Outer envelope** — continuous ring (overlapping corner thickness)  
- **Grove sealed (P2.1)** — north / west / **full east** walls; south lip has **exactly two gaps** (southwest x −95…45, southeast x 165…265)  
- **East bypass removed** — no partial east wall or east-side cut-through; east boundary is continuous  
- **Variable spine** — pinch walls at Ambush + Gate match visual choke  
- **Floor tints** — soft path shading without box borders  
- **Ground** — matches world bounds (−1340…1880 × −560…150); outside is wall-enclosed  

### P2.1 — Quiet Grove fix (final layout issue)

| Issue | Fix |
|-------|-----|
| **East-wall opening** | Partial east wall ended above south lip → gap into out-of-bounds east of grove |
| **Unintended access** | Player could slip through east side into non-playable margin |
| **Correction** | East wall spans full grove height (`GROVE_Y0` → `GROVE_Y1`); removed east bypass block segment |

### P2.2 — Grove ↔ Hold connectivity + Crossroads gate (final refinement)

| Issue | Cause | Fix |
|-------|-------|-----|
| **SE exit unusable** | North spine had one gap x 45…1880 — SE exit at x 165…265 sat **inside walled segment**, blocking drop into spine | Split north spine: wall x 45…165, **gap x 165…265** aligned with grove SE south lip |
| **Crossroads / Hold too open** | No vertical divider on shared boundary — entire east half of north wall was open | **Gate pillars** x 48 / 92 with y −40…40 passage — main route choke |
| **Dual route unclear** | Hold felt same whether or not player visited grove | Route guides: main path through gate; grove SE path bypasses gate into Hold |

Script: `scripts/world/vertical_slice_graybox_geometry.gd`

---

## Player guidance (Pass 2)

- **START / END** markers on spine  
- **Route polyline** — main spine through **Crossroads → Hold gate**; grove branch with **SW → Crossroads** and **SE → Hold**  
- **Crossroads spur ticks** — suggest north branch without text  
- **Choke geometry** — Ambush and Gate physically narrow movement  
- **Zone HUD** — `SliceZoneLabel` updates from layout-driven zone notifiers  
- **No invisible blockers** — if you see a wall, it collides  
- **Quiet Grove rest** — entering restores full HP; enemies stop chasing while the player is inside  

---

## Named encounters (archetype Pass 1)

Encounters use **behavioral archetypes** via `VerticalSliceArchetypePresets.apply_to_enemy()` — not stat-only placeholders.

| Name | Enemies | Archetype behavior | Lesson |
|------|---------|---------------------|--------|
| The Ambush | 1× Scout | Hit-and-run skirmisher | Focused attack, positioning |
| The Crossing | 1× Raider | Baseline fighter | Core melee loop |
| The Crossroads | Scout + Raider | Skirmisher + baseline mix | Prioritization |
| The Hold | 2× Raider | Sustained surround pressure | Surround / CC |
| The Gate | 1× Brute | Control check | Spacing / protection |
| The Fork | Scout + Brute | Speed + spacing dual problem | Dual problem |
| The Last Stand | Scout + Raider + Brute | Full role synthesis | Synthesis |

Pacing and trigger positions unchanged from Pass 1.

Spawn: **(−1180, 0)** · Run: **F6** on `VerticalSlice_Level_P1.tscn`

---

## Archetype implementation (Pass 1)

`vertical_slice_archetype_presets.gd` applies stats **and** behavior exports (`disengage_duration`, `circle_bias`, `post_attack_recovery`, etc.) to `enemy.gd` at spawn.

| Archetype | AI difference from Raider |
|-----------|---------------------------|
| **Scout** | DISENGAGE after attack, orbit chase, strafe engage |
| **Raider** | Baseline — no change |
| **Brute** | RECOVER after attack, knockback filter, slow committed strikes |

---

## Phase 1 graybox — complete

Pass 2 + P2.1 + P2.2 satisfy Phase 1 level layout goals:

- [x] Connected route from START to END with named locations  
- [x] Visible walls match collision  
- [x] Quiet Grove — **two functional south exits** (SW → Crossroads, SE → Hold)  
- [x] Hold reachable via **main gate** or **grove quiet path**  
- [x] Crossroads → Hold **narrowed gate** — no whole-boundary openness  
- [x] No east-wall out-of-bounds from grove  
- [x] Encounter order unchanged; triggers on spine  

**Ready for Enemy Archetype Prototype Pass 1** after brief playtest confirmation of both Hold routes and gate readability.

---

## Scripts

| File | Role |
|------|------|
| `vertical_slice_graybox_geometry.gd` | Pass 2 walls, floor tints, route guides |
| `vertical_slice_level_p1.gd` | Encounters, zone notifiers, restart |
| `vertical_slice_encounter.gd` | Triggers + spawn |
| `vertical_slice_world_shell.gd` | Debug shell |

---

## Document history

| Version | Date | Scope |
|---------|------|-------|
| **P1** | 2026-05-29 | Initial graybox + encounters |
| **P1.1** | 2026-05-29 | Corridor fix, enemy readability, help UI |
| **P2** | 2026-05-29 | Connected route, sealed boundaries, location shaping, roadmap docs |
| **P2.1** | 2026-05-29 | Quiet Grove — full east wall, two south exits |
| **P2.2** | 2026-05-29 | SE exit → Hold gap, Crossroads → Hold gate, dual-route |
| **Archetype P1** | 2026-05-29 | Scout/Raider/Brute behavioral AI — encounters use true roles |
