repeat
	task.wait()
until game.Players.LocalPlayer.Character

local RS 				= game:GetService("ReplicatedStorage")
local UIS 				= game:GetService("UserInputService")
local TS 				= game:GetService('TweenService')
local Run 				= game:GetService("RunService")
local Players 			= game:GetService("Players")
local Debris 			= game:GetService("Debris")

local ACS_Workspace 	= workspace:WaitForChild("ACS_WorkSpace")
local Engine 			= RS:WaitForChild("ACS_Engine")

-- ACS Folders
local Essential 		= Engine:WaitForChild("Essential")
local GameRules			= Engine:WaitForChild("GameRules")
local Modules 			= Engine:WaitForChild("Modules")
local Event 			= Engine:WaitForChild("Events")
local HUD 				= Engine:WaitForChild("HUD")
local FX				= Engine:WaitForChild("FX")
local SoundFX  			= FX:WaitForChild("SoundFX")

local ClientMods    = Modules:WaitForChild("Client")
local WeaponMods 	= Modules:WaitForChild("Weapon")
local CoreMods  	= Modules:WaitForChild("Core")

local Config		= require(GameRules:WaitForChild("Config"))
local SpringMod 	= require(Modules:WaitForChild("Spring"))
local Thread 		= require(Modules:WaitForChild("Thread"))

-- Core Modules
local ObjectPool	= require(CoreMods:WaitForChild("ObjectPool"))
local RayIgnore  	= require(CoreMods:WaitForChild("RayIgnore"))

-- Client Modules
local InputBindingController= require(ClientMods:WaitForChild("InputBindingController"))
local PlayerStateManager	= require(ClientMods:WaitForChild("PlayerStateManager"))
local PostureController 	= require(ClientMods:WaitForChild("PostureController"))
local CameraController 		= require(ClientMods:WaitForChild("CameraController"))
local ViewModelManager 	 	= require(ClientMods:WaitForChild("ViewModelManager"))
local WeaponAnimator 		= require(ClientMods:WaitForChild("WeaponAnimator"))
local HUDController 		= require(ClientMods:WaitForChild("HUDController"))
local InputSystem   		= require(ClientMods:WaitForChild("InputSystem"))
local CrosshairController   = require(ClientMods:WaitForChild("CrosshairController"))

-- Weapon Modules
local WeaponController  = require(WeaponMods:WaitForChild("WeaponController"))
local RecoilController 	= require(WeaponMods:WaitForChild("RecoilController"))
local WeaponRegistry	= require(WeaponMods:WaitForChild("WeaponRegistry"))
local WeaponState		= require(WeaponMods:WaitForChild("WeaponState"))
local AttachmentManager 		= require(WeaponMods:WaitForChild("AttachmentManager"))

local Player 		= Players.LocalPlayer
local PlayerGui 	= Player.PlayerGui
local Character 	= Player.Character or Player.CharacterAdded:Wait()
local Humanoid 		= Character:WaitForChild('Humanoid')
local PlayerMouse 	= Player:GetMouse()
local CurrentCamera = workspace.CurrentCamera

-- Current weapon preferences
local WeaponInHand, WeaponTool, WeaponData, AnimData = nil, nil, nil, nil
local Ammo, StoredAmmo = nil, nil

WeaponRegistry.Changed:Connect(function(event_type, data)
    if event_type == "Equipped" then
		WeaponInHand = data.weapon_in_hand
        WeaponTool = data.weapon_tool
		WeaponData = data.weapon_data
		AnimData = data.anim_data

		if WeaponData then
			Ammo = WeaponData.AmmoInGun
			StoredAmmo = WeaponData.StoredAmmo
		end
        
    elseif event_type == "Unequipped" then
        WeaponInHand = nil
        WeaponTool = nil
		WeaponData = nil
		AnimData = nil
		Ammo = nil
		StoredAmmo = nil
    end
end)

-- Gui
local PlayerSessionId = Event.AcessId:InvokeServer(Player.UserId)
PlayerStateManager.PlayerSessionId = PlayerSessionId

