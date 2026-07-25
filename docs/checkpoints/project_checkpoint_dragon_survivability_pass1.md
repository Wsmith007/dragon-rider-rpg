# Dragon Rider RPG — Dragon Survivability Pass 1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** LaunchMenu · `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn`  
**Design constitution:** [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md)  
**Related:** [`project_checkpoint_combat_stakes_pass1.md`](./project_checkpoint_combat_stakes_pass1.md) · [`project_checkpoint_milestone9A.md`](./project_checkpoint_milestone9A.md)  
**Documentation:** [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md)  
**Status:** **IMPLEMENTED — source validated; live playtest required**  
**Date:** 2026-07-25

---

## Goals

The dragon should feel like a partner with stakes: take damage, draw some attention, knock out without permanent death, revive after danger clears, and apply Sync/Instability consequences — without becoming a fragile escort quest.

Bond strength is **not** changed by knockout.

---

## Dragon HP Baseline

| Value | Default | Notes |
|-------|--------:|-------|
| Max HP | **50** | Raised from foundation 40 |
| Hits vs Scout (6) | ~8 | Durable skirmish pressure |
| Hits vs Raider (10) | 5 | Clear chip |
| Hits vs Brute (18) | ~3 | Heavy threat |

Configurable on `DragonSurvivability` (`max_health`, invuln, grace, revive ratio).

- Brief hit invulnerability: **0.15 s**
- Post-revive grace: **2.0 s**
- HP clamped to `[0, max]`; never permanently dies

---

## Enemy Targeting Model

Conservative extension of existing player-centric AI (`enemy.gd`):

1. **Detection / lose aggro** still keyed off the **player**.
2. Soft `_combat_target` = player **or** dragon.
3. Retarget at most every **~0.45 s** with **hysteresis** (`target_switch_hysteresis = 1.25`).
4. Scores: `player_target_weight` (1.0) vs `dragon_target_weight` (0.55); dragon score ×1.75 when ASSISTING/PROTECTING.
5. Chase / engage / attack aim at the current focus.
6. Attack resolve: player `Health.take_damage` **or** `DragonSurvivability.receive_damage`.
7. Knocked-out dragon is **invalid**; invalid focus falls back to player.
8. Player combat safe zone still idles enemies (no farming dragon in Quiet Grove).

Not every enemy peels to the dragon — player bias remains primary.

---

## Knockout Rules

At zero HP (once):

- Enter `KNOCKED_OUT`
- Cancel strike / cooperative assist
- Ignore wait/recall commands that need activity
- Stay in scene with muted KO modulate
- Not a valid enemy target
- No game over if the player lives
- Penalties applied **once** per KO (`_knockout_penalties_applied`)

---

## Instability Consequence

On KO: `BondSystem.apply_instability_delta(+25)` once.

Does **not** auto-clear on revival. Existing encounter/relationship recovery rules still apply elsewhere.

---

## Temporary Sync Consequence

No modifier stack exists. Pass 1 representation:

1. On KO: `BondSystem.apply_sync_delta(-10)` once.
2. Store `_sync_penalty_active_amount = 10` and `_sync_penalty_remaining = 12 s`.
3. When the timer expires (even if still KO or already revived): `apply_sync_delta(+10)` once to restore.
4. Scene reset / `reset_to_full()` restores any outstanding penalty before clearing state.

Bond strength is never touched.

---

## Revival Flow

Automatic (no interact UI / inventory):

1. While KO, if **immediate danger is clear** for `revive_delay_after_clear` (2.5 s):
   - Player in combat safe zone, **or**
   - No living enemies within `danger_clear_radius` (300) of the player (fallback: dragon)
2. Revive at **35%** max HP
3. Apply post-revive grace (2 s) so instant re-KO loops are harder
4. Resume follow / normal AI

`begin_rescue()` remains a no-op stub for a future interact rescue.

---

## HUD Behavior

`PlayerHud` adds a secondary dragon bar + label under player HP:

- Shows `Dragon N / M` while active
- Shows `KO` + status “Knocked Out” while KO
- Signal-driven (`health_changed`, `survivability_state_changed`)
- Visually secondary (thinner green bar)

---

## Developer Test Controls

| Shortcut | Action |
|----------|--------|
| **F8** | Dragon HP −10 |
| **Shift+F8** | Dragon HP +10 |
| **F9** | Force knockout |
| **Shift+F9** | Force revive |

Existing F1 / F5–F7 / F10–F12 / weapon / bond keys unchanged. Documented in `BondTestHelpUI`.

---

## Deferred Systems

- Player interact / hold-to-rescue revival
- Dedicated dragon hurt / KO audio assets
- Full aggro table / taunt skills
- Dragon HP on a future RPG menu
- Bond-gated KO resistance / revive speed
- Auto Instability recovery on revive

---

## Manual Validation Checklist

- [ ] Scout / Raider / Brute can damage the dragon; hits apply once
- [ ] Dragon HP never goes below 0 or above max
- [ ] Enemies sometimes peel to an assisting/protecting or closer dragon without all abandoning the player
- [ ] No frame-to-frame target jitter
- [ ] KO dragon ignored; enemies recover to player
- [ ] On KO: assist/protect/strike stop; Instability +25 once; Sync −10 once
- [ ] Sync restores +10 after ~12 s
- [ ] After danger clears ~2.5 s, dragon revives at ~35% with grace
- [ ] HUD updates; KO label clear
- [ ] F8 / Shift+F8 / F9 / Shift+F9 work; other developer keys unchanged
- [ ] Player combat, follow/wait/recall, critical-health feedback still work
- [ ] No thought bubbles; no debugger errors

---

## Implementation Files

| File | Role |
|------|------|
| `scripts/dragon/dragon_survivability.gd` | HP / KO / revival / bond penalties |
| `scripts/dragon/dragon.gd` | KO gate, flash, callbacks |
| `scripts/enemies/enemy.gd` | Soft combat target |
| `scripts/ui/player_hud.gd` + `PlayerHud.tscn` | Dragon HP chip |
| `scripts/ui/health_debug_controls.gd` | F8/F9 dragon testers |
| `scripts/core/developer_input_*.gd` | Shortcut wiring |
| `scripts/world/test_world.gd` / `vertical_slice_world_shell.gd` | Bind dragon debug |
| `scenes/ui/BondTestHelpUI.tscn` | Help text |

---

## Final Status

**IMPLEMENTED** for Pass 1. Live developer playtest still required before treating feel as validated.
