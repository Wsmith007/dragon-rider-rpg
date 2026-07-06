# Dragon Rider RPG — Developer Experience Pass 1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest shells:** `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn` (F6)  
**Prior work:** [`project_checkpoint_ui_cleanup_pass1.md`](./project_checkpoint_ui_cleanup_pass1.md) (overlay model — superseded for dev panels)  
**Design constitution:** [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md)  
**Documentation:** [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) · [`PROJECT_STATE.md`](../PROJECT_STATE.md)

**Status:** **IMPLEMENTED — stable enough for ongoing playtest**  
**Scope:** Application shell, viewport fill, docked developer workspace — **no gameplay, combat, AI, or relationship math changes**  
**Date:** 2026-05-29 (updated 2026-07-05)

---

## Summary

Developer Experience Pass 1 replaces the earlier **overlay slide-in** developer panels with a **docked right sidebar** that shares horizontal space with the game. **F10** toggles that sidebar. When it is off, the gameplay `SubViewport` fills the entire window. When it is on, the game shrinks left by exactly **420 px** and debug + help occupy the right column.

This pass is considered **stable enough for now** because:

- The viewport reliably fills the window with **zero reserved sidebar width** when F10 is off (the root cause of the old gray-margin bug is fixed).
- F10 open/close animates cleanly and keeps the `SubViewport` synced to the remaining game region.
- Debug and help panels render inside the sidebar without overlapping gameplay.
- Bond debug label binding was repaired after the `FillPanel` / `ContentPanel` scene restructure; null-assignment crashes are resolved.
- Shell logic is isolated in `playtest_shell.gd`; gameplay scenes remain children of the `SubViewport`.

---

## F10 Developer Mode — final behavior

| State | What happens |
|-------|----------------|
| **Startup (default)** | Developer Mode **off**. Sidebar `visible = false`, `custom_minimum_size.x = 0`. Game uses **100%** of window width. |
| **Press F10** | Toggles Developer Mode on/off via `_unhandled_input` in `playtest_shell.gd`. Echo/repeat ignored. Input consumed so F10 does not leak to gameplay. |
| **Turning ON** | Sidebar width tweens **0 → 420 px** over **0.22 s** (cubic ease-out). Debug + help panels become visible. Viewport sync runs during the tween. |
| **Turning OFF** | Sidebar width tweens **420 → 0 px**, then sidebar hidden. Game region expands back to full width. |
| **Signal** | `developer_mode_changed(enabled: bool)` emitted on toggle (available for future player-build gating). |

**Not part of F10:**

- In-world **F11** combat range debug (inside `SubViewport` gameplay scene).
- **Ctrl+Shift+R** full gameplay reload on `VerticalSlice_Level_P1` only (`vertical_slice_world_shell.gd`).
- Player HUD, combat floaters, and area announce — always driven inside the `SubViewport`, independent of F10.

**Removed from earlier iterations:**

- `developer_mode_controller.gd` overlay slide animations.
- `HSplitContainer` + permanent `split_offset` / scene-file sidebar minimum width.
- Shell-level camera zoom compensation (`max(zoom_x, zoom_y)` letterboxing).

---

## Right sidebar layout

### Shell structure

```
TestWorld / VerticalSlice_Level_P1 (Control — playtest_shell.gd)
└── ShellRow (HBoxContainer, anchors full window, separation 0)
    ├── GameRegion (Control, SIZE_EXPAND_FILL)
    │   ├── GameBackdrop (ColorRect, full rect — dark green surround if sync fails)
    │   └── GameplayViewportContainer (SubViewportContainer, anchors full, stretch=true)
    │       └── GameplayViewport (SubViewport — size synced at runtime)
    │           └── TestWorldGame / VerticalSliceLevelP1Game
    └── DeveloperSidebar (VBoxContainer, width 0 or 420 via code only)
        ├── DebugPanel (PanelContainer, stretch_ratio 1.15)
        │   └── BondDebugUI
        └── HelpPanel (PanelContainer, stretch_ratio 0.85)
            └── BondTestHelpUI
```