-- Character states
local NVG 					= false
local NVGdebounce 			= false

local NearZ 		= CFrame.new(0,0,-.5)

local AttachmentModifications = AttachmentManager.Data

local ModStorageFolder 	= PlayerGui:FindFirstChild('ModStorage') or Instance.new('Folder')
ModStorageFolder.Parent = PlayerGui
ModStorageFolder.Name 	= 'ModStorage'

HUDController.StatusGui = HUD:WaitForChild("StatusUI"):Clone()
HUDController.StatusGui.Parent = PlayerGui

local BloodScreen 		= TS:Create(HUDController.StatusGui.Efeitos.Health, TweenInfo.new(1,Enum.EasingStyle.Circular,Enum.EasingDirection.InOut,-1,true), {Size =  UDim2.fromScale(1.2,1.4)})
local BloodScreenLowHP 	= TS:Create(HUDController.StatusGui.Efeitos.LowHealth, TweenInfo.new(1,Enum.EasingStyle.Circular,Enum.EasingDirection.InOut,-1,true), {Size =  UDim2.fromScale(1.2,1.4)})

local Crosshair = HUDController.StatusGui.Crosshair
CrosshairController:Initialize(Crosshair, PlayerMouse, Humanoid)

local SwaySpring = SpringMod.new(Vector3.new())
SwaySpring.d = .25
SwaySpring.s = 20

--// Char Parts
local HumanoidRootPart 	= Character:WaitForChild("HumanoidRootPart")

local function RegisterPool(pool_name, create_function, reset_function, default_size)
	pcall(function()
		ObjectPool.Register(pool_name, create_function, reset_function, default_size)
	end)
end

RegisterPool(
	"BulletTrace",
	function()
		local raycast_params = RaycastParams.new()
		raycast_params.FilterType = Enum.RaycastFilterType.Exclude
		raycast_params.IgnoreWater = true
		return raycast_params
	end,
	function(raycast_params)
		raycast_params.FilterDescendantsInstances = {}
	end,
	20
)

RegisterPool(
	"WeaponCollision",
	function()
		local raycast_params = RaycastParams.new()
		raycast_params.FilterType  = Enum.RaycastFilterType.Exclude
		raycast_params.IgnoreWater = true
		return raycast_params
	end,
	function(raycast_params)
		raycast_params.FilterDescendantsInstances = {}
	end,
	10
)

RegisterPool(
	"Melee",
	function()
		local raycast_params = RaycastParams.new()
		raycast_params.FilterType  = Enum.RaycastFilterType.Exclude
		raycast_params.IgnoreWater = true
		return raycast_params
	end,
	function(raycast_params)
		raycast_params.FilterDescendantsInstances = {}
	end,
	5
)

RegisterPool(
	"LaserTrace",
	function()
		local laser_params = RaycastParams.new()
		laser_params.FilterType = Enum.RaycastFilterType.Exclude
		laser_params.IgnoreWater = true
		laser_params.RespectCanCollide = true
		return laser_params
	end,
	function(laser_params)
		laser_params.FilterDescendantsInstances = {}
	end,
	5
)

RegisterPool(
	"BipodTrace",
	function()
		local bipod_trace = RaycastParams.new()
		bipod_trace.FilterType = Enum.RaycastFilterType.Exclude
		bipod_trace.IgnoreWater = true
		bipod_trace.RespectCanCollide = true
		return bipod_trace
	end,
	function(bipod_trace)
		bipod_trace.FilterDescendantsInstances = {}
	end,
	5
)

-- Initial camera setup
CameraController.InitialCameraSetup(Character)

if Config.TeamTags then
	local tag = Essential.TeamTag:Clone()
	tag.Parent = Character
	tag.Disabled = false
end

game:GetService("RunService"):BindToRenderStep("Camera Update", 200, CameraController.UpdateLean)

----------//KeyBinds\\----------

InputBindingController.BindMovementActions()
WeaponController.WeaponListeners()

----------//KeyBinds\\----------

