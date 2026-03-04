repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local RS 			= game:GetService("ReplicatedStorage")
local User 			= game:GetService("UserInputService")
local CAS 			= game:GetService("ContextActionService")
local Run 			= game:GetService("RunService")
local TS 			= game:GetService('TweenService')
local Debris 		= game:GetService("Debris")

local Engine 			= RS:WaitForChild("ACS_Engine")
local Event 			= Engine:WaitForChild("Events")
local HUDs 				= Engine:WaitForChild("HUD")
local Rules				= Engine:WaitForChild("GameRules")
local FX				= Engine:WaitForChild("FX")

local Mods 				= Engine:WaitForChild("Modules")
local CoreMods			= Mods:WaitForChild("Core")
local WeaponMods 		= Mods:WaitForChild("Weapon")

local gameRules		= require(Rules:WaitForChild("Config"))
local HitMod 		= require(Mods:WaitForChild("Hitmarker"))
local ObjectPool    = require(CoreMods:WaitForChild("ObjectPool"))
local WeaponRegistry= require(WeaponMods:WaitForChild("WeaponRegistry"))
local Util 			= require(Mods:WaitForChild("Utilities"))

local Player 		= game.Players.LocalPlayer
local Mouse 		= Player:GetMouse()
local CurrentCamera = workspace.CurrentCamera
local ACS_Workspace = workspace.ACS_WorkSpace

local WhizzSound = {"4872110675"; "5303773495"; "5303772965"; "5303773495"; "5303772257"; "342190005"; "342190012"; "342190017"; "342190024";}
local Ignore_Model = {CurrentCamera, Player.Character, ACS_Workspace.Client, ACS_Workspace.Server}

ObjectPool.Register(
	"ServerBulletTrace",
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

ObjectPool.Register(
	"ServerBulletTracerAttachment",
	function()
		local att = Instance.new("Attachment")
		att.Name = "At1"
		return att
	end,
	function(att)
		att.Position = Vector3.new(-0.05, 0, 0)
	end,
	15
)

ObjectPool.Register(
	"ServerBulletTracerAttachment2",
	function()
		local att = Instance.new("Attachment")
		att.Name = "At2"
		return att
	end,
	function(att)
		att.Position = Vector3.new(-0.05, 0, 0)
	end,
	15
)

ObjectPool.Register(
	"ServerBulletTrail",
	function()
		local trail = Instance.new("Trail")
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0, 0);
			NumberSequenceKeypoint.new(1, 1);
		})

		trail.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2, 0);
			NumberSequenceKeypoint.new(1, 1);
		})

		trail.Texture = "rbxassetid://232918622"
		trail.TextureMode = Enum.TextureMode.Stretch

		trail.FaceCamera = true
		trail.LightEmission = 1
		trail.LightInfluence = 0
		trail.Lifetime = 0.25
		return trail
	end,
	function(trail)
		trail.Enabled = true
		trail.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		trail.Attachment0 = nil
		trail.Attachment1 = nil
	end,
	15
)

local NVG = false
Event.NVG.Event:Connect(function(value)
	NVG = value
end)

Event.HitEffect.OnClientEvent:Connect(function(player, position, hit_part, normal, material)
	if player ~= Player then
		HitMod.HitEffect(Ignore_Model, position, hit_part, normal, material)
	end
end)

Event.Weapon.Shoot.OnClientEvent:Connect(function(player, suppressor, flash_hider)
	if player == Player then return end

	local character = player.Character
	if not character then return end

	local weapon_in_hand = WeaponRegistry.GetWeaponInHand()
	if not weapon_in_hand then return end

	if character:FindFirstChild("SG-" .. weapon_in_hand.Name) and character:FindFirstChild("SG-" .. weapon_in_hand.Name).Handle:FindFirstChild("Muzzle") then
		local handle = character:FindFirstChild("SG-" .. weapon_in_hand.Name).Handle
		if not handle then return end
		local muzzle = handle.Muzzle

		if not muzzle or not muzzle:IsA("Attachment") then
			for _, child in ipairs(handle:GetChildren()) do
				if child.Name == "Muzzle" and child:IsA("Attachment") then
					muzzle = child
					break
				end
			end
		end

		if not muzzle then
			Util.LogTagged("ACS_EventHandler", "Muzzle attachment is not found")
			return
		end

		if suppressor then
			muzzle.Supressor:Play()
		else
			muzzle.Fire:Play()
		end

		if flash_hider then
			muzzle["Smoke"]:Emit(10)
		else
			muzzle["FlashFX[Flash]"]:Emit(10)
			muzzle["Smoke"]:Emit(10)
		end
	end

	if character:FindFirstChild("AnimBase") ~= nil and character.AnimBase:FindFirstChild("AnimBaseW") then
		local AnimBase = character:WaitForChild("AnimBase"):WaitForChild("AnimBaseW")
		TS:Create(AnimBase, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut,0,false,0), {C1 =  CFrame.new(0,0,0.15):Inverse()} ):Play()
		task.delay(0.1, function()
			TS:Create(AnimBase, TweenInfo.new(0.05,Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0), {C1 =  CFrame.new():Inverse()} ):Play()
		end)
	end
