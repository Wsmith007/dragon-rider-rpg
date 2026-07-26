# Dragon Rider RPG — Dragon Survivability Pass 1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** LaunchMenu · `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn`  
**Design constitution:** [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md)  
**Related:** [`project_checkpoint_combat_stakes_pass1.md`](./project_checkpoint_combat_stakes_pass1.md) · [`project_checkpoint_milestone9A.md`](./project_checkpoint_milestone9A.md)  
**Documentation:** [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md)  
**Status:** **REFINED after playtest — interact revive + Sync 60s + stronger dragon pressure**  
**Date:** 2026-07-25

---

## Playtest Validation (original Pass 1)

Developer confirmed:

- [x] Dragon health, knockout, HUD, penalties, and original auto-revival worked
- [x] No major regressions observed
- [x] Sync penalty at **12 s** felt too short → extended to **60 s**
- [x] Automatic revival rejected → replaced with **hold E** interact revive
- [x] Enemies rarely hit the dragon → targeting pressure + dragon hit radius tuned

---

## Goals

The dragon should feel like a partner with stakes: take damage, draw some attention, knock out without permanent death, and require the player to clear nearby danger and interact to revive — without becoming a fragile escort quest.

Bond strength is **not** changed by knockout.

---

## Dragon HP Baseline

| Value | Default | Notes |
|-------|--------:|-------|
| Max HP | **50** | Raised from foundation 40 |
| Hits vs Scout (6) | ~8 | Durable skirmish pressure |
| Hits vs Raider (10) | 5 | Clear chip |
| Hits vs Brute (18) | ~3 | Heavy threat |

- Brief hit invulnerability: **0.15 s**
- Post-revive grace: **2.0 s**
- HP clamped to `[0, max]`; never permanently dies

---

## Enemy Targeting Model (refined again after live playtest)

### Playtest problems (after first pressure tune)

- Enemies felt like “last body that passed close wins.”
- Scouts preferred the dragon too often.
- Brutes tunneled onto the dragon and ignored an intervening player.
- Target commitment felt like fixation, not tactics.

### Root causes (code)

1. Score used `weight / distance` → closest actor dominated.
2. Universal dragon close bonus ×1.65 within 80u applied even to Scouts.
3. Assist participation ×2.0 stacked with proximity.
4. Brute base weights already favored dragon (`player×0.92` vs `dragon×1.2`).
5. Sticky ×1.15 + hysteresis 1.18 made abandoning dragon hard.
6. No player-interception term; only dragon-blocking-path.
7. No max stale / no-progress escape from a bad focus.

### Current model

Detection / lose aggro still keyed off the **player**. Soft `_combat_target` = player or dragon.

| Factor | Behavior |
|--------|----------|
| Soft distance | `1 / (1 + d / 70)` — proximity helps, does not overwrite |
| Base Scout | Player weight ×**1.45**, dragon ×**0.45** |
| Base Raider | Player ×**1.15**, dragon ×**0.85** |
| Base Brute | Player ×**1.05**, dragon ×**1.05** |
| Scout proximity peel | Only if dragon ≤ **28** (tiny); no generic 80u peel |
| Raider/Brute close dragon | Mild bonus ≤ **55** |
| Assist participation | Scout ×1.12 · Raider ×1.28 · Brute ×1.35 |
| Recent dragon damage | Scout ×1.55 · others ×1.4 (still meaningful) |
| Player interception | Corridor / melee reach; Brute ×**1.75**, Raider ×1.45, Scout ×1.35 |
| Switch | Retarget **0.40 s**, hysteresis **1.22**, sticky ×1.08 |
| Min commitment | **0.55 s** (invalid targets ignore; margin rises to 1.35 while committed) |
| Stale recovery | Out of useful range **2.2 s** or no distance progress **1.8 s** → force reassess |
| Active rush | Still skips retarget (attack phase) |
| KO dragon | Immediately invalid → fallback player |

Player remains primary. Dragon draws pressure from damage, blocking, and Brute obstruction — not from walking past.

**Feel not re-validated** until developer retests.

---

## Knockout Rules

At zero HP (once):

- Enter `KNOCKED_OUT`
- Cancel strike / cooperative assist
- Ignore wait/recall commands that need activity
- Stay in scene with muted KO modulate
- Not a valid enemy target
- No game over if the player lives
- Penalties applied **once** per KO

---

## Instability Consequence

On KO: `BondSystem.apply_instability_delta(+25)` once. Not auto-cleared on revival.

---

## Temporary Sync Consequence

1. On KO: `BondSystem.apply_sync_delta(-10)` once.
2. Timer **60 s** (first-pass tuning; was 12 s — too short in playtest).
3. On expiry: `apply_sync_delta(+10)` once. Re-KO while active refreshes the timer only (no stack).
4. Encounter restart / `reset_to_full()` clears outstanding penalty correctly.

Bond strength never touched.

---

## Revival Flow (player interaction)

Automatic post-combat revival **removed** after playtest rejection.

1. Dragon reaches 0 HP → `KNOCKED_OUT` and stays down.
2. Player approaches within `revive_interact_range` (**56**).
3. HUD prompt: **Hold E — Revive Dragon** (or “Clear nearby enemies…” if blocked).
4. Hold `interact` (**E**) for `revive_hold_duration` (**2.5 s**).
5. Revive at **35%** HP + **2 s** grace.

### Safety / cancel rules

- Hostile enemy within `revive_danger_radius` (**220**) of the dragon **blocks** revive (prompt shows danger).
- Leaving range cancels progress.
- Player taking damage cancels progress.
- Active dragon never shows revive prompt.
- Cannot double-revive from one KO.
- Debug **Shift+F9** still force-revives.

---

## HUD Behavior

- Secondary dragon HP bar + KO label
- Revive prompt line under status (progress % while holding)

---

## Developer Test Controls

| Shortcut | Action |
|----------|--------|
| **F8** | Dragon HP −10 |
| **Shift+F8** | Dragon HP +10 |
| **F9** | Force knockout |
| **Shift+F9** | Force revive |
| **E** | Hold to revive (gameplay) |

---

## Deferred Systems

- Dedicated dragon hurt / KO audio assets
- Full aggro table / taunt skills
- Dragon HP on a future RPG menu
- Bond-gated KO resistance / revive speed
- Auto Instability recovery on revive

---

## Remaining Manual Validation

- [ ] Hold E revive works; danger radius blocks; damage/range cancel progress
- [ ] Sync −10 lasts ~60 s then restores
- [ ] Scout prefers player; proximity alone rarely peels to dragon
- [ ] Raider balanced; brief pass-by does not steal target
- [ ] Brute respects player interception; does not permanently tunnel dragon
- [ ] Stale/unreachable focus reassesses; KO dragon ignored; no frame jitter
- [ ] F8/F9 still work; rush commitment unchanged during active rush

---

## Implementation Files

| File | Role |
|------|------|
| `scripts/dragon/dragon_survivability.gd` | HP / KO / interact revive / Sync 60s |
| `scripts/player/player_dragon_revive.gd` | Hold-E interaction |
| `scripts/enemies/enemy.gd` | Soft target + pressure tuning |
| `scripts/dragon/dragon_strike_behavior.gd` | Notify peel threat on hit |
| `scripts/ui/player_hud.gd` + `PlayerHud.tscn` | Prompt + HP chip |
| `scenes/player/Player.tscn` | DragonRevive node |
| `project.godot` | `interact` (E) |

---

## Final Status

**REFINED** after playtest. Interact revival + Sync duration + targeting pressure implemented. Further live validation still recommended for feel.
