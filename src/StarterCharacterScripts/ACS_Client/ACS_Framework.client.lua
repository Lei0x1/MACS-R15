repeat
	task.wait()
until game.Players.LocalPlayer.Character

local RS 			= game:GetService("ReplicatedStorage")
local UIS 			= game:GetService("UserInputService")
local CAS 			= game:GetService("ContextActionService")
local Run 			= game:GetService("RunService")
local TS 			= game:GetService('TweenService')
local Debris 		= game:GetService("Debris")
local Players 		= game:GetService("Players")

local ACS_Workspace = workspace:WaitForChild("ACS_WorkSpace")
local Engine 		= RS:WaitForChild("ACS_Engine")
local Event 		= Engine:WaitForChild("Events")
local Mods 			= Engine:WaitForChild("Modules")
local HUDs 			= Engine:WaitForChild("HUD")
local Essential 	= Engine:WaitForChild("Essential")
local ArmModel 		= Engine:WaitForChild("ArmModel")
local WeaponModels  = Engine:WaitForChild("WeaponModels")
local AttModels 	= Engine:WaitForChild("AttModels")
local AttModules  	= Engine:WaitForChild("AttModules")
local GameRules		= Engine:WaitForChild("GameRules")
local FX			= Engine:WaitForChild("FX")

local Config		= require(GameRules:WaitForChild("Config"))
local SpringMod 	= require(Mods:WaitForChild("Spring"))
local HitMod 		= require(Mods:WaitForChild("Hitmarker"))
local Thread 		= require(Mods:WaitForChild("Thread"))
local Util			= require(Mods:WaitForChild("Utilities"))

local player 		= Players.LocalPlayer
local Character 	= player.Character or player.CharacterAdded:Wait()
local mouse 		= player:GetMouse()
local CurrentCamera = workspace.CurrentCamera
local ACS_Client 	= Character:WaitForChild("ACS_Client")

local Equipped 		= 0
local Primary 		= ""
local Secondary 	= ""
local Grenades 		= ""

local Ammo
local StoredAmmo

-- Current weapon preferences
local WeaponInHand, WeaponTool, WeaponData, AnimData
local ViewModel, AnimPart, LArm, RArm, LArmWeld, RArmWeld, GunWeld

-- Attachment datas
local SightData, BarrelData, UnderBarrelData, OtherData

-- Combat variables
local GenerateBullet = 1
local BSpread
local RecoilPower
local LastSpreadUpdate = time()

-- Gui
local StatusGui
local SKP_01 = Event.AcessId:InvokeServer(player.UserId)

-- Crosshair positions
local CrosshairUpPos, CrosshairDownPos, CrosshairLeftPos, CrosshairRightPos = UDim2.new(),UDim2.new(),UDim2.new(),UDim2.new()

-- Character states
local CharacterSpeed 		= 0
local IsRunning 			= false
local RunKeyDown 			= false
local IsAimming 			= false
local IsShooting 			= false
local IsReloading 			= false
local Mouse1Down 			= false
local AnimDebounce 			= false
local CancelReload 			= false
local SafeMode				= false
local JumpDelay 			= false
local NVG 					= false
local NVGdebounce 			= false	
local CurrentGunStance 		= 0
local CurrentAimPartMode 	= 1

-- Attachment states
local SightAtt			= nil
local Reticle			= nil
local CurrentAimPart 	= nil
local BarrelAtt 		= nil
local Suppressor 		= false
local FlashHider 		= false
local UnderBarrelAtt	= nil
local OtherAtt 			= nil
local LaserAtt 			= false
local LaserActive		= false
local InfraredMode		= false
local InfraredEnabled	= false
local LaserDist 		= 0
local Laser 			= nil
local Pointer 			= nil
local TorchAtt 			= false
local TorchActive 		= false
local HasBipodAtt 		= false
local CanBipod 			= false
local BipodActive 		= false

-- Grenade state
local GrenadeAmmo 			= 0
local GrenadeDebounce 	= false
local CookingGrenade 	= false
local GrenadeThrowPower = 150

-- Tool state
local ToolEquip 	= false
local Sens 			= 50

local CameraSens 	= 50  	-- Default camera sensitivity
local HipFireSens   = 50  	-- Default hipfire sensitivity
local IsHipFiring 	= false -- Track if hipfiring
local ADSSens 		= 50    -- Default ADS sensitivity

local BipodCF 		= CFrame.new()
local NearZ 		= CFrame.new(0,0,-.5)

local WeaponModifications = {

	CamRecoil 	= {
		RecoilTilt 	= 1,
		RecoilUp 	= 1,
		RecoilLeft 	= 1,
		RecoilRight = 1
	}

	,GunRecoil	= {
		RecoilUp 	= 1,
		RecoilTilt 	= 1,
		RecoilLeft 	= 1,
		RecoilRight = 1
	}

	,ZoomValue 		= 70
	,Zoom2Value 	= 70
	,AimRM 			= 1
	,SpreadRM 		= 1
	,DamageMod 		= 1
	,minDamageMod 	= 1

	,MinRecoilPower 			= 1
	,MaxRecoilPower 			= 1
	,RecoilPowerStepAmount 		= 1

	,MinSpread 					= 1
	,MaxSpread 					= 1					
	,AimInaccuracyStepAmount 	= 1
	,AimInaccuracyDecrease 		= 1
	,WalkMult 					= 1
	,adsTime 					= 1		
	,MuzzleVelocity 			= 1
}  

local MainCFrame 		= CFrame.new() --weapon offset of camera
local GunCFrame  		= CFrame.new() --weapon offset of camera
local LeftArmCFrame 	= CFrame.new() --left arm offset of weapon
local RightArmCFrame 	= CFrame.new() --right arm offset of weapon
local GunBobCFrame		= CFrame.new()
local RecoilCFrame 		= CFrame.new()
local AimCFrame 		= CFrame.new()