end)

Event.SVLaser.OnClientEvent:Connect(function(player, position, mode, Cor, IR, weapon_tool)
	if player == Player then return end
	
	local character = player.Character
	if not character then return end

	if weapon_tool then

		if ACS_Workspace.Server:FindFirstChild(player.Name .. "_Laser") == nil then
			local Dot = Instance.new('Part', ACS_Workspace.Server)
			local Att0 = Instance.new('Attachment', Dot)
			Att0.Name = "Att0"
			Dot.Name = player.Name .. "_Laser"
			Dot.Transparency = 1

			if character:FindFirstChild("SG-" .. weapon_tool.Name) and character:FindFirstChild("SG-" .. weapon_tool.Name).Handle:FindFirstChild("Muzzle") then
				local Muzzle = character:FindFirstChild("SG-" .. weapon_tool.Name).Handle.Muzzle

				local Laser = Instance.new('Beam', Dot)
				Laser.Transparency = NumberSequence.new(0)
				Laser.LightEmission = 1
				Laser.LightInfluence = 0
				Laser.Attachment0 = Att0
				Laser.Attachment1 = Muzzle
				Laser.Color = ColorSequence.new(Cor)
				Laser.FaceCamera = true
				Laser.Width0 = 0.01
				Laser.Width1 = 0.01
				if not NVG then
					Laser.Enabled = false
				end
			end
		end

		if mode == 1 then
			if ACS_Workspace.Server:FindFirstChild(player.Name.."_Laser") then
				local LA = ACS_Workspace.Server:FindFirstChild(player.Name.."_Laser")
				LA.Shape = 'Ball'
				LA.Size = Vector3.new(0.2, 0.2, 0.2)
				LA.CanCollide = false
				LA.Anchored = true
				LA.Color = Cor
				LA.Material = Enum.Material.Neon
				LA.Position = position
				if NVG then
					LA.Transparency = 0

					if LA:FindFirstChild("Beam") then
						LA.Beam.Enabled = true
					end
				else
					if IR then
						LA.Transparency = 1
					else
						LA.Transparency = 0
					end

					if LA:FindFirstChild("Beam") then
						LA.Beam.Enabled = false
					end
				end
			end

		elseif mode == 2 then
			if ACS_Workspace.Server:FindFirstChild(player.Name.."_Laser") then
				ACS_Workspace.Server:FindFirstChild(player.Name.."_Laser"):Destroy()
			end
		end
	end
end)

Event.SVFlash.OnClientEvent:Connect(function(player, Arma, Mode)
	if player ~= Player and player.Character and Arma then
		local Weapon = player.Character:FindFirstChild("SG-" .. Arma.Name)
		if Weapon then
			if Mode then
				for _, Key in pairs(Weapon:GetDescendants()) do
					if Key:IsA("BasePart") and Key.Name == "FlashPoint" then
						Key.Light.Enabled = true
					end
				end
			else
				for _, Key in pairs(Weapon:GetDescendants()) do
					if Key:IsA("BasePart") and Key.Name == "FlashPoint" then
						Key.Light.Enabled = false
					end
				end
			end
		end
	end
end)

