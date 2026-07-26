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

## Enemy Targeting Model (refined)

Conservative extension of existing player-centric AI (`enemy.gd`):

1. **Detection / lose aggro** still keyed off the **player**.
2. Soft `_combat_target` = player **or** dragon.
3. Retarget every **~0.35 s** with hysteresis **1.18**.
4. Base weights: player **1.05**, dragon **0.9** (was 1.0 / 0.55).
5. Score multipliers:
   - Assist/protect participation ×**2.0**
   - Dragon within **80** units ×**1.65**
   - Dragon clearly closer than player ×**1.35**
   - Dragon blocking line to player ×**1.4**
   - Recently damaged by dragon (3.5 s) ×**1.55**
   - Commitment sticky ×**1.15** on current focus
6. Archetype lean: Scout prefers player; Brute prefers closer/blocking dragon; Raider balanced.
7. Attack reach uses **dragon_body_radius 22** (was player 14) so lunges can connect.
8. Knocked-out dragon is **invalid**.

Player remains primary; dragon must draw meaningful hits in ordinary multi-enemy fights.

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
- [ ] Enemies land real hits on dragon in multi-enemy fights
- [ ] Soft peel without all enemies abandoning player; no target jitter
- [ ] KO still stops assist/protect; F8/F9 still work

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