### Width and split

| Property | Value |
|----------|--------|
| Sidebar width when open | **420 px** (`DEVELOPER_SIDEBAR_WIDTH`) |
| Sidebar width when closed | **0 px** — not merely hidden; **no layout reservation** |
| Vertical split | Debug **~55%** top (`stretch_ratio 1.15`), Help **~45%** bottom (`stretch_ratio 0.85`) |
| Separation | `0` between game and sidebar; `0` between debug and help |
| Chrome | Debug panel: dark `StyleBoxFlat`. Help panel: light `StyleBoxFlat`. |
| Scrolling | Both panels use internal `ScrollContainer`; long content scrolls independently. |

The sidebar is a **sibling** of `GameRegion` in an `HBoxContainer`. It is **not** an overlay, margin hack, or permanently allocated column.

---

## Game viewport resizing behavior

### Design intent

The gameplay `SubViewport` should always match the pixel size of `GameplayViewportContainer` inside `GameRegion` — 1:1, no shell camera zoom, no fixed 1920×1080 letterbox inside a smaller region.

### Sync pipeline (`playtest_shell.gd`)

1. **On ready:** `_finish_ready()` applies collapsed sidebar, waits **two process frames** (layout settle), then calls `_sync_viewport_size()`.
2. **On resize:** `NOTIFICATION_RESIZED`, `get_viewport().size_changed`, and `resized` on `ShellRow`, `GameRegion`, and `GameplayViewportContainer` queue a deferred sync.
3. **During F10 tween:** `_sync_viewport_size()` is called in parallel with the width tween so the game region grows/shrinks live.
4. **Size source:** `_viewport_container.size` (floored). If still &lt; 2 px, falls back to `_game_region.size`. If still invalid, retries next frame via `_retry_viewport_sync_after_layout()`.
5. **Apply:** `GameplayViewport.size = Vector2i(container_w, container_h)` with minimum 1×1. `stretch = true` on the container.

### Scene defaults

- `GameplayViewport` scene default is **2×2** so a failed sync is obvious (tiny render) rather than silently showing a stale large buffer.
- `GameBackdrop` fills any gap with a dark color if the container is momentarily empty during layout.

### Camera

**The shell does not modify `Camera2D.zoom`.** A larger `SubViewport` shows more world pixels at the same world scale; entities appear larger on screen because they use more pixels. Camera follow behavior remains in `camera_follow.gd`.

### Debug logging

`DEBUG_VIEWPORT_LAYOUT := true` in `playtest_shell.gd` prints `VIEWPORT_LAYOUT | ShellRow=… GameRegion=… Container=… SubViewport=…` when sizes change. Set to `false` once layout is confirmed stable.

### Window / project settings

| Setting | Value |
|---------|--------|
| Default window | **2560×1440** |
| Stretch mode | `canvas_items` |
| Stretch aspect | `expand` |

Shell root `Control` anchors full rect.

---

## Help panel behavior (`BondTestHelpUI`)

**Location:** `ShellRow/DeveloperSidebar/HelpPanel/BondTestHelpUI`  
**Script:** `scripts/ui/bond_test_help_ui.gd`  
**Visible:** Only when F10 Developer Mode is on (parent visibility controlled by shell).

### Content

Static **control reference** sections (movement, stance, target focus, combat, dragon commands, weapons, slice reload keys) plus **live debug readouts** updated every frame:

| Live field | Source |
|------------|--------|
| Bond / Sync / Instability | `BondSystem` signals |
| Movement state, facing, stance, move speed | Player methods (`get_movement_state_label`, etc.) |
| Target focus active / focused target | `PlayerTargetFocus` |
| Weapon profile name + detail | `MeleeAttack` signals |

### Layout

- `Panel` → `Margin` → `Scroll` → `VBox` (full-rect anchors on root `Control`).
- Light panel styling; `mouse_filter` ignores input so clicks pass through to game only when sidebar is not obscuring (sidebar is outside `SubViewport`).

