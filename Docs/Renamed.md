# Documentation of Renamed functions, variables

## Renaming (functions/variables/misc)
##### Function
 - `WeaponModifications` -> `AttachmentModifications`
 - `SetLaser` -> `ToggleLaserAttachment`
 - `SetTorch` -> `ToggleFlashlight`
 - `SetMods` -> `ApplyAttachmentModifiers`
 - `ResetMods` -> `ResetWeaponModifiers`
 - `Setup` -> `EquipWeapon`
 - `UnSet` -> `UnequipWeapon`
 - `SetAimpart` -> `ToggleAimPoint`
 - `UpdateSensitivity` -> `ApplyMouseSensitivity`
 - `RunCheck` -> `UpdateWeaponStance`
 - `CastRay` -> `ProcessBulletTrace`
 - `CreateBullet` -> `SpawnProjectile`
 - `GunFx` -> `WeaponFX`
 - `ShellCheck`- > `EjectShellCasing`
 - `MeleeCast` -> `MeleeAttack`
 - `Recoil` -> `ApplyRecoilPattern`
 - `RenderCam` -> `ApplyCameraRecoil`
 - `RenderGunRecoil` -> `ApplyWeaponRecoil`
 - `TracerCalculation` -> `ShouldShowTracer`
 - `Grenade` -> `CookGrenade`
 - `GrenadeMode` -> `CycleThrowPower`
 - `TossGrenade` -> `ThrowGrenade`
 - `CheckMagFunction` -> `CheckAmmoCount`
 - `EquipAnim` -> `PlayEquipAnimation`
 - `IdleAnim` -> `PlayIdleAnimation`
 - `SprintAnim` -> `PlaySprintAnimation`
 - `ReloadAnim` -> `PlayReloadAnimation`
 - `TacticalReloadAnim` -> `PlayTacticalReloadAnimation`
 - `PumpAnim` -> `PlayPumpActionAnimation`
 - `MagCheckAnim` -> `PlayCheckAmmoAnimation`
 - `meleeAttack` -> `PlayMeleeAttackAnimation`
 - `GrenadeReady` -> `PlayGrenadeReadyAnimation`
 - `GrenadeThrow` -> `PlayGrenadeThrowAnimation`
 - `Stand` -> `SetStandingStance`
 - `Crouch` -> `SetCrouchingStance`
 - `Prone` -> `SetProneStance`
 - `Lean` -> `ApplyLeanOffset`

##### Variable
 - `SKP_01` -> `PlayerSessionId`
 - `Virar` -> `LeanDirection`
 - `L_150_` -> `CameraLeanController`
 - `L_225_arg1` -> `hit_part`
 - `L_226_` -> `has_humanoid`
 - `L_227_` -> `target_humanoid`
 - `L_214_forvar2` -> `part`
 - `L_370_` -> `can_equip`
 - `RecoilPower` -> `CurrentRecoilPower`
 - `Ignore_Model` -> `BASE_IGNORE`
 - `Visivel` -> `is_visible`
 - `balaspread` -> `bullet_spread`
 - `B_color` -> `bullet_color`
 - `VitimaHuman` -> `TargetHumanoid`
 - `Atirar` -> `Shoot`
 - `Arma` -> `weapon_tool`
 - `L_17_` -> `team_tag_ui`
 - `Mode` -> `equip_mode`
 - `ServerGun` -> `server_gun_model`
 - `Modo` -> `Mode`
 - `PClient` -> `acs_client`
 - `SKP_0` -> `player`
 - `vitima_human` -> `target_humanoid`

##### Miscellaneous
 - `BSpread` -> `CurrentSpread`
 - `ToolEquip` -> `IsWeaponEquipped`
 - `AnimDebounce` -> `IsAnimationPlaying`
 - `GenerateBullet` -> `BulletCount`
 - `Mouse1Down` -> `IsMouseButton1Down`
 - `CheckingMag` -> `IsCheckingAmmo`
 - `CookingGrenade` -> `IsCookingGrenade`
 - `GrenadeDebounce` -> `IsGrenadeActionInProgress`
 - `CanBipod` -> `IsBipodDeployable`
 - `HasBipodAtt` -> `HasBipodAttachment`
 - `ExpEffect` -> `ExplosionEffect`