local AimTweenInfo 		= TweenInfo.new(
	0.2,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

local Ignore_Model = { CurrentCamera, Character, ACS_Workspace.Client, ACS_Workspace.Server }

local ModStorageFolder 	= player.PlayerGui:FindFirstChild('ModStorage') or Instance.new('Folder')
ModStorageFolder.Parent = player.PlayerGui
ModStorageFolder.Name 	= 'ModStorage'

StatusGui = HUDs:WaitForChild("StatusUI"):Clone()
StatusGui.Parent = player.PlayerGui 

local BloodScreen 		= TS:Create(StatusGui.Efeitos.Health, TweenInfo.new(1,Enum.EasingStyle.Circular,Enum.EasingDirection.InOut,-1,true), {Size =  UDim2.new(1.2,0,1.4,0)})
local BloodScreenLowHP 	= TS:Create(StatusGui.Efeitos.LowHealth, TweenInfo.new(1,Enum.EasingStyle.Circular,Enum.EasingDirection.InOut,-1,true), {Size =  UDim2.new(1.2,0,1.4,0)})

local Crosshair = StatusGui.Crosshair

local RecoilSpring = SpringMod.new(Vector3.new())
RecoilSpring.d = .1
RecoilSpring.s = 20

local CameraSpring = SpringMod.new(Vector3.new())
CameraSpring.d	= .5
CameraSpring.s	= 20

local SwaySpring = SpringMod.new(Vector3.new())
SwaySpring.d = .25
SwaySpring.s = 20

local Stance = Event.Stance
local Stances = 0
local Virar = 0
local CameraX = 0
local CameraY = 0

local IsSitting 	= false
local IsSwimming	= false
local IsFalling 	= false
local IsTired 		= false -- : unused
local IsCrouched 	= false
local IsProned		= false
local IsSteady 		= false
local CanLean 		= true
local ChangeStance 	= true

--// Char Parts
local Humanoid 			= Character:WaitForChild('Humanoid')
local Head 				= Character:WaitForChild('Head')
local Torso 			= Character:WaitForChild('UpperTorso')
local HumanoidRootPart 	= Character:WaitForChild('HumanoidRootPart')
local RootJoint 		= Character.LowerTorso:WaitForChild('Root')
local Neck 				= Head:WaitForChild('Neck')
local Right_Shoulder 	= Character.RightUpperArm:WaitForChild('RightShoulder')
local Left_Shoulder 	= Character.LeftUpperArm:WaitForChild('LeftShoulder')
local Right_Hip 		= Character.RightUpperLeg:WaitForChild('RightHip')
local Left_Hip 			= Character.LeftUpperLeg:WaitForChild('LeftHip')

local YOffset 					= Neck.C0.Y
local WaistYOffset 				= Neck.C0.Y
local CFrame_new, CFrame_Angle 	= CFrame.new, CFrame.Angles
local Asin 						= math.asin
local T 						= 0.15

-- Initial camera setup
UIS.MouseIconEnabled 		= true
player.CameraMode 			= Enum.CameraMode.Classic
CurrentCamera.CameraType 	= Enum.CameraType.Custom
CurrentCamera.CameraSubject = Humanoid

if Config.TeamTags then
	local tag = Essential.TeamTag:Clone()
	tag.Parent = Character
	tag.Disabled = false
end

local ShellFolder = ACS_Workspace:WaitForChild("Casings")
local ShellLimit = Config.ShellLimit

function CreateShell(shell, origin)
	Event.Shell:FireServer(shell, origin.WorldCFrame, WeaponData.EjectionOverride)
end

Event.Shell.OnClientEvent:Connect(function(shell, origin, override)
	local distance = (Character.UpperTorso.Position - origin.Position).Magnitude
	local shell_folder
	
	if Engine.AmmoModels:FindFirstChild(shell) then
		shell_folder = Engine.AmmoModels:FindFirstChild(shell)
	else
		shell_folder = Engine.AmmoModels.Default
	end
	
	local shell_stats = require(shell_folder.EjectionForce)
	
	if distance < 100 then
		local new_shell = shell_folder.Casing:Clone()
		new_shell.Parent = ShellFolder
		new_shell.Anchored = false
		new_shell.CanCollide = true
		new_shell.CFrame = origin * CFrame_Angle(0, math.rad(0), 0)
		new_shell.Name = shell .. "_Casing"
		new_shell.CastShadow = false
		new_shell.CustomPhysicalProperties = shell_stats.PhysicalProperties
		new_shell.CollisionGroup = "Casings"
		
		local Att = Instance.new("Attachment", new_shell)
		Att.Position = shell_stats.ForcePoint
		
		local shell_force = Instance.new("VectorForce", new_shell)
		shell_force.Visible = false
		
		if override then
			shell_force.Force = override
		else
			shell_force.Force = shell_stats.CalculateForce()
		end
		
		shell_force.Attachment0 = Att
		Debris:AddItem(Att, 0.01)
		
		if #ShellFolder:GetChildren() > ShellLimit then
			local children = ShellFolder:GetChildren()
			if #children > 0 then
				children[math.random(math.max(1, math.floor(#children / 2)), #children)]:Destroy()
			end
		end
		
		if Config.ShellDespawn > 0 then
			Debris:AddItem(new_shell, Config.ShellDespawn)
		end
		
		task.wait(0.25)
		if new_shell and new_shell:FindFirstChild("Drop") then
			local new_sound = new_shell.Drop:Clone()
			new_sound.Parent = new_shell
			new_sound.PlaybackSpeed = math.random(30, 50) / 40
			new_sound:Play()
			new_sound.PlayOnRemove = true
			new_sound:Destroy()
			
			Debris:AddItem(new_sound, 2)
		end
	end
end)

function HandleAction(actionName, inputState, inputObject)

	if actionName == "Fire" and inputState == Enum.UserInputState.Begin and AnimDebounce then
		Shoot()

		if WeaponData.Type == "Grenade" then
			CookingGrenade = true
			Grenade()
		end

	elseif actionName == "Fire" and inputState == Enum.UserInputState.End then
		Mouse1Down = false
		CookingGrenade = false
	end

	if actionName == "Reload" and inputState == Enum.UserInputState.Begin and AnimDebounce and not CheckingMag and not IsReloading then
		if WeaponData.Jammed then
			Jammed()
		else
			Reload()
		end
	end

	if actionName == "Reload" and inputState == Enum.UserInputState.Begin and IsReloading and WeaponData.ShellInsert then
		CancelReload = true
	end

	if actionName == "CycleLaser" and inputState == Enum.UserInputState.Begin and LaserAtt then
		SetLaser()
	end

	if actionName == "CycleLight" and inputState == Enum.UserInputState.Begin and TorchAtt then
		SetTorch()
	end

	if actionName == "CycleFiremode" and inputState == Enum.UserInputState.Begin and WeaponData and WeaponData.FireModes.ChangeFiremode then
		Firemode()
	end

	if actionName == "CycleAimpart" and inputState == Enum.UserInputState.Begin then
		SetAimpart()
	end

	if actionName == "ZeroUp" and inputState == Enum.UserInputState.Begin and WeaponData and WeaponData.EnableZeroing  then
		if WeaponData.CurrentZero < WeaponData.MaxZero then
			WeaponInHand.Handle.Click:play()
			WeaponData.CurrentZero = math.min(WeaponData.CurrentZero + WeaponData.ZeroIncrement, WeaponData.MaxZero) 
			UpdateGui()
		end
	end

	if actionName == "ZeroDown" and inputState == Enum.UserInputState.Begin and WeaponData and WeaponData.EnableZeroing  then
		if WeaponData.CurrentZero > 0 then
			WeaponInHand.Handle.Click:play()
			WeaponData.CurrentZero = math.max(WeaponData.CurrentZero - WeaponData.ZeroIncrement, 0) 
			UpdateGui()
		end
	end

	if actionName == "CheckMag" and inputState == Enum.UserInputState.Begin and not CheckingMag and not IsReloading and not RunKeyDown and AnimDebounce then
		CheckMagFunction()
	end

	if actionName == "ToggleBipod" and inputState == Enum.UserInputState.Begin and CanBipod then

		BipodActive = not BipodActive
		UpdateGui()
	end

	if actionName == "NVG" and inputState == Enum.UserInputState.Begin and not NVGdebounce then
		if player.Character then
			local helmet = player.Character:FindFirstChild("Helmet")
			if helmet then
				local nvg = helmet:FindFirstChild("Up")
				if nvg then
					NVGdebounce = true
					delay(.8,function()
						NVG = not NVG
						Event.NVG:Fire(NVG)
						NVGdebounce = false		
					end)

				end
			end
		end
	end

	if actionName == "Aim" and inputState == Enum.UserInputState.Begin and AnimDebounce then
		if WeaponData and WeaponData.canAim and CurrentGunStance > -2 and not RunKeyDown and not CheckingMag then
			IsAimming = not IsAimming
			ToggleAim(IsAimming)
		end

		if WeaponData.Type == "Grenade" then
			GrenadeMode()
		end
	end

	if actionName == "Stand" and inputState == Enum.UserInputState.Begin and ChangeStance and not IsSwimming and not IsSitting and not RunKeyDown then
		if Stances == 2 then
			IsCrouched = true
			IsProned = false
			Stances = 1
			CameraY = -1
			Crouch()


		elseif Stances == 1 then		
			IsCrouched = false
			Stances = 0
			CameraY = 0
			Stand()
		end	
	end

	if actionName == "Crouch" and inputState == Enum.UserInputState.Begin and ChangeStance and not IsSwimming and not IsSitting and not RunKeyDown then
		if Stances == 0 then
			Stances = 1
			CameraY = -1
			Crouch()
			IsCrouched = true
		elseif Stances == 1 then	
			Stances = 2
			CameraX = 0
			CameraY = -3.25
			Virar = 0
			Lean()
			Prone()
			IsCrouched = false
			IsProned = true
		end
	end

	if actionName == "ToggleWalk" and inputState == Enum.UserInputState.Begin and ChangeStance and not RunKeyDown then
		IsSteady = not IsSteady

		if IsSteady then
			StatusGui.MainFrame.Poses.IsSteady.Visible = true
		else
			StatusGui.MainFrame.Poses.IsSteady.Visible = false
		end

		if Stances == 0 then
			Stand()
		end
	end

	if actionName == "LeanLeft" and inputState == Enum.UserInputState.Begin and Stances ~= 2 and ChangeStance and not IsSwimming and not RunKeyDown and CanLean then
		if Virar == 0 or Virar == 1 then
			Virar = -1
			CameraX = -1.25
		else
			Virar = 0
			CameraX = 0
		end
		Lean()
	end

	if actionName == "LeanRight" and inputState == Enum.UserInputState.Begin and Stances ~= 2 and ChangeStance and not IsSwimming and not RunKeyDown and CanLean then
		if Virar == 0 or Virar == -1 then
			Virar = 1
			CameraX = 1.25
		else
			Virar = 0
			CameraX = 0
		end
		Lean()
	end

	if actionName == "Run" and inputState == Enum.UserInputState.Begin and IsRunning and not script.Parent:GetAttribute("Injured") then
		RunKeyDown 	= true
		Stand()
		Stances = 0
		Virar = 0
		CameraX = 0
		CameraY = 0
		Lean()

		Character:WaitForChild("Humanoid").WalkSpeed = Config.RunWalkSpeed

		if IsAimming then
			IsAimming = false
			ToggleAim(IsAimming)
		end

		if not CheckingMag and not IsReloading and WeaponData and WeaponData.Type ~= "Grenade" and (CurrentGunStance == 0 or CurrentGunStance == 2 or CurrentGunStance == 3) then
			CurrentGunStance = 3
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
			SprintAnim()
		end

	elseif actionName == "Run" and inputState == Enum.UserInputState.End and RunKeyDown then
		RunKeyDown 	= false
		Stand()
		if not CheckingMag and not IsReloading and WeaponData and WeaponData.Type ~= "Grenade" and (CurrentGunStance == 0 or CurrentGunStance == 2 or CurrentGunStance == 3) then
			CurrentGunStance = 0
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
			IdleAnim()
		end
	end
end

function ResetMods()

	WeaponModifications.CamRecoil.RecoilUp 		= 1
	WeaponModifications.CamRecoil.RecoilLeft 	= 1
	WeaponModifications.CamRecoil.RecoilRight 	= 1
	WeaponModifications.CamRecoil.RecoilTilt 	= 1

	WeaponModifications.GunRecoil.RecoilUp 		= 1
	WeaponModifications.GunRecoil.RecoilTilt 	= 1
	WeaponModifications.GunRecoil.RecoilLeft 	= 1
	WeaponModifications.GunRecoil.RecoilRight 	= 1

	WeaponModifications.AimRM			= 1
	WeaponModifications.SpreadRM 		= 1
	WeaponModifications.DamageMod 		= 1
	WeaponModifications.minDamageMod 	= 1

	WeaponModifications.MinRecoilPower 		= 1
	WeaponModifications.MaxRecoilPower 		= 1
	WeaponModifications.RecoilPowerStepAmount 	= 1

	WeaponModifications.MinSpread 					= 1
	WeaponModifications.MaxSpread 					= 1
	WeaponModifications.AimInaccuracyStepAmount 	= 1
	WeaponModifications.AimInaccuracyDecrease 		= 1
	WeaponModifications.WalkMult 					= 1
	WeaponModifications.MuzzleVelocity 			= 1

end

function SetMods(ModData)

	WeaponModifications.CamRecoil.RecoilUp 		= WeaponModifications.CamRecoil.RecoilUp * ModData.camRecoil.RecoilUp
	WeaponModifications.CamRecoil.RecoilLeft 	= WeaponModifications.CamRecoil.RecoilLeft * ModData.camRecoil.RecoilLeft
	WeaponModifications.CamRecoil.RecoilRight 	= WeaponModifications.CamRecoil.RecoilRight * ModData.camRecoil.RecoilRight
	WeaponModifications.CamRecoil.RecoilTilt 	= WeaponModifications.CamRecoil.RecoilTilt * ModData.camRecoil.RecoilTilt

	WeaponModifications.GunRecoil.RecoilUp 		= WeaponModifications.GunRecoil.RecoilUp * ModData.gunRecoil.RecoilUp
	WeaponModifications.GunRecoil.RecoilTilt 	= WeaponModifications.GunRecoil.RecoilTilt * ModData.gunRecoil.RecoilTilt
	WeaponModifications.GunRecoil.RecoilLeft 	= WeaponModifications.GunRecoil.RecoilLeft * ModData.gunRecoil.RecoilLeft
	WeaponModifications.GunRecoil.RecoilRight 	= WeaponModifications.GunRecoil.RecoilRight * ModData.gunRecoil.RecoilRight

	WeaponModifications.AimRM						= WeaponModifications.AimRM * ModData.AimRecoilReduction
	WeaponModifications.SpreadRM 					= WeaponModifications.SpreadRM * ModData.AimSpreadReduction
	WeaponModifications.DamageMod 					= WeaponModifications.DamageMod * ModData.DamageMod
	WeaponModifications.minDamageMod 				= WeaponModifications.minDamageMod * ModData.minDamageMod

	WeaponModifications.MinRecoilPower 			= WeaponModifications.MinRecoilPower * ModData.MinRecoilPower
	WeaponModifications.MaxRecoilPower 			= WeaponModifications.MaxRecoilPower * ModData.MaxRecoilPower
	WeaponModifications.RecoilPowerStepAmount 		= WeaponModifications.RecoilPowerStepAmount * ModData.RecoilPowerStepAmount

	WeaponModifications.MinSpread 					= WeaponModifications.MinSpread * ModData.MinSpread
	WeaponModifications.MaxSpread 					= WeaponModifications.MaxSpread * ModData.MaxSpread
	WeaponModifications.AimInaccuracyStepAmount 	= WeaponModifications.AimInaccuracyStepAmount * ModData.AimInaccuracyStepAmount
	WeaponModifications.AimInaccuracyDecrease 		= WeaponModifications.AimInaccuracyDecrease * ModData.AimInaccuracyDecrease
	WeaponModifications.WalkMult 					= WeaponModifications.WalkMult * ModData.WalkMult
	WeaponModifications.MuzzleVelocity 			= WeaponModifications.MuzzleVelocity * ModData.MuzzleVelocityMod
end

local function LoadAttachmentModule(module_name)
	local module_script = AttModules:FindFirstChild(module_name)
	if not module_script then
		warn("Attachment module not found: ", module_name)
		return nil
	end
	
	return Util.SafeRequire(module_script)
end

function LoadAttachment(weapon)
	if weapon and weapon:FindFirstChild("Nodes") ~= nil then
		--load sight Att
		if weapon.Nodes:FindFirstChild("Sight") ~= nil and WeaponData.SightAtt ~= "" then

			SightData =  LoadAttachmentModule(WeaponData.SightAtt)

			SightAtt = AttModels[WeaponData.SightAtt]:Clone()
			SightAtt.Parent = weapon
			SightAtt:SetPrimaryPartCFrame(weapon.Nodes.Sight.CFrame)
			weapon.AimPart.CFrame = SightAtt.AimPos.CFrame

			Reticle = SightAtt.SightMark.SurfaceGui.Border.Scope	
			if SightData.SightZoom > 0 then
				WeaponModifications.ZoomValue = SightData.SightZoom
			end
			if SightData.SightZoom2 > 0 then
				WeaponModifications.Zoom2Value = SightData.SightZoom2
			end
			SetMods(SightData)


			for index, key in pairs(weapon:GetChildren()) do
				if key.Name == "IS" then
					key.Transparency = 1
				end
			end

			for index, key in pairs(SightAtt:GetChildren()) do
				if key:IsA('BasePart') then
					Util.Weld(weapon:WaitForChild("Handle"), key )
					key.Anchored = false
					key.CanCollide = false
				end
			end

		end

		--load Barrel Att
		if weapon.Nodes:FindFirstChild("Barrel") ~= nil and WeaponData.BarrelAtt ~= "" then

			BarrelData =  LoadAttachmentModule(WeaponData.BarrelAtt)

			BarrelAtt = AttModels[WeaponData.BarrelAtt]:Clone()
			BarrelAtt.Parent = weapon
			BarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.Barrel.CFrame)


			if BarrelAtt:FindFirstChild("BarrelPos") ~= nil then
				weapon.Handle.Muzzle.WorldCFrame = BarrelAtt.BarrelPos.CFrame
			end

			Suppressor 		= BarrelData.IsSuppressor
			FlashHider 		= BarrelData.IsFlashHider

			SetMods(BarrelData)

			for index, key in pairs(BarrelAtt:GetChildren()) do
				if key:IsA('BasePart') then
					Util.Weld(weapon:WaitForChild("Handle"), key )
					key.Anchored = false
					key.CanCollide = false
				end
			end
		end

		--load Under Barrel Att
		if weapon.Nodes:FindFirstChild("UnderBarrel") ~= nil and WeaponData.UnderBarrelAtt ~= "" then

			UnderBarrelData =  LoadAttachmentModule(WeaponData.UnderBarrelAtt)

			UnderBarrelAtt = AttModels[WeaponData.UnderBarrelAtt]:Clone()
			UnderBarrelAtt.Parent = weapon
			UnderBarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.UnderBarrel.CFrame)


			SetMods(UnderBarrelData)
			HasBipodAtt = UnderBarrelData.IsBipod

			if HasBipodAtt then
				CAS:BindAction("ToggleBipod", HandleAction, true, Enum.KeyCode.B)
			end

			for index, key in pairs(UnderBarrelAtt:GetChildren()) do
				if key:IsA('BasePart') then
					Util.Weld(weapon:WaitForChild("Handle"), key )
					key.Anchored = false
					key.CanCollide = false
				end
			end
		end

		if weapon.Nodes:FindFirstChild("Other") ~= nil and WeaponData.OtherAtt ~= "" then

			OtherData =  LoadAttachmentModule(WeaponData.OtherAtt)

			OtherAtt = AttModels[WeaponData.OtherAtt]:Clone()
			OtherAtt.Parent = weapon
			OtherAtt:SetPrimaryPartCFrame(weapon.Nodes.Other.CFrame)


			SetMods(OtherData)
			LaserAtt = OtherData.EnableLaser
			TorchAtt = OtherData.EnableFlashlight
			
			if OtherData.InfraRed then
				InfraredEnabled = true
			end
			
			for index, key in pairs(OtherAtt:GetChildren()) do
				if key:IsA('BasePart') then
					Util.Weld(weapon:WaitForChild("Handle"), key )
					key.Anchored = false
					key.CanCollide = false
				end
			end
		end
	end
end

function SetLaser()
	if Config.RealisticLaser and InfraredEnabled then
		if not LaserActive and not InfraredMode then
			LaserActive = true
			InfraredMode 		= true

		elseif LaserActive and InfraredMode then
			InfraredMode 		= false
		else
			LaserActive = false
			InfraredMode 		= false
		end
	else
		LaserActive = not LaserActive
	end

	print(LaserActive, InfraredMode)

	if LaserActive then
		if not Pointer then
			for index, Key in pairs(WeaponInHand:GetDescendants()) do
				if Key:IsA("BasePart") and Key.Name == "LaserPoint" then
					local LaserPointer = Instance.new('Part',Key)
					LaserPointer.Shape = 'Ball'
					LaserPointer.Size = Vector3.new(0.2, 0.2, 0.2)
					LaserPointer.CanCollide = false
					LaserPointer.Color = Key.Color
					LaserPointer.Material = Enum.Material.Neon

					local LaserSP = Instance.new('Attachment',Key)			
					local LaserEP = Instance.new('Attachment',LaserPointer)

					local Laser = Instance.new('Beam',LaserPointer)
					Laser.Transparency = NumberSequence.new(0)
					Laser.LightEmission = 1
					Laser.LightInfluence = 1
					Laser.Attachment0 = LaserSP
					Laser.Attachment1 = LaserEP
					Laser.Color = ColorSequence.new(Key.Color)
					Laser.FaceCamera = true
					Laser.Width0 = 0.01
					Laser.Width1 = 0.01

					if Config.RealisticLaser then
						Laser.Enabled = false
					end

					Pointer = LaserPointer
					break
				end
			end
		end
	else
		for index, Key in pairs(WeaponInHand:GetDescendants()) do
			if Key:IsA("BasePart") and Key.Name == "LaserPoint" then
				Key:ClearAllChildren()
				break
			end
		end
		Pointer = nil
		if Config.ReplicatedLaser then
			Event.SVLaser:FireServer(nil,2,nil,false,WeaponTool)
		end
	end
	WeaponInHand.Handle.Click:play()
	UpdateGui()
end

function SetTorch()

	TorchActive = not TorchActive
	
	if TorchActive then
		for index, Key in pairs(WeaponInHand:GetDescendants()) do
			if Key:IsA("BasePart") and Key.Name == "FlashPoint" then
				Key.Light.Enabled = true
			end
		end
	else
		for index, Key in pairs(WeaponInHand:GetDescendants()) do
			if Key:IsA("BasePart") and Key.Name == "FlashPoint" then
				Key.Light.Enabled = false
			end
		end
	end
	Event.SVFlash:FireServer(WeaponTool,TorchActive)
	WeaponInHand.Handle.Click:play()
	UpdateGui()
end

function UpdateSensitivity()
	if not WeaponData then return end

	if IsAimming then
		UIS.MouseDeltaSensitivity = (ADSSens / 100)
	elseif IsHipFiring then
		UIS.MouseDeltaSensitivity = (HipFireSens / 100)
	else
		UIS.MouseDeltaSensitivity = (CameraSens / 100)
	end

	UpdateGui()
end

function ToggleAim(IsAimming)
	if WeaponData and WeaponInHand then

		if IsAimming then

			if SafeMode then
				SafeMode = false
				CurrentGunStance = 0
				IdleAnim()
				UpdateGui()
			end

			game:GetService('UserInputService').MouseDeltaSensitivity = (Sens/100)

			WeaponInHand.Handle.AimDown:Play()

			CurrentGunStance = 2
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)

			TS:Create(Crosshair.Up, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
			TS:Create(Crosshair.Down, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
			TS:Create(Crosshair.Left, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
			TS:Create(Crosshair.Right, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
			TS:Create(Crosshair.Center, TweenInfo.new(.2,Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()

		else
			game:GetService('UserInputService').MouseDeltaSensitivity = 1
			WeaponInHand.Handle.AimUp:Play()

			CurrentGunStance = 0
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)

			if  WeaponData.CrossHair then
				TS:Create(Crosshair.Up, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 0}):Play()
				TS:Create(Crosshair.Down, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 0}):Play()
				TS:Create(Crosshair.Left, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 0}):Play()
				TS:Create(Crosshair.Right, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 0}):Play()
			end

			if  WeaponData.CenterDot then
				TS:Create(Crosshair.Center, TweenInfo.new(.2,Enum.EasingStyle.Linear), {ImageTransparency = 0}):Play()
			else
				TS:Create(Crosshair.Center, TweenInfo.new(.2,Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
			end
		end
	end
end

function SetAimpart()
	if IsAimming then
		if CurrentAimPartMode == 1 then
			CurrentAimPartMode = 2
			if WeaponInHand:FindFirstChild('AimPart2') then
				CurrentAimPart = WeaponInHand:FindFirstChild('AimPart2')
			end 
		else
			CurrentAimPartMode = 1
			CurrentAimPart = WeaponInHand:FindFirstChild('AimPart')
		end
		--print("Set to Aimpart: "..CurrentAimPartMode)
	end
end

function Firemode()

	WeaponInHand.Handle.SafetyClick:Play()
	Mouse1Down = false

	---Semi Settings---		
	if WeaponData.ShootType == 1 and WeaponData.FireModes.Burst == true then
		WeaponData.ShootType = 2
	elseif WeaponData.ShootType == 1 and WeaponData.FireModes.Burst == false and WeaponData.FireModes.Auto == true then
		WeaponData.ShootType = 3
		---Burst Settings---
	elseif WeaponData.ShootType == 2 and WeaponData.FireModes.Auto == true then
		WeaponData.ShootType = 3
	elseif WeaponData.ShootType == 2 and WeaponData.FireModes.Semi == true and WeaponData.FireModes.Auto == false then
		WeaponData.ShootType = 1
		---Auto Settings---
	elseif WeaponData.ShootType == 3 and WeaponData.FireModes.Semi == true then
		WeaponData.ShootType = 1
	elseif WeaponData.ShootType == 3 and WeaponData.FireModes.Semi == false and WeaponData.FireModes.Burst == true then
		WeaponData.ShootType = 2
		---Explosive Settings---
	end
	UpdateGui()

end

function Setup(Tool)
	
	if not Character or not Tool or not Character:FindFirstChild("Humanoid") or Character.Humanoid.Health <= 0 then
		return
	end

	ToolEquip = true
	UIS.MouseIconEnabled 	= false
	player.CameraMode 			= Enum.CameraMode.LockFirstPerson

	WeaponTool 		= Tool
	WeaponData 		= Util.SafeRequire(Tool:WaitForChild("ACS_Settings"))
	AnimData 		= Util.SafeRequire(Tool:WaitForChild("ACS_Animations"))
	
	local weapon_type = WeaponData.Type
	
	local weapon_type_folder = WeaponModels:FindFirstChild(weapon_type)
	if not weapon_type_folder then
		warn("Weapon type folder not found: " .. weapon_type)
		return
	end
	
	local model_check = weapon_type_folder:FindFirstChild(Tool.Name)
	if not model_check then
		warn("Model " .. Tool.Name .. " not found in " .. weapon_type .. " folder")
		return
	end
	
	WeaponInHand 			 = model_check:Clone()
	WeaponInHand.PrimaryPart = WeaponInHand:WaitForChild("Handle")

	Event.Equip:FireServer(Tool, 1, WeaponData, AnimData)

	ViewModel = ArmModel:WaitForChild("Arms"):Clone()
	ViewModel.Name = "Viewmodel"

	if Character:FindFirstChild("Body Colors") ~= nil then
		local Colors = Character:WaitForChild("Body Colors"):Clone()
		Colors.Parent = ViewModel
	end

	if Character:FindFirstChild("Shirt") ~= nil then
		local Shirt = Character:FindFirstChild("Shirt"):Clone()
		Shirt.Parent = ViewModel
	end
	
	if WeaponData.Sensitivity then
		CameraSens 		= WeaponData.Sensitivity.Camera or 50
		HipFireSens 	= WeaponData.Sensitivity.HipFire or 50
		ADSSens 		= WeaponData.Sensitivity.ADS or 50
	else
		CameraSens 		= 50
		HipFireSens 	= 50
		ADSSens 		= 50
	end
	
	UIS.MouseDeltaSensitivity = (CameraSens / 100)

	AnimPart = Instance.new("Part",ViewModel)
	AnimPart.Size = Vector3.new(0.1,0.1,0.1)
	AnimPart.Anchored = true
	AnimPart.CanCollide = false
	AnimPart.Transparency = 1

	ViewModel.PrimaryPart = AnimPart

	LArmWeld = Instance.new("Motor6D",AnimPart)
	LArmWeld.Name = "LeftArm"
	LArmWeld.Part0 = AnimPart

	RArmWeld = Instance.new("Motor6D",AnimPart)
	RArmWeld.Name = "RightArm"
	RArmWeld.Part0 = AnimPart

	GunWeld = Instance.new("Motor6D",AnimPart)
	GunWeld.Name = "Handle"

	--Setup arms to camera

	ViewModel.Parent = CurrentCamera

	MainCFrame = AnimData.MainCFrame
	GunCFrame = AnimData.GunCFrame

	LeftArmCFrame = AnimData.LArmCFrame
	RightArmCFrame = AnimData.RArmCFrame


	if  WeaponData.CrossHair then
		TS:Create(Crosshair.Up, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 0}):Play()
		TS:Create(Crosshair.Down, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 0}):Play()
		TS:Create(Crosshair.Left, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 0}):Play()
		TS:Create(Crosshair.Right, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 0}):Play()	

		if WeaponData.Bullets > 1 then
			Crosshair.Up.Rotation = 90
			Crosshair.Down.Rotation = 90
			Crosshair.Left.Rotation = 90
			Crosshair.Right.Rotation = 90
		else
			Crosshair.Up.Rotation = 0
			Crosshair.Down.Rotation = 0
			Crosshair.Left.Rotation = 0
			Crosshair.Right.Rotation = 0
		end

	else
		TS:Create(Crosshair.Up, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
		TS:Create(Crosshair.Down, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
		TS:Create(Crosshair.Left, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
		TS:Create(Crosshair.Right, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
	end

	if  WeaponData.CenterDot then
		TS:Create(Crosshair.Center, TweenInfo.new(.2,Enum.EasingStyle.Linear), {ImageTransparency = 0}):Play()
	else
		TS:Create(Crosshair.Center, TweenInfo.new(.2,Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
	end

	LArm = ViewModel:WaitForChild("Left Arm")
	LArmWeld.Part1 = LArm
	LArmWeld.C0 = CFrame.new()
	LArmWeld.C1 = CFrame.new(1,-1,-5) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0)):inverse()

	RArm = ViewModel:WaitForChild("Right Arm")
	RArmWeld.Part1 = RArm
	RArmWeld.C0 = CFrame.new()
	RArmWeld.C1 = CFrame.new(-1,-1,-5) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0)):inverse()
	GunWeld.Part0 = RArm

	LArm.Anchored = false
	RArm.Anchored = false

	--Setup weapon to camera
	WeaponModifications.ZoomValue 		= WeaponData.Zoom
	WeaponModifications.Zoom2Value 		= WeaponData.Zoom2
	InfraredEnabled 					= WeaponData.InfraRed


	CAS:BindAction("Fire", HandleAction, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
	CAS:BindAction("Aim", HandleAction, true, Enum.UserInputType.MouseButton2, Enum.KeyCode.ButtonL2) 
	CAS:BindAction("Reload", HandleAction, true, Enum.KeyCode.R, Enum.KeyCode.ButtonB)
	CAS:BindAction("CycleAimpart", HandleAction, false, Enum.KeyCode.T)
	
	CAS:BindAction("CycleLaser", HandleAction, true, Enum.KeyCode.H)
	CAS:BindAction("CycleLight", HandleAction, true, Enum.KeyCode.J)
	
	CAS:BindAction("CycleFiremode", HandleAction, false, Enum.KeyCode.V)
	CAS:BindAction("CheckMag", HandleAction, false, Enum.KeyCode.M)

	CAS:BindAction("ZeroDown", HandleAction, false, Enum.KeyCode.LeftBracket)
	CAS:BindAction("ZeroUp", HandleAction, false, Enum.KeyCode.RightBracket)

	LoadAttachment(WeaponInHand)

	BSpread				= math.min(WeaponData.MinSpread * WeaponModifications.MinSpread, WeaponData.MaxSpread * WeaponModifications.MaxSpread)
	RecoilPower 		= math.min(WeaponData.MinRecoilPower * WeaponModifications.MinRecoilPower, WeaponData.MaxRecoilPower * WeaponModifications.MaxRecoilPower)

	Ammo = WeaponData.AmmoInGun
	StoredAmmo = WeaponData.StoredAmmo
	
	CurrentAimPart = WeaponInHand:FindFirstChild("AimPart")
	
	for index, Key in pairs(WeaponInHand:GetDescendants()) do
		if Key:IsA("BasePart") and Key.Name == "FlashPoint" then
			TorchAtt = true
		end
		if Key:IsA("BasePart") and Key.Name == "LaserPoint" then
			LaserAtt = true
		end
	end
	
	if WeaponData.Type == "Gun" and WeaponData.ShellEjectionMod then
		WeaponInHand.Bolt.SlidePull.Played:Connect(function()
			if Ammo > 0 then
				CreateShell(WeaponData.BulletType, WeaponInHand.Handle.Chamber)
				WeaponInHand.Handle.Chamber.Smoke:Emit(10)
				-- CanPump = false
			end
		end)
	end
	
	if WeaponData.EnableHUD then
		StatusGui.GunHUD.Visible = true
	end
	UpdateGui()

	for index, key in pairs(WeaponInHand:GetChildren()) do
		if key:IsA('BasePart') and key.Name ~= 'Handle' then

			if key.Name ~= "Bolt" and key.Name ~= 'Lid' and key.Name ~= "Slide" then
				Util.Weld(WeaponInHand:WaitForChild("Handle"), key)
			end

			if key.Name == "Bolt" or key.Name == "Slide" then
				Util.WeldComplex(WeaponInHand:WaitForChild("Handle"), key, key.Name)
			end;

			if key.Name == "Lid" then
				if WeaponInHand:FindFirstChild('LidHinge') then
					Util.Weld(key, WeaponInHand:WaitForChild("LidHinge"))
				else
					Util.Weld(key, WeaponInHand:WaitForChild("Handle"))
				end
			end
		end
	end;

	for L_213_forvar1, L_214_forvar2 in pairs(WeaponInHand:GetChildren()) do
		if L_214_forvar2:IsA('BasePart') then
			L_214_forvar2.Anchored = false
			L_214_forvar2.CanCollide = false
		end
	end;

	if WeaponInHand:FindFirstChild("Nodes") then
		for L_213_forvar1, L_214_forvar2 in pairs(WeaponInHand.Nodes:GetChildren()) do
			if L_214_forvar2:IsA('BasePart') then
				Util.Weld(WeaponInHand:WaitForChild("Handle"), L_214_forvar2)
				L_214_forvar2.Anchored = false
				L_214_forvar2.CanCollide = false
			end
		end;
	end

	GunWeld.Part1 = WeaponInHand:WaitForChild("Handle")
	GunWeld.C1 = GunCFrame

	--WeaponInHand:SetPrimaryPartCFrame( RArm.CFrame * GunCFrame)

	WeaponInHand.Parent = ViewModel	
	if Ammo <= 0 and WeaponData.Type == "Gun" then
		WeaponInHand.Handle.Slide.C0 = WeaponData.SlideEx:inverse()
	end
	
	EquipAnim()
	if WeaponData and WeaponData.Type ~= "Grenade" then
		RunCheck()
	end
end

function UnSet()
	ToolEquip = false
	Event.Equip:FireServer(WeaponTool, 2, nil, nil)
	--unsetup weapon data module
	CAS:UnbindAction("Fire")
	CAS:UnbindAction("Aim")
	CAS:UnbindAction("Reload")
	CAS:UnbindAction("CycleLaser")
	CAS:UnbindAction("CycleLight")
	CAS:UnbindAction("CycleFiremode")
	CAS:UnbindAction("CycleAimpart")
	CAS:UnbindAction("ZeroUp")
	CAS:UnbindAction("ZeroDown")
	CAS:UnbindAction("CheckMag")

	Mouse1Down = false
	IsAimming = false

	TS:Create(CurrentCamera,AimTweenInfo,{FieldOfView = 70}):Play()
	TS:Create(Crosshair.Up, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
	TS:Create(Crosshair.Down, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
	TS:Create(Crosshair.Left, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
	TS:Create(Crosshair.Right, TweenInfo.new(.2,Enum.EasingStyle.Linear), {BackgroundTransparency = 1}):Play()
	TS:Create(Crosshair.Center, TweenInfo.new(.2,Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()

	UIS.MouseIconEnabled = true
	game:GetService('UserInputService').MouseDeltaSensitivity = 1
	CurrentCamera.CameraType = Enum.CameraType.Custom
	player.CameraMode = Enum.CameraMode.Classic


	if WeaponInHand then
		
		if WeaponData.Type == "Gun" then
			local chambered = true
			if WeaponData.Jammed or Ammo < 1 then
				chambered = false
			end
			
			WeaponData.AmmoInGun = Ammo
			WeaponData.StoredAmmo = StoredAmmo
			
			-- Event.Refil:FireServer(WeaponData, Ammo, StoredAmmo, WeaponData.Jammed)
		end
		
		if ViewModel and ViewModel.Parent then
			ViewModel:Destroy()
		end

		ViewModel 		= nil
		WeaponInHand	= nil
		WeaponTool		= nil
		LArm 			= nil
		RArm 			= nil
		LArmWeld 		= nil
		RArmWeld 		= nil
		WeaponData 		= nil
		AnimData		= nil
		SightAtt		= nil
		Reticle			= nil
		BarrelAtt 		= nil
		UnderBarrelAtt 	= nil
		OtherAtt 		= nil
		LaserAtt 		= false
		LaserActive		= false
		InfraredMode	= false
		TorchAtt 		= false
		TorchActive 	= false
		HasBipodAtt 	= false
		BipodActive 	= false
		LaserDist 		= 0
		Pointer 		= nil
		BSpread 		= nil
		RecoilPower 	= nil
		Suppressor 		= false
		FlashHider 		= false
		CancelReload 	= false
		IsReloading 	= false
		SafeMode		= false
		CheckingMag		= false
		GrenadeDebounce = false
		CookingGrenade 	= false
		CurrentGunStance= 0
		ResetMods()
		GenerateBullet 	= 1
		CurrentAimPartMode 	= 1

		StatusGui.GunHUD.Visible = false
		StatusGui.GrenadeForce.Visible = false
		BipodCF = CFrame.new()
		if Config.ReplicatedLaser then
			Event.SVLaser:FireServer(nil,2,nil,false,WeaponTool)
		end
	end
end

function RenderCam()			
	CurrentCamera.CFrame = CurrentCamera.CFrame*CFrame.Angles(CameraSpring.p.x,CameraSpring.p.y,CameraSpring.p.z)
end

function RenderGunRecoil()			
	RecoilCFrame = RecoilCFrame*CFrame.Angles(RecoilSpring.p.x,RecoilSpring.p.y,RecoilSpring.p.z)
end

function Recoil()
	local vr = (math.random(WeaponData.camRecoil.camRecoilUp[1], WeaponData.camRecoil.camRecoilUp[2])/2) * WeaponModifications.CamRecoil.RecoilUp
	local lr = (math.random(WeaponData.camRecoil.camRecoilLeft[1], WeaponData.camRecoil.camRecoilLeft[2])) * WeaponModifications.CamRecoil.RecoilLeft
	local rr = (math.random(WeaponData.camRecoil.camRecoilRight[1], WeaponData.camRecoil.camRecoilRight[2])) * WeaponModifications.CamRecoil.RecoilRight
	local hr = (math.random(-rr, lr)/2)
	local tr = (math.random(WeaponData.camRecoil.camRecoilTilt[1], WeaponData.camRecoil.camRecoilTilt[2])/2) * WeaponModifications.CamRecoil.RecoilTilt

	local RecoilX = math.rad(vr * Util.RAND( 1, 1, .1))
	local RecoilY = math.rad(hr * Util.RAND(-1, 1, .1))
	local RecoilZ = math.rad(tr * Util.RAND(-1, 1, .1))

	local gvr = (math.random(WeaponData.gunRecoil.gunRecoilUp[1], WeaponData.gunRecoil.gunRecoilUp[2]) /10) * WeaponModifications.GunRecoil.RecoilUp
	local gdr = (math.random(-1,1) * math.random(WeaponData.gunRecoil.gunRecoilTilt[1], WeaponData.gunRecoil.gunRecoilTilt[2]) /10) * WeaponModifications.GunRecoil.RecoilTilt
	local glr = (math.random(WeaponData.gunRecoil.gunRecoilLeft[1], WeaponData.gunRecoil.gunRecoilLeft[2])) * WeaponModifications.GunRecoil.RecoilLeft
	local grr = (math.random(WeaponData.gunRecoil.gunRecoilRight[1], WeaponData.gunRecoil.gunRecoilRight[2])) * WeaponModifications.GunRecoil.RecoilRight

	local ghr = (math.random(-grr, glr)/10)	

	local ARR = WeaponData.AimRecoilReduction * WeaponModifications.AimRM

	if BipodActive then
		CameraSpring:accelerate(Vector3.new( RecoilX, RecoilY/2, 0 ))

		if not IsAimming then
			RecoilSpring:accelerate(Vector3.new( math.rad(.25 * gvr * RecoilPower), math.rad(.25 * ghr * RecoilPower), math.rad(.25 * gdr)))
			RecoilCFrame = RecoilCFrame * CFrame.new(0,0,.1) * CFrame.Angles( math.rad(.25 * gvr * RecoilPower ),math.rad(.25 * ghr * RecoilPower ),math.rad(.25 * gdr * RecoilPower ))

		else
			RecoilSpring:accelerate(Vector3.new( math.rad( .25 * gvr * RecoilPower/ARR) , math.rad(.25 * ghr * RecoilPower/ARR), math.rad(.25 * gdr/ ARR)))
			RecoilCFrame = RecoilCFrame * CFrame.new(0,0,.1) * CFrame.Angles( math.rad(.25 * gvr * RecoilPower/ARR ),math.rad(.25 * ghr * RecoilPower/ARR ),math.rad(.25 * gdr * RecoilPower/ARR ))
		end

		Thread:Wait(0.05)
		CameraSpring:accelerate(Vector3.new(-RecoilX, -RecoilY/2, 0))

	else
		CameraSpring:accelerate(Vector3.new( RecoilX , RecoilY, RecoilZ ))
		if not IsAimming then
			RecoilSpring:accelerate(Vector3.new( math.rad(gvr * RecoilPower), math.rad(ghr * RecoilPower), math.rad(gdr)))
			RecoilCFrame = RecoilCFrame * CFrame.new(0,-0.05,.1) * CFrame.Angles( math.rad( gvr * RecoilPower ),math.rad( ghr * RecoilPower ),math.rad( gdr * RecoilPower ))

		else
			RecoilSpring:accelerate(Vector3.new( math.rad(gvr * RecoilPower/ARR) , math.rad(ghr * RecoilPower/ARR), math.rad(gdr/ ARR)))
			RecoilCFrame = RecoilCFrame * CFrame.new(0,0,.1) * CFrame.Angles( math.rad( gvr * RecoilPower/ARR ),math.rad( ghr * RecoilPower/ARR ),math.rad( gdr * RecoilPower/ARR ))
		end
	end
end

function CheckForHumanoid(L_225_arg1)
	local L_226_ = false
	local L_227_ = nil
	if L_225_arg1 then
		if (L_225_arg1.Parent:FindFirstChildOfClass("Humanoid") or L_225_arg1.Parent.Parent:FindFirstChildOfClass("Humanoid")) then
			L_226_ = true
			if L_225_arg1.Parent:FindFirstChildOfClass('Humanoid') then
				L_227_ = L_225_arg1.Parent:FindFirstChildOfClass('Humanoid')
			elseif L_225_arg1.Parent.Parent:FindFirstChildOfClass('Humanoid') then
				L_227_ = L_225_arg1.Parent.Parent:FindFirstChildOfClass('Humanoid')
			end
		else
			L_226_ = false
		end	
	end
	return L_226_, L_227_
end

function CastRay(bullet, Origin)
	if bullet then

		local Bpos = bullet.Position
		local Bpos2 = CurrentCamera.CFrame.Position

		local recast = false
		local TotalDistTraveled = 0
		local Debounce = false
		local raycast_result

		local raycast_params = RaycastParams.new()
		raycast_params.FilterDescendantsInstances = Ignore_Model
		raycast_params.FilterType = Enum.RaycastFilterType.Exclude
		raycast_params.IgnoreWater = true

		while bullet do
			Run.Heartbeat:Wait()
			if bullet.Parent ~= nil then
				Bpos = bullet.Position
				TotalDistTraveled = (bullet.Position - Origin).Magnitude

				if TotalDistTraveled > 7000 then
					bullet:Destroy()
					Debounce = true
					break
				end

				for _, plyr in pairs(game.Players:GetChildren()) do
					if not Debounce and plyr:IsA('Player') and plyr ~= player and plyr.Character and plyr.Character:FindFirstChild('Head') ~= nil and (plyr.Character.Head.Position - Bpos).magnitude <= 25 then
						Event.Whizz:FireServer(plyr)
						Event.Suppression:FireServer(plyr,1,nil,nil)
						Debounce = true
					end
				end

				-- Set an origin and directional vector
				raycast_result = workspace:Raycast(Bpos2, (Bpos - Bpos2) * 1, raycast_params)

				recast = false

				if raycast_result then
					local Hit2 = raycast_result.Instance

					if Hit2 and Hit2.Parent:IsA('Accessory') or Hit2.Parent:IsA('Hat') then
						for _,players in pairs(game.Players:GetPlayers()) do
							if players.Character then
								for i, hats in pairs(players.Character:GetChildren()) do
									if hats:IsA("Accessory") then
										table.insert(Ignore_Model, hats)
									end
								end
							end
						end
						recast = true
						CastRay(bullet, Origin)
						break
					end
					
					if Hit2 and Hit2.Name == "Ignorable" or Hit2.Name == "Glass" or Hit2.Name == "Ignore" or Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1"  or Hit2.Parent.Name == "Arm2" then
						table.insert(Ignore_Model, Hit2)
						recast = true
						CastRay(bullet, Origin)
						break
					end
					
					if Hit2 and Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1"  or Hit2.Parent.Name == "Arm2" then
						table.insert(Ignore_Model, Hit2.Parent)
						recast = true
						CastRay(bullet, Origin)
						break
					end

					if Hit2 and (Hit2.Transparency >= 1 or Hit2.CanCollide == false) and Hit2.Name ~= 'Head' and Hit2.Name ~= 'Right Arm' and Hit2.Name ~= 'Left Arm' and Hit2.Name ~= 'Right Leg' and Hit2.Name ~= 'Left Leg' and Hit2.Name ~= "UpperTorso" and Hit2.Name ~= "LowerTorso" and Hit2.Name ~= "RightUpperArm" and Hit2.Name ~= "RightLowerArm" and Hit2.Name ~= "RightHand" and Hit2.Name ~= "LeftUpperArm" and Hit2.Name ~= "LeftLowerArm" and Hit2.Name ~= "LeftHand" and Hit2.Name ~= "RightUpperLeg" and Hit2.Name ~= "RightLowerLeg" and Hit2.Name ~= "RightFoot" and Hit2.Name ~= "LeftUpperLeg" and Hit2.Name ~= "LeftLowerLeg" and Hit2.Name ~= "LeftFoot" and Hit2.Name ~= 'Armor' and Hit2.Name ~= 'EShield' then
						table.insert(Ignore_Model, Hit2)
						recast = true
						CastRay(bullet, Origin)
						break
					end

					if not recast then

						bullet:Destroy()
						Debounce = true

						local FoundHuman,VitimaHuman = CheckForHumanoid(raycast_result.Instance)
						HitMod.HitEffect(Ignore_Model, raycast_result.Position, raycast_result.Instance , raycast_result.Normal, raycast_result.Material, WeaponData)
						Event.HitEffect:FireServer(raycast_result.Position, raycast_result.Instance , raycast_result.Normal, raycast_result.Material, WeaponData)
						
						local HitPart = raycast_result.Instance
						TotalDistTraveled = (raycast_result.Position - Origin).Magnitude

						if FoundHuman == true and VitimaHuman.Health > 0 and WeaponData then
							local SKP_02 = SKP_01.."-"..player.UserId

							if HitPart.Name == "Head" or HitPart.Parent.Name == "Top" or HitPart.Parent.Name == "Headset" or HitPart.Parent.Name == "Olho" or HitPart.Parent.Name == "Face" or HitPart.Parent.Name == "Numero" then
								Event.Damage:InvokeServer(WeaponTool, VitimaHuman, TotalDistTraveled, 1, WeaponData, WeaponModifications, nil, nil, SKP_02)
							elseif HitPart.Name == "Torso" or HitPart.Name == "UpperTorso" or HitPart.Name == "LowerTorso" or HitPart.Parent.Name == "Chest" or HitPart.Parent.Name == "Waist" or HitPart.Name == "Right Arm" or HitPart.Name == "Left Arm" or HitPart.Name == "RightUpperArm" or HitPart.Name == "RightLowerArm" or HitPart.Name == "RightHand" or HitPart.Name == "LeftUpperArm" or HitPart.Name == "LeftLowerArm" or HitPart.Name == "LeftHand" then				
								Event.Damage:InvokeServer(WeaponTool, VitimaHuman, TotalDistTraveled, 2, WeaponData, WeaponModifications, nil, nil, SKP_02)
							elseif HitPart.Name == "Right Leg" or HitPart.Name == "Left Leg" or HitPart.Name == "RightUpperLeg" or HitPart.Name == "RightLowerLeg" or HitPart.Name == "RightFoot" or HitPart.Name == "LeftUpperLeg" or HitPart.Name == "LeftLowerLeg" or HitPart.Name == "LeftFoot" then
								Event.Damage:InvokeServer(WeaponTool, VitimaHuman, TotalDistTraveled, 3, WeaponData, WeaponModifications, nil, nil, SKP_02)		
							end	
						end
					end
					break
				end

				Bpos2 = Bpos
			else
				break
			end
		end
	end
end

local Tracers = 0
function TracerCalculation()
	if WeaponData.Tracer or WeaponData.BulletFlare then
		if WeaponData.RandomTracer.Enabled then
			if (math.random(1, 100) <= WeaponData.RandomTracer.Chance) then	
				return true
			else
				return false
			end
		else
			if Tracers >= WeaponData.TracerEveryXShots then
				Tracers = 0
				return true
			else
				Tracers = Tracers + 1
				return false
			end
		end
	end
end

function CreateBullet()
	
	if WeaponData.IsLauncher then
		for _, cPart in pairs(WeaponInHand:GetChildren()) do
			if cPart.Name == "Warhead" then
				cPart.Transparency = 1
			end
		end
	end

	local bullet = Instance.new("Part",ACS_Workspace.Client)
	bullet.Name = player.Name.."_Bullet"
	bullet.CanCollide = false
	bullet.Shape = Enum.PartType.Ball
	bullet.Transparency = 1
	bullet.Size = Vector3.new(1,1,1)

	local origin 		= WeaponInHand.Handle.Muzzle.WorldPosition
	local direction 	= WeaponInHand.Handle.Muzzle.WorldCFrame.LookVector + (WeaponInHand.Handle.Muzzle.WorldCFrame.UpVector * (((WeaponData.BulletDrop * WeaponData.CurrentZero/4)/WeaponData.MuzzleVelocity))/2)
	local bulletCF 		= CFrame.new(origin, direction) 
	local walk_mul 		= WeaponData.WalkMult * WeaponModifications.WalkMult
	local B_color 		= Color3.fromRGB(255,255,255)
	local balaspread

	if IsAimming and WeaponData.Bullets <= 1 then
		balaspread = CFrame.Angles(
			math.rad(Util.RAND(-BSpread - (CharacterSpeed/1) * walk_mul, BSpread + (CharacterSpeed/1) * walk_mul) / (10 * WeaponData.AimSpreadReduction)),
			math.rad(Util.RAND(-BSpread - (CharacterSpeed/1) * walk_mul, BSpread + (CharacterSpeed/1) * walk_mul) / (10 * WeaponData.AimSpreadReduction)),
			math.rad(Util.RAND(-BSpread - (CharacterSpeed/1) * walk_mul, BSpread + (CharacterSpeed/1) * walk_mul) / (10 * WeaponData.AimSpreadReduction))
		)
	else
		balaspread = CFrame.Angles(
			math.rad(Util.RAND(-BSpread - (CharacterSpeed/1) * walk_mul, BSpread + (CharacterSpeed/1) * walk_mul) / 10),
			math.rad(Util.RAND(-BSpread - (CharacterSpeed/1) * walk_mul, BSpread + (CharacterSpeed/1) * walk_mul) / 10),
			math.rad(Util.RAND(-BSpread - (CharacterSpeed/1) * walk_mul, BSpread + (CharacterSpeed/1) * walk_mul) / 10)
		)
	end

	direction = balaspread * direction

	local Visivel = TracerCalculation()

	if WeaponData.RainbowMode then
		B_color = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
	else
		B_color = WeaponData.TracerColor
	end

	if Visivel then
		if Config.ReplicatedBullets then
			Event.ServerBullet:FireServer(origin, direction, WeaponData, WeaponModifications)
		end

		if WeaponData.Tracer == true then

			local At1 = Instance.new("Attachment")
			At1.Name = "At1"
			At1.Position = Vector3.new(-(.05),0,0)
			At1.Parent = bullet

			local At2  = Instance.new("Attachment")
			At2.Name = "At2"
			At2.Position = Vector3.new((.05),0,0)
			At2.Parent = bullet

			local Particles = Instance.new("Trail")
			Particles.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0, 0);
				NumberSequenceKeypoint.new(1, 1);
			}
			)
			Particles.WidthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 2, 0);
				NumberSequenceKeypoint.new(1, 1);
			}
			)


			Particles.Color = ColorSequence.new(B_color)
			Particles.Texture = "rbxassetid://232918622"
			Particles.TextureMode = Enum.TextureMode.Stretch

			Particles.FaceCamera = true
			Particles.LightEmission = 1
			Particles.LightInfluence = 0
			Particles.Lifetime = .25
			Particles.Attachment0 = At1
			Particles.Attachment1 = At2
			Particles.Parent = bullet
		end

		if WeaponData.BulletFlare == true then
			local bg = Instance.new("BillboardGui", bullet)
			bg.Adornee = bullet
			bg.Enabled = false
			local flashsize = math.random(275, 375)/10
			bg.Size = UDim2.new(flashsize, 0, flashsize, 0)
			bg.LightInfluence = 0
			local flash = Instance.new("ImageLabel", bg)
			flash.BackgroundTransparency = 1
			flash.Size = UDim2.new(1, 0, 1, 0)
			flash.Position = UDim2.new(0, 0, 0, 0)
			flash.Image = "http://www.roblox.com/asset/?id=1047066405"
			flash.ImageTransparency = math.random(2, 5)/15
			flash.ImageColor3 = B_color

			spawn(function()
				wait(.1)
				if bullet:FindFirstChild("BillboardGui") ~= nil then
					Bullet.BillboardGui.Enabled = true
				end
			end)
		end

	end

	local BulletMass = bullet:GetMass()
	local Force = Vector3.new(0,BulletMass * (196.2) - (WeaponData.BulletDrop) * (196.2), 0)
	local BF = Instance.new("BodyForce",bullet)

	bullet.CFrame = bulletCF
	bullet:ApplyImpulse(direction * WeaponData.MuzzleVelocity * WeaponModifications.MuzzleVelocity)
	BF.Force = Force

	game.Debris:AddItem(bullet, 5)

	CastRay(bullet, origin)
end


function MeleeCast()

	local re_cast
	-- Set an origin and directional vector
	local raycast_origin 	 = CurrentCamera.CFrame.Position
	local raycast_direction  = CurrentCamera.CFrame.LookVector * WeaponData.BladeRange

	local raycast_params = RaycastParams.new()
	raycast_params.FilterDescendantsInstances = Ignore_Model
	raycast_params.FilterType = Enum.RaycastFilterType.Exclude
	raycast_params.IgnoreWater = true
	
	local raycast_result = workspace:Raycast(raycast_origin, raycast_direction, raycast_params)

	if raycast_result then
		local Hit2 = raycast_result.Instance

		--Check if it's a hat or accessory
		if Hit2 and Hit2.Parent:IsA('Accessory') or Hit2.Parent:IsA('Hat') then

			for _,players in pairs(game.Players:GetPlayers()) do
				if players.Character then
					for i, hats in pairs(players.Character:GetChildren()) do
						if hats:IsA("Accessory") then
							table.insert(Ignore_Model, hats)
						end
					end
				end
			end

			return MeleeCast()
		end

		if Hit2 and Hit2.Name == "Ignorable" or Hit2.Name == "Glass" or Hit2.Name == "Ignore" or Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1"  or Hit2.Parent.Name == "Arm2" then
			table.insert(Ignore_Model, Hit2)
			return MeleeCast()
		end

		if Hit2 and Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1"  or Hit2.Parent.Name == "Arm2" then
			table.insert(Ignore_Model, Hit2.Parent)
			return MeleeCast()
		end

		if Hit2 and (Hit2.Transparency >= 1 or Hit2.CanCollide == false) and Hit2.Name ~= 'Head' and Hit2.Name ~= 'Right Arm' and Hit2.Name ~= 'Left Arm' and Hit2.Name ~= 'Right Leg' and Hit2.Name ~= 'Left Leg' and Hit2.Name ~= "UpperTorso" and Hit2.Name ~= "LowerTorso" and Hit2.Name ~= "RightUpperArm" and Hit2.Name ~= "RightLowerArm" and Hit2.Name ~= "RightHand" and Hit2.Name ~= "LeftUpperArm" and Hit2.Name ~= "LeftLowerArm" and Hit2.Name ~= "LeftHand" and Hit2.Name ~= "RightUpperLeg" and Hit2.Name ~= "RightLowerLeg" and Hit2.Name ~= "RightFoot" and Hit2.Name ~= "LeftUpperLeg" and Hit2.Name ~= "LeftLowerLeg" and Hit2.Name ~= "LeftFoot" and Hit2.Name ~= 'Armor' and Hit2.Name ~= 'EShield' then
			table.insert(Ignore_Model, Hit2)
			return MeleeCast()
		end
	end
	
	if not raycast_result then
		return
	end

	local found_human, vitima_human = CheckForHumanoid(raycast_result.Instance)
	
	HitMod.HitEffect(Ignore_Model, raycast_result.Position, raycast_result.Instance , raycast_result.Normal, raycast_result.Material, WeaponData)
	Event.HitEffect:FireServer(raycast_result.Position, raycast_result.Instance , raycast_result.Normal, raycast_result.Material, WeaponData)

	local hit_part = raycast_result.Instance

	if found_human == true and vitima_human.Health > 0 then
		local SKP_02 = SKP_01.."-"..player.UserId

		if hit_part.Name == "Head" or hit_part.Parent.Name == "Top" or hit_part.Parent.Name == "Headset" or hit_part.Parent.Name == "Olho" or hit_part.Parent.Name == "Face" or hit_part.Parent.Name == "Numero" then
			Thread:Spawn(function()
				Event.Damage:InvokeServer(WeaponTool, vitima_human, 0, 1, WeaponData, WeaponModifications, nil, nil, SKP_02)	
			end)

		elseif hit_part.Name == "Torso" or hit_part.Name == "UpperTorso" or hit_part.Name == "LowerTorso" or hit_part.Parent.Name == "Chest" or hit_part.Parent.Name == "Waist" or hit_part.Name == "RightUpperArm" or hit_part.Name == "RightLowerArm" or hit_part.Name == "RightHand" or hit_part.Name == "LeftUpperArm" or hit_part.Name == "LeftLowerArm" or hit_part.Name == "LeftHand" then
			Thread:Spawn(function()
				Event.Damage:InvokeServer(WeaponTool, vitima_human, 0, 2, WeaponData, WeaponModifications, nil, nil, SKP_02)	
			end)

		elseif hit_part.Name == "Right Arm" or hit_part.Name == "Right Leg" or hit_part.Name == "Left Leg" or hit_part.Name == "Left Arm" or hit_part.Name == "RightUpperLeg" or hit_part.Name == "RightLowerLeg" or hit_part.Name == "RightFoot" or hit_part.Name == "LeftUpperLeg" or hit_part.Name == "LeftLowerLeg" or hit_part.Name == "LeftFoot" then
			Thread:Spawn(function()
				Event.Damage:InvokeServer(WeaponTool, vitima_human, 0, 3, WeaponData, WeaponModifications, nil, nil, SKP_02)	
			end)

		end
	end
end

function UpdateGui()
	if not StatusGui or not WeaponData then return end
	
	local HUD = StatusGui.GunHUD

	if WeaponData ~= nil then

		if WeaponData.Jammed then
			HUD.B.BackgroundColor3 = Color3.fromRGB(255,0,0)
		else
			HUD.B.BackgroundColor3 = Color3.fromRGB(255,255,255)
		end

		if SafeMode then
			HUD.A.Visible = true
		else
			HUD.A.Visible = false
		end
		
		if IsAimming then
			HUD.Sens.Text = "ADS " .. (ADSSens/100)
			HUD.Sens.TextColor3 = Color3.fromRGB(255,255,255)
		elseif IsHipFiring then
			HUD.Sens.Text = "Hip " .. (ADSSens/100)
			HUD.Sens.TextColor3 = Color3.fromRGB(255,150, 0)
		else
			HUD.Sens.Text = "Cam " .. (CameraSens/100)
			HUD.Sens.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		if Ammo > 0 then
			HUD.B.Visible = true
		else
			HUD.B.Visible = false
		end

		if WeaponData.ShootType == 1 then
			HUD.FText.Text = "Semi"
		elseif WeaponData.ShootType == 2 then
			HUD.FText.Text = "Burst"
		elseif WeaponData.ShootType == 3 then
			HUD.FText.Text = "Auto"
		elseif WeaponData.ShootType == 4 then
			HUD.FText.Text = "Pump-Action"
		elseif WeaponData.ShootType == 5 then
			HUD.FText.Text = "Bolt-Action"
		end

		HUD.Sens.Text = (Sens/100)
		HUD.BText.Text = WeaponData.BulletType
		HUD.NText.Text = WeaponData.gunName

		if WeaponData.EnableZeroing then
			HUD.ZeText.Visible = true
			HUD.ZeText.Text = WeaponData.CurrentZero .." m"
		else
			HUD.ZeText.Visible = false
		end

		if WeaponData.MagCount then
			HUD.SAText.Text = math.ceil(StoredAmmo/WeaponData.Ammo)
			HUD.Magazines.Visible = true
			HUD.Bullets.Visible = false
		else
			HUD.SAText.Text = StoredAmmo
			HUD.Magazines.Visible = false
			HUD.Bullets.Visible = true
		end

		if Suppressor then
			HUD.Att.Silencer.Visible = true
		else
			HUD.Att.Silencer.Visible = false
		end


		if LaserAtt then
			HUD.Att.Laser.Visible = true
			if LaserActive then
				if InfraredMode then
					TS:Create(HUD.Att.Laser, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(0,255,0), ImageTransparency = .123}):Play()
				else
					TS:Create(HUD.Att.Laser, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = .123}):Play()
				end
			else
				TS:Create(HUD.Att.Laser, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,0,0), ImageTransparency = .5}):Play()
			end
		else
			HUD.Att.Laser.Visible = false
		end

		if HasBipodAtt then
			HUD.Att.Bipod.Visible = true
		else
			HUD.Att.Bipod.Visible = false
		end

		if TorchAtt then
			HUD.Att.Flash.Visible = true
			if TorchActive then
				TS:Create(HUD.Att.Flash, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = .123}):Play()
			else
				TS:Create(HUD.Att.Flash, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,0,0), ImageTransparency = .5}):Play()
			end
		else
			HUD.Att.Flash.Visible = false
		end

		if WeaponData.Type == "Grenade" then
			StatusGui.GrenadeForce.Visible = true
		else
			StatusGui.GrenadeForce.Visible = false
		end
	end