Event.Whizz.OnClientEvent:Connect(function()
	local Som = Instance.new('Sound')
	Som.Parent = Player.PlayerGui
	Som.SoundId = "rbxassetid://" .. WhizzSound[math.random(1, #WhizzSound)]
	Som.Volume = 2
	Som.PlayOnRemove = true

	Som:Destroy()
end)

Event.MedSys.MedHandler.OnClientEvent:Connect(function(Mode)

	if Mode == 4 then
		local color_correction_effect = Instance.new('ColorCorrectionEffect')
		color_correction_effect.Parent = CurrentCamera

		TS:Create(color_correction_effect,TweenInfo.new(.15,Enum.EasingStyle.Linear),{Contrast = -.25}):Play()
		task.delay(.15,function()
			TS:Create(color_correction_effect,TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In,0,false,0.15),{Contrast = 0}):Play()
			Debris:AddItem(color_correction_effect,1.5)
		end)

	elseif Mode == 5 then
		local color_correction_effect = Instance.new('ColorCorrectionEffect')
		color_correction_effect.Parent = CurrentCamera

		TS:Create(color_correction_effect,TweenInfo.new(.15,Enum.EasingStyle.Linear),{Contrast = .5}):Play()
		task.delay(.15,function()
			TS:Create(color_correction_effect,TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In,0,false,0.15),{Contrast = 0}):Play()
			Debris:AddItem(color_correction_effect,1.5)
		end)

	elseif Mode == 6 then
		local color_correction_effect = Instance.new('ColorCorrectionEffect')
		color_correction_effect.Parent = CurrentCamera

		TS:Create(color_correction_effect,TweenInfo.new(.15,Enum.EasingStyle.Linear),{Contrast = -.25}):Play()
		task.delay(.15,function()
			TS:Create(color_correction_effect,TweenInfo.new(60,Enum.EasingStyle.Sine,Enum.EasingDirection.In,0,false,0.15),{Contrast = 0}):Play()
			Debris:AddItem(color_correction_effect,60)
		end)

	elseif Mode == 7 then
		local color_correction_effect = Instance.new('ColorCorrectionEffect')
		color_correction_effect.Parent = CurrentCamera

		TS:Create(color_correction_effect,TweenInfo.new(.15,Enum.EasingStyle.Linear),{Contrast = .5}):Play()
		task.delay(.15,function()
			TS:Create(color_correction_effect,TweenInfo.new(30,Enum.EasingStyle.Sine,Enum.EasingDirection.In,0,false,0.15),{Contrast = 0}):Play()
			Debris:AddItem(color_correction_effect,30)
		end)
	end

end)

Event.Suppression.OnClientEvent:Connect(function(mode, intensity, tempo)
	local status_gui = Player.PlayerGui:FindFirstChild("StatusUI")
	if Player.Character and Player.Character.Humanoid.Health > 0 and status_gui then
		if mode == 1 then

			TS:Create(status_gui.Efeitos.Suppress,TweenInfo.new(.1),{ImageTransparency = 0, Size = UDim2.fromScale(1,1.15)}):Play()
			task.delay(.1,function()
				TS:Create(status_gui.Efeitos.Suppress,TweenInfo.new(1,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut,0,false,0.15),{ImageTransparency = 1,Size = UDim2.fromScale(2,2)}):Play()
			end)
		elseif mode == 2 then

			local ear_ring = FX.SoundFX.EarRing:Clone()
			ear_ring.Parent = Player.PlayerGui
			ear_ring.Volume = 0
			ear_ring:Play()
			Debris:AddItem(ear_ring, tempo)

			TS:Create(ear_ring, TweenInfo.new(.1),{Volume = 2}):Play()
			task.delay(.1,function()
				TS:Create(ear_ring,TweenInfo.new(tempo,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0.15),{Volume = 0}):Play()
			end)

			TS:Create(status_gui.Efeitos.Dirty,TweenInfo.new(.1),{ImageTransparency = 0, Size = UDim2.fromScale(1,1.15)}):Play()
			task.delay(.1,function()
				TS:Create(status_gui.Efeitos.Dirty,TweenInfo.new(tempo,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut,0,false,0.15),{ImageTransparency = 1,Size = UDim2.fromScale(2,2)}):Play()
			end)

		else

			local ear_ring = FX.SoundFX.EarRing:Clone()
			ear_ring.Parent = Player.PlayerGui
			ear_ring.Volume = 0
			ear_ring:Play()
			Debris:AddItem(ear_ring, tempo)

			TS:Create(ear_ring,TweenInfo.new(.1),{Volume = 2}):Play()
			task.delay(.1,function()
				TS:Create(ear_ring,TweenInfo.new(tempo,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0.15),{Volume = 0}):Play()
			end)
		end
	end
end)

