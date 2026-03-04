--[[
    WeaponController.lua
    Created by @ddydddd9 - Moonlight

	Main weapon controller handling equipping, firing, reloading, attachments, and all weapon-related gameplay mechanics
]]

local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local PlayerGui = Player.PlayerGui
local CurrentCamera = workspace.CurrentCamera
local ACS_Workspace = workspace.ACS_WorkSpace
local ACS_Client = Character:WaitForChild("ACS_Client")

local Engine = RS:WaitForChild("ACS_Engine")
local Event = Engine:WaitForChild("Events")
local GameRules = Engine:WaitForChild("GameRules")
local WeaponModels = Engine:WaitForChild("WeaponModels")
local Modules = Engine:WaitForChild("Modules")
local CoreModules = Modules:WaitForChild("Core")
local ClientModules = Modules:WaitForChild("Client")
local WeaponModules = Modules:WaitForChild("Weapon")

local Config = require(GameRules:WaitForChild("Config"))
local Util = require(Modules:WaitForChild("Utilities"))
local Thread = require(Modules:WaitForChild("Thread"))
local Hitmarker = require(Modules:WaitForChild("Hitmarker"))

local BallisticsManager = require(CoreModules:WaitForChild("BallisticsManager"))
local ObjectPool = require(CoreModules:WaitForChild("ObjectPool"))
local RayIgnore  = require(CoreModules:WaitForChild("RayIgnore"))

local CrosshairController = require(ClientModules:WaitForChild("CrosshairController"))
local InputBindingController = require(ClientModules:WaitForChild("InputBindingController"))
local ViewModelManager = require(ClientModules:WaitForChild("ViewModelManager"))
local WeaponAnimator = require(ClientModules:WaitForChild("WeaponAnimator"))
local HUDController = require(ClientModules:WaitForChild("HUDController"))
local PlayerStateManager = require(ClientModules:WaitForChild("PlayerStateManager"))
local InputSystem = require(ClientModules:WaitForChild("InputSystem"))
local PostureController = require(ClientModules:WaitForChild("PostureController"))
local CameraController = require(ClientModules:WaitForChild("CameraController"))

local WeaponState = require(WeaponModules:WaitForChild("WeaponState"))
local WeaponRegistry = require(WeaponModules:WaitForChild("WeaponRegistry"))
local AttachmentManager = require(WeaponModules:WaitForChild("AttachmentManager"))
local AttachmentController = require(WeaponModules:WaitForChild("AttachmentController"))
local RecoilController = require(WeaponModules:WaitForChild("RecoilController"))

Player.CharacterAdded:Connect(function(new_character)
	Character = new_character
	ACS_Client = new_character:WaitForChild("ACS_Client")
	CurrentCamera = workspace.CurrentCamera
	
	WeaponState.IsWeaponEquipped = false
end)

local WeaponController = {}

local WeaponInHand, WeaponData, WeaponTool, AnimData = nil, nil, nil, nil
local Ammo, StoredAmmo = nil, nil

WeaponRegistry.Changed:Connect(function(event, data)
    if event == "Equipped" then
        WeaponInHand = data.weapon_in_hand
        WeaponTool = data.weapon_tool
        WeaponData = data.weapon_data
        AnimData = data.anim_data

        if WeaponData then
            Ammo = WeaponData.AmmoInGun
            StoredAmmo = WeaponData.StoredAmmo
        end

    elseif event == "Unequipped" then
        WeaponInHand = nil
        WeaponTool = nil
		WeaponData = nil
		AnimData = nil
		Ammo = nil
		StoredAmmo = nil
    end
end)

local AttachmentModifications = AttachmentManager.Data

local function GetModelLength(model)
	local handle = WeaponInHand:FindFirstChild("Handle")
	if not handle then
		WeaponState.CurrentWeaponSize = 1
		return
	end
	
	local min_z, max_z = math.huge, -math.huge
	local handleCF = handle.CFrame

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part ~= handle then
			local localPos = handleCF:PointToObjectSpace(part.Position)
			local halfSize = part.Size.Z / 2
			
			min_z = math.min(min_z, localPos.Z - halfSize)
			max_z = math.max(max_z, localPos.Z + halfSize)
		end
	end
	
	if min_z == math.huge or max_z == -math.huge then
		WeaponState.CurrentWeaponSize = 1
		return
	end

	local model_length = math.abs(max_z - min_z)
	WeaponState.CurrentWeaponSize = model_length

	return model_length
end