end

function CheckMagFunction()

	if IsAimming then
		IsAimming = false
		ToggleAim(IsAimming)
	end

	if StatusGui then
		local HUD = StatusGui.GunHUD

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
	
	Mouse1Down 	= false
	SafeMode 	= false
	CurrentGunStance 	= 0
	
	Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
	
	UpdateGui()
	MagCheckAnim()
	RunCheck()
end

function Grenade()
	if GrenadeDebounce then return end
	
	GrenadeDebounce = true
	GrenadeReady()

	repeat
		wait()
	until not CookingGrenade
	
	TossGrenade()
end

function TossGrenade()
	if not WeaponTool and not WeaponData or not GrenadeDebounce then return end
	
	local SKP_02 = SKP_01 .. "-" .. player.UserId
	
	GrenadeThrow()
	
	if not WeaponTool or not WeaponData then return end
	
	Event.Grenade:FireServer(WeaponTool,WeaponData,CurrentCamera.CFrame,CurrentCamera.CFrame.LookVector,GrenadeThrowPower,SKP_02)
	UnSet()
end

function GrenadeMode()
	if GrenadeThrowPower >= 150 then
		GrenadeThrowPower = 100
		StatusGui.GrenadeForce.Text = "Mid Throw"
	elseif GrenadeThrowPower >= 100 then
		GrenadeThrowPower = 50
		StatusGui.GrenadeForce.Text = "Low Throw"
	elseif GrenadeThrowPower >= 50 then
		GrenadeThrowPower = 150
		StatusGui.GrenadeForce.Text = "High Throw"
	end