Event.CurrentGunStance.OnClientEvent:Connect(function(player, stance, anim_data)
	local character = player.Character
	local anim_base = character.AnimBase
	
	if
		character.Humanoid.Health > 0
		and character:FindFirstChild("AnimBase") ~= nil
		and anim_base:FindFirstChild("RAW") ~= nil
		and anim_base:FindFirstChild("LAW") ~= nil
	then
		local Right_Weld = anim_base:WaitForChild("RAW")
		local Left_Weld = anim_base:WaitForChild("LAW")

		local RightElbow = anim_base:FindFirstChild("RLAW")
		local LeftElbow = anim_base:FindFirstChild("LLAW")

		local RightWrist = anim_base:FindFirstChild("RHW")
		local LeftWrist = anim_base:FindFirstChild("LHW")

		-- Only proceed if we have the required welds
		if not Right_Weld or not Left_Weld then
			return
		end

		local RECFrame = CFrame.new(0, character.RightUpperArm.Size.Y / 2, 0)
		local RWCFrame = CFrame.new(0, character.RightLowerArm.Size.Y / 1.9, 0)

		local LECFrame = CFrame.new(0, character.LeftUpperArm.Size.Y / 2, 0)
		local LWCFrame = CFrame.new(0, character.LeftLowerArm.Size.Y / 1.9, 0)

		local function SafeTween(weld, targetCF)
			if weld and targetCF then
				TS:Create(weld, TweenInfo.new(0.25, Enum.EasingStyle.Sine), { C0 = targetCF }):Play()
			end
		end

		if stance == 0 then
			-- Hip fire/default stance
			SafeTween(Right_Weld, anim_data.SV_RightArmPos)
			SafeTween(Left_Weld, anim_data.SV_LeftArmPos)

			-- For R15, use specific elbow/wrist positions if available, otherwise use defaults
			if RightElbow then
				SafeTween(RightElbow, RECFrame * (anim_data.SV_RightElbowPos or CFrame.new()))
			end

			if RightWrist then
				SafeTween(RightWrist, RWCFrame * (anim_data.SV_RightWristPos or CFrame.new()))
			end

			if LeftElbow then
				SafeTween(LeftElbow, LECFrame * (anim_data.SV_LeftElbowPos or CFrame.new()))
			end

			if LeftWrist then
				SafeTween(LeftWrist, LWCFrame * (anim_data.SV_LeftWristPos or CFrame.new()))
			end
		elseif stance == 2 then
			-- Aim stance
			SafeTween(Right_Weld, anim_data.RightAim)
			SafeTween(Left_Weld, anim_data.LeftAim)

			if RightElbow and anim_data.RightElbowAim then
				SafeTween(RightElbow, RECFrame * anim_data.RightElbowAim)
			end

			if RightWrist and anim_data.RightWristAim then
				SafeTween(RightWrist, RWCFrame * anim_data.RightWristAim)
			end

			if LeftElbow and anim_data.LeftElbowAim then
				SafeTween(LeftElbow, LECFrame * anim_data.LeftElbowAim)
			end

			if LeftWrist and anim_data.LeftWristAim then
				SafeTween(LeftWrist, LWCFrame * anim_data.LeftWristAim)
			end
		elseif stance == 1 then
			-- High ready stance
			SafeTween(Right_Weld, anim_data.RightHighReady)
			SafeTween(Left_Weld, anim_data.LeftHighReady)

			if RightElbow and anim_data.RightElbowHighReady then
				SafeTween(RightElbow, RECFrame * anim_data.RightElbowHighReady)
			end

			if RightWrist and anim_data.RightWristHighReady then
				SafeTween(RightWrist, RWCFrame * anim_data.RightWristHighReady)
			end

			if LeftElbow and anim_data.LeftElbowHighReady then
				SafeTween(LeftElbow, LECFrame * anim_data.LeftElbowHighReady)
			end

			if LeftWrist and anim_data.LeftWristHighReady then
				SafeTween(LeftWrist, LWCFrame * anim_data.LeftWristHighReady)
			end
		elseif stance == -1 then
			-- Low ready stance
			SafeTween(Right_Weld, anim_data.RightLowReady)
			SafeTween(Left_Weld, anim_data.LeftLowReady)

			if RightElbow and anim_data.RightElbowLowReady then
				SafeTween(RightElbow, RECFrame * anim_data.RightElbowLowReady)
			end

			if RightWrist and anim_data.RightWristLowReady then
				SafeTween(RightWrist, RWCFrame * anim_data.RightWristLowReady)
			end

			if LeftElbow and anim_data.LeftElbowLowReady then
				SafeTween(LeftElbow, LECFrame * anim_data.LeftElbowLowReady)
			end

			if LeftWrist and anim_data.LeftWristLowReady then
				SafeTween(LeftWrist, LWCFrame * anim_data.LeftWristLowReady)
			end
		elseif stance == -2 then
			-- Patrol stance
			SafeTween(Right_Weld, anim_data.RightPatrol)
			SafeTween(Left_Weld, anim_data.LeftPatrol)

			if RightElbow and anim_data.RightElbowPatrol then
				SafeTween(RightElbow, RECFrame * anim_data.RightElbowPatrol)
			end

			if RightWrist and anim_data.RightWristPatrol then
				SafeTween(RightWrist, RWCFrame * anim_data.RightWristPatrol)
			end

			if LeftElbow and anim_data.LeftElbowPatrol then
				SafeTween(LeftElbow, LECFrame * anim_data.LeftElbowPatrol)
			end

			if LeftWrist and anim_data.LeftWristPatrol then
				SafeTween(LeftWrist, LWCFrame * anim_data.LeftWristPatrol)
			end
		elseif stance == 3 then
			-- Sprint stance
			SafeTween(Right_Weld, anim_data.RightSprint)
			SafeTween(Left_Weld, anim_data.LeftSprint)

			if RightElbow and anim_data.RightElbowSprint then
				SafeTween(RightElbow, RECFrame * anim_data.RightElbowSprint)
			end

			if RightWrist and anim_data.RightWristSprint then
				SafeTween(RightWrist, RWCFrame * anim_data.RightWristSprint)
			end

			if LeftElbow and anim_data.LeftElbowSprint then
				SafeTween(LeftElbow, LECFrame * anim_data.LeftElbowSprint)
			end

			if LeftWrist and anim_data.LeftWristSprint then
				SafeTween(LeftWrist, LWCFrame * anim_data.LeftWristSprint)
			end
		end
	end
end)