function WeaponController.WeaponListeners()
	-- Fire action
	InputSystem.Listen("Fire", function(state, _input)
		if state == Enum.UserInputState.Begin and WeaponAnimator.IsAnimationPlaying then
			WeaponController.Shoot()

			if WeaponData and WeaponData.Type == "Grenade" then
				WeaponState.IsCookingGrenade = true
				CookGrenade()
				ThrowGrenade()
			end

		elseif state == Enum.UserInputState.End then
			PlayerStateManager.IsMouseButton1Down = false
			WeaponState.IsCookingGrenade = false
			WeaponState.IsHipFiring = false
			ApplyMouseSensitivity()
		end
	end)

	-- Aim action
	InputSystem.Listen("Aim", function(state, _input)
		if state == Enum.UserInputState.Begin and WeaponAnimator.IsAnimationPlaying then
			if WeaponState.IsWeaponColliding and not Config.WeaponCollisionADS then return end
			if WeaponData and WeaponData.canAim and WeaponState.CurrentGunStance > -2 and not PlayerStateManager.RunKeyDown and not WeaponState.IsCheckingAmmo then
				WeaponState.IsAimming = not WeaponState.IsAimming
				ToggleAimingDownSights(WeaponState.IsAimming)
			end

			if WeaponData and WeaponData.Type == "Grenade" then
				CycleThrowPower()
			end
		elseif state == Enum.UserInputState.End and Config.WeaponAimAutomaticRecovery and WeaponState.IsAimming then
			WeaponState.IsAimming = false
			ToggleAimingDownSights(WeaponState.IsAimming)
		end
	end)

	-- Reload action
	InputSystem.Listen("Reload", function(state, _input)
		if state == Enum.UserInputState.Begin and WeaponAnimator.IsAnimationPlaying and not WeaponState.IsCheckingAmmo and not WeaponState.IsReloading then
			if WeaponData and WeaponData.Jammed then
				Jammed()
			else
				Reload()
			end
		elseif state == Enum.UserInputState.Begin and WeaponState.IsReloading and WeaponData and WeaponData.ShellInsert then
			WeaponState.CancelReload = true
		end
	end)

	-- Cycle Laser action
	InputSystem.Listen("CycleLaserAtt", function(state, _input)
		if state == Enum.UserInputState.Begin and AttachmentManager.Flags.LaserAtt then
			if not AttachmentManager.Flags.LaserAtt then return end
			AttachmentController.ToggleLaserAttachment()
		end
	end)

	-- Cycle Light action
	InputSystem.Listen("CycleFlashLight", function(state, _input)
		if state == Enum.UserInputState.Begin and AttachmentManager.Flags.TorchAtt then
			AttachmentController.ToggleFlashlight()
		end
	end)

	-- Cycle FireMode action
	InputSystem.Listen("CycleFireMode", function(state, _input)
		if state == Enum.UserInputState.Begin and WeaponData and WeaponData.FireModes and WeaponData.FireModes.ChangeFiremode then
			FireMode()
		end
	end)

	-- Cycle Aimpart action
	InputSystem.Listen("CycleAimpart", function(state, _input)
		if state == Enum.UserInputState.Begin then
			ToggleAimPoint()
		end
	end)

	-- Zero Up action
	InputSystem.Listen("ZeroUp", function(state, _input)
		if state == Enum.UserInputState.Begin and WeaponData and WeaponData.EnableZeroing then
			if WeaponData.CurrentZero < WeaponData.MaxZero then
				WeaponInHand.Handle.Click:Play()
				WeaponData.CurrentZero = math.min(WeaponData.CurrentZero + WeaponData.ZeroIncrement, WeaponData.MaxZero)
				HUDController.UpdateGui()
			end
		end
	end)

	-- Zero Down action
	InputSystem.Listen("ZeroDown", function(state, _input)
		if state == Enum.UserInputState.Begin and WeaponData and WeaponData.EnableZeroing then
			if WeaponData.CurrentZero > 0 then
				WeaponInHand.Handle.Click:Play()
				WeaponData.CurrentZero = math.max(WeaponData.CurrentZero - WeaponData.ZeroIncrement, 0)
				HUDController.UpdateGui()
			end
		end
	end)

	-- Check Magazine action
	InputSystem.Listen("CheckMag", function(state, _input)
		if state == Enum.UserInputState.Begin and not WeaponState.IsCheckingAmmo and not WeaponState.IsReloading and not PlayerStateManager.RunKeyDown and WeaponAnimator.IsAnimationPlaying then
			CheckAmmoCount()
		end
	end)

	-- Toggle Bipod action
	InputSystem.Listen("ToggleBipod", function(state, _input)
		if state == Enum.UserInputState.Begin and AttachmentManager.Flags.IsBipodDeployable then
			AttachmentManager.Flags.BipodActive = not AttachmentManager.Flags.BipodActive
			HUDController.UpdateGui()
		end
	end)

	-- NVG action
	InputSystem.Listen("NVG", function(state, _input)
		if state == Enum.UserInputState.Begin and not PlayerStateManager.NVGdebounce then
			if Player.Character then
				local helmet = Player.Character:FindFirstChild("Helmet")
				if helmet then
					local nvg = helmet:FindFirstChild("Up")
					if nvg then
						PlayerStateManager.NVGdebounce = true
						task.delay(.8, function()
							PlayerStateManager.NVG = not PlayerStateManager.NVG
							Event.NVG:Fire(PlayerStateManager.NVG)
							PlayerStateManager.NVGdebounce = false
						end)
					end

					PlayerStateManager.NVG = true
				end
			end
		end
	end)

	-- Stand action
	InputSystem.Listen("Stand", function(state, _input)
		if state == Enum.UserInputState.Begin and PlayerStateManager.ChangeStance and not PlayerStateManager.IsSwimming and not PlayerStateManager.IsSitting and not PlayerStateManager.RunKeyDown and not ACS_Client:GetAttribute("Collapsed") then
			if PlayerStateManager.Stances == 2 then
				PlayerStateManager.IsCrouched = true
				PlayerStateManager.IsProned = false
				PlayerStateManager.Stances = 1
				PlayerStateManager.CameraY = -1

				PostureController.SetCrouchingStance()
			elseif PlayerStateManager.Stances == 1 then
				PlayerStateManager.IsCrouched = false
				PlayerStateManager.Stances = 0
				PlayerStateManager.CameraY = 0

				PostureController.SetStandingStance()
			end
		end
	end)

	-- Crouch action
	InputSystem.Listen("Crouch", function(state, _input)
		if state == Enum.UserInputState.Begin and PlayerStateManager.ChangeStance and not PlayerStateManager.IsSwimming and not PlayerStateManager.IsSitting and not PlayerStateManager.RunKeyDown and not ACS_Client:GetAttribute("Collapsed") then
			if PlayerStateManager.Stances == 0 then
				PlayerStateManager.Stances = 1
				PlayerStateManager.CameraY = -1

				PostureController.SetCrouchingStance()

				PlayerStateManager.IsCrouched = true
			elseif PlayerStateManager.Stances == 1 then
				PlayerStateManager.Stances = 2
				PlayerStateManager.CameraX = 0
				PlayerStateManager.CameraY = -3.25
				PlayerStateManager.LeanDirection = 0

				CameraController.ApplyLeanOffset()
				PostureController.SetProneStance()

				PlayerStateManager.IsCrouched = false
				PlayerStateManager.IsProned = true
			end
		end
	end)

	-- Toggle Walk action
	InputSystem.Listen("ToggleWalk", function(state, _input)
		if state == Enum.UserInputState.Begin and PlayerStateManager.ChangeStance and not PlayerStateManager.RunKeyDown then
			PlayerStateManager.IsSteady = not PlayerStateManager.IsSteady

			if PlayerStateManager.IsSteady then
				HUDController.StatusGui.MainFrame.Poses.IsSteady.Visible = true
			else
				HUDController.StatusGui.MainFrame.Poses.IsSteady.Visible = false
			end

			if PlayerStateManager.Stances == 0 then
				PostureController.SetStandingStance()
			end
		end
	end)

	-- Lean Left action
	InputSystem.Listen("LeanLeft", function(state, _input)
		if state == Enum.UserInputState.Begin and PlayerStateManager.Stances ~= 2 and PlayerStateManager.ChangeStance and not PlayerStateManager.IsSwimming and not PlayerStateManager.RunKeyDown and PlayerStateManager.CanLean and not ACS_Client:GetAttribute("Collapsed") then
			if PlayerStateManager.LeanDirection == 0 or PlayerStateManager.LeanDirection == 1 then
				PlayerStateManager.LeanDirection = -1
				PlayerStateManager.CameraX = -1.25
			else
				PlayerStateManager.LeanDirection = 0
				PlayerStateManager.CameraX = 0
			end
			CameraController.ApplyLeanOffset()
		elseif state == Enum.UserInputState.End and Config.LeanAutomaticRecovery and PlayerStateManager.LeanDirection == -1 then
			PlayerStateManager.LeanDirection = 0
			PlayerStateManager.CameraX = 0
			CameraController.ApplyLeanOffset()
		end
	end)

	-- Lean Right action
	InputSystem.Listen("LeanRight", function(state, _input)
		if state == Enum.UserInputState.Begin and PlayerStateManager.Stances ~= 2 and PlayerStateManager.ChangeStance and not PlayerStateManager.IsSwimming and not PlayerStateManager.RunKeyDown and PlayerStateManager.CanLean and not ACS_Client:GetAttribute("Collapsed") then
			if PlayerStateManager.LeanDirection == 0 or PlayerStateManager.LeanDirection == -1 then
				PlayerStateManager.LeanDirection = 1
				PlayerStateManager.CameraX = 1.25
			else
				PlayerStateManager.LeanDirection = 0
				PlayerStateManager.CameraX = 0
			end

			CameraController.ApplyLeanOffset()
		elseif state == Enum.UserInputState.End and Config.LeanAutomaticRecovery and PlayerStateManager.LeanDirection == 1 then
			PlayerStateManager.LeanDirection = 0
			PlayerStateManager.CameraX = 0

			CameraController.ApplyLeanOffset()
		end
	end)

	-- Run action
	InputSystem.Listen("Run", function(state, _input)
		if state == Enum.UserInputState.Begin and PlayerStateManager.IsRunning and not script.Parent:GetAttribute("Injured") then
			PlayerStateManager.RunKeyDown = true
			PostureController.SetStandingStance()
			PlayerStateManager.Stances = 0
			PlayerStateManager.LeanDirection = 0
			PlayerStateManager.CameraX = 0
			PlayerStateManager.CameraY = 0
			CameraController.ApplyLeanOffset()

			Character:WaitForChild("Humanoid").WalkSpeed = Config.RunWalkSpeed

			if WeaponState.IsAimming then
				WeaponState.IsAimming = false
				ToggleAimingDownSights(WeaponState.IsAimming)
			end

			if not WeaponState.IsCheckingAmmo and not WeaponState.IsReloading and WeaponData and WeaponData.Type ~= "Grenade" and (WeaponState.CurrentGunStance == 0 or WeaponState.CurrentGunStance == 2 or WeaponState.CurrentGunStance == 3) then
				WeaponState.CurrentGunStance = 3
				Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance, AnimData)
				WeaponAnimator.PlaySprintAnimation()
			end

		elseif state == Enum.UserInputState.End and PlayerStateManager.RunKeyDown then
			PlayerStateManager.RunKeyDown = false
			PostureController.SetStandingStance()
			if not WeaponState.IsCheckingAmmo and not WeaponState.IsReloading and WeaponData and WeaponData.Type ~= "Grenade" and (WeaponState.CurrentGunStance == 0 or WeaponState.CurrentGunStance == 2 or WeaponState.CurrentGunStance == 3) then
				WeaponState.CurrentGunStance = 0
				Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance, AnimData)
				WeaponAnimator.PlayIdleAnimation()
			end
		end
	end)
