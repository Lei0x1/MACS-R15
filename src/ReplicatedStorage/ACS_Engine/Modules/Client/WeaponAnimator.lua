--[[
    WeaponAnimator.lua
    Created by @ddydddd9 - Moonlight

	Weapon animation controller for managing viewmodel animations
	with safe execution and state tracking
]]

local RS = game:GetService("ReplicatedStorage")

local Engine = RS:WaitForChild("ACS_Engine")
local Modules = Engine:WaitForChild("Modules")
local ClientModules = Modules:WaitForChild("Client")
local WeaponModules = Modules:WaitForChild("Weapon")

local ViewModelManager = require(ClientModules:WaitForChild("ViewModelManager"))

local WeaponRegistry = require(WeaponModules:WaitForChild("WeaponRegistry"))
local WeaponState = require(WeaponModules:WaitForChild("WeaponState"))

local WeaponAnimator = {}

WeaponAnimator.IsAnimationPlaying = false

local function GetCurrentWeaponData()
	local weapon_data = WeaponRegistry:GetAll()
	if not weapon_data or not weapon_data.isEquipped then
		return nil
	end

	return weapon_data
end

local function GetAnimationOrDefault(animation_table, animation_name, default_animation)
	local animation = animation_table[animation_name]
	if not animation then
		animation = default_animation
	end

	return animation
end

local function SafeAnimate(animation_name)
	local weapon_data = GetCurrentWeaponData()
	if not weapon_data then
		warn("[AnimationController:] No weapon equipped for " .. animation_name)
		return false
	end

	local animation_function = weapon_data.AnimData[animation_name]
	if not animation_function then
		warn("[AnimationController] Animation " .. animation_name .. " not found")
		return false
	end

	local parts = {
		ViewModelManager.RAW,
		ViewModelManager.LAW,
		ViewModelManager.GunWeld,
		weapon_data.WeaponInHand,
		ViewModelManager.ViewModel
	}

	local success = pcall(animation_function, parts)
	return success
end

function WeaponAnimator.PlayEquipAnimation()
	WeaponAnimator.IsAnimationPlaying = false
	local result = SafeAnimate("EquipAnim")
	WeaponAnimator.IsAnimationPlaying = true
	return result
end


function WeaponAnimator.PlayIdleAnimation()
	local result = SafeAnimate("IdleAnim")
	WeaponAnimator.IsAnimationPlaying = true
	return result
end

function WeaponAnimator.PlaySprintAnimation()
	WeaponAnimator.IsAnimationPlaying = false
	local result = SafeAnimate("SprintAnim")
	return result
end

function WeaponAnimator.HighReady()
	return SafeAnimate("HighReady")
end

function WeaponAnimator.LowReady()
	return SafeAnimate("LowReady")
end

function WeaponAnimator.Patrol()
	return SafeAnimate("Patrol")
end

function WeaponAnimator.PlayReloadAnimation()
	return SafeAnimate("ReloadAnim")
end

function WeaponAnimator.PlayTacticalReloadAnimation()
	return SafeAnimate("TacticalReloadAnim")
end

function WeaponAnimator.JammedAnim()
	return SafeAnimate("JammedAnim")
end

function WeaponAnimator.PlayPumpActionAnimation()
	WeaponState.IsReloading = true
	local result = SafeAnimate("PumpAnim")
	WeaponState.IsReloading = false
	return result
end

function WeaponAnimator.PlayCheckAmmoAnimation()
	WeaponState.IsCheckingAmmo = true
	local result = SafeAnimate("MagCheck")
	WeaponState.IsCheckingAmmo = false
	return result
end

function WeaponAnimator.PlayFireModeAnimation()
	return SafeAnimate("FireMode")
end

function WeaponAnimator.MeleeAttackAnim()
	return SafeAnimate("MeleeAttackAnim")
end

function WeaponAnimator.PlayGrenadeReadyAnimation()
	return SafeAnimate("GrenadeReady")
end

function WeaponAnimator.PlayGrenadeThrowAnimation()
	return SafeAnimate("GrenadeThrow")
end

function WeaponAnimator.Reset()
    WeaponAnimator.IsAnimationPlaying = false
end

return WeaponAnimator