----------//Gun System\\----------
local PendingTool = nil
Character.ChildAdded:Connect(function(tool)
	if not tool:IsA("Tool") then return end
	if Humanoid.Health <= 0 then return end
	if WeaponState.IsWeaponEquipped then return end
	
	local weapon_settings_module = tool:FindFirstChild("ACS_Settings")
	if not weapon_settings_module then return end
	
	local weapon_settings = require(weapon_settings_module :: ModuleScript)
	local weapon_type = weapon_settings.Type
	
	if weapon_type ~= "Gun" and weapon_type ~= "Melee" and weapon_type ~= "Grenade" then
		return
	end
	
	if Humanoid.Sit and Humanoid.SeatPart and Humanoid.SeatPart:IsA("VehicleSeat") then
		return
	end
	
	PendingTool = tool
	
	if not WeaponState.IsWeaponEquipped then
		WeaponController.EquipWeapon(tool)
	end
end)

Character.ChildRemoved:Connect(function(tool)
	if tool == WeaponTool then
		if WeaponState.IsWeaponEquipped then
			WeaponController.UnequipWeapon()
		end
	end
end)

Humanoid.Running:Connect(function(speed)
	PlayerStateManager.CharacterSpeed = speed
	if speed > 0.1 then
		PlayerStateManager.IsRunning = true
	else
		PlayerStateManager.IsRunning = false
	end
end)

Humanoid.Swimming:Connect(function(speed)
	if PlayerStateManager.IsSwimming then
		PlayerStateManager.CharacterSpeed = speed
		if speed > 0.1 then
			PlayerStateManager.IsRunning = true
		else
			PlayerStateManager.IsRunning = false
		end
	end
end)

Humanoid.Died:Connect(function(speed)
	TS:Create(Character.Humanoid, TweenInfo.new(1), {CameraOffset = Vector3.new(0,0,0)} ):Play()
	PlayerStateManager.ChangeStance = false

	PostureController.SetStandingStance()

	PlayerStateManager.Stances = 0
	PlayerStateManager.LeanDirection = 0
	PlayerStateManager.CameraX = 0
	PlayerStateManager.CameraY = 0

	CameraController.ApplyLeanOffset()

	Event.NVG:Fire(false)
	InputSystem.ClearAll()
	CrosshairController:Destroy()
	WeaponRegistry:ClearWeaponData()
	PlayerStateManager.Reset()
	ViewModelManager:Clear()
	WeaponAnimator.Reset()
end)

Player.CharacterAdded:Connect(function(new_character)
	Character = new_character
	Humanoid = Character:WaitForChild("Humanoid")
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	PlayerMouse = Player:GetMouse()
	CurrentCamera = workspace.CurrentCamera

	Humanoid.CharacterAppearanceLoaded:Wait()

	InputBindingController.BindMovementActions()

	CameraController.InitialCameraSetup(Character)
end)

Humanoid.Seated:Connect(function(IsSeated, Seat)
	if IsSeated and Seat and (Seat:IsA("VehicleSeat")) then
		WeaponController.UnequipWeapon()
		Humanoid:UnequipTools()
		PlayerStateManager.CanLean = false
		Player.CameraMaxZoomDistance = Config.VehicleMaxZoom
	else
		Player.CameraMaxZoomDistance = game.StarterPlayer.CameraMaxZoomDistance
	end

	if IsSeated  then
		PlayerStateManager.IsSitting = true
		PlayerStateManager.Stances = 0
		PlayerStateManager.LeanDirection = 0
		PlayerStateManager.CameraX = 0
		PlayerStateManager.CameraY = 0

		PostureController.SetStandingStance()
		CameraController.ApplyLeanOffset()
	else
		PlayerStateManager.IsSitting = false
		PlayerStateManager.CanLean = true
	end
end)

