--[[
    RecoilController.lua
    Created by @ddydddd9 - Moonlight

	Recoil controller managing camera and weapon recoil patterns with spring-based smoothing and attachment modifiers
]]

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local Engine = RS:WaitForChild("ACS_Engine")
local Modules = Engine:WaitForChild("Modules")
local WeaponModules = Modules:WaitForChild("Weapon")

local Spring = require(Modules:WaitForChild("Spring"))
local Thread = require(Modules:WaitForChild("Thread"))
local Util = require(Modules:WaitForChild("Utilities"))
local WeaponRegistry = require(WeaponModules:WaitForChild("WeaponRegistry"))
local AttachmentManager = require(WeaponModules:WaitForChild("AttachmentManager"))
local WeaponState = require(WeaponModules:WaitForChild("WeaponState"))

Player.CharacterAdded:Connect(function(new_character)
	CurrentCamera = workspace.CurrentCamera
end)

local RecoilController = {}

RecoilController.RecoilSpring = Spring.new(Vector3.new())
RecoilController.RecoilSpring.d = 0.1
RecoilController.RecoilSpring.s = 20

RecoilController.CameraSpring = Spring.new(Vector3.new())
RecoilController.CameraSpring.d = 0.5
RecoilController.CameraSpring.s = 20

RecoilController.RecoilCFrame = CFrame.new()
RecoilController.CurrentRecoilPower = {}

function RecoilController.ApplyCameraRecoil()
    CurrentCamera.CFrame = CurrentCamera.CFrame * CFrame.Angles(RecoilController.CameraSpring.p.x, RecoilController.CameraSpring.p.y, RecoilController.CameraSpring.p.z)
end

function RecoilController.ApplyWeaponRecoil()
    RecoilController.RecoilCFrame = RecoilController.RecoilCFrame * CFrame.Angles(RecoilController.RecoilSpring.p.x, RecoilController.RecoilSpring.p.y, RecoilController.RecoilSpring.p.z)
end

function RecoilController.ApplyRecoilPattern()
    local weapon_data = WeaponRegistry.GetWeaponData()
    local attachment_modifications = AttachmentManager.Data

    local rad = math.rad
	local random = math.random

	local vr = (random(weapon_data.camRecoil.camRecoilUp[1], weapon_data.camRecoil.camRecoilUp[2])/2) * attachment_modifications.CamRecoil.RecoilUp
	local lr = (random(weapon_data.camRecoil.camRecoilLeft[1], weapon_data.camRecoil.camRecoilLeft[2])) * attachment_modifications.CamRecoil.RecoilLeft
	local rr = (random(weapon_data.camRecoil.camRecoilRight[1], weapon_data.camRecoil.camRecoilRight[2])) * attachment_modifications.CamRecoil.RecoilRight
	local hr = (random(-rr, lr)/2)
	local tr = (random(weapon_data.camRecoil.camRecoilTilt[1], weapon_data.camRecoil.camRecoilTilt[2])/2) * attachment_modifications.CamRecoil.RecoilTilt

	local RecoilX = rad(vr * Util.RAND( 1, 1, .1))
	local RecoilY = rad(hr * Util.RAND(-1, 1, .1))
	local RecoilZ = rad(tr * Util.RAND(-1, 1, .1))

	local gvr = (random(weapon_data.gunRecoil.gunRecoilUp[1], weapon_data.gunRecoil.gunRecoilUp[2]) /10) * attachment_modifications.GunRecoil.RecoilUp
	local gdr = (random(-1,1) * random(weapon_data.gunRecoil.gunRecoilTilt[1], weapon_data.gunRecoil.gunRecoilTilt[2]) /10) * attachment_modifications.GunRecoil.RecoilTilt
	local glr = (random(weapon_data.gunRecoil.gunRecoilLeft[1], weapon_data.gunRecoil.gunRecoilLeft[2])) * attachment_modifications.GunRecoil.RecoilLeft
	local grr = (random(weapon_data.gunRecoil.gunRecoilRight[1], weapon_data.gunRecoil.gunRecoilRight[2])) * attachment_modifications.GunRecoil.RecoilRight

	local ghr = (random(-grr, glr)/10)	

	local ARR = weapon_data.AimRecoilReduction * attachment_modifications.AimRM

	if AttachmentManager.Flags.BipodActive then
		RecoilController.CameraSpring:accelerate(Vector3.new( RecoilX, RecoilY/2, 0 ))

		if not WeaponState.IsAimming then
			RecoilController.RecoilSpring:accelerate(Vector3.new( rad(0.25 * gvr * RecoilController.CurrentRecoilPower), rad(.25 * ghr * RecoilController.CurrentRecoilPower), rad(.25 * gdr)))
			RecoilController.RecoilCFrame = RecoilController.RecoilCFrame * CFrame.new(0, 0, 0.1) * CFrame.Angles(rad(.25 * gvr * RecoilController.CurrentRecoilPower ), rad(.25 * ghr * RecoilController.CurrentRecoilPower ), rad(.25 * gdr * RecoilController.CurrentRecoilPower ))

		else
			RecoilController.RecoilSpring:accelerate(Vector3.new( rad(0.25 * gvr * RecoilController.CurrentRecoilPower/ARR) , rad(.25 * ghr * RecoilController.CurrentRecoilPower/ARR), rad(.25 * gdr/ ARR)))
			RecoilController.RecoilCFrame = RecoilController.RecoilCFrame * CFrame.new(0, 0, 0.1) * CFrame.Angles(rad(.25 * gvr * RecoilController.CurrentRecoilPower/ARR ), rad(.25 * ghr * RecoilController.CurrentRecoilPower/ARR ), rad(.25 * gdr * RecoilController.CurrentRecoilPower/ARR ))
		end

		Thread:Wait(0.05)
		RecoilController.CameraSpring:accelerate(Vector3.new(-RecoilX, -RecoilY/2, 0))
	else
		RecoilController.CameraSpring:accelerate(Vector3.new( RecoilX , RecoilY, RecoilZ ))
		if not WeaponState.IsAimming then
			RecoilController.RecoilSpring:accelerate(Vector3.new( rad(gvr * RecoilController.CurrentRecoilPower), rad(ghr * RecoilController.CurrentRecoilPower), rad(gdr)))
			RecoilController.RecoilCFrame = RecoilController.RecoilCFrame * CFrame.new(0,-0.05,.1) * CFrame.Angles( rad( gvr * RecoilController.CurrentRecoilPower ),rad( ghr * RecoilController.CurrentRecoilPower ),rad( gdr * RecoilController.CurrentRecoilPower ))

		else
			RecoilController.RecoilSpring:accelerate(Vector3.new( rad(gvr * RecoilController.CurrentRecoilPower/ARR) , rad(ghr * RecoilController.CurrentRecoilPower/ARR), rad(gdr/ ARR)))
			RecoilController.RecoilCFrame = RecoilController.RecoilCFrame * CFrame.new(0,0,.1) * CFrame.Angles( rad( gvr * RecoilController.CurrentRecoilPower/ARR ),rad( ghr * RecoilController.CurrentRecoilPower/ARR ),rad( gdr * RecoilController.CurrentRecoilPower/ARR ))
		end
	end
end

function RecoilController.Reset()
    RecoilController.CurrentRecoilPower = nil
end

return RecoilController