function ProcessBulletTrace(bullet)
	if not bullet then return end

	local Bpos = bullet.Position
	local Bpos2 = Bpos
	local recast = false
	local raycastResult

	local raycast_params, ray_slot = ObjectPool.Acquire("ServerBulletTrace")
	if not raycast_params then return end

	raycast_params.FilterDescendantsInstances = Ignore_Model

	while bullet do
		Run.Heartbeat:Wait()
		if bullet.Parent ~= nil then
			Bpos = bullet.Position

			-- Set an origin and directional vector
			raycastResult = workspace:Raycast(Bpos2, (Bpos - Bpos2) * 1, raycast_params)

			recast = false

			if raycastResult then
				local Hit2 = raycastResult.Instance

				if
					Hit2
					and (Hit2.Parent:IsA("Accessory") or Hit2.Parent:IsA("Hat") or Hit2.Transparency >= 1 or Hit2.CanCollide == false or Hit2.Name == "Ignorable" or Hit2.Name == "Glass" or Hit2.Name == "Ignore" or Hit2.Parent.Name == "Top" or Hit2.Parent.Name == "Helmet" or Hit2.Parent.Name == "Up" or Hit2.Parent.Name == "Down" or Hit2.Parent.Name == "Face" or Hit2.Parent.Name == "Olho" or Hit2.Parent.Name == "Headset" or Hit2.Parent.Name == "Numero" or Hit2.Parent.Name == "Vest" or Hit2.Parent.Name == "Chest" or Hit2.Parent.Name == "Waist" or Hit2.Parent.Name == "Back" or Hit2.Parent.Name == "Belt" or Hit2.Parent.Name == "Leg1" or Hit2.Parent.Name == "Leg2" or Hit2.Parent.Name == "Arm1" or Hit2.Parent.Name == "Arm2")
					and Hit2.Name ~= "Right Arm"
					and Hit2.Name ~= "Left Arm"
					and Hit2.Name ~= "Right Leg"
					and Hit2.Name ~= "Left Leg"
					and Hit2.Name ~= "UpperTorso"
					and Hit2.Name ~= "LowerTorso"
					and Hit2.Name ~= "RightUpperArm"
					and Hit2.Name ~= "RightLowerArm"
					and Hit2.Name ~= "RightHand"
					and Hit2.Name ~= "LeftUpperArm"
					and Hit2.Name ~= "LeftLowerArm"
					and Hit2.Name ~= "LeftHand"
					and Hit2.Name ~= "RightUpperLeg"
					and Hit2.Name ~= "RightLowerLeg"
					and Hit2.Name ~= "RightFoot"
					and Hit2.Name ~= "LeftUpperLeg"
					and Hit2.Name ~= "LeftLowerLeg"
					and Hit2.Name ~= "LeftFoot"
					and Hit2.Name ~= "Armor"
					and Hit2.Name ~= "EShield"
				then
					table.insert(Ignore_Model, Hit2)
					recast = true
					ProcessBulletTrace(bullet)
					break
				end
			end

			if raycastResult and not recast then
				bullet:Destroy()
				break
			end

			Bpos2 = Bpos
		else
			break
		end
	end

	ObjectPool.Release("ServerBulletTrace", ray_slot)