end

function WeaponController.EquipWeapon(weapon_tool)
	if not Character or not weapon_tool or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then
		return
	end

	WeaponState.IsWeaponEquipped = true
	UIS.MouseIconEnabled = false

	Player.CameraMode = Enum.CameraMode.LockFirstPerson

	WeaponTool 	= weapon_tool
	WeaponData 	= Util.SafeRequire(weapon_tool:WaitForChild("ACS_Settings"))
	AnimData 	= Util.SafeRequire(weapon_tool:WaitForChild("ACS_Animations"))

	local saved_ammo = weapon_tool:GetAttribute("SavedAmmo")
	local saved_stored_ammo = weapon_tool:GetAttribute("SavedStoredAmmo")

	if saved_ammo ~= nil then
		WeaponData.AmmoInGun = saved_ammo
		WeaponState.Ammo = saved_ammo
	end
	if saved_stored_ammo ~= nil then
		WeaponData.StoredAmmo = saved_stored_ammo
		WeaponState.StoredAmmo = saved_stored_ammo
	end

	Ammo = WeaponData.AmmoInGun
	StoredAmmo = WeaponData.StoredAmmo

	WeaponState.Ammo = Ammo
	WeaponState.StoredAmmo = StoredAmmo

	local weapon_type = WeaponData.Type
	local weapon_type_folder = WeaponModels:FindFirstChild(weapon_type)
	if not weapon_type_folder then
		warn("Weapon type folder not found: " .. weapon_type)
		return
	end

	local model_check = weapon_type_folder:FindFirstChild(weapon_tool.Name)
	if not model_check then
		warn("Model " .. weapon_tool.Name .. " not found in " .. weapon_type .. " folder")
		return
	end

	WeaponInHand = model_check:Clone()
	GetModelLength(WeaponInHand)

	WeaponRegistry:StoreEquippedWeapon(
		WeaponInHand,
		WeaponTool,
		WeaponData,
		AnimData
	)

	Event.Equip:FireServer(weapon_tool, 1, WeaponData, AnimData)
	
	if WeaponData.Sensitivity then
		WeaponState.CameraSens 		= WeaponData.Sensitivity.Camera or 50
		WeaponState.HipFireSens 	= WeaponData.Sensitivity.HipFire or 50
		WeaponState.ADSSens 		= WeaponData.Sensitivity.ADS or 50
	else
		WeaponState.CameraSens 		= 50
		WeaponState.HipFireSens 	= 50
		WeaponState.ADSSens 		= 50
	end
	
	UIS.MouseDeltaSensitivity = (WeaponState.CameraSens / 100)

	WeaponState.MainCFrame = AnimData.MainCFrame
	WeaponState.GunCFrame = AnimData.GunCFrame

	ViewModelManager:Create(Character, WeaponState.GunCFrame, CurrentCamera)

	CrosshairController:UpdateWeaponData(WeaponData)
	CrosshairController:SetAimingState(false)

	-- Attach gun attachment modifier
	AttachmentModifications.ZoomValue 	= WeaponData.Zoom
	AttachmentModifications.Zoom2Value 	= WeaponData.Zoom2
	AttachmentManager.Flags.InfraredEnabled 	= WeaponData.InfraRed
	AttachmentManager.Load(WeaponInHand)

	-- Keybinds
	InputBindingController.UnbindWeaponActions()
	InputBindingController.BindWeaponActions()

	WeaponState.CurrentSpread = math.min(WeaponData.MinSpread * AttachmentModifications.MinSpread, WeaponData.MaxSpread * AttachmentModifications.MaxSpread)
	RecoilController.CurrentRecoilPower = math.min(WeaponData.MinRecoilPower * AttachmentModifications.MinRecoilPower, WeaponData.MaxRecoilPower * AttachmentModifications.MaxRecoilPower)
	
	WeaponState.CurrentAimPart = WeaponInHand:FindFirstChild("AimPart")
	
	for _, part in pairs(WeaponInHand:GetDescendants()) do
		if part:IsA("BasePart") and part.Name == "FlashPoint" then
			AttachmentManager.Flags.TorchAtt = true
		end
		if part:IsA("BasePart") and part.Name == "LaserPoint" then
			AttachmentManager.Flags.LaserAtt = true
		end
	end
	
	if WeaponData.Type == "Gun" and WeaponData.ShellEjectionMod then
		WeaponInHand.Bolt.SlidePull.Played:Connect(function()
			if Ammo > 0 then
				-- CreateShell(WeaponData.BulletType, WeaponInHand.Handle.Chamber)
				WeaponInHand.Handle.Chamber.Smoke:Emit(10)
				-- CanPump = false
			end
		end)
	end

	for _, weapon_model_parts in pairs(WeaponInHand:GetChildren()) do
		if weapon_model_parts:IsA('BasePart') and weapon_model_parts.Name ~= 'Handle' then

			if weapon_model_parts.Name ~= "Bolt" and weapon_model_parts.Name ~= 'Lid' and weapon_model_parts.Name ~= "Slide" then
				Util.Weld(WeaponInHand:WaitForChild("Handle"), weapon_model_parts)
			end

			if weapon_model_parts.Name == "Bolt" or weapon_model_parts.Name == "Slide" then
				Util.WeldComplex(WeaponInHand:WaitForChild("Handle"), weapon_model_parts, weapon_model_parts.Name)
			end

			if weapon_model_parts.Name == "Lid" then
				if WeaponInHand:FindFirstChild('LidHinge') then
					Util.Weld(weapon_model_parts, WeaponInHand:WaitForChild("LidHinge"))
				else
					Util.Weld(weapon_model_parts, WeaponInHand:WaitForChild("Handle"))
				end
			end
		end
	end

	for _, weapon_model_parts in pairs(WeaponInHand:GetChildren()) do
		if weapon_model_parts:IsA('BasePart') then
			weapon_model_parts.Anchored = false
			weapon_model_parts.CanCollide = false
		end
	end

	if WeaponInHand:FindFirstChild("Nodes") then
		for _, weapon_node_parts in pairs(WeaponInHand.Nodes:GetChildren()) do
			if weapon_node_parts:IsA('BasePart') then
				Util.Weld(WeaponInHand:WaitForChild("Handle"), weapon_node_parts)
				weapon_node_parts.Anchored = false
				weapon_node_parts.CanCollide = false
			end
		end
	end

	if Ammo <= 0 and WeaponData.Type == "Gun" then
		WeaponInHand.Handle.Slide.C0 = WeaponData.SlideEx:inverse()
	end

	if WeaponData.EnableHUD then
		HUDController.StatusGui.GunHUD.Visible = true
	end
	HUDController.UpdateGui()

	WeaponAnimator.PlayEquipAnimation()
	if WeaponData and WeaponData.Type ~= "Grenade" then
		UpdateWeaponStance()
	end