end

function JamChance()
	if not WeaponData or not WeaponData.CanBreak or WeaponData.Jammed or Ammo - 1 <= 0 then
		return
	end
	
	local Jam = math.random(1000)
	if Jam > 2 then
		return
	end
	
	WeaponData.Jammed = true
	WeaponInHand.Handle.Click:Play()
end

function Jammed()
	if not WeaponData or WeaponData.Type ~= "Gun" or not WeaponData.Jammed then
		return
	end

	Mouse1Down = false
	IsReloading = true
	SafeMode = false
	CurrentGunStance = 0
	Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
	UpdateGui()

	JammedAnim()
	WeaponData.Jammed = false
	UpdateGui()
	IsReloading = false
	RunCheck()
end

function Reload()
	
	if WeaponData.Type == "Gun" and StoredAmmo > 0 and (Ammo < WeaponData.Ammo or WeaponData.IncludeChamberedBullet and Ammo < WeaponData.Ammo + 1) then

		Mouse1Down = false
		IsReloading = true
		SafeMode = false
		CurrentGunStance = 0
		Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
		UpdateGui()

		if WeaponData.ShellInsert then
			if Ammo > 0 then
				for i = 1,WeaponData.Ammo - Ammo do
					if not WeaponData or not WeaponInHand or not WeaponTool or CancelReload then
						break
					end
					
					if StoredAmmo > 0 and Ammo < WeaponData.Ammo then
						if CancelReload then
							break
						end
						
						ReloadAnim()
						Ammo = Ammo + 1
						StoredAmmo = StoredAmmo - 1
						UpdateGui()
					end
				end
			else
				TacticalReloadAnim()
				
				if not WeaponData or not WeaponInHand or not WeaponTool then
					IsReloading = false
					CancelReload = false
					return
				end
				
				Ammo = Ammo + 1
				StoredAmmo = StoredAmmo - 1
				UpdateGui()
				
				for i = 1,WeaponData.Ammo - Ammo do
					if not WeaponData or not WeaponInHand or not WeaponTool or CancelReload then
						break
					end
					
					if StoredAmmo > 0 and WeaponData and Ammo < WeaponData.Ammo then
						if CancelReload then
							break
						end
						
						ReloadAnim()
						Ammo = Ammo + 1
						StoredAmmo = StoredAmmo - 1
						UpdateGui()
					end
				end

			end
		else
			if Ammo > 0 then
				ReloadAnim()
			else
				TacticalReloadAnim()
			end
			
			if not WeaponData or not WeaponInHand or not WeaponTool then
				IsReloading = false
				CancelReload = false
				return
			end

			if (Ammo - (WeaponData.Ammo - StoredAmmo)) < 0 then
				Ammo = Ammo + StoredAmmo
				StoredAmmo = 0

			elseif Ammo <= 0 then
				StoredAmmo = StoredAmmo - (WeaponData.Ammo - Ammo)
				Ammo = WeaponData.Ammo

			elseif Ammo > 0 and WeaponData.IncludeChamberedBullet then
				StoredAmmo = StoredAmmo - (WeaponData.Ammo - Ammo) - 1
				Ammo = WeaponData.Ammo + 1

			elseif Ammo > 0 and not WeaponData.IncludeChamberedBullet then
				StoredAmmo = StoredAmmo - (WeaponData.Ammo - Ammo)
				Ammo = WeaponData.Ammo
			end
		end
		
		if WeaponData and WeaponInHand and WeaponTool then
			if WeaponData.Type == "Gun" and WeaponData.IsLauncher then
				-- Event.RepAmmo:FireServer(WeaponTool, Ammo, StoredAmmo, WeaponData.Jammed)
			end
		end
		
		CancelReload = false
		IsReloading = false
		
		if WeaponData and WeaponInHand and WeaponTool then
			RunCheck()
			UpdateGui()
		end
	end