end

Event.ServerBullet.OnClientEvent:Connect(function(player, origin, direction, attachment_modifier)
	if player == Player then return end

	local character = player.Character
	if not character then return end

	local weapon_data = WeaponRegistry.GetWeaponData()
	if not weapon_data then
		Util.LogTagged("ACS_EventHandler", "WeaponData is nil")
		return
	end

	local bullet = Instance.new("Part" , ACS_Workspace.Server)
	bullet.Name = player.Name.."_Bullet"
	bullet.CanCollide = false
	bullet.Shape = Enum.PartType.Ball
	bullet.Transparency = 1
	bullet.Size = Vector3.new(1,1,1)

	local function on_bullet_destroyed()
		local att_slot = bullet:GetAttribute("Server_att1_slot")
		local att2_slot = bullet:GetAttribute("Server_att2_slot")
		local trail_slot = bullet:GetAttribute("Server_trail_slot")

		if att_slot then
			ObjectPool.Release("ServerBulletTracerAttachment", att_slot)
		end

		if att2_slot then
			ObjectPool.Release("ServerBulletTracerAttachment2", att2_slot)
		end

		if trail_slot then
			ObjectPool.Release("ServerBulletTrail", trail_slot)
		end
	end

	bullet.AncestryChanged:Connect(function()
		if not bullet.Parent then
			on_bullet_destroyed()
		end
	end)

	local bullet_cframe = CFrame.new(origin, direction) 
	-- local WalkMul 		= WeaponData.WalkMult * attachment_modifier.WalkMult
	local bullet_color 		= Color3.fromRGB(255,255,255)

	if weapon_data.RainbowMode then
		bullet_color = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
	else
		bullet_color = weapon_data.TracerColor
	end

	if weapon_data.Tracer == true then

		local att1, att_slot = ObjectPool.Acquire("ServerBulletTracerAttachment")
		local att2, att_slot2 = ObjectPool.Acquire("ServerBulletTracerAttachment2")
		local trail, trail_slot = ObjectPool.Acquire("ServerBulletTrail")
		
		if att1 and att2 and trail then
			att1.Parent = bullet
			att2.Parent = bullet

			trail.Color = ColorSequence.new(bullet_color)
			trail.Attachment0 = att1
			trail.Attachment1 = att2
			trail.Parent = bullet

			bullet:SetAttribute("Server_att1_slot", att_slot)
			bullet:SetAttribute("Server_att2_slot", att_slot2)
			bullet:SetAttribute("Server_trail_slot", trail_slot)
		end
	end

	if weapon_data.BulletFlare == true then
		local bg = Instance.new("BillboardGui")
		bg.Adornee = bullet

		local flash_size = math.random(275, 375)/10
		bg.Size = UDim2.fromScale(flash_size, flash_size)
		bg.LightInfluence = 0

		local flash = Instance.new("ImageLabel")
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.fromScale(1, 1)
		flash.Position = UDim2.new(0, 0, 0, 0)
		flash.Image = "http://www.roblox.com/asset/?id=1047066405"
		flash.ImageTransparency = math.random(2, 5)/15
		flash.ImageColor3 = bullet_color

		bg.Parent = bullet
		flash.Parent = bg
	end

	local bullet_mass = bullet:GetMass()
	local force = Vector3.new(0, bullet_mass * (196.2) - (weapon_data.BulletDrop) * (196.2), 0)
	local BF = Instance.new("BodyForce")
	bullet.CFrame = bullet_cframe
	bullet:ApplyImpulse(direction * weapon_data.MuzzleVelocity * attachment_modifier.MuzzleVelocity)
	BF.Force = force
	BF.Parent = bullet

	game.Debris:AddItem(bullet, 5)
	ProcessBulletTrace(bullet)
end)