end

function WeaponController.UnequipWeapon()
	WeaponState.IsWeaponEquipped = false
	Event.Equip:FireServer(WeaponTool, 2, nil, nil)
	--unsetup weapon data module
	
	InputBindingController.UnbindWeaponActions()

	PlayerStateManager.IsMouseButton1Down = false
	WeaponState.IsAimming = false

	TS:Create(CurrentCamera, WeaponState.AimTweenInfo, { FieldOfView = 70 }):Play()
	CrosshairController:Reset()

	UIS.MouseIconEnabled = true
	game:GetService('UserInputService').MouseDeltaSensitivity = 1
	CurrentCamera.CameraType = Enum.CameraType.Custom
	Player.CameraMode = Enum.CameraMode.Classic

	if WeaponInHand then
		
		if WeaponData.Type == "Gun" then
			WeaponState.IsChambered = true
			if WeaponData.Jammed or Ammo < 1 then
				WeaponState.IsChambered = false
			end
			
			WeaponData.AmmoInGun = Ammo
			WeaponData.StoredAmmo = StoredAmmo
			
			WeaponTool:SetAttribute("SavedAmmo", Ammo)
			WeaponTool:SetAttribute("SavedStoredAmmo", StoredAmmo)
		end
		
		ViewModelManager:Clear()
		WeaponInHand	= nil
		WeaponTool		= nil
		WeaponData 	    = nil
		AnimData		= nil
		WeaponRegistry:ClearWeaponData()
		WeaponState.Reset()
		RecoilController.Reset()
		AttachmentManager.Reset()
		WeaponState.CurrentAimPartMode 	= 1
		RayIgnore:Reset()

		HUDController.WeaponReset()
		WeaponState.BipodCFrame = CFrame.new()
		
		if Config.ReplicatedLaser then
			Event.SVLaser:FireServer(nil , 2, nil, false, WeaponTool)
		end
	end
end

function CreateShell(ammo_type, ejection_origin)
	-- if not WeaponData then return end
	Event.Shell:FireServer(ammo_type, ejection_origin.WorldCFrame, WeaponData.EjectionOverride)
end

function EjectShellCasing()
	if WeaponData.ShellEjectionMod and WeaponData.ShootType < 4 then
		if Engine.AmmoModels:FindFirstChild(WeaponData.BulletType) then
			CreateShell(WeaponData.BulletType, WeaponInHand.Handle.Chamber)
		else
			CreateShell("Default", WeaponInHand.Handle.Chamber)
		end
	end
end