end

function GunFx()
	local Muzzle = WeaponInHand.Handle.Muzzle
	
	if Suppressor then
		local new_sound = Muzzle.Supressor:Clone()
		new_sound.PlaybackSpeed = new_sound.PlaybackSpeed + math.random(-20, 20) / 1000
		new_sound.Parent = Muzzle
		new_sound.Name = "Firing"
		new_sound:Play()
		new_sound.PlayOnRemove = true
		new_sound:Destroy()
	else
		local new_sound = Muzzle.Fire:Clone()
		new_sound.PlaybackSpeed = new_sound.PlaybackSpeed + math.random(-20, 20) / 1000
		new_sound.Parent = Muzzle
		new_sound.Name = "Firing"
		new_sound:Play()
		new_sound.PlayOnRemove = true
		new_sound:Destroy()
	end
	
	if Muzzle:FindFirstChild("Echo") then
		local new_sound = Muzzle.Echo:Clone()
		new_sound.PlaybackSpeed = new_sound.PlaybackSpeed + math.random(-20, 20) / 1000
		new_sound.Parent = Muzzle
		new_sound.Name = "FireEcho"
		new_sound:Play()
		new_sound.PlayOnRemove = true
		new_sound:Destroy()
	end
	
	if WeaponData.FlashChance and math.random(1, 10) <= WeaponData.FlashChance and not FlashHider then
		if Muzzle:FindFirstChild("FlashFX") then
			Muzzle["FlashFX"].Enabled = true
			delay(0.1, function()
				if Muzzle:FindFirstChild("FlashFX") then
					Muzzle["FlashFX"].Enabled = false
				end
			end)
		end

		Muzzle["FlashFX[Flash]"]:Emit(10)
	end
	Muzzle["Smoke"]:Emit(10)

	if BSpread then
		BSpread = math.min(WeaponData.MaxSpread * WeaponModifications.MaxSpread, BSpread + WeaponData.AimInaccuracyStepAmount * WeaponModifications.AimInaccuracyStepAmount)
		RecoilPower =  math.min(WeaponData.MaxRecoilPower * WeaponModifications.MaxRecoilPower, RecoilPower + WeaponData.RecoilPowerStepAmount * WeaponModifications.RecoilPowerStepAmount)
	end

	GenerateBullet = GenerateBullet + 1
	LastSpreadUpdate = time()

	if Ammo > 0 or not WeaponData.SlideLock then
		TS:Create( WeaponInHand.Handle.Slide, TweenInfo.new(30/WeaponData.ShootRate,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,true,0), {C0 =  WeaponData.SlideEx:inverse() }):Play()
	elseif Ammo <= 0 and WeaponData.SlideLock then
		TS:Create( WeaponInHand.Handle.Slide, TweenInfo.new(30/WeaponData.ShootRate,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0), {C0 =  WeaponData.SlideEx:inverse() }):Play()
	end
	
	WeaponInHand.Handle.Chamber.Smoke:Emit(10)
	-- WeaponInHand.Handle.Chamber.Shell:Emit(1)
	
	for _, effect in pairs(WeaponInHand.Handle.Chamber:GetChildren()) do
		if effect.Name == "Shell" then
			effect:Emit(1)
		end
	end
