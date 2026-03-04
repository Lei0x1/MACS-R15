--[[
    WeaponState.lua
    Created by @ddydddd9 - Moonlight

    Runtime weapon state manager tracking aiming, firing, reloading, ammo, sensitivity, and stance configurations
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local WeaponState = {
    IsWeaponEquipped = false,
    IsAimming = false,
    IsShooting = false,
    IsReloading = false,
    IsCheckingAmmo = false,
    IsChambered = false,
    IsWeaponColliding = false,
    CancelReload = false,
    SafeMode = false,

    CurrentGunStance = 0,
    CurrentAimPartMode = 1,
    CurrentAimPart = nil,
    CurrentWeaponSize = nil,
    CurrentSpread = nil,

    GrenadeAmmo = 0,
    IsGrenadeActionInProgress = false,
    IsCookingGrenade = false,
    GrenadeThrowPower = 150,

    CameraSens = 50,
    HipFireSens = 50,
    IsHipFiring = false,
    ADSSens = 50,

    Ammo = nil,
    StoredAmmo = nil,
    BulletCount = 1
}

WeaponState.MainCFrame = CFrame.new()
WeaponState.GunCFrame = CFrame.new()
WeaponState.GunBobCFrame = CFrame.new()
WeaponState.AimCFrame = CFrame.new()
WeaponState.BipodCFrame = CFrame.new()
WeaponState.WeaponCollisionCF = CFrame.new()

--[[
    State's that are intentionally defined outside the reset groups.

    It represents persistent tween configuration and is not part of the
    mutable runtime weapon state. Unlike the fields above, it is not
    reset during weapon unequip cycles.
]]

-- Time
WeaponState.LastSpreadUpdate = time()

-- Tweening
WeaponState.AimTweenInfo = TweenInfo.new(
	0.2,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

function WeaponState:ResetWeaponStatus()
    self.IsWeaponEquipped = false
    self.IsAimming = false
    self.IsShooting = false
    self.IsReloading = false
    self.IsCheckingAmmo = false
    self.IsChambered = false
    self.IsWeaponColliding = false
    self.CancelReload = false
    self.SafeMode = false
end

function WeaponState:ResetWeaponConfig()
    self.CurrentGunStance = 0
    self.CurrentAimPartMode = 1
    self.CurrentAimPart = nil
    self.CurrentWeaponSize = nil
    self.CurrentSpread = nil
end

function WeaponState:ResetGrenade()
    self.GrenadeAmmo = 0
    self.IsGrenadeActionInProgress = false
    self.IsCookingGrenade = false
    self.GrenadeThrowPower = 150
end

function WeaponState:ResetSensitivity()
    self.CameraSens = 50
    self.HipFireSens = 50
    self.IsHipFiring = false
    self.ADSSens = 50
end

function WeaponState:ResetAmmo()
    self.Ammo = nil
    self.StoredAmmo = nil
    self.BulletCount = 1
end

function WeaponState:ResetCFrame()
    self.MainCFrame = CFrame.new()
    self.GunCFrame = CFrame.new()
    self.GunBobCFrame = CFrame.new()
    self.AimCFrame = CFrame.new()
    self.BipodCFrame = CFrame.new()
    self.WeaponCollisionCF = CFrame.new()
end

function WeaponState.Reset()
    WeaponState:ResetWeaponStatus()
    WeaponState:ResetWeaponConfig()
    WeaponState:ResetGrenade()
    WeaponState:ResetSensitivity()
    WeaponState:ResetAmmo()
end

Player.Character.Humanoid.Died:Connect(function()
    WeaponState.IsWeaponColliding = false
    WeaponState.Reset()
    WeaponState:ResetCFrame()
end)

return WeaponState