Event.Shell.OnClientEvent:Connect(function(ammo_type, ejection_cframe, force_override)
	local casing_container = ACS_Workspace:WaitForChild("Casings")
	local max_casing_amount = Config.ShellLimit

	local distance = (Character.UpperTorso.Position - ejection_cframe.Position).Magnitude
	local ammo_model_folder
	
	if Engine.AmmoModels:FindFirstChild(ammo_type) then
		ammo_model_folder = Engine.AmmoModels:FindFirstChild(ammo_type)
	else
		ammo_model_folder = Engine.AmmoModels.Default
	end
	
	local ejection_config = require(ammo_model_folder.EjectionForce)
	
	if distance < 100 then
		local casing_instance = ammo_model_folder.Casing:Clone()
		casing_instance.Parent = casing_container
		casing_instance.Anchored = false
		casing_instance.CanCollide = true
		casing_instance.CFrame = ejection_cframe * CFrame.Angles(0, math.rad(0), 0)
		casing_instance.Name = ammo_type .. "_Casing"
		casing_instance.CastShadow = false
		casing_instance.CustomPhysicalProperties = ejection_config.PhysicalProperties
		casing_instance.CollisionGroup = "Casings"
		
		local force_attachment = Instance.new("Attachment")
		force_attachment.Position = ejection_config.ForcePoint
		force_attachment.Parent = casing_instance
		
		local ejection_force = Instance.new("VectorForce")
		ejection_force.Visible = false
		
		if force_override then
			ejection_force.Force = force_override
		else
			ejection_force.Force = ejection_config.CalculateForce()
		end
		
		ejection_force.Attachment0 = force_attachment
		ejection_force.Parent = casing_instance

		Debris:AddItem(force_attachment, 0.01)
		
		if #casing_container:GetChildren() > max_casing_amount then
			local children = casing_container:GetChildren()
			if #children > 0 then
				children[math.random(math.max(1, math.floor(#children / 2)), #children)]:Destroy()
			end
		end
		
		if Config.ShellDespawn > 0 then
			Debris:AddItem(casing_instance, Config.ShellDespawn)
		end
		
		task.wait(0.25)
		if casing_instance and casing_instance:FindFirstChild("Drop") then
			local new_sound = casing_instance.Drop:Clone()
			new_sound.Parent = casing_instance
			new_sound.PlaybackSpeed = math.random(30, 50) / 40
			new_sound:Play()
			new_sound.PlayOnRemove = true
			new_sound:Destroy()
			
			Debris:AddItem(new_sound, 2)
		end
	end
end)

function WeaponController.Shoot()
	if not WeaponData and not WeaponInHand then return end

	-- Cache properties
	local weapon_type = WeaponData.Type
	local weapon_shoot_type = WeaponData.ShootType
	local weapon_shoot_rate = WeaponData.ShootRate
	local weapon_data = WeaponData
	local attachment_flags = AttachmentManager.Flags
	
	if weapon_data and weapon_type == "Gun" and not WeaponState.IsShooting and not WeaponState.IsReloading then
		if WeaponState.IsReloading or PlayerStateManager.RunKeyDown or WeaponState.SafeMode or WeaponState.IsCheckingAmmo then
			PlayerStateManager.IsMouseButton1Down = false
			return
		end

		if Ammo <= 0 or weapon_data.Jammed then
			WeaponInHand.Handle.Click:Play()
			PlayerStateManager.IsMouseButton1Down = false
			return
		end

		PlayerStateManager.IsMouseButton1Down = true
		WeaponState.IsHipFiring = true
		ApplyMouseSensitivity()

		task.delay(0, function()
			if weapon_data and weapon_shoot_type == 1 then -- SEMI --
				WeaponState.IsShooting = true

				Event.Weapon.Shoot:FireServer(attachment_flags.Suppressor, attachment_flags.FlashHider)
				EjectShellCasing()
				
				for _ =  1, WeaponData.Bullets do
					Thread:Spawn(BallisticsManager.SpawnProjectile)
				end
			
				Ammo = Ammo - 1
				WeaponState.Ammo = Ammo
				WeaponData.AmmoInGun = Ammo
				
				WeaponFX()
				JamChance()
				HUDController.UpdateGui()
				
				Thread:Spawn(RecoilController.ApplyRecoilPattern)
				task.wait(60 / weapon_shoot_rate)
				WeaponState.IsShooting = false
				WeaponState.IsHipFiring = false
				
				ApplyMouseSensitivity()

			elseif weapon_data and weapon_shoot_type == 2 then -- BURST --
				for _ = 1, WeaponData.BurstShot do
					if WeaponState.IsShooting or Ammo <= 0 or PlayerStateManager.IsMouseButton1Down == false or WeaponData.Jammed then
						break
					end
					
					WeaponState.IsShooting = true
					
					Event.Weapon.Shoot:FireServer(attachment_flags.Suppressor, attachment_flags.FlashHider)
					EjectShellCasing()
					
					for _ =  1, weapon_data.Bullets do
						Thread:Spawn(BallisticsManager.SpawnProjectile)
					end
					
					Ammo = Ammo - 1
					WeaponState.Ammo = Ammo
					
					WeaponFX()
					JamChance()
					HUDController.UpdateGui()
					
					Thread:Spawn(RecoilController.ApplyRecoilPattern)
					task.wait(60 / weapon_shoot_rate)
					WeaponState.IsShooting = false
				end
				
				WeaponState.IsHipFiring = false
				ApplyMouseSensitivity()
				
			elseif weapon_data and weapon_shoot_type == 3 then -- AUTO --
				while PlayerStateManager.IsMouseButton1Down do
					if WeaponState.IsShooting or Ammo <= 0 or WeaponData.Jammed then
						break
					end
					
					WeaponState.IsShooting = true
					Event.Weapon.Shoot:FireServer(attachment_flags.Suppressor, attachment_flags.FlashHider)
					EjectShellCasing()
					
					for _ =  1, weapon_data.Bullets do
						Thread:Spawn(BallisticsManager.SpawnProjectile)
					end
					
					Ammo = Ammo - 1
					WeaponState.Ammo = Ammo
					
					WeaponFX()
					JamChance()
					HUDController.UpdateGui()
					
					Thread:Spawn(RecoilController.ApplyRecoilPattern)
					task.wait(60 / weapon_shoot_rate)
					WeaponState.IsShooting = false
				end
				
				WeaponState.IsHipFiring = false
				ApplyMouseSensitivity()
				
			elseif weapon_data and weapon_shoot_type == 4 and weapon_shoot_type == 5 then -- PUMP / BOLT Action
				WeaponState.IsShooting = true	
				Event.Weapon.Shoot:FireServer(attachment_flags.Suppressor, attachment_flags.FlashHider)
				
				for _ =  1, WeaponData.Bullets do
					Thread:Spawn(BallisticsManager.SpawnProjectile)
				end
				
				Ammo = Ammo - 1
				WeaponState.Ammo = Ammo
				
				WeaponFX()
				HUDController.UpdateGui()
				
				Thread:Spawn(RecoilController.ApplyRecoilPattern)
				
				WeaponAnimator.PlayPumpActionAnimation()
				UpdateWeaponStance()
				
				WeaponState.IsShooting = false
				WeaponState.IsHipFiring = false
				
				ApplyMouseSensitivity()
			end
		end)

	elseif weapon_data and weapon_shoot_type == "Melee" and not PlayerStateManager.RunKeyDown then
		if not WeaponState.IsShooting then
			WeaponState.IsShooting = true
			WeaponAnimator.MeleeAttackAnim()
			MeleeAttack()
			UpdateWeaponStance()
			WeaponState.IsShooting = false
		end
	end
end

function ApplyMouseSensitivity()
	if not WeaponData then return end

	if WeaponState.IsAimming then
		UIS.MouseDeltaSensitivity = (WeaponState.ADSSens / 100)
	elseif WeaponState.IsHipFiring then
		UIS.MouseDeltaSensitivity = (WeaponState.HipFireSens / 100)
	else
		UIS.MouseDeltaSensitivity = (WeaponState.CameraSens / 100)
	end

	HUDController.UpdateGui()
end

local function LensShootDarken()
	local shooting_overlay = PlayerGui.VisualFX.UI.GunFire.FireFX
	if not shooting_overlay then return end

	local darken_duration = WeaponData.LensDarkenSpeed
	if not darken_duration then return end

	local overlay_opacities = {0, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45, 0.50}
	local random_level_index = math.random(1, #overlay_opacities)
	local target_opacity = overlay_opacities[random_level_index]

	local darken_tween = TS:Create(shooting_overlay, TweenInfo.new(darken_duration), { ImageTransparency = target_opacity})
	local clear_tween = TS:Create(shooting_overlay, TweenInfo.new(1), {ImageTransparency = 1})

	local connection1, connection2
	connection1 = darken_tween.Completed:Connect(function()
		connection1:Disconnect()
		clear_tween:Play()

		connection2 = clear_tween.Completed:Connect(function()
			connection2:Disconnect()
		end)
	end)

	darken_tween:Play()
end

local ShotBlur, ShotBloom
function WeaponFX()
	local weapon_data = WeaponData
	local handle = WeaponInHand.Handle
	local chamber = handle.Chamber
	local attachment_flags = AttachmentManager.Flags
	local muzzle = handle.Muzzle

	if attachment_flags.Suppressor then
		muzzle.Supressor:Play()
		-- supressor_sound.PlaybackSpeed = supressor_sound.PlaybackSpeed + math.random(-20, 20) / 1000
	else
		muzzle.Fire:Play()
		-- fire_sound.PlaybackSpeed = fire_sound.PlaybackSpeed + math.random(-20, 20) / 1000
	end
	
	if muzzle:FindFirstChild("Echo") then
		muzzle.Echo:Play()
		-- echo_sound.PlaybackSpeed = echo_sound.PlaybackSpeed + math.random(-20, 20) / 1000
	end

	if weapon_data.FlashChance and math.random(1, 10) <= weapon_data.FlashChance and not attachment_flags.FlashHider then
		if muzzle:FindFirstChild("FlashFX") then
			muzzle["FlashFX"].Enabled = true
			task.delay(0.1, function()
				if muzzle:FindFirstChild("FlashFX") then
					muzzle["FlashFX"].Enabled = false
				end
			end)
		end

		muzzle["FlashFX[Flash]"]:Emit(10)
	end
	muzzle["Smoke"]:Emit(10)

	if weapon_data.ShootingBloom and not ShotBloom then
		ShotBloom = Instance.new("BloomEffect")
		ShotBloom.Size = weapon_data.BloomSize or 20
		ShotBloom.Threshold = weapon_data.BloomThresh or 1.5
		ShotBloom.Parent = CurrentCamera

		Debris:AddItem(ShotBloom, 0.02)
	end

	if weapon_data.ShootingBlur then
		ShotBlur = Instance.new("BlurEffect")
		ShotBlur.Size = weapon_data.ShootingBlurSize or 5
		ShotBlur.Parent = CurrentCamera

		Debris:AddItem(ShotBlur, 0.04)
	end

	LensShootDarken()

	if WeaponState.CurrentSpread then
		WeaponState.CurrentSpread = math.min(
			weapon_data.MaxSpread * AttachmentModifications.MaxSpread,
			WeaponState.CurrentSpread + weapon_data.AimInaccuracyStepAmount * AttachmentModifications.AimInaccuracyStepAmount
		)
		RecoilController.CurrentRecoilPower =  math.min(
			weapon_data.MaxRecoilPower * AttachmentModifications.MaxRecoilPower,
			RecoilController.CurrentRecoilPower + weapon_data.RecoilPowerStepAmount * AttachmentModifications.RecoilPowerStepAmount
		)
	end

	WeaponState.BulletCount += 1
	WeaponState.LastSpreadUpdate = time()

	if Ammo > 0 or not weapon_data.SlideLock then
		TS:Create(WeaponInHand.Handle.Slide, TweenInfo.new(30/weapon_data.ShootRate,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,true,0), {C0 =  weapon_data.SlideEx:inverse() }):Play()
	elseif Ammo <= 0 and weapon_data.SlideLock then
		TS:Create(WeaponInHand.Handle.Slide, TweenInfo.new(30/weapon_data.ShootRate,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0), {C0 =  weapon_data.SlideEx:inverse() }):Play()
	end

	local chamber_smoke = chamber:FindFirstChild("Smoke")
	if chamber_smoke then
		chamber_smoke:Emit(10)
	end
	
	for _, effect in pairs(chamber:GetChildren()) do
		if effect.Name == "Shell" then
			effect:Emit(1)
		end
	end
end

function Reload()
	
	if WeaponData.Type == "Gun" and StoredAmmo > 0 and (Ammo < WeaponData.Ammo or WeaponData.IncludeChamberedBullet and Ammo < WeaponData.Ammo + 1) then

		WeaponState.IsReloading = true
		WeaponState.SafeMode = false
		WeaponState.CurrentGunStance = 0
		Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance, AnimData)
		HUDController.UpdateGui()

		if WeaponData.ShellInsert then
			if Ammo > 0 then
				for _ = 1,WeaponData.Ammo - Ammo do
					if not WeaponData or not WeaponInHand or not WeaponTool or WeaponState.CancelReload then
						break
					end
					
					if StoredAmmo > 0 and Ammo < WeaponData.Ammo then
						if WeaponState.CancelReload then
							break
						end
						
						WeaponAnimator.PlayReloadAnimation()
						Ammo = Ammo + 1
						StoredAmmo = StoredAmmo - 1
						WeaponState.Ammo = Ammo
						WeaponState.StoredAmmo = StoredAmmo
						WeaponData.AmmoInGun = Ammo
						WeaponData.StoredAmmo = StoredAmmo
						HUDController.UpdateGui()
					end
				end
			else
				WeaponAnimator.PlayTacticalReloadAnimation()
				
				if not WeaponData or not WeaponInHand or not WeaponTool then
					WeaponState.IsReloading = false
					WeaponState.CancelReload = false
					return
				end
				
				Ammo = Ammo + 1
				StoredAmmo = StoredAmmo - 1
				WeaponState.Ammo = Ammo
				WeaponState.StoredAmmo = StoredAmmo
				WeaponData.AmmoInGun = Ammo
				WeaponData.StoredAmmo = StoredAmmo
				HUDController.UpdateGui()
				
				for _ = 1,WeaponData.Ammo - Ammo do
					if not WeaponData or not WeaponInHand or not WeaponTool or WeaponState.CancelReload then
						break
					end
					
					if StoredAmmo > 0 and WeaponData and Ammo < WeaponData.Ammo then
						if WeaponState.CancelReload then
							break
						end
						
						WeaponAnimator.PlayReloadAnimation()
						Ammo = Ammo + 1
						StoredAmmo = StoredAmmo - 1
						WeaponState.Ammo = Ammo
						WeaponState.StoredAmmo = StoredAmmo
						WeaponData.AmmoInGun = Ammo
						WeaponData.StoredAmmo = StoredAmmo
						HUDController.UpdateGui()
					end
				end
			end
		else
			if Ammo > 0 then
				WeaponAnimator.PlayReloadAnimation()
			else
				WeaponAnimator.PlayTacticalReloadAnimation()
			end
			
			if not WeaponData or not WeaponInHand or not WeaponTool then
				WeaponState.IsReloading = false
				WeaponState.CancelReload = false
				return
			end

			local mag_size = WeaponData.Ammo
			local ammo_needed = mag_size - Ammo

			if StoredAmmo < ammo_needed then
				Ammo += StoredAmmo
				StoredAmmo = 0
				WeaponState.Ammo = Ammo
				WeaponState.StoredAmmo = 0

			elseif Ammo > 0 and WeaponData.IncludeChamberedBullet then
				StoredAmmo -= ammo_needed + 1
				Ammo = mag_size + 1

				WeaponState.StoredAmmo -= ammo_needed + 1
				WeaponState.Ammo = mag_size + 1

			else
				StoredAmmo -= ammo_needed
				Ammo = mag_size

				WeaponState.StoredAmmo -= ammo_needed
				WeaponState.Ammo = mag_size
			end
		end
		
		--if WeaponData and WeaponInHand and WeaponTool then
		--	if WeaponData.Type == "Gun" and WeaponData.IsLauncher then
		--		-- Event.RepAmmo:FireServer(WeaponTool, Ammo, StoredAmmo, WeaponData.Jammed)
		--	end
		--end
		
		WeaponState.CancelReload = false
		WeaponState.IsReloading = false
		
		if WeaponData and WeaponInHand and WeaponTool then
			UpdateWeaponStance()
			HUDController.UpdateGui()
		end
	end
end

function JamChance()
	if not WeaponData or not WeaponData.CanBreak or WeaponData.Jammed or Ammo - 1 <= 0 then return end

	local Jam = math.random(1000)
	if Jam > 2 then return end

	WeaponData.Jammed = true
	WeaponInHand.Handle.Click:Play()
end

function Jammed()
	if not WeaponData or WeaponData.Type ~= "Gun" or not WeaponData.Jammed then
		return
	end

	PlayerStateManager.IsMouseButton1Down = false
	WeaponState.IsReloading = true
	WeaponState.SafeMode = false
	WeaponState.CurrentGunStance = 0
	Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance,AnimData)
	HUDController.UpdateGui()

	WeaponAnimator.JammedAnim()
	WeaponData.Jammed = false
	HUDController.UpdateGui()
	WeaponState.IsReloading = false
	UpdateWeaponStance()
end

function FireMode()
	WeaponInHand.Handle.SafetyClick:Play()
	PlayerStateManager.IsMouseButton1Down = false

	local firemode = WeaponData.FireModes
	local current_firemode = WeaponData.ShootType

	repeat
		current_firemode = current_firemode % 3 + 1
	until
		(current_firemode == 1 and firemode.Semi) or
		(current_firemode == 2 and firemode.Burst) or
		(current_firemode == 3 and firemode.Auto)
	
	WeaponData.ShootType = current_firemode
	WeaponAnimator.PlayFireModeAnimation()
	HUDController.UpdateGui()
end

function CheckAmmoCount()

	if WeaponState.IsAimming then
		WeaponState.IsAimming = false
		ToggleAimingDownSights(WeaponState.IsAimming)
	end

	if HUDController.StatusGui then
		local HUD = HUDController.StatusGui.GunHUD

		TS:Create(HUD.CMText,TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0),{TextTransparency = 0,TextStrokeTransparency = 0.75}):Play()

		if Ammo >= WeaponData.Ammo then
			HUD.CMText.Text = "Full"
		elseif Ammo > math.floor((WeaponData.Ammo)*.75) and Ammo < WeaponData.Ammo then
			HUD.CMText.Text = "Nearly full"
		elseif Ammo < math.floor((WeaponData.Ammo)*.75) and Ammo > math.floor((WeaponData.Ammo)*.5) then
			HUD.CMText.Text = "Almost half"
		elseif Ammo == math.floor((WeaponData.Ammo)*.5) then
			HUD.CMText.Text = "Half"
		elseif Ammo > math.ceil((WeaponData.Ammo)*.25) and Ammo <  math.floor((WeaponData.Ammo)*.5) then
			HUD.CMText.Text = "Less than half"
		elseif Ammo < math.ceil((WeaponData.Ammo)*.25) and Ammo > 0 then
			HUD.CMText.Text = "Almost empty"
		elseif Ammo == 0 then
			HUD.CMText.Text = "Empty"
		end

		task.delay(0.25, function()
			TS:Create(HUD.CMText,TweenInfo.new(.25,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,5),{TextTransparency = 1,TextStrokeTransparency = 1}):Play()
		end)
	end
	
	PlayerStateManager.IsMouseButton1Down 	= false
	WeaponState.SafeMode 			= false
	WeaponState.CurrentGunStance 	= 0
	
	Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance,AnimData)
	
	HUDController.UpdateGui()
	WeaponAnimator.PlayCheckAmmoAnimation()
	UpdateWeaponStance()
end

function UpdateWeaponStance()
	if PlayerStateManager.RunKeyDown then
		PlayerStateManager.IsMouseButton1Down = false
		WeaponState.CurrentGunStance = 3
		Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance,AnimData)
		WeaponAnimator.PlaySprintAnimation()
	else
		if WeaponState.IsAimming then
			WeaponState.CurrentGunStance = 2
			Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance,AnimData)
		else
			WeaponState.CurrentGunStance = 0
			Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance,AnimData)
		end
		WeaponAnimator.PlayIdleAnimation()
	end