end

function ShellCheck()
	if WeaponData.ShellEjectionMod and WeaponData.ShootType < 4 then
		if Engine.AmmoModels:FindFirstChild(WeaponData.BulletType) then
			CreateShell(WeaponData.BulletType, WeaponInHand.Handle.Chamber)
		else
			CreateShell("Default", WeaponInHand.Handle.Chamber)
		end
	end
end

function Shoot()
	if not WeaponData then return end
	
	if WeaponData and WeaponData.Type == "Gun" and not IsShooting and not IsReloading then

		if IsReloading or RunKeyDown or SafeMode or CheckingMag then
			Mouse1Down = false
			return
		end

		if Ammo <= 0 or WeaponData.Jammed then
			WeaponInHand.Handle.Click:Play()
			Mouse1Down = false
			return
		end

		Mouse1Down = true
		IsHipFiring = true
		UpdateSensitivity()

		task.delay(0, function()
			if WeaponData and WeaponData.ShootType == 1 then -- SEMI --
				IsShooting = true
				ShellCheck()
				
				Event.Atirar:FireServer(WeaponTool, Suppressor, FlashHider)
				ShellCheck()
				
				for _ =  1, WeaponData.Bullets do
					Thread:Spawn(CreateBullet)
				end
				
				Ammo = Ammo - 1
				
				GunFx()
				JamChance()
				UpdateGui()
				
				Thread:Spawn(Recoil)
				wait(60/WeaponData.ShootRate)
				IsShooting = false
				IsHipFiring = false
				
				UpdateSensitivity()

			elseif WeaponData and WeaponData.ShootType == 2 then -- BURST --
				for i = 1, WeaponData.BurstShot do
					if IsShooting or Ammo <= 0 or Mouse1Down == false or WeaponData.Jammed then
						break
					end
					
					IsShooting = true	
					
					Event.Atirar:FireServer(WeaponTool, Suppressor, FlashHider)
					ShellCheck()
					
					for _ =  1, WeaponData.Bullets do
						Thread:Spawn(CreateBullet)
					end
					
					Ammo = Ammo - 1
					
					GunFx()
					JamChance()
					UpdateGui()
					
					Thread:Spawn(Recoil)
					wait(60/WeaponData.ShootRate)
					IsShooting = false
				end
				
				IsHipFiring = false
				UpdateSensitivity()
				
			elseif WeaponData and WeaponData.ShootType == 3 then -- AUTO --
				while Mouse1Down do
					if IsShooting or Ammo <= 0 or WeaponData.Jammed then
						break
					end
					
					IsShooting = true	
					Event.Atirar:FireServer(WeaponTool,Suppressor,FlashHider)
					ShellCheck()
					
					for _ =  1, WeaponData.Bullets do
						Thread:Spawn(CreateBullet)
					end
					
					Ammo = Ammo - 1
					
					GunFx()
					JamChance()
					UpdateGui()
					
					Thread:Spawn(Recoil)
					wait(60/WeaponData.ShootRate)
					IsShooting = false
				end
				
				IsHipFiring = false
				UpdateSensitivity()
				
			elseif WeaponData and WeaponData.ShootType == 4 or WeaponData and WeaponData.ShootType == 5 then -- PUMP / BOLT Action
				IsShooting = true	
				Event.Atirar:FireServer(WeaponTool,Suppressor,FlashHider)
				
				for _ =  1, WeaponData.Bullets do
					Thread:Spawn(CreateBullet)
				end
				
				Ammo = Ammo - 1
				
				GunFx()
				UpdateGui()
				
				Thread:Spawn(Recoil)
				
				PumpAnim()
				RunCheck()
				
				IsShooting = false
				IsHipFiring = false
				
				UpdateSensitivity()
			end
		end)

	elseif WeaponData and WeaponData.Type == "Melee" and not RunKeyDown then
		if not IsShooting then
			IsShooting = true
			MeleeCast()
			meleeAttack()
			RunCheck()
			IsShooting = false
		end
	end
