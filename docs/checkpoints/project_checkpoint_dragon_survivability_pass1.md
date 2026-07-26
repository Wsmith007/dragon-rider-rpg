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

## Enemy Targeting Model (pressure distribution retune)

### Arc of playtest corrections

1. **First pressure tune** over-targeted the dragon (hard distance, strong close/assist bonuses, Brute dragon bias). Combat felt like “last body past wins” / permanent dragon tank.
2. **Commit `721a571`** kept soft falloff, commitment, interception, and stale recovery — but **overcorrected** toward player-only focus. Live playtest: nearly every enemy ignored the dragon; combat felt worse than pre-`721a571` despite fixing tunnel vision.
3. **This retune** keeps the `721a571` architecture and restores middle-ground **score weights / bonuses / switch margins** so the dragon takes ordinary pressure again.

### Why dragon targeting became too rare (`721a571`)

Exports were `player_target_weight=1.25`, `dragon_target_weight=0.75`. Effective bases:

| Archetype | Player base | Dragon base | Ratio |
|-----------|-------------|-------------|-------|
| Scout | 1.25×1.45 = **1.81** | 0.75×0.45 = **0.34** | ~5.4∶1 |
| Raider | 1.25×1.15 = **1.44** | 0.75×0.85 = **0.64** | ~2.3∶1 |
| Brute | 1.25×1.05 = **1.31** | 0.75×1.05 = **0.79** | ~1.7∶1 |

Sticky ×1.08 + hysteresis **1.22** / committed **1.35** / commitment **0.55 s** then made peels nearly impossible even with assist/damage/block.

### Intended middle ground (not yet live-validated)

- **Scout** — usually player; uncommon dragon peels on damage, very close, blocking, or inaccessible player.
- **Raider** — mild player default; frequently peels to nearby / assisting / blocking dragon (primary splitter).
- **Brute** — often engages close / blocking / recently attacking dragon; player interception still redirects; not player-only and not permanent dragon tunnel.
- Multi-enemy: player stays threatened; at least one enemy commonly pressures dragon; no hard quotas.

### Current tuned model

Detection / lose aggro still keyed off the **player**. Soft `_combat_target` = player or dragon. Score: `base × (0.55 + 0.45 × soft_proximity)`.

| Factor | Value |
|--------|-------|
| Soft distance | `1 / (1 + d / 70)` |
| Exports | `player_target_weight=1.10` · `dragon_target_weight=0.95` |
| Base Scout | Player ×**1.20** → **1.32** · dragon ×**0.82** → **0.78** |
| Base Raider | Player ×**1.05** → **1.16** · dragon ×**1.05** → **1.00** |
| Base Brute | Player ×**1.00** → **1.10** · dragon ×**1.15** → **1.09** |
| Close dragon ≤**60** | Scout ×1.10 (×1.22 if ≤36) · Raider ×1.26 · Brute ×1.38 |
| Assist participation | Scout ×1.22 · Raider ×1.35 · Brute ×1.42 |
| Recent dragon damage | Scout ×**2.15** · Raider ×1.52 · Brute ×1.45 |
| Path blocking | Scout ×1.18 · Raider ×1.28 · Brute ×1.42 |
| Closer-than-player | Scout ×1.12 · Raider ×1.18 · Brute ×1.28 |
| Player interception | Scout ×1.32 · Raider ×1.42 · Brute ×1.70 |
| Player melee floor | ×1.14 within `attack_range×1.25` |
| Sticky | ×**1.06** on current target |
| Switch | Retarget **0.40 s**, hysteresis **1.18**, committed margin **1.26**, min commitment **0.45 s** |
| Stale recovery | OOR **2.2 s** / no-progress **1.8 s** (unchanged) |
| Active rush / KO | Rush skips retarget; KO dragon invalid (unchanged) |

**Feel not re-validated** until developer retests after this commit.

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

### Survivability / revive (prior)

- [ ] Hold E revive works; danger radius blocks; damage/range cancel progress
- [ ] Sync −10 lasts ~60 s then restores
- [ ] F8/F9 still work

### Pressure distribution retest (required after this retune)

- [ ] Scout usually pressures player; can peel on dragon damage / very close / block
- [ ] Raider often splits; brief pass-by alone does not decide target
- [ ] Brute engages close/blocking dragon; player stepping between redirects Brute
- [ ] Scout+Raider: Scout on player, Raider may hit dragon; dragon takes real hits
- [ ] Two Raiders: pressure often splits (both on one target possible, not every fight)
- [ ] Scout+Brute / full trio: player threatened; ≥1 enemy commonly on dragon; dragon can lose HP without debug
- [ ] Stale/unreachable focus reassesses; KO dragon ignored; no frame jitter
- [ ] Rush commitment unchanged during active rush

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

**REFINED** — interact revival + Sync 60s + soft targeting architecture (`721a571`) + pressure-distribution score retune. Live feel **not claimed validated** until developer retests the checklist above.
