# MACS R15 — Patch Notes

This document tracks all feature additions, improvements, fixes.

## Versioning

- **MAJOR** — Architectural changes / breaking changes
- **MINOR** — Feature additions and gameplay improvements
- **PATCH** — Bug fixes and tuning

---

### v0.2.0 - Architectural Refactor & AI Integration

This release mainly focused on Major architectural refactor, and
bringing AI system from ACS 1.7.5 with centralized modulescript, plus some minor features added.

**Note**: Major internal gun system refactor:
- Reduced `ACS_Framework.lua` logic from 3k+ lines → ~700 lines
- Centralized runtime state management
- Removed duplicated state references
- Decoupled controllers from UI and FX layers
- Significant network payload reduction
- Introduced object pooling for performance stability

#### Added
 - AI System (based on ACS 1.7.5), refactored so all AI entities rely on a single centralized ModuleScript for full runtime control, instead of multiple distributed server-scripts in ACS 1.7.5. (not production ready, needs more improvement)
 - Weapon/Gun Collision System - Tarkov-style viewmodel collision detection with automatic gun size calculation on equip
 - RayIgnore Module - Utility module for dynamic raycast ignore list management
 - VisualFX (Weapon Specific) Shooting Blur, ShootingBloom.
 - InputSystem Module - Core input dispatcher with gamepad support, action binding and listener management for unified input handling
 - Crosshair Module - Crosshair controller managing dynamic weapon reticle positioning, color changes, and aiming states
 - ObjectPool Module - Configurable instance pooling system with automatic reset
 - BulletEffects Module - Visual effects module for bullet tracers and muzzle flares with dynamic camera-based scaling
 - WeaponRegistry Module - Centralized equipped weapon registry (WeaponInHand, WeaponTool, WeaponData, AnimData access)
 - AttachmentManager Module - Centralized weapon attachment system for managing attachment instances, modifiers, and state
 - AttachmentController Module - Attachment controller for toggling weapon attachments (lasers, flashlights) with visual feedback and network synchronization
 - InputBindingController Module - Input binding manager for movement and weapon controls with dynamic action registration/unregistration
 - PlayerStateManager Module - Centralized character state manager for movement, stances, leaning, and weapon states plus etc... with modular reset functionality
 - WeaponState Module - Runtime weapon state manager (aiming, firing, reload, ammo, stance, sensitivity, etc...)
 - ViewModelManager Module - Viewmodel creation, arm management, dynamic welding
 - PostureController Module - Stance transitions, movement speed adjustments, HUD sync
 - WeaponAnimator Module - Viewmodel animation controller (safe execution, state tracking)
 - HUDController Module - HUD display controller for weapon stats, attachments, and combat indicators with real-time state synchronization
 - RecoilController Module - Spring-based camera and weapon recoil system with attachment modifiers
 - CameraController Module - View handling, leaning mechanics, HUD synchronization
 - CrosshairController Module - Crosshair controller managing dynamic weapon reticle positioning, color changes, and aiming states
 - WeaponController Module - Core weapon logic equip, fire, reload, attachments, and all weapon-related gameplay mechanics
 - BallisticsManager Module - Projectile spawning, hit detection, damage calculation, suppression handling (not true physics ballistics yet)

#### Improvement
 - Renamed some function, variable, parameter to not be ambiguous and vague (assisted by AI tooling - cause im too lazy) also ofc not all of it. Check out [Renamed documentation](Renamed.md). Changes from previous version didn't get documented.
 - Reorganized:
   - FX -> VisualFX, SoundFX
   - Attachments -> Attachments/Models & Attachments/Modules
 - Character leaning now supports automatic recovery.
 - Weapon aiming now supports automatic recovery.
 - Crosshair and center dot turn red when hovering over a Humanoid.
 - Ignore_Model is no longer a persistently.
 - Frequently used raycasts are now pooled for performance.
 - Hitmarker module now pools attachments and sound instances.
 - Network Optimization
   - HitEffect
     - Removed full WeaponData table from payload. It was being unused in ACS 2.0 based version.
     - Reduced from ~2KB -> ~55 bytes
   - ServerBullet
     - Removed full WeaponData table.
     - Resolved via WeaponRegistry
     - Reduced from ~3 KB to ~608 bytes.

#### Fixed
 - Prevented Holster logic WeaponTool.Name from iterating when the player is dead.
 - Integration of InputSystem Module (Movement, Weapon) Actions.

### v0.1.0 - Initial Framework Base
 - ACS 2.0.0 (R15) baseline integration.
 - Casing 3d Ejection Shell.
 - Holster System.
 - InputSystem Module — Unified action and axis input abstraction built on ContextActionService for modular binding, listener management, and clean runtime unbinding.
 - Weapon supports per-mode sensitivity tuning.