end

local L_150_ = {}

local LeanSpring = {}
LeanSpring.cornerPeek = SpringMod.new(0)
LeanSpring.cornerPeek.d = 1
LeanSpring.cornerPeek.s = 20
LeanSpring.peekFactor = math.rad(-15)
LeanSpring.dirPeek = 0

function L_150_.Update()

	LeanSpring.cornerPeek.t = LeanSpring.peekFactor * Virar
	local NewLeanCF = CFrame.fromAxisAngle(Vector3.new(0, 0, 1), LeanSpring.cornerPeek.p)
	CurrentCamera.CFrame = CurrentCamera.CFrame * NewLeanCF
end

game:GetService("RunService"):BindToRenderStep("Camera Update", 200, L_150_.Update)

function RunCheck()
	if RunKeyDown then
		Mouse1Down = false
		CurrentGunStance = 3
		Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
		SprintAnim()
	else
		if IsAimming then
			CurrentGunStance = 2
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
		else
			CurrentGunStance = 0
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
		end
		IdleAnim()
	end
end

function Stand()
	Stance:FireServer(Stances,Virar)
	TS:Create(Character.Humanoid, TweenInfo.new(.3), {CameraOffset = Vector3.new(CameraX,CameraY,0)} ):Play()

	StatusGui.MainFrame.Poses.Levantado.Visible = true
	StatusGui.MainFrame.Poses.Agaixado.Visible = false
	StatusGui.MainFrame.Poses.Deitado.Visible = false

	if IsSteady then
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

	-- IsStanced = false	

end

function Crouch()
	Stance:FireServer(Stances,Virar)
	TS:Create(Character.Humanoid, TweenInfo.new(.3), {CameraOffset = Vector3.new(CameraX,CameraY,0)} ):Play()

	StatusGui.MainFrame.Poses.Levantado.Visible = false
	StatusGui.MainFrame.Poses.Agaixado.Visible = true
	StatusGui.MainFrame.Poses.Deitado.Visible = false

	if script.Parent:GetAttribute("Injured") then
		Character.Humanoid.WalkSpeed = Config.InjuredCrouchWalkSpeed
		Character.Humanoid.JumpPower = 0
	else
		Character.Humanoid.WalkSpeed = Config.CrouchWalkSpeed
		Character.Humanoid.JumpPower = 0
	end

	-- IsStanced = true	
end

function Prone()
	Stance:FireServer(Stances,Virar)
	TS:Create(Character.Humanoid, TweenInfo.new(.3), {CameraOffset = Vector3.new(CameraX,CameraY,0)} ):Play()

	StatusGui.MainFrame.Poses.Levantado.Visible = false
	StatusGui.MainFrame.Poses.Agaixado.Visible = false
	StatusGui.MainFrame.Poses.Deitado.Visible = true
	
	if ACS_Client:GetAttribute("Surrender") then
		Character.Humanoid.WalkSpeed = 0
	else
		Character.Humanoid.WalkSpeed = Config.ProneWalksSpeed
	end
	
	Character.Humanoid.JumpPower = 0 
	-- IsStanced = true
end

function Lean()
	TS:Create(Character.Humanoid, TweenInfo.new(.3), {CameraOffset = Vector3.new(CameraX,CameraY,0)} ):Play()
	Stance:FireServer(Stances,Virar)

	if Virar == 0 then
		StatusGui.MainFrame.Poses.Esg_Left.Visible = false
		StatusGui.MainFrame.Poses.Esg_Right.Visible = false
	elseif Virar == 1 then
		StatusGui.MainFrame.Poses.Esg_Left.Visible = false
		StatusGui.MainFrame.Poses.Esg_Right.Visible = true
	elseif Virar == -1 then
		StatusGui.MainFrame.Poses.Esg_Left.Visible = true
		StatusGui.MainFrame.Poses.Esg_Right.Visible = false
	end
end