Humanoid.Changed:Connect(function(property)
	if Config.AntiBunnyHop then
		if property == "Jump" and Humanoid.Sit == true and Humanoid.SeatPart ~= nil then
			Humanoid.Sit = false
		elseif property == "Jump" and Humanoid.Sit == false then
			if PlayerStateManager.JumpDelay then
				Humanoid.Jump = false
				return false
			end
			PlayerStateManager.JumpDelay = true
			task.delay(0, function()
				task.wait(Config.JumpCoolDown)
				PlayerStateManager.JumpDelay = false
			end)
		end
	end
end)

Humanoid.StateChanged:Connect(function(old, state)
	if state == Enum.HumanoidStateType.Swimming then
		PlayerStateManager.IsSwimming = true
		PlayerStateManager.Stances = 0
		PlayerStateManager.LeanDirection = 0
		PlayerStateManager.CameraX = 0
		PlayerStateManager.CameraY = 0
		PostureController.SetStandingStance()
		CameraController.ApplyLeanOffset()
	else
		PlayerStateManager.IsSwimming = false
	end

	if Config.EnableFallDamage then
		if state == Enum.HumanoidStateType.Freefall and not PlayerStateManager.IsFalling then
			PlayerStateManager.IsFalling = true
			local curVel = 0
			local peak = 0

			while PlayerStateManager.IsFalling do
				curVel = HumanoidRootPart.AssemblyLinearVelocity.Magnitude
				peak = peak + 1
				Thread:Wait()
			end
			local damage = (curVel - (Config.MaxVelocity)) * Config.DamageMult
			if damage > 5 and peak > 20 then
				local SKP_02 = PlayerSessionId .. "-" .. Player.UserId

				RecoilController.CameraSpring:accelerate(Vector3.new(-damage/20, 0, math.random(-damage, damage)/5))
				SwaySpring:accelerate(Vector3.new( math.random(-damage, damage)/5, damage/5,0))

				local hurtSound = SoundFX.FallDamage:Clone()
				hurtSound.Parent = PlayerGui
				hurtSound.Volume = damage/Humanoid.MaxHealth
				hurtSound:Play()
				Debris:AddItem(hurtSound,hurtSound.TimeLength)

				Event.Damage:InvokeServer(nil, nil, nil, nil, nil, nil, true, damage, SKP_02)

			end
		elseif state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Dead then
			PlayerStateManager.IsFalling = false
			SwaySpring:accelerate(Vector3.new(0, 2.5, 0))
		end
	end
end)

PlayerMouse.WheelBackward:Connect(function() -- fires when the wheel goes forwards
	if WeaponState.IsWeaponEquipped and not WeaponState.IsCheckingAmmo and not WeaponState.IsAimming and not WeaponState.IsReloading and not PlayerStateManager.RunKeyDown and WeaponAnimator.IsAnimationPlaying and WeaponData.Type == "Gun" then
		PlayerStateManager.IsMouseButton1Down = false
		if WeaponState.CurrentGunStance == 0 then
			WeaponState.SafeMode = true
			WeaponState.CurrentGunStance = -1
			HUDController.UpdateGui()
			Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance, AnimData)
			WeaponAnimator.LowReady()
		elseif WeaponState.CurrentGunStance == -1 then
			WeaponState.SafeMode = true
			WeaponState.CurrentGunStance = -2
			HUDController.UpdateGui()
			Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance, AnimData)
			WeaponAnimator.Patrol()
		elseif WeaponState.CurrentGunStance == 1 then
			WeaponState.SafeMode = false
			WeaponState.CurrentGunStance = 0
			HUDController.UpdateGui()
			Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance, AnimData)
			WeaponAnimator.PlayIdleAnimation()
		end
	end
end)