### Binding notes

- Player discovered via `get_tree().get_nodes_in_group("player")` in `_ready`.
- Works because shell `_ready` runs child gameplay wiring after the `SubViewport` game scene is present.
- Help panel does **not** receive dragon bind calls from the shell; it reads bond globals and player group directly.

### Unchanged in this pass

Help **content and styling** were not redesigned here — only **placement** moved from bottom-left overlay to docked sidebar bottom half.

---

## Debug panel behavior (`BondDebugUI`)

**Location:** `ShellRow/DeveloperSidebar/DebugPanel/BondDebugUI`  
**Script:** `scripts/ui/bond_debug_ui.gd`  
**Shell accessor:** `get_bond_debug_ui()` → `BondDebugUI` node.

### Content sections (scrollable, top → bottom in `VBox`)

1. **Relationship observation** — current bond/sync/instability, active encounter counters, last resolved encounter, applied/proposed deltas, session history, recent event log. Driven by `RelationshipSystem` signals.
2. **Dragon communication** — current dragon thought line (from `DragonCommunicationBehavior` when bound).
3. **Bond debug grid** — protection radius, alert range, threat distance, command pending/delay, dragon state, bond tier + planned resilience effects. Refreshed from `BondSystem`, dragon behaviors, and `_process` for fast-changing fields.

### Binding lifecycle

1. `_ready`: `_cache_ui_nodes()` resolves all labels under `FillPanel/Margin/Scroll/ContentPanel/ContentMargin/VBox` via `get_node_or_null`. If required labels missing → `push_error`, panel skips init.
2. `_initialize_ui()`: applies large-text theme overrides, connects bond + relationship signals, initial refresh.
3. `bind_to_dragon(dragon)`: called from `test_world.gd` / `vertical_slice_world_shell.gd` after gameplay wiring. Attaches protection/threat/command/communication behaviors; no-op if `_ui_ready` is false.

### Layout fix (Pass 1 repair)

Earlier blank debug panel was caused by:

- Inner content `PanelContainer` anchor setup collapsing the root `Control` to zero size inside `PanelContainer`.
- `@onready` paths breaking when `Margin` moved under new `FillPanel` wrapper.

**Current scene chain:**

```
BondDebugUI (Control)
└── FillPanel (PanelContainer, full rect)
    └── Margin → Scroll → ContentPanel → ContentMargin → VBox
        ├── Relationship (…)
        ├── Communication (…)
        ├── TitleLabel "Bond Debug"
        └── Grid (protection / dragon stats)
```

`FillPanel` uses transparent chrome; `ContentPanel` uses dark `StyleBoxFlat` for readable text (`font_color` overrides applied in code).

### Update frequency

| Data | Update trigger |
|------|----------------|
| Bond / relationship | Signals + initial refresh |
| Threat distance, command delay | `_process` while panel ready |
| Dragon state / thought | Dragon signals after `bind_to_dragon` |

All label writes go through `_set_label_text()` (null-safe).

---

## Known limitations

| Limitation | Notes |
|------------|--------|
| **Fixed 420 px sidebar** | Not user-resizable. Pass 2 could restore `HSplitContainer` with correct zero-min collapse, or persist width in settings. |
| **No player-build flag** | F10 always available in playtest shells. `developer_mode_changed` exists for future gating. |
| **`canvas_items` stretch** | On very non-16:9 monitors, shell UI scales with window; game still fills `GameRegion` within that. |
| **`DEBUG_VIEWPORT_LAYOUT` still on** | Console spam until manually disabled after validation. |
| **Help player bind timing** | Help uses player group lookup in `_ready`; assumes game scene is loaded in `SubViewport` before help `_ready`. Works in current shell order; fragile if scene load order changes. |
| **Debug bond row order** | `TitleLabel "Bond Debug"` appears **below** relationship/communication blocks in the `VBox` (scene order legacy). Readable but not ideal information hierarchy. |
| **In-viewport debug controls** | `HealthDebugControls`, `EnemySpawnDebug`, F11 ranges remain inside gameplay scene — not consolidated into sidebar. |
| **Vertical slice reload** | Ctrl+Shift+R only on `VerticalSlice_Level_P1`; `TestWorld` has no full reload shortcut. |

