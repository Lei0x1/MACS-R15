--[[
    CameraController.lua
    Created by @ddydddd9 - Moonlight

	Camera control module for managing view, leaning mechanics, and HUD synchronization
]]

local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player 		= Players.LocalPlayer
local Character 	= Player.Character or Player.CharacterAdded:Wait()
local CurrentCamera = workspace.CurrentCamera

local Engine = RS:WaitForChild("ACS_Engine")
local Event = Engine:WaitForChild("Events")
local Modules = Engine:WaitForChild("Modules")
local ClientModules = Modules:WaitForChild("Client")

local Spring = require(Modules:WaitForChild("Spring"))
local HUDController = require(ClientModules:WaitForChild("HUDController"))
local PlayerStateManager = require(ClientModules:WaitForChild("PlayerStateManager"))

Player.CharacterAdded:Connect(function(new_character)
	Character = new_character
	CurrentCamera = workspace.CurrentCamera
end)

local CameraController = {}

local LeanController = {}
local LeanSpring = {}
LeanSpring.cornerPeek = Spring.new(0)
LeanSpring.cornerPeek.d = 1
LeanSpring.cornerPeek.s = 20
LeanSpring.peekFactor = math.rad(-15)
LeanSpring.dirPeek = 0

function LeanController.Update()
    LeanSpring.cornerPeek.t = LeanSpring.peekFactor * PlayerStateManager.LeanDirection
    local new_lean_cframe = CFrame.fromAxisAngle(Vector3.new(0, 0, 1), LeanSpring.cornerPeek.p)
    CurrentCamera.CFrame = CurrentCamera.CFrame * new_lean_cframe
end

function CameraController.InitialCameraSetup(character)
	local humanoid = character.Humanoid
	if not humanoid then return end

    UIS.MouseIconEnabled 		= true
	Player.CameraMode 			= Enum.CameraMode.Classic
	CurrentCamera.CameraType 	= Enum.CameraType.Custom
	CurrentCamera.CameraSubject = humanoid
end

function CameraController.ApplyLeanOffset()
	TS:Create(Character.Humanoid, TweenInfo.new(0.3), {CameraOffset = Vector3.new(PlayerStateManager.CameraX, PlayerStateManager.CameraY,0)} ):Play()
	Event.Stance:FireServer(PlayerStateManager.Stances, PlayerStateManager.LeanDirection)

	if PlayerStateManager.LeanDirection == 0 then
		HUDController.StatusGui.MainFrame.Poses.Esg_Left.Visible = false
		HUDController.StatusGui.MainFrame.Poses.Esg_Right.Visible = false
	elseif PlayerStateManager.LeanDirection == 1 then
		HUDController.StatusGui.MainFrame.Poses.Esg_Left.Visible = false
		HUDController.StatusGui.MainFrame.Poses.Esg_Right.Visible = true
	elseif PlayerStateManager.LeanDirection == -1 then
		HUDController.StatusGui.MainFrame.Poses.Esg_Left.Visible = true
		HUDController.StatusGui.MainFrame.Poses.Esg_Right.Visible = false
	end
end

function CameraController.UpdateLean()
    LeanController.Update()
end

return CameraController