end

function ToggleAimingDownSights(is_aimming)
	if not WeaponData and WeaponInHand then return end

	WeaponState.IsAimming = is_aimming
	if is_aimming then
		if WeaponState.SafeMode then
			WeaponState.SafeMode = false
			WeaponState.CurrentGunStance = 0
			WeaponAnimator.PlayIdleAnimation()
			HUDController.UpdateGui()
		end

		if WeaponData.AimBlur or Config.ForceAimBlur then
			PlayerGui.VisualFX.UI.GunFire.Overlay.Visible = true
		end

		ApplyMouseSensitivity()
		WeaponInHand.Handle.AimDown:Play()

		WeaponState.CurrentGunStance = 2
		Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance, AnimData)
		CrosshairController:SetAimingState(true)

	else
		ApplyMouseSensitivity()
		WeaponInHand.Handle.AimUp:Play()
		PlayerGui.VisualFX.UI.GunFire.Overlay.Visible = false

		WeaponState.CurrentGunStance = 0
		Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance,AnimData)
		CrosshairController:SetAimingState(false)
	end
end

function ToggleAimPoint()
	if WeaponState.IsAimming then
		if WeaponState.CurrentAimPartMode == 1 then
			WeaponState.CurrentAimPartMode = 2
			if WeaponInHand:FindFirstChild('AimPart2') then
				WeaponState.CurrentAimPart = WeaponInHand:FindFirstChild('AimPart2')
			end 
		else
			WeaponState.CurrentAimPartMode = 1
			WeaponState.CurrentAimPart = WeaponInHand:FindFirstChild('AimPart')
		end
	end
