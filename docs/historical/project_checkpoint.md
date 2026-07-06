# Dragon Rider RPG — Project Checkpoint (Legacy)

> **Use [`project_checkpoint_milestone9A.md`](../checkpoints/project_checkpoint_milestone9A.md)** for current prototype status including live relationship stat application.  
> [`project_checkpoint_milestone5.md`](./project_checkpoint_milestone5.md) remains useful for earlier bond-tier and control details. This file describes an earlier Milestone 3-era snapshot and is kept for historical reference.  
> **Documentation:** Level 5 historical — see [`DOCUMENTATION_HIERARCHY.md`](../DOCUMENTATION_HIERARCHY.md).

**Engine:** Godot 4.6 · **Language:** GDScript  
**Main scene:** `res://scenes/world/TestWorld.tscn`

---

## Active Bond Model (current)

The prototype now uses a **3-stat gameplay model**:

| Stat | Role |
|------|------|
| **Bond Strength** | Relationship depth — protection behavior |
| **Sync** | Coordination — assist frequency |
| **Instability** | Strain — assist hesitation and cancellation |

`trust_state` remains on `BondProfile` for compatibility but is **deprecated** and not used in gameplay.

See `project_checkpoint_milestone5.md` for controls, file structure, and implemented hooks.

---

## Historical Snapshot (Milestone 3 era)

The sections below describe an older state before bond scaffold, protection/assist split, and instability reactions.

### Player (historical)
- Top-down movement, camera follow, health, melee attack

### Dragon (historical)
- Follow, wait/recall (Q), alert, assisting lunge
- No bond system, no protection vs assist split

### Not implemented at that time
- Bond system gameplay hooks
- Player dodge, race selection, save/load

---

## Design Reference

- Core loop: **Player intent → Bond → Dragon AI → Action → Bond update**
- Canonical persisted fields: `bond_strength`, `sync`, `instability`, `trust_state` (deprecated), `communication_stage`, `resonance_style`
- Read `./project_checkpoint_milestone5.md` before generating code