PlayerMouse.WheelForward:Connect(function() -- fires when the wheel goes backwards

	if WeaponState.IsWeaponEquipped and not WeaponState.IsCheckingAmmo and not WeaponState.IsAimming and not WeaponState.IsReloading and not PlayerStateManager.RunKeyDown and WeaponAnimator.IsAnimationPlaying and WeaponData.Type == "Gun" then
		PlayerStateManager.IsMouseButton1Down = false
		if WeaponState.CurrentGunStance == 0 then
			WeaponState.SafeMode = true
			WeaponState.CurrentGunStance = 1
			HUDController.UpdateGui()
			Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance,AnimData)
			WeaponAnimator.HighReady()
		elseif WeaponState.CurrentGunStance == -1 then
			WeaponState.SafeMode = false
			WeaponState.CurrentGunStance = 0
			HUDController.UpdateGui()
			Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance,AnimData)
			WeaponAnimator.PlayIdleAnimation()
		elseif WeaponState.CurrentGunStance == -2 then
			WeaponState.SafeMode = true
			WeaponState.CurrentGunStance = -1
			HUDController.UpdateGui()
			Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance,AnimData)
			WeaponAnimator.LowReady()
		end
	end
end)

script.Parent:GetAttributeChangedSignal("Injured"):Connect(function()
	local valor = script.Parent:GetAttribute("Injured")

	if valor and PlayerStateManager.RunKeyDown then
		PlayerStateManager.RunKeyDown 	= false
		PostureController.SetStandingStance()
		if not WeaponState.IsCheckingAmmo and not WeaponState.IsReloading and WeaponData and WeaponData.Type ~= "Grenade" and (WeaponState.CurrentGunStance == 0 or WeaponState.CurrentGunStance == 2 or WeaponState.CurrentGunStance == 3) then
			WeaponState.CurrentGunStance = 0
			Event.CurrentGunStance:FireServer(WeaponState.CurrentGunStance,AnimData)
			WeaponAnimator.PlayIdleAnimation()
		end
	end

	if PlayerStateManager.Stances == 0 then
		PostureController.SetStandingStance()
	elseif PlayerStateManager.Stances == 1 then
		PostureController.SetCrouchingStance()
	end

end)

----------//Gun System\\----------

----------//Health HUD\\----------
BloodScreen:Play()
BloodScreenLowHP:Play()
Humanoid.HealthChanged:Connect(function(health)
	local effect = HUDController.StatusGui.Efeitos
	effect.Health.ImageTransparency = ((health - (Humanoid.MaxHealth / 2)) / (Humanoid.MaxHealth / 2))
	effect.LowHealth.ImageTransparency = (health / (Humanoid.MaxHealth / 2))
end)
----------//Health HUD\\----------

----------//Render Functions\\----------

function UpdateWeaponCollision()
    if not WeaponInHand or not WeaponState.IsWeaponEquipped or WeaponState.IsAimming then
        WeaponState.WeaponCollisionCF = CFrame.new()
        WeaponState.IsWeaponColliding = false
        return
    end
    
    local handle = WeaponInHand:FindFirstChild("Handle")
    if not handle then return end
    
    local gun_size = WeaponState.CurrentWeaponSize
    local camera_pos = CurrentCamera.CFrame.Position

    local weapon_collision_params, weapon_collision = ObjectPool.Acquire("WeaponCollision")
	if not weapon_collision_params then return end

    local ignore_list = RayIgnore:BuildIgnoreList()
    weapon_collision_params.FilterDescendantsInstances = ignore_list
    
    local ray1 = workspace:Raycast(camera_pos, handle.Position - camera_pos, weapon_collision_params)
    local ray2 = workspace:Raycast(handle.Position, handle.CFrame.LookVector * gun_size, weapon_collision_params)
	ObjectPool.Release("WeaponCollision", weapon_collision)
    
    local pushback_distance = 0 -- DEBUG -2.5
    local collision_detected = false
    
    if ray1 and (handle.Position - ray1.Position).Magnitude < gun_size then
        pushback_distance = (((handle.Position - ray1.Position).Magnitude / gun_size) - 1) * -3
        collision_detected = true
        
    elseif ray2 and (handle.Position - ray2.Position).Magnitude < gun_size then
        pushback_distance = (((handle.Position - ray2.Position).Magnitude / gun_size) - 1) * -2
        collision_detected = true
    end
    
    local pushback_cframe = CFrame.new(0, 0, pushback_distance)
    
    local speed = collision_detected and 0.3 or 0.1
    WeaponState.WeaponCollisionCF = WeaponState.WeaponCollisionCF:Lerp(pushback_cframe, speed)
    WeaponState.IsWeaponColliding = collision_detected