end

function CookGrenade()
	if WeaponState.IsGrenadeActionInProgress then return end
	WeaponState.IsGrenadeActionInProgress = true
	WeaponAnimator.PlayGrenadeReadyAnimation()

	repeat
        task.wait()
    until not WeaponState.IsCookingGrenade
end

function ThrowGrenade()
	if not WeaponTool and not WeaponData or not WeaponState.IsGrenadeActionInProgress then return end
	local SKP_02 = PlayerStateManager.PlayerSessionId .. "-" .. Player.UserId
	WeaponAnimator.PlayGrenadeThrowAnimation()
	if not WeaponTool or not WeaponData then return end
	Event.Grenade:FireServer(WeaponTool, WeaponData, CurrentCamera.CFrame, CurrentCamera.CFrame.LookVector, WeaponState.GrenadeThrowPower, SKP_02)
	WeaponController.UnequipWeapon()
end

function CycleThrowPower()
	if WeaponState.GrenadeThrowPower >= 150 then
		WeaponState.GrenadeThrowPower = 100
		HUDController.StatusGui.GrenadeForce.Text = "Mid Throw"
	elseif WeaponState.GrenadeThrowPower >= 100 then
		WeaponState.GrenadeThrowPower = 50
		HUDController.StatusGui.GrenadeForce.Text = "Low Throw"
	elseif WeaponState.GrenadeThrowPower >= 50 then
		WeaponState.GrenadeThrowPower = 150
		HUDController.StatusGui.GrenadeForce.Text = "High Throw"
	end
