--[[
    PostureController.lua
    Created by @ddydddd9 - Moonlight

	Posture controller for managing stance transitions,
	movement speed adjustments, and HUD synchronization
]]

local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player 		= Players.LocalPlayer
local Character 	= Player.Character or Player.CharacterAdded:Wait()
local ACS_Client 	= Character:WaitForChild("ACS_Client")

local Engine = RS:WaitForChild("ACS_Engine")
local Event = Engine:WaitForChild("Events")
local GameRules = Engine:WaitForChild("GameRules")
local Modules = Engine:WaitForChild("Modules")
local ClientModules = Modules:WaitForChild("Client")

local Config = require(GameRules:WaitForChild("Config"))
local HUDController = require(ClientModules:WaitForChild("HUDController"))
local PlayerStateManager = require(ClientModules:WaitForChild("PlayerStateManager"))

Player.CharacterAdded:Connect(function(new_character)
	Character = new_character
	ACS_Client = new_character:WaitForChild("ACS_Client")
end)

local PostureController = {}

function PostureController.SetStandingStance()
    Event.Stance:FireServer(PlayerStateManager.Stances, PlayerStateManager.LeanDirection)
	TS:Create(Character.Humanoid, TweenInfo.new(.3), {CameraOffset = Vector3.new(PlayerStateManager.CameraX, PlayerStateManager.CameraY,0)} ):Play()

	HUDController.StatusGui.MainFrame.Poses.Levantado.Visible = true
	HUDController.StatusGui.MainFrame.Poses.Agaixado.Visible = false
	HUDController.StatusGui.MainFrame.Poses.Deitado.Visible = false

	if PlayerStateManager.IsSteady then
		Character.Humanoid.WalkSpeed = Config.SlowPaceWalkSpeed
		Character.Humanoid.JumpPower = Config.JumpPower
	else
		if script.Parent:GetAttribute("Injured") then
			Character.Humanoid.WalkSpeed = Config.InjuredWalksSpeed
			Character.Humanoid.JumpPower = Config.JumpPower
		else
			Character.Humanoid.WalkSpeed = Config.NormalWalkSpeed
			Character.Humanoid.JumpPower = Config.JumpPower
		end
	end
end

function PostureController.SetCrouchingStance()
	Event.Stance:FireServer(PlayerStateManager.Stances, PlayerStateManager.LeanDirection)
	TS:Create(Character.Humanoid, TweenInfo.new(.3), {CameraOffset = Vector3.new(PlayerStateManager.CameraX, PlayerStateManager.CameraY,0)} ):Play()

	HUDController.StatusGui.MainFrame.Poses.Levantado.Visible = false
	HUDController.StatusGui.MainFrame.Poses.Agaixado.Visible = true
	HUDController.StatusGui.MainFrame.Poses.Deitado.Visible = false

	if script.Parent:GetAttribute("Injured") then
		Character.Humanoid.WalkSpeed = Config.InjuredCrouchWalkSpeed
		Character.Humanoid.JumpPower = 0
	else
		Character.Humanoid.WalkSpeed = Config.CrouchWalkSpeed
		Character.Humanoid.JumpPower = 0
	end
end

function PostureController.SetProneStance()
	Event.Stance:FireServer(PlayerStateManager.Stances, PlayerStateManager.LeanDirection)
	TS:Create(Character.Humanoid, TweenInfo.new(.3), {CameraOffset = Vector3.new(PlayerStateManager.CameraX, PlayerStateManager.CameraY,0)} ):Play()

	HUDController.StatusGui.MainFrame.Poses.Levantado.Visible = false
	HUDController.StatusGui.MainFrame.Poses.Agaixado.Visible = false
	HUDController.StatusGui.MainFrame.Poses.Deitado.Visible = true
	
	if ACS_Client:GetAttribute("Surrender") then
		Character.Humanoid.WalkSpeed = 0
	else
		Character.Humanoid.WalkSpeed = Config.ProneWalksSpeed
	end
	
	Character.Humanoid.JumpPower = 0
end

return PostureController