# ACS Framework — Complete Patch Notes

See [Official ACS 2.0.0 Patch Note](Official%20ACS%202.0.0%20Patch%20Note.md) for official patch note

---

## Version 2.0.0
### Core
- Migrated the entire system to a new **modular framework architecture**.
- Introduced a **fully integrated Grenade & Melee System**.
- Implemented **Custom Viewmodel Arms** for enhanced first-person weapon handling.
- Reworked **Medic System**, improving healing logic, synchronization, and exploit protection.
- Added **ACS Combat Logs** for structured server-side event tracking.
- Replaced multiple `BoolValue` instances with Attributes for improved replication, performance, and clarity.
- Renamed and standardized variable naming:
  - Translated legacy non-English variable names to **standard English conventions**.
  - Renamed `"Saude"` folder → `ACS_Client`.
- Reworked animation handling with a **new animation chaining system**.

### Gameplay Systems
- Implemented `Spring-Based Recoil System` for smoother recoil transitions.
- Enhanced **damage system** and **near-death visual effects**.
- Improved **weapon jamming behavior**:
  - Jam clearing now requires **reload key**, replacing the previous `"F"` input.
- Added **Blacklist & Account Age** Restrictions for exploit prevention.

### Security & Anti-Exploit
- Introduced **multiple new server-side** validation layers.
- Migrated several sensitive client-side functions to **server execution**.
- Added **automatic exploit detection** and **banning mechanisms**.

### Feature removal (By design)
The following systems were **intentionally removed** to improve performance, realism, and maintainability:

- Removed **Stamina System**
- Removed **Thirst** / **Hunger System**
- Removed **Camera Recoil Recovery**
- Removed **Rappel System**
- Removed **M203 Launcher System**

These removals were part of a **design simplification pass** to improve gameplay flow, reduce complexity, and minimize exploit surfaces.

---

## Version 1.7.7 / A - Security & Stability Update

### Fixes & Security
- Patched **two common exploit vectors**.
- Fixed **fall damage logic**.
- Fixed **drowning mechanics**.

---

## Version 1.7.6 - Interface & Mobility Update

### New Features
- Reintroduced **Rappel System**.
- Implemented **new HUD interface**.

---

## Version 1.7.5 - Tactical & AI Expansion

### Gameplay Additions
- Added **Rappel System**.
- Introduced **new suppression visual effects**.
- Suppressors now **remain attached** when unequipped.
- Added **AI Combat System**, featuring:
  - Client-side visual effects
  - Dynamic aiming behavior
  - Partial ACS module usage for performance
  - Enhanced pathfinding algorithms

### Technical Improvements
- Framework-level optimizations.
- Fixed **bullet whizzing FX persisting after destruction**.
- Improved **laser** and **IR laser cycling logic**.
- Added new Boolean:
  - `Suppressor` → `ACS_Modulo > Variaveis`

---

## Version 1.7 - Core Combat & Visual Upgrade

### Server-Side Visual Replication**
- Server-side Laser Dot
- Server-side Flashlight
- Server-side Muzzle Flash

### Weapon & Combat Enhancements
- Improved hitscan accuracy.
- Fixed shell-inserting reload behavior.
- Added hit confirmation sound (hitmarker).
- Improved camera recoil system.
- Fixed viewmodel weapon alignment offset.
- Implemented bipod system.
- Enhanced particle effects.

### Tactical Systems
- Implemented **Breaching System**:
  - Doors
  - Walls
  - Windows
- Added **IR Laser System**:
  - Only visible when **NVG is active**
  - Requires **Realistic Laser mode enabled**
- Implemented **laser mode** cycling:
  - Regular Laser ↔ IR Laser

### Controls & Input Changes
- Changed **Mag Check Keybind** → **M**
- Changed **Aimpart Cycle Keybind** → **T**
- Prevented **weapon equip** while driving vehicles

### Launcher System
- Reworked **M203 launcher mechanics**
- Launcher ammo temporarily **client-side only**