end

function MeleeAttack()
	local raycast_origin 	 = CurrentCamera.CFrame.Position
	local raycast_direction  = CurrentCamera.CFrame.LookVector * WeaponData.BladeRange

	local raycast_params, melee_slot = ObjectPool.Acquire("Melee")
	if not raycast_params then return end

	local local_ignore = RayIgnore:BuildIgnoreList()
	raycast_params.FilterDescendantsInstances = local_ignore
	
	local raycast_result = workspace:Raycast(raycast_origin, raycast_direction, raycast_params)

	if raycast_result then
		local Hit2 = raycast_result.Instance

		if Hit2 and Hit2.Parent:IsA('Accessory') or Hit2.Parent:IsA('Hat') then
			for _,players in pairs(game.Players:GetPlayers()) do
				if players.Character then
					for _, hats in pairs(players.Character:GetChildren()) do
						if hats:IsA("Accessory") then
							RayIgnore:AddToIgnore(hats)
						end
					end
				end
			end

			ObjectPool.Release("Melee", melee_slot)
			return MeleeAttack()
		end

		if Hit2 and Hit2.Name == "Ignorable" or Hit2.Name == "Glass" or Hit2.Name == "Ignore" or Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1"  or Hit2.Parent.Name == "Arm2" then
			RayIgnore:AddToIgnore(Hit2)
			ObjectPool.Release("Melee", melee_slot)
			return MeleeAttack()
		end

		if Hit2 and Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1"  or Hit2.Parent.Name == "Arm2" then
			RayIgnore:AddToIgnore(Hit2.Parent)
			ObjectPool.Release("Melee", melee_slot)
			return MeleeAttack()
		end

		if Hit2 and (Hit2.Transparency >= 1 or Hit2.CanCollide == false) and Hit2.Name ~= 'Head' and Hit2.Name ~= 'Right Arm' and Hit2.Name ~= 'Left Arm' and Hit2.Name ~= 'Right Leg' and Hit2.Name ~= 'Left Leg' and Hit2.Name ~= "UpperTorso" and Hit2.Name ~= "LowerTorso" and Hit2.Name ~= "RightUpperArm" and Hit2.Name ~= "RightLowerArm" and Hit2.Name ~= "RightHand" and Hit2.Name ~= "LeftUpperArm" and Hit2.Name ~= "LeftLowerArm" and Hit2.Name ~= "LeftHand" and Hit2.Name ~= "RightUpperLeg" and Hit2.Name ~= "RightLowerLeg" and Hit2.Name ~= "RightFoot" and Hit2.Name ~= "LeftUpperLeg" and Hit2.Name ~= "LeftLowerLeg" and Hit2.Name ~= "LeftFoot" and Hit2.Name ~= 'Armor' and Hit2.Name ~= 'EShield' then
			RayIgnore:AddToIgnore(Hit2)
			ObjectPool.Release("Melee", melee_slot)
			return MeleeAttack()
		end
	end
	
	if not raycast_result then
		ObjectPool.Release("Melee", melee_slot)
		return
	end

	local found_human, target_humanoid = Util.CheckForHumanoid(raycast_result.Instance)
	
	local current_ignore = RayIgnore:BuildIgnoreList()
	Hitmarker.HitEffect(current_ignore, raycast_result.Position, raycast_result.Instance , raycast_result.Normal, raycast_result.Material)
	Event.HitEffect:FireServer(raycast_result.Position, raycast_result.Instance , raycast_result.Normal, raycast_result.Material)

	local hit_part = raycast_result.Instance

	if found_human == true and target_humanoid.Health > 0 then
		local SKP_02 = PlayerStateManager.PlayerSessionId.."-"..Player.UserId

		if hit_part.Name == "Head" or hit_part.Parent.Name == "Top" or hit_part.Parent.Name == "Headset" or hit_part.Parent.Name == "Olho" or hit_part.Parent.Name == "Face" or hit_part.Parent.Name == "Numero" then
			Thread:Spawn(function()
				Event.Damage:InvokeServer(WeaponTool, target_humanoid, 0, 1, WeaponData, AttachmentModifications, nil, nil, SKP_02)	
			end)

		elseif hit_part.Name == "Torso" or hit_part.Name == "UpperTorso" or hit_part.Name == "LowerTorso" or hit_part.Parent.Name == "Chest" or hit_part.Parent.Name == "Waist" or hit_part.Name == "RightUpperArm" or hit_part.Name == "RightLowerArm" or hit_part.Name == "RightHand" or hit_part.Name == "LeftUpperArm" or hit_part.Name == "LeftLowerArm" or hit_part.Name == "LeftHand" then
			Thread:Spawn(function()
				Event.Damage:InvokeServer(WeaponTool, target_humanoid, 0, 2, WeaponData, AttachmentModifications, nil, nil, SKP_02)	
			end)

		elseif hit_part.Name == "Right Arm" or hit_part.Name == "Right Leg" or hit_part.Name == "Left Leg" or hit_part.Name == "Left Arm" or hit_part.Name == "RightUpperLeg" or hit_part.Name == "RightLowerLeg" or hit_part.Name == "RightFoot" or hit_part.Name == "LeftUpperLeg" or hit_part.Name == "LeftLowerLeg" or hit_part.Name == "LeftFoot" then
			Thread:Spawn(function()
				Event.Damage:InvokeServer(WeaponTool, target_humanoid, 0, 3, WeaponData, AttachmentModifications, nil, nil, SKP_02)	
			end)

		end
	end

	ObjectPool.Release("Melee", melee_slot)
	return nil
end

return WeaponController