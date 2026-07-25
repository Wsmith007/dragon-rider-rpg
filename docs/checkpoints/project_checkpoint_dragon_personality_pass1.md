# Dragon Rider RPG — Dragon Personality Pass 1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** LaunchMenu · `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn`  
**Design constitution:** [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md)  
**Dragon behavior reference:** [`dragon_ai.md`](../design/dragon_ai.md)  
**Player feedback layer:** [`project_checkpoint_vertical_slice_polish_1A.md`](./project_checkpoint_vertical_slice_polish_1A.md)  
**Documentation:** [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md)  
**Status:** **COMPLETE — Behavioral Communication**  
**Date:** 2026-07-24

---

## Design Decision

Ambient thought-bubble dialogue was playtested and **rejected**.

Lines such as `"Danger."`, `"Clear."`, `"Together."`, `"With you."`, and `"Holding."` added visual clutter during combat and duplicated information the dragon already communicates through movement, facing, proximity, and action.

**Accepted Pass 1 direction:**

- The dragon communicates **passively through body language and behavior**.
- The player learns to read stance, facing, proximity, hesitation, and actions.
- Automatic in-world text / thought bubbles do **not** appear during normal combat or exploration.
- Spoken or text dialogue should occur only through **intentional player-initiated interaction** (future milestone).

**Not this pass:** dialogue trees, interaction prompts, contextual conversation UI, RPG menus, inventory, skill trees, or save/load.

---

## Scope (revised)

**In scope / delivered:**

- Remove ambient event-driven bubble output from normal gameplay
- Keep dragon AI behaviors intact (notice threat, turn, close up, protect, assist, wait, recall, hesitate)
- Keep PlayerHud dragon status chip and StatusVisual (non-bubble feedback)
- Document future player-initiated Dragon Dialogue and high-level RPG menu direction
- Keep bubble presentation node disabled for possible future intentional dialogue

**Not in scope:**

- Building the conversation system
- Changing combat, AI decisions, bond/sync/instability math, audio, or animation
- Full pause / inventory / character menus

---

## What Was Tested and Rejected

Event-driven ambient cues hooked to alert, clear, protect, assist, wait, recall, encounter clear, hesitation, and assist-cancel, with anti-spam cooldowns and bond-tier phrasing.

**Why rejected:** clutter + redundancy with behavioral communication.

---

## Implementation Summary

| Component | Result |
|-----------|--------|
| `dragon_communication_behavior.gd` | Ambient signal hooks removed; no automatic `message_changed` publishes |
| `dragon_communication_catalog.gd` | Ambient combat line table removed; `get_dragon_message` returns `""` |
| `dragon_communication_bubble.gd` | `display_enabled` defaults **false**; will not bind when disabled |
| `Dragon.tscn` / `DragonCommunicationBubble.tscn` | Bubble instances disabled |
| Threat / strike / command / cooperation / follow / protection | **Unchanged** — behavioral language remains |

Developer UI gating (`gameplay/developer_tools_enabled` + DeveloperInput) remains from earlier export work and is separate from this communication revision.

---

## Behavioral Cues Preserved

These continue to carry personality without text bubbles:

- Noticing nearby enemies (threat alert)
- Turning / stance toward sensed threats
- Closing proximity when danger is present
- Protect, assist, wait, recall, follow
- Hesitation before uncertain cooperative assists
- StatusVisual / HUD chip state labels (not ambient dialogue)

---

## Future Dragon Interaction System (deferred)

The player will eventually be able to:

1. Face or approach the dragon.
2. Press an interaction button.
3. Enter an intentional dialogue interaction.
4. Choose from context-sensitive dialogue options.
5. Receive dialogue influenced by factors such as world/encounter state, progression, Bond, Sync, learned abilities, story state, and recent events.

Dialogue should feel deliberate and meaningful — never automatic combat chatter.

---

## Future RPG Menu Direction (deferred, non-binding)

A future multi-page menu may cover areas such as:

- Inventory and equipment
- Player statistics and skills
- Dragon statistics and skills
- Learned abilities / skill trees
- Bond and Sync information
- Save and load
- Settings
- Map

Architecture is not locked by this checkpoint.

---

## Files Modified

| File | Change |
|------|--------|
| `scripts/dragon/dragon_communication_behavior.gd` | Ambient publishing removed |
| `scripts/dragon/dragon_communication_catalog.gd` | Ambient lines retired |
| `scripts/dragon/dragon_communication_bubble.gd` | Disabled by default |
| `scenes/dragon/Dragon.tscn` | `display_enabled = false` |
| `scenes/dragon/DragonCommunicationBubble.tscn` | `display_enabled = false` |
| This checkpoint | Records rejection + behavioral Pass 1 |

---

## Playtest Checklist

- [x] No automatic thought bubbles during normal play
- [x] No automatic text on enemy sense / clear / assist / protect / wait / recall
- [x] Dragon still turns toward threats (AI unchanged)
- [x] Protect / assist / wait / recall / follow / hesitation still function (AI unchanged)
- [x] No ambient catalog lines remain for combat cues
- [ ] Live smoke confirmation in editor after pull (developer)

---

## Final Pass 1 Status

**COMPLETE — Behavioral Communication**

Ambient text was tested and rejected. Behavioral body language is the accepted Pass 1 personality language. Player-initiated dialogue and RPG menus are explicitly deferred.

---

## Related Documentation

| Document | Relationship |
|----------|----------------|
| [`dragon_ai.md`](../design/dragon_ai.md) | Autonomy and emotional design |
| [`project_checkpoint_vertical_slice_polish_1A.md`](./project_checkpoint_vertical_slice_polish_1A.md) | HUD chip — complementary, not ambient bubbles |
| [`PROJECT_STATE.md`](../PROJECT_STATE.md) | Systems table updated for behavioral Pass 1 |