---

## Why this is stable enough for now

1. **Layout correctness** — The primary failure mode (420 px dead strip with F10 off) is eliminated by driving sidebar width purely through `custom_minimum_size` (0 vs 420) instead of scene defaults + split container.
2. **Viewport sync is defensive** — Deferred sync, two-frame ready wait, container-size fallback, and retry-on-next-frame handle Godot layout ordering without manual resolution tables.
3. **Developer UI is isolated** — Shell scripts (`playtest_shell.gd`, `test_world.gd`, `vertical_slice_world_shell.gd`) handle layout only. Gameplay HUD inside `SubViewport` is unaffected by F10.
4. **Debug panel is recoverable** — Explicit node caching + null-safe text updates prevent hard crashes if a label path regresses; errors surface in Output instead.
5. **Playtest validated behaviors** — Viewport fill, F10 toggle, sidebar content visibility, and encounter spawn deferral (separate fix in `vertical_slice_encounter.gd`) were exercised during integration without requiring further shell changes.
6. **Documented supersession** — Overlay-based developer mode from UI Cleanup Pass 1 is intentionally retired; no dual code paths remain.

Further polish (draggable split, player-build hide, debug log flag default-off, reorder debug sections) is **Pass 2** scope and does not block vertical-slice playtesting.

---

## Implementation files

| File | Role |
|------|------|
| `scripts/world/playtest_shell.gd` | HBox shell, F10 toggle, viewport sync, `get_bond_debug_ui()` |
| `scripts/world/test_world.gd` | `TestWorld` gameplay wiring + `bind_to_dragon` |
| `scripts/world/vertical_slice_world_shell.gd` | Slice shell + Ctrl+Shift+R reload |
| `scenes/world/TestWorld.tscn` | Shell scene (TestWorld) |
| `scenes/world/VerticalSlice_Level_P1.tscn` | Shell scene (vertical slice) |
| `scenes/ui/BondDebugUI.tscn` | Debug panel scene |
| `scripts/ui/bond_debug_ui.gd` | Debug readouts + relationship observation |
| `scenes/ui/BondTestHelpUI.tscn` | Help panel scene |
| `scripts/ui/bond_test_help_ui.gd` | Help content + live stats |
| `project.godot` | 2560×1440 window, `canvas_items` / `expand` stretch |

**Deleted / superseded:** `scripts/ui/developer_mode_controller.gd` (overlay approach).

---

## Playtest checklist

1. **F10 off** — game fills entire window; no gray border; no hidden 420 px strip.
2. **F10 on** — game shrinks left by exactly 420 px; debug (top) and help (bottom) visible and scrollable.
3. **F10 toggle during play** — tween completes; viewport tracks continuously; no stuck sizes.
4. **Resize window** — `SubViewport` tracks `GameRegion`; HUD/combat inside viewport remain correct.
5. **Debug panel** — bond, dragon state, relationship counters update during encounters.
6. **Help panel** — key reference visible; live movement/target/weapon stats update.
7. **Play without F10** — full-screen gameplay; player HUD and feedback unaffected.

---

## Related documents

| Document | Relationship |
|----------|--------------|
| [`project_checkpoint_ui_cleanup_pass1.md`](./project_checkpoint_ui_cleanup_pass1.md) | Historical overlay model — dev panels since moved to docked sidebar |
| [`project_checkpoint_milestone9A.md`](./project_checkpoint_milestone9A.md) | Relationship observation data shown in debug panel |
| [`vertical_slice_design_v1.md`](../design/vertical_slice_design_v1.md) | Roadmap — Developer Experience Pass 1 marked implemented |
| [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md) | Documentation authority |
| [`PROJECT_STATE.md`](../PROJECT_STATE.md) | Current milestone and entry point |
