# Dragon Rider RPG — Vertical Slice UI Cleanup Pass 1 Checkpoint

> **⚠ Partially superseded.** HUD layout, PlayerHud, and area announce remain valid. **Window size, shell layout, and Developer Mode behavior** were superseded by [`project_checkpoint_developer_experience_pass1.md`](./project_checkpoint_developer_experience_pass1.md) (2560×1440, F10 docked 420px sidebar via `playtest_shell.gd`). This document is preserved as the UI Cleanup Pass 1 record.

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn` (F6)  
**Prior polish:** [`project_checkpoint_vertical_slice_polish_1A.md`](./project_checkpoint_vertical_slice_polish_1A.md)  
**Design constitution:** [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md)

**Status:** **IMPLEMENTED** — presentation-only pass; playtest validation pending  
**Scope:** HUD layout, Developer Mode, window size, area announce, dragon state visuals  
**Not in scope:** gameplay, AI, combat math, relationship calculations, new HUD features

**Date:** 2026-05-29

---

## Goals

Separate **player UI** from **developer UI**. Reduce clutter. Improve readability at default resolution without changing gameplay scale.

| Principle | Detail |
|-----------|--------|
| Permanent HUD | Communicates gameplay (HP, dragon status, transient feedback) |
| Developer panels | Communicate systems — hidden until F10 |
| No overlap | Top-left stack no longer fights zone label |
| Dragon feedback | HUD + subtle ring — not constant speech bubbles |

---

## HUD Cleanup Philosophy

The top-left is a single **PlayerHud** panel:

1. **HP bar + numeric readout**
2. **Dragon status** (`Dragon: Following`, etc.)

No separate floating chips. No permanent zone label in the corner.

Transient player feedback remains in **PlayerFeedbackUI** (center/top): encounter summary, relationship toasts, area announce, combat floaters.

---

## Developer Mode Philosophy

**F10** toggles unified **Developer Mode** — not just the bond debug panel.

When enabled:

- **Debug panel** slides in from the **right** (400 px, semi-transparent)
- **Help panel** slides in from the **bottom-left** (controls + live debug readouts)

When disabled:

- Both panels slide off-screen
- Gameplay uses the **full viewport**

The game world stays visible; overlays do not permanently consume layout width (old 1200+400 split removed).

---

## Permanent vs Temporary UI

| Element | Visibility | Location |
|---------|------------|----------|
| **PlayerHud** (HP + dragon) | Always | Top-left |
| **Off-screen enemy arrows** | Always (when enemies off-screen) | Screen edges |
| **Area announce** | ~3.2 s on zone enter | Top-center |
| **Encounter summary** | ~2.6 s after resolve | Center |
| **Relationship toast** | ~1.8 s on stat apply | Upper-center |
| **Combat floaters** | ~0.85 s on hit | At hit position |
| **Help panel** | Developer Mode only | Bottom-left overlay |
| **Debug panel (BondDebugUI)** | Developer Mode only | Right overlay |
| **F11 combat ranges** | Toggle only (F11) | In-world debug |
| **BondTestHelpUI live stats** | Developer Mode only | Inside help panel |

---

## Current Area Presentation

**Before:** Permanent `SliceZoneLabel` at top-left overlapping HP.

**After:** **Transient area announce** via `PlayerFeedbackUI.announce_area()`:

- Large centered title at top of screen
- Fade in → hold ~3.2 s → fade out
- Triggered on zone enter (slice level) and on slice restart (`The Clearing`)

No permanent area label in the HUD stack.

---

## Window / Layout Changes

| Setting | Before | After |
|---------|--------|-------|
| Main window | 1600×900 | **1920×1080** |
| Gameplay SubViewport | 1200×900 (split layout) | **1920×1080** (full shell) |
| Debug panel | Docked 400 px column | **Overlay** (F10) |
| Stretch | (default) | **canvas_items**, aspect **expand** |

Gameplay world scale unchanged — larger window improves readability and reduces HUD crowding.

---

## Dragon State Presentation

| Channel | Change |
|---------|--------|
| **Speech bubble** | **Disabled** (`display_enabled = false`) — routine state text removed |
| **PlayerHud** | Retains `Dragon: Following / Waiting / …` |
| **Body tint** | Unchanged (existing `dragon.gd` modulate by state) |
| **StatusVisual** | New subtle pulsing ring for Waiting, Protecting, Assisting, Hesitating |

No constant floating text above the dragon during normal follow/alert cycles.

---

## Implementation Files

| File | Role |
|------|------|
| `scenes/ui/PlayerHud.tscn` | Unified top-left HUD |
| `scripts/ui/player_hud.gd` | HP + dragon status bind |
| `scripts/ui/developer_mode_controller.gd` | F10 overlay slide |
| `scenes/world/TestWorld.tscn` | Full viewport + DeveloperModeOverlay |
| `scenes/world/VerticalSlice_Level_P1.tscn` | Same shell pattern |
| `scripts/ui/player_feedback_ui.gd` | Area announce; dragon chip removed |
| `scripts/dragon/dragon_status_visual.gd` | Subtle state ring |
| `scripts/dragon/dragon_communication_bubble.gd` | `display_enabled` flag |
| `scripts/world/vertical_slice_level_p1.gd` | Zone → announce_area |
| `project.godot` | 1920×1080 + stretch |

---

## Remaining UI Polish Opportunities

### Pass 1B+ (recommended next)

- Dark-theme **Help panel** content styling to match developer overlay chrome
- Hide **F11** and spawn keys behind Developer Mode flag for player builds
- Qualitative Sync/Instability strip (no numbers) if partnership state needs always-visible hint
- Encounter summary queue when fights chain quickly
- Safe-area padding for ultrawide / scaled windows
- Dragon personality lines (Pass 1B) — intentional dialogue, not state spam

### Nice to have

- Slide animation easing tuned per panel weight
- Minimap / zone map (post-slice)
- Player build flag to disable combat floaters density in packs

---

## Playtest Checklist

1. Top-left: HP and dragon status readable — no overlap  
2. Enter new zone — area name appears center-top, fades away  
3. Default window 1920×1080 — HUD and combat readable  
4. F10 — both help and debug slide in; F10 again hides both  
5. Gameplay visible while Developer Mode open  
6. No constant dragon speech bubbles during follow  
7. Protecting/Assisting — subtle ring + HUD label sufficient  
8. Player can play without ever opening F10 (Polish 1A feedback still works)

---

## Related Documents

| Document | Relationship |
|----------|--------------|
| [`project_checkpoint_vertical_slice_polish_1A.md`](./project_checkpoint_vertical_slice_polish_1A.md) | Player feedback layer — cross-referenced |
| [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md) | Roadmap updated |
| [`project_checkpoint_combat_depth_1B.md`](./project_checkpoint_combat_depth_1B.md) | Target focus visuals unchanged mechanically |