----------//Animation Loader\\----------
function EquipAnim()
	AnimDebounce = false
	pcall(function()
		AnimData.EquipAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
	AnimDebounce = true
end


function IdleAnim()
	pcall(function()
		AnimData.IdleAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
	AnimDebounce = true
end

function SprintAnim()
	AnimDebounce = false
	pcall(function()
		AnimData.SprintAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function HighReady()
	pcall(function()
		AnimData.HighReady({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function LowReady()
	pcall(function()
		AnimData.LowReady({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function Patrol()
	pcall(function()
		AnimData.Patrol({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function ReloadAnim()
	pcall(function()
		AnimData.ReloadAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function TacticalReloadAnim()
	pcall(function()
		AnimData.TacticalReloadAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function JammedAnim()
	pcall(function()
		AnimData.JammedAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function PumpAnim()
	IsReloading = true
	pcall(function()
		AnimData.PumpAnim({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
	IsReloading = false
end

function MagCheckAnim()
	CheckingMag = true
	pcall(function()
		AnimData.MagCheck({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
	CheckingMag = false
end

function meleeAttack()
	pcall(function()
		AnimData.meleeAttack({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function GrenadeReady()
	pcall(function()
		AnimData.GrenadeReady({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end

function GrenadeThrow()
	pcall(function()
		AnimData.GrenadeThrow({
			RArmWeld,
			LArmWeld,
			GunWeld,
			WeaponInHand,
			ViewModel,
		})
	end)
end
----------//Animation Loader\\----------

----------//KeyBinds\\----------
CAS:BindAction("Run", HandleAction, false, Enum.KeyCode.LeftShift)

CAS:BindAction("Stand", HandleAction, false, Enum.KeyCode.X)
CAS:BindAction("Crouch", HandleAction, false, Enum.KeyCode.C)
CAS:BindAction("NVG", HandleAction, false, Enum.KeyCode.N)

CAS:BindAction("ToggleWalk", HandleAction, false, Enum.KeyCode.Z)
CAS:BindAction("LeanLeft", HandleAction, false, Enum.KeyCode.Q)
CAS:BindAction("LeanRight", HandleAction, false, Enum.KeyCode.E)
----------//KeyBinds\\----------

----------//Gun System\\----------
local PendingTool = nil
Character.ChildAdded:connect(function(Tool)	
	if not Tool:IsA("Tool") then return end
	if Humanoid.Health <= 0 then return end
	if ToolEquip then return end
	
	local weapon_settings_module = Tool:FindFirstChild("ACS_Settings")
	if not weapon_settings_module then return end
	
	local weapon_settings = require(weapon_settings_module :: ModuleScript)
	local weapon_type = weapon_settings.Type
	
	if weapon_type ~= "Gun" and weapon_type ~= "Melee" and weapon_type ~= "Grenade" then
		return
	end
	
	if Humanoid.Sit and Humanoid.SeatPart and Humanoid.SeatPart:IsA("VehicleSeat") then
		return
	end
	
	PendingTool = Tool
	
	if not ToolEquip then
		Setup(Tool)
	elseif ToolEquip then
		pcall(function()
			UnSet()
			Setup(Tool)
		end)
	end
	
	--[[
	if Tool:IsA('Tool') and Humanoid.Health > 0 and not ToolEquip and Tool:FindFirstChild("ACS_Settings") ~= nil and (require(Tool.ACS_Settings).Type == 'Gun' or require(Tool.ACS_Settings).Type == 'Melee' or require(Tool.ACS_Settings).Type == 'Grenade') then
		local L_370_ = true
		if Character:WaitForChild('Humanoid').Sit and Character.Humanoid.SeatPart:IsA("VehicleSeat") or Character:WaitForChild('Humanoid').Sit and Character.Humanoid.SeatPart:IsA("VehicleSeat") then
			L_370_ = false;
		end

		if L_370_ then
			PendingTool = Tool
			if not ToolEquip then
				--pcall(function()
				Setup(Tool)
				--end)

			elseif ToolEquip then
				pcall(function()
					UnSet()
					Setup(Tool)
				end)
			end
		end
	end
	]]
end)

Character.ChildRemoved:connect(function(Tool)
	if Tool == WeaponTool then
		if ToolEquip then
			UnSet()
		end
	end
end)

Humanoid.Running:Connect(function(speed)
	CharacterSpeed = speed
	if speed > 0.1 then
		IsRunning = true
	else
		IsRunning = false
	end
end)

Humanoid.Swimming:Connect(function(speed)
	if IsSwimming then
		CharacterSpeed = speed
		if speed > 0.1 then
			IsRunning = true
		else
			IsRunning = false
		end
	end
end)

Humanoid.Died:Connect(function(speed)
	TS:Create(Character.Humanoid, TweenInfo.new(1), {CameraOffset = Vector3.new(0,0,0)} ):Play()
	ChangeStance = false
	Stand()
	Stances = 0
	Virar = 0
	CameraX = 0
	CameraY = 0
	Lean()
	Equipped = 0
	UnSet()
	Event.NVG:Fire(false)
end)

Humanoid.Seated:Connect(function(IsSeated, Seat)

	if IsSeated and Seat and (Seat:IsA("VehicleSeat")) then
		UnSet()
		Humanoid:UnequipTools()
		CanLean = false
		player.CameraMaxZoomDistance = Config.VehicleMaxZoom
	else
		player.CameraMaxZoomDistance = game.StarterPlayer.CameraMaxZoomDistance
	end

	if IsSeated  then
		IsSitting = true
		Stances = 0
		Virar = 0
		CameraX = 0
		CameraY = 0
		Stand()
		Lean()
	else
		IsSitting = false
		CanLean = true
	end
end)

Humanoid.Changed:connect(function(Property)
	if Config.AntiBunnyHop then
		if Property == "Jump" and Humanoid.Sit == true and Humanoid.SeatPart ~= nil then
			Humanoid.Sit = false
		elseif Property == "Jump" and Humanoid.Sit == false then
			if JumpDelay then
				Humanoid.Jump = false
				return false
			end
			JumpDelay = true
			delay(0, function()
				wait(Config.JumpCoolDown)
				JumpDelay = false
			end)
		end
	end
end)

Humanoid.StateChanged:connect(function(Old,state)
	if state == Enum.HumanoidStateType.Swimming then
		IsSwimming = true
		Stances = 0
		Virar = 0
		CameraX = 0
		CameraY = 0
		Stand()
		Lean()
	else
		IsSwimming = false
	end

	if Config.EnableFallDamage then
		if state == Enum.HumanoidStateType.Freefall and not IsFalling then
			IsFalling = true
			local curVel = 0
			local peak = 0

			while IsFalling do
				curVel = HumanoidRootPart.Velocity.magnitude
				peak = peak + 1
				Thread:Wait()
			end
			local damage = (curVel - (Config.MaxVelocity)) * Config.DamageMult
			if damage > 5 and peak > 20 then
				local SKP_02 = SKP_01.."-"..player.UserId

				CameraSpring:accelerate(Vector3.new(-damage/20, 0, math.random(-damage, damage)/5))
				SwaySpring:accelerate(Vector3.new( math.random(-damage, damage)/5, damage/5,0))

				local hurtSound = FX.FallDamage:Clone()
				hurtSound.Parent = player.PlayerGui
				hurtSound.Volume = damage/Humanoid.MaxHealth
				hurtSound:Play()
				Debris:AddItem(hurtSound,hurtSound.TimeLength)

				Event.Damage:InvokeServer(nil, nil, nil, nil, nil, nil, true, damage, SKP_02)

			end
		elseif state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Dead then
			IsFalling = false
			SwaySpring:accelerate(Vector3.new(0, 2.5, 0))
		end
	end
end)

mouse.WheelBackward:Connect(function() -- fires when the wheel goes forwards

	if ToolEquip and not CheckingMag and not IsAimming and not IsReloading and not RunKeyDown and AnimDebounce and WeaponData.Type == "Gun" then
		Mouse1Down = false
		if CurrentGunStance == 0 then
			SafeMode = true
			CurrentGunStance = -1
			UpdateGui()
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
			LowReady()
		elseif CurrentGunStance == -1 then
			SafeMode = true
			CurrentGunStance = -2
			UpdateGui()
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
			Patrol()
		elseif CurrentGunStance == 1 then
			SafeMode = false
			CurrentGunStance = 0
			UpdateGui()
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
			IdleAnim()
		end
	end

	if ToolEquip and IsAimming and Sens > 5 then
		Sens = Sens - 5
		UpdateGui()
		game:GetService('UserInputService').MouseDeltaSensitivity = (Sens/100)
	end

end)

mouse.WheelForward:Connect(function() -- fires when the wheel goes backwards

	if ToolEquip and not CheckingMag and not IsAimming and not IsReloading and not RunKeyDown and AnimDebounce and WeaponData.Type == "Gun" then
		Mouse1Down = false
		if CurrentGunStance == 0 then
			SafeMode = true
			CurrentGunStance = 1
			UpdateGui()
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
			HighReady()
		elseif CurrentGunStance == -1 then
			SafeMode = false
			CurrentGunStance = 0
			UpdateGui()
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
			IdleAnim()
		elseif CurrentGunStance == -2 then
			SafeMode = true
			CurrentGunStance = -1
			UpdateGui()
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
			LowReady()
		end
	end

	if ToolEquip and IsAimming and Sens < 100 then
		Sens = Sens + 5
		UpdateGui()
		game:GetService('UserInputService').MouseDeltaSensitivity = (Sens/100)
	end

end)

script.Parent:GetAttributeChangedSignal("Injured"):Connect(function()
	local valor = script.Parent:GetAttribute("Injured")

	if valor and RunKeyDown then
		RunKeyDown 	= false
		Stand()
		if not CheckingMag and not IsReloading and WeaponData and WeaponData.Type ~= "Grenade" and (CurrentGunStance == 0 or CurrentGunStance == 2 or CurrentGunStance == 3) then
			CurrentGunStance = 0
			Event.CurrentGunStance:FireServer(CurrentGunStance,AnimData)
			IdleAnim()
		end
	end

	if Stances == 0 then
		Stand()
	elseif Stances == 1 then
		Crouch()
	end

end)

----------//Gun System\\----------

----------//Health HUD\\----------
BloodScreen:Play()
BloodScreenLowHP:Play()
Humanoid.HealthChanged:Connect(function(Health)
	StatusGui.Efeitos.Health.ImageTransparency = ((Health - (Humanoid.MaxHealth/2))/(Humanoid.MaxHealth/2))
	StatusGui.Efeitos.LowHealth.ImageTransparency = (Health /(Humanoid.MaxHealth/2))
end)
----------//Health HUD\\----------

----------//Render Functions\\----------
Run.RenderStepped:Connect(function(step)
	RenderGunRecoil()
	RenderCam()

	if ViewModel and LArm and RArm and WeaponInHand then --Check if the weapon and arms are loaded

		local mouse_delta = UIS:GetMouseDelta()
		SwaySpring:accelerate(Vector3.new(mouse_delta.x / 60, mouse_delta.y / 60, 0))

		local swayVec = SwaySpring.p
		local TSWAY = swayVec.z
		local XSSWY = swayVec.X
		local YSSWY = swayVec.Y
		local Sway = CFrame.Angles(YSSWY,XSSWY,XSSWY)

		if HasBipodAtt then
			local origin = UnderBarrelAtt.Main.Position
			local direction = Vector3.new(0, -1.75, 0)
			
			local raycast_params = RaycastParams.new()
			raycast_params.FilterDescendantsInstances = { Ignore_Model }
			raycast_params.FilterType = Enum.RaycastFilterType.Exclude
			raycast_params.IgnoreWater = true
			raycast_params.RespectCanCollide = true
			
			local raycast_result = workspace:Raycast(origin, direction, raycast_params)

			if raycast_result then
				CanBipod = true
				if CanBipod and BipodActive and not RunKeyDown and (CurrentGunStance == 0 or CurrentGunStance == 2) then
					TS:Create(StatusGui.GunHUD.Att.Bipod, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = .123}):Play()
					if not IsAimming then
						BipodCF = BipodCF:Lerp(CFrame.new(0,(((UnderBarrelAtt.Main.Position - raycast_result).magnitude)-1) * (-1.5), 0),.2)
					else
						BipodCF = BipodCF:Lerp(CFrame.new(),.2)
					end				

				else
					BipodActive = false
					BipodCF = BipodCF:Lerp(CFrame.new(),.2)
					TS:Create(StatusGui.GunHUD.Att.Bipod, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,255,0), ImageTransparency = .5}):Play()
				end
			else
				BipodActive = false
				CanBipod = false
				BipodCF = BipodCF:Lerp(CFrame.new(),.2)
				TS:Create(StatusGui.GunHUD.Att.Bipod, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,0,0), ImageTransparency = .5}):Play()
			end

		end

		AnimPart.CFrame = CurrentCamera.CFrame * NearZ * BipodCF * MainCFrame * GunBobCFrame * AimCFrame

		if not AnimData.GunModelFixed then
			WeaponInHand:SetPrimaryPartCFrame(
				ViewModel.PrimaryPart.CFrame
					* GunCFrame
			)
		end

		if IsRunning then
			GunBobCFrame = GunBobCFrame:Lerp(CFrame.new(
				0.025 * (CharacterSpeed/10) * math.sin(tick() * 8),
				0.025 * (CharacterSpeed/10) * math.cos(tick() * 16),
				0
				) * CFrame.Angles(
					math.rad( 1 * (CharacterSpeed/10) * math.sin(tick() * 16) ), 
					math.rad( 1 * (CharacterSpeed/10) * math.cos(tick() * 8) ), 
					math.rad(0)
				), 0.1)
		else
			GunBobCFrame = GunBobCFrame:Lerp(CFrame.new(
				0.005 * math.sin(tick() * 1.5),
				0.005 * math.cos(tick() * 2.5),
				0 
				), 0.1)
		end

		if CurrentAimPart and IsAimming and AnimDebounce and not CheckingMag then
			if not NVG or WeaponInHand.AimPart:FindFirstChild("NVAim") == nil then
				if CurrentAimPartMode == 1 then
					TS:Create(CurrentCamera,AimTweenInfo,{FieldOfView = WeaponModifications.ZoomValue}):Play()
					MainCFrame = MainCFrame:Lerp(MainCFrame * CFrame.new(0,0,-.5) * RecoilCFrame * Sway:inverse() * CurrentAimPart.CFrame:toObjectSpace(CurrentCamera.CFrame), 0.2)
				else
					TS:Create(CurrentCamera,AimTweenInfo,{FieldOfView = WeaponModifications.Zoom2Value}):Play()
					MainCFrame = MainCFrame:Lerp(MainCFrame * CFrame.new(0,0,-.5) * RecoilCFrame * Sway:inverse() * CurrentAimPart.CFrame:toObjectSpace(CurrentCamera.CFrame), 0.2)
				end
			else
				TS:Create(CurrentCamera,AimTweenInfo,{FieldOfView = 70}):Play()
				MainCFrame = MainCFrame:Lerp(MainCFrame * CFrame.new(0,0,-.5) * RecoilCFrame * Sway:inverse() * (WeaponInHand.AimPart.CFrame * WeaponInHand.AimPart.NVAim.CFrame):toObjectSpace(CurrentCamera.CFrame), 0.2)
			end

		else
			TS:Create(CurrentCamera,AimTweenInfo,{FieldOfView = 70}):Play()
			MainCFrame = MainCFrame:Lerp(AnimData.MainCFrame * RecoilCFrame * Sway:inverse(), 0.2)   
		end

		for index, Part in pairs(WeaponInHand:GetDescendants()) do
			if Part:IsA("BasePart") and Part.Name == "SightMark" then
				local dist_scale = Part.CFrame:pointToObjectSpace(CurrentCamera.CFrame.Position)/Part.Size
				local Reticle = Part.SurfaceGui.Border.Scope	
				Reticle.Position=UDim2.new(.5+dist_scale.x,0,.5-dist_scale.y,0)	
			end
		end

		RecoilCFrame = RecoilCFrame:Lerp(CFrame.new() * CFrame.Angles( math.rad(RecoilSpring.p.X), math.rad(RecoilSpring.p.Y), math.rad(RecoilSpring.p.z)), 0.2)


		if WeaponData.CrossHair then
			if IsAimming then
				CrosshairUpPos = CrosshairUpPos:Lerp(UDim2.new(.5,0,.5,0),0.2)
				CrosshairDownPos = CrosshairDownPos:Lerp(UDim2.new(.5,0,.5,0),0.2)
				CrosshairLeftPos = CrosshairLeftPos:Lerp(UDim2.new(.5,0,.5,0),0.2)
				CrosshairRightPos = CrosshairRightPos:Lerp(UDim2.new(.5,0,.5,0),0.2)
			else
				local Normalized = ((WeaponData.CrosshairOffset + BSpread + (CharacterSpeed * WeaponData.WalkMult * WeaponModifications.WalkMult) ) / 50)/10

				CrosshairUpPos = CrosshairUpPos:Lerp(UDim2.new(0.5, 0, 0.5 - Normalized,0),0.5)
				CrosshairDownPos = CrosshairDownPos:Lerp(UDim2.new(.5, 0, 0.5 + Normalized,0),0.5)
				CrosshairLeftPos = CrosshairLeftPos:Lerp(UDim2.new(.5 - Normalized, 0, 0.5, 0),0.5)
				CrosshairRightPos = CrosshairRightPos:Lerp(UDim2.new(.5 + Normalized, 0, 0.5, 0),0.5)
			end

			Crosshair.Position = UDim2.new(0,mouse.X,0,mouse.Y)

			Crosshair.Up.Position = CrosshairUpPos
			Crosshair.Down.Position = CrosshairDownPos
			Crosshair.Left.Position = CrosshairLeftPos
			Crosshair.Right.Position = CrosshairRightPos

		else

			CrosshairUpPos = CrosshairUpPos:Lerp(UDim2.new(.5,0,.5,0),0.2)
			CrosshairDownPos = CrosshairDownPos:Lerp(UDim2.new(.5,0,.5,0),0.2)
			CrosshairLeftPos = CrosshairLeftPos:Lerp(UDim2.new(.5,0,.5,0),0.2)
			CrosshairRightPos = CrosshairRightPos:Lerp(UDim2.new(.5,0,.5,0),0.2)

			Crosshair.Position = UDim2.new(0,mouse.X,0,mouse.Y)

			Crosshair.Up.Position = CrosshairUpPos
			Crosshair.Down.Position = CrosshairDownPos
			Crosshair.Left.Position = CrosshairLeftPos
			Crosshair.Right.Position = CrosshairRightPos

		end

		if BSpread then
			local currTime = time()
			if currTime - LastSpreadUpdate > (60/WeaponData.ShootRate) * 2 and not IsShooting and BSpread > WeaponData.MinSpread * WeaponModifications.MinSpread then
				BSpread = math.max(WeaponData.MinSpread * WeaponModifications.MinSpread, BSpread - WeaponData.AimInaccuracyDecrease * WeaponModifications.AimInaccuracyDecrease)
			end
			if currTime - LastSpreadUpdate > (60/WeaponData.ShootRate) * 1.5 and not IsShooting and RecoilPower > WeaponData.MinRecoilPower * WeaponModifications.MinRecoilPower then
				RecoilPower =  math.max(WeaponData.MinRecoilPower * WeaponModifications.MinRecoilPower, RecoilPower - WeaponData.RecoilPowerStepAmount * WeaponModifications.RecoilPowerStepAmount)
			end
		end

		if LaserActive and Pointer ~= nil then

			if NVG then
				Pointer.Transparency = 0
				Pointer.Beam.Enabled = true
			else
				if not Config.RealisticLaser then
					Pointer.Beam.Enabled = true
				else
					Pointer.Beam.Enabled = false
				end
				if InfraredMode then
					Pointer.Transparency = 1
				else
					Pointer.Transparency = 0
				end
			end
			
			local raycast_params = RaycastParams.new()
			raycast_params.FilterDescendantsInstances = { Ignore_Model }
			raycast_params.FilterType = Enum.RaycastFilterType.Exclude
			raycast_params.IgnoreWater = true
			raycast_params.RespectCanCollide = true
			
			for index, Key in pairs(WeaponInHand:GetDescendants()) do
				if Key:IsA("BasePart") and Key.Name == "LaserPoint" then
					local origin = Key.CFrame.Position
					local direction = Key.CFrame.LookVector * 1000
					
					local raycast_result = workspace:Raycast(origin, direction, raycast_params)
					local hit_position = nil

					if raycast_result then
						Pointer.CFrame =  CFrame.new(raycast_result.Position, raycast_result.Position + raycast_result.Normal)
						hit_position = raycast_result.Position
					else
						Pointer.CFrame =  CFrame.new(CurrentCamera.CFrame.Position + Key.CFrame.LookVector * 2000, Key.CFrame.LookVector)
					end

					if Config.ReplicatedLaser then
						Event.SVLaser:FireServer(hit_position, 1, Pointer.Color, InfraredMode, WeaponTool)
					end
					break
				end
			end
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

	UpdateGui()

	if not Infinite then
		Event.Refil:FireServer(Stored, NewStored)
	end

end)
----------//Events\\----------