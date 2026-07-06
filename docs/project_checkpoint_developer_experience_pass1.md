# Dragon Rider RPG — Developer Experience Pass 1 Checkpoint

**Engine:** Godot 4.6 · **Language:** GDScript  
**Playtest:** `TestWorld.tscn` · `VerticalSlice_Level_P1.tscn` (F6)  
**Prior work:** [`project_checkpoint_ui_cleanup_pass1.md`](project_checkpoint_ui_cleanup_pass1.md)  
**Design constitution:** [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md)

**Status:** **IMPLEMENTED (viewport layout fix)** — shell + sidebar; playtest validation pending  
**Scope:** Application shell, viewport fill, developer workspace — **no gameplay changes**  
**Date:** 2026-05-29

---

## Goals

- Game viewport **fills the application window** when F10 is off  
- Developer sidebar is a **sibling layout region**, not margin space or overlay  
- No large gray margins around gameplay  
- Debug + help remain in the right sidebar when F10 is on  

---

## What was constraining the viewport (root cause)

Three layout bugs combined to produce a small centered game view with gray surround:

| Constraint | Effect |
|------------|--------|
| **`DeveloperSidebar.custom_minimum_size.x = 420` in scene** | Sidebar always reserved **420 px** even when F10 was off and sidebar was `visible = false` |
| **`HSplitContainer.split_offset` vs minimum size** | Split could not collapse sidebar to zero width; empty 420 px strip appeared beside the game |
| **Shell camera zoom (`max(zoom_x, zoom_y)`)** | Artificial zoom compensation letterboxed world content inside the SubViewport when aspect ratios diverged |
| **Fixed `SubViewport.size = 1920×1080` in scene** | Initial size before layout pass; only harmful if sync failed or container stayed small |

The game did not resize when F10 toggled because the sidebar width was **already consumed** by `custom_minimum_size` — F10 only revealed UI inside pre-allocated empty margin.

---

## How the viewport now expands

### Shell structure

```
TestWorld (Control — playtest_shell.gd)
└── ShellRow (HBoxContainer, full window)
    ├── GameRegion (Control, SIZE_EXPAND_FILL)
    │   ├── GameBackdrop (ColorRect, anchors full)
    │   └── GameplayViewportContainer (SubViewportContainer, anchors full, stretch=true)
    │       └── GameplayViewport (size synced every layout pass)
    └── DeveloperSidebar (VBox, width 0 or 420 via code only)
        ├── DebugPanel → BondDebugUI
        └── HelpPanel → BondTestHelpUI
```

### Resize pipeline

1. `GameRegion` expands to all `HBox` space not used by the sidebar  
2. `GameplayViewportContainer` anchors fill `GameRegion` edge-to-edge  
3. `_sync_viewport_size()` sets `SubViewport.size` = container pixel size (1:1, `stretch=true`)  
4. Sync runs on: ready (deferred), `NOTIFICATION_RESIZED`, shell/game/viewport `resized` signals  

### Camera

**No shell camera zoom.** `playtest_shell.gd` does not modify `Camera2D.zoom`. Camera behavior remains in `camera_follow.gd` at default **1.0**. A larger viewport shows more world at the same scale — gameplay entities render larger on screen because they use more pixels.

---

## F10 sidebar resizing

| F10 | `DeveloperSidebar.custom_minimum_size.x` | `GameRegion` width |
|-----|------------------------------------------|-------------------|
| **OFF** | `0` (sidebar hidden, **zero layout width**) | **100%** of window |
| **ON** | `420` (sidebar visible) | **window − 420 px** (~83% at 2560) |

Transition: ~0.22 s tween on sidebar minimum width + live viewport sync.

**Removed:** `HSplitContainer`, `split_offset`, scene-file sidebar minimum width.

---

## Window / project settings

| Setting | Value |
|---------|--------|
| Default window | 2560×1440 |
| Stretch mode | `canvas_items` |
| Stretch aspect | `expand` |

Shell root `Control` anchors full rect. No hardcoded 1200×900 or 1600×900 viewport splits remain.

---

## Developer sidebar (unchanged intent)

- **420 px** fixed width when open  
- Debug top (~55%), Help bottom (~45%), both scrollable  
- Light help panel, dark debug panel  
- No overlap with game — sibling `HBox` regions  

---

## Remaining limitations

- Sidebar width not yet user-draggable (Pass 2: `HSplitContainer` with correct zero-min when collapsed, or saved width pref)  
- `canvas_items` stretch on very non-16:9 monitors may scale shell UI — game still fills `GameRegion` within that  
- No player-build flag to hide F10 yet  

---

## Implementation files

| File | Role |
|------|------|
| `scripts/world/playtest_shell.gd` | HBox shell, viewport sync, F10 sidebar width |
| `scenes/world/TestWorld.tscn` | Layout scene |
| `scenes/world/VerticalSlice_Level_P1.tscn` | Layout scene |

---

## Playtest checklist

1. **F10 off** — game fills entire window, no gray border, no 420 px dead strip  
2. **F10 on** — game shrinks left by exactly 420 px; debug/help in right column  
3. Resize window — viewport tracks game region continuously  
4. HUD / combat floaters still correct inside SubViewport  
5. Help + debug scroll when content overflows  

---

## Related documents

| Document | Relationship |
|----------|--------------|
| [`project_checkpoint_ui_cleanup_pass1.md`](project_checkpoint_ui_cleanup_pass1.md) | Historical overlay model |
| [`vertical_slice_design_v1.md`](vertical_slice_design_v1.md) | Roadmap |