----------//Events\\----------

------------------------------------------------------------
--\Doors Update
------------------------------------------------------------
local DoorsFolder = ACS_Workspace:FindFirstChild("Doors")
local CAS = game:GetService("ContextActionService")

local mDistance = 5
local Key = nil

function getNearest()
	local nearest = nil
	local minDistance = mDistance
	local Character = Player.Character or Player.CharacterAdded:Wait()

	for I,Door in pairs (DoorsFolder:GetChildren()) do
		if Door.Door:FindFirstChild("Knob") ~= nil then
			local distance = (Door.Door.Knob.Position - Character.UpperTorso.Position).magnitude

			if distance < minDistance then
				nearest = Door
				minDistance = distance
			end
		end
	end
	--print(nearest)
	return nearest
end

function Interact(action_name, input_state, input_object)
	if input_state ~= Enum.UserInputState.Begin then return end

	local nearestDoor = getNearest()
	local Character = Player.Character or Player.CharacterAdded:Wait()

	if nearestDoor == nil then return end

	if (nearestDoor.Door.Knob.Position - Character.UpperTorso.Position).magnitude <= mDistance then
		if nearestDoor ~= nil then
			if nearestDoor:FindFirstChild("RequiresKey") then
				Key = nearestDoor.RequiresKey.Value
			else
				Key = nil
			end
			Event.DoorEvent:FireServer(nearestDoor,1,Key)
		end
	end
end


function GetNearest(parts, max_distance, part)
	local closestPart
	local minDistance = max_distance
	for _, partToFace in ipairs(parts) do
		local distance = (part.Position - partToFace.Position).magnitude
		if distance < minDistance then
			closestPart = partToFace
			minDistance = distance
		end
	end
	return closestPart
end

CAS:BindAction("Interact", Interact, false, Enum.KeyCode.G)

--[[
if gameRules.WaterMark then
	local StarterGui = game:GetService("StarterGui")
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "Advanced Combat System";
		Color = Color3.fromRGB(255, 175, 0); 
		Font = Enum.Font.Roboto; 
		TextSize = 14
	})

	Player.Chatted:Connect(function(Message)
		if string.lower(Message) == "/acs" then
			local StarterGui = game:GetService("StarterGui")

			StarterGui:SetCore("ChatMakeSystemMessage", {
				Text = "------------------------------------------------";
				Color = Color3.fromRGB(0, 0, 35); 
				Font = Enum.Font.RobotoCondensed; 
				TextSize = 20
			})

			StarterGui:SetCore("ChatMakeSystemMessage", {
				Text = "Advanced Combat System";
				Color = Color3.fromRGB(255, 175, 0); 
				Font = Enum.Font.RobotoCondensed; 
				TextSize = 20
			})

			StarterGui:SetCore("ChatMakeSystemMessage", {
				Text = "Made By: 00Scorpion00";
				Color = Color3.fromRGB(255, 255, 255); 
				Font = Enum.Font.RobotoCondensed; 
				TextSize = 14
			})

			StarterGui:SetCore("ChatMakeSystemMessage", {
				Text = "Version: "..gameRules.Version;
				Color = Color3.fromRGB(255, 255, 255); 
				Font = Enum.Font.RobotoCondensed; 
				TextSize = 14
			})

			StarterGui:SetCore("ChatMakeSystemMessage", {
				Text = "------------------------------------------------";
				Color = Color3.fromRGB(0, 0, 35); 
				Font = Enum.Font.RobotoCondensed; 
				TextSize = 20
			})
		end
	end)
end
]]

Event.CombatLog.OnClientEvent:Connect(function(CombatLog)
	local CL = Player.PlayerGui:FindFirstChild("CombatLog")
	if CL then
		CL.Refresh:Fire(CombatLog)
	else
		local CL = HUDs.CombatLog:Clone()
		CL.Parent = Player.PlayerGui
		CL.CLS.Disabled = false
		CL.Refresh:Fire(CombatLog)
	end
end)