end

Run.RenderStepped:Connect(function(step)
	if WeaponState.IsWeaponEquipped then
		RecoilController.ApplyWeaponRecoil()
	end

	RecoilController.ApplyCameraRecoil()

	--============================
	-- WIP
	-- local distance = (CurrentCamera.CFrame.Position - CurrentCamera.Focus.Position).Magnitude
    -- local isFirstPerson = distance < 1

    -- PlayerStateManager.IsFirstPersonView = isFirstPerson
    -- PlayerStateManager.IsThirdPersonView = not isFirstPerson
	--============================

	-- if ViewModelManager.ViewModel and ViewModelManager.LArm and ViewModelManager.RArm and WeaponInHand then
	if ViewModelManager.ViewModel and ViewModelManager.LA and ViewModelManager.RA and WeaponInHand then

		local mouse_delta = UIS:GetMouseDelta()
		SwaySpring:accelerate(Vector3.new(mouse_delta.X / 60, mouse_delta.Y / 60, 0))

		local swayVec = SwaySpring.p
		local TSWAY = swayVec.z
		local XSSWY = swayVec.X
		local YSSWY = swayVec.Y
		local Sway = CFrame.Angles(YSSWY,XSSWY,XSSWY)

		if AttachmentManager.Flags.HasBipodAttachment and AttachmentManager.Instances.UnderBarrelAtt.Main then
			local origin = AttachmentManager.Instances.UnderBarrelAtt.Main.Position
			local direction = Vector3.new(0, -1.75, 0)
			
			local bipod_params, bipod_slot = ObjectPool.Acquire("BipodTrace")
			if not bipod_params then return end
			bipod_params.FilterDescendantsInstances = RayIgnore:BuildIgnoreList()

			local raycast_result = workspace:Raycast(origin, direction, bipod_params)
			ObjectPool.Release("BipodTrace", bipod_slot)

			if raycast_result then
				AttachmentManager.Flags.IsBipodDeployable = true
				if AttachmentManager.Flags.IsBipodDeployable and AttachmentManager.Flags.BipodActive and not PlayerStateManager.RunKeyDown and (WeaponState.CurrentGunStance == 0 or WeaponState.CurrentGunStance == 2) then
					TS:Create(HUDController.StatusGui.GunHUD.Att.Bipod, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = .123}):Play()
					if not WeaponState.IsAimming then
						WeaponState.BipodCFrame = WeaponState.BipodCFrame:Lerp(CFrame.new(0,(((AttachmentManager.Instances.UnderBarrelAtt.Main.Position - raycast_result).magnitude)-1) * (-1.5), 0),.2)
					else
						WeaponState.BipodCFrame = WeaponState.BipodCFrame:Lerp(CFrame.new(),.2)
					end				

				else
					AttachmentManager.Flags.BipodActive = false
					WeaponState.BipodCFrame = WeaponState.BipodCFrame:Lerp(CFrame.new(),.2)
					TS:Create(HUDController.StatusGui.GunHUD.Att.Bipod, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,255,0), ImageTransparency = .5}):Play()
				end
			else
				AttachmentManager.Flags.BipodActive = false
				AttachmentManager.Flags.IsBipodDeployable = false
				WeaponState.BipodCFrame = WeaponState.BipodCFrame:Lerp(CFrame.new(),.2)
				TS:Create(HUDController.StatusGui.GunHUD.Att.Bipod, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,0,0), ImageTransparency = .5}):Play()
			end
		end

		UpdateWeaponCollision()
		ViewModelManager.AnimBase.CFrame = CurrentCamera.CFrame * NearZ * WeaponState.BipodCFrame * WeaponState.MainCFrame * WeaponState.GunBobCFrame * WeaponState.AimCFrame * WeaponState.WeaponCollisionCF

		if not AnimData.GunModelFixed then
			WeaponInHand:SetPrimaryPartCFrame(
				ViewModelManager.ViewModel.PrimaryPart.CFrame
					* WeaponState.GunCFrame
			)
		end

		if PlayerStateManager.IsRunning then
			local speed_factor = PlayerStateManager.CharacterSpeed / 10
			local current_time = tick()
			local math_sin = math.sin
			local math_cos = math.cos
			local math_rad = math.rad
			local sin8 = math_sin(current_time * 8)
			local cos8 = math_cos(current_time * 8)
			local cos16 = math_cos(current_time * 16)
			local sin16 = math_sin(current_time * 16)

			WeaponState.GunBobCFrame = WeaponState.GunBobCFrame:Lerp(CFrame.new(
				0.025 * speed_factor * sin8,
				0.025 * speed_factor * cos16,
				0
				) * CFrame.Angles(
					math_rad( 1 * speed_factor * sin16),
					math_rad( 1 * speed_factor * cos8), 
					math_rad(0)
				), 0.1)
		else
			local current_time = tick()
			local math_sin = math.sin
			local math_cos = math.cos

			WeaponState.GunBobCFrame = WeaponState.GunBobCFrame:Lerp(CFrame.new(
				0.005 * math_sin(current_time * 1.5),
				0.005 * math_cos(current_time * 2.5),
				0
			), 0.1)
		end

		if WeaponState.CurrentAimPart and WeaponState.IsAimming and WeaponAnimator.IsAnimationPlaying and not WeaponState.IsCheckingAmmo then
			if not NVG or WeaponInHand.AimPart:FindFirstChild("NVAim") == nil then
				if WeaponState.CurrentAimPartMode == 1 then
					TS:Create(CurrentCamera, WeaponState.AimTweenInfo, { FieldOfView = AttachmentModifications.ZoomValue }):Play()
					WeaponState.MainCFrame = WeaponState.MainCFrame:Lerp(WeaponState.MainCFrame * CFrame.new(0,0,-.5) * RecoilController.RecoilCFrame * Sway:Inverse() * WeaponState.CurrentAimPart.CFrame:toObjectSpace(CurrentCamera.CFrame), 0.2)
				else
					TS:Create(CurrentCamera, WeaponState.AimTweenInfo, { FieldOfView = AttachmentModifications.Zoom2Value }):Play()
					WeaponState.MainCFrame = WeaponState.MainCFrame:Lerp(WeaponState.MainCFrame * CFrame.new(0,0,-.5) * RecoilController.RecoilCFrame * Sway:Inverse() * WeaponState.CurrentAimPart.CFrame:toObjectSpace(CurrentCamera.CFrame), 0.2)
				end
			else
				TS:Create(CurrentCamera, WeaponState.AimTweenInfo, { FieldOfView = 70 }):Play()
				WeaponState.MainCFrame = WeaponState.MainCFrame:Lerp(WeaponState.MainCFrame * CFrame.new(0,0,-.5) * RecoilController.RecoilCFrame * Sway:Inverse() * (WeaponInHand.AimPart.CFrame * WeaponInHand.AimPart.NVAim.CFrame):toObjectSpace(CurrentCamera.CFrame), 0.2)
			end
		else
			TS:Create(CurrentCamera, WeaponState.AimTweenInfo, { FieldOfView = 70 }):Play()
			WeaponState.MainCFrame = WeaponState.MainCFrame:Lerp(AnimData.MainCFrame * RecoilController.RecoilCFrame * Sway:Inverse(), 0.2)   
		end

		for _, Part in pairs(WeaponInHand:GetDescendants()) do
			if Part:IsA("BasePart") and Part.Name == "SightMark" then
				local dist_scale = Part.CFrame:pointToObjectSpace(CurrentCamera.CFrame.Position) / Part.Size
				local reticle_gui = Part.SurfaceGui.Border.Scope	
				reticle_gui.Position = UDim2.fromScale(0.5 + dist_scale.x, 0.5 - dist_scale.y)	
			end
		end

		RecoilController.RecoilCFrame = RecoilController.RecoilCFrame:Lerp(CFrame.new() * CFrame.Angles( math.rad(RecoilController.RecoilSpring.p.X), math.rad(RecoilController.RecoilSpring.p.Y), math.rad(RecoilController.RecoilSpring.p.z)), 0.2)

		CrosshairController:UpdatePosition(
			PlayerMouse.X,
			PlayerMouse.Y,
			WeaponState.CurrentSpread,
			PlayerStateManager.CharacterSpeed
		)
		CrosshairController:UpdateColor()

		if WeaponState.CurrentSpread then
			local currTime = time()
			if currTime - WeaponState.LastSpreadUpdate > (60/WeaponData.ShootRate) * 2 and not WeaponState.IsShooting and WeaponState.CurrentSpread > WeaponData.MinSpread * AttachmentModifications.MinSpread then
				WeaponState.CurrentSpread = math.max(WeaponData.MinSpread * AttachmentModifications.MinSpread, WeaponState.CurrentSpread - WeaponData.AimInaccuracyDecrease * AttachmentModifications.AimInaccuracyDecrease)
			end
			if currTime - WeaponState.LastSpreadUpdate > (60/WeaponData.ShootRate) * 1.5 and not WeaponState.IsShooting and RecoilController.CurrentRecoilPower > WeaponData.MinRecoilPower * AttachmentModifications.MinRecoilPower then
				RecoilController.CurrentRecoilPower =  math.max(WeaponData.MinRecoilPower * AttachmentModifications.MinRecoilPower, RecoilController.CurrentRecoilPower - WeaponData.RecoilPowerStepAmount * AttachmentModifications.RecoilPowerStepAmount)
			end
		end

		if AttachmentManager.Flags.LaserActive and AttachmentManager.Flags.Pointer then
			local pointer = AttachmentManager.Flags.Pointer
			local beam = pointer:FindFirstChild("Beam")

			if NVG then
				pointer.Transparency = 0

				if beam then
					beam.Enabled = true
				end
			else
				if beam then
					beam.Enabled = not Config.RealisticLaser
				end

				if AttachmentManager.Flags.InfraredMode then
					pointer.Transparency = 1
				else
					pointer.Transparency = 0
				end
			end
			
			local laser_params, laser_slot = ObjectPool.Acquire("LaserTrace")
			if not laser_params then return end
			laser_params.FilterDescendantsInstances = RayIgnore:BuildIgnoreList()
			
			for _, part in pairs(WeaponInHand:GetDescendants()) do
				if part:IsA("BasePart") and part.Name == "LaserPoint" then
					local origin = part.CFrame.Position
					local direction = part.CFrame.LookVector * 1000
					
					local raycast_result = workspace:Raycast(origin, direction, laser_params)
					local hit_position = nil

					if raycast_result then
						AttachmentManager.Flags.Pointer.CFrame =  CFrame.new(raycast_result.Position, raycast_result.Position + raycast_result.Normal)
						hit_position = raycast_result.Position
					else
						AttachmentManager.Flags.Pointer.CFrame =  CFrame.new(CurrentCamera.CFrame.Position + part.CFrame.LookVector * 2000, part.CFrame.LookVector)
					end

					if Config.ReplicatedLaser then
						Event.SVLaser:FireServer(hit_position, 1, AttachmentManager.Flags.Pointer.Color, AttachmentManager.Flags.InfraredMode, WeaponTool)
					end
					break
				end
			end

			ObjectPool.Release("LaserTrace", laser_slot)
		end
	end
end)
----------//Render Functions\\----------

----------//Events\\----------
Event.Refil.OnClientEvent:Connect(function(Tool, Infinite, Stored)

	local data = require(Tool.ACS_Settings)
	local NewStored = math.min(data.MaxStoredAmmo - StoredAmmo, Stored.Value) 

	StoredAmmo = StoredAmmo + NewStored
	data.StoredAmmo = StoredAmmo

	WeaponState.StoredAmmo = StoredAmmo

	HUDController.UpdateGui()

	if not Infinite then
		Event.Refil:FireServer(Stored, NewStored)
	end

end)
----------//Events\\----------