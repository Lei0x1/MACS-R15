--[[
    BallisticsManager.lua
	Created by @ddydddd9 - Moonlight

	Ballistics manager handling projectile spawning, bullet traces,
	hit detection, and damage calculation with suppression effects
]]

local RS = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local CurrentCamera = workspace.CurrentCamera
local ACS_Workspace = workspace.ACS_WorkSpace

local Engine = RS:WaitForChild("ACS_Engine")
local GameRules = Engine:WaitForChild("GameRules")
local Event = Engine:WaitForChild("Events")
local Modules = Engine:WaitForChild("Modules")
local CoreModules = Modules:WaitForChild("Core")
local ClientModules = Modules:WaitForChild("Client")
local WeaponModules = Modules:WaitForChild("Weapon")

local Config = require(GameRules:WaitForChild("Config"))
local Util = require(Modules:WaitForChild("Utilities"))
local Hitmarker = require(Modules:WaitForChild("Hitmarker"))

local PlayerStateManager = require(ClientModules:WaitForChild("PlayerStateManager"))

local ObjectPool = require(CoreModules:WaitForChild("ObjectPool"))
local RayIgnore = require(CoreModules:WaitForChild("RayIgnore"))

local WeaponRegistry = require(WeaponModules:WaitForChild("WeaponRegistry"))
local WeaponState = require(WeaponModules:WaitForChild("WeaponState"))
local BulletEffects = require(WeaponModules:WaitForChild("BulletEffects"))
local AttachmentManager = require(WeaponModules:WaitForChild("AttachmentManager"))

Player.CharacterAdded:Connect(function(new_character)
	Character = new_character
	CurrentCamera = workspace.CurrentCamera
	ACS_Workspace = workspace.ACS_WorkSpace
end)

local BallisticsManager = {}

local WeaponInHand, WeaponData, WeaponTool = nil, nil, nil

WeaponRegistry.Changed:Connect(function(event, data)
    if event == "Equipped" then
        WeaponInHand = data.weapon_in_hand
        WeaponTool = data.weapon_tool
        WeaponData = data.weapon_data

    elseif event == "Unequipped" then
        WeaponInHand = nil
        WeaponTool = nil
		WeaponData = nil
    end
end)

local AttachmentModifications = AttachmentManager.Data

local TracerShots = 0
function BallisticsManager.ShouldShowTracer()
	local weapon_data = WeaponRegistry:GetWeaponData()
    if not weapon_data or not weapon_data.Tracer then
		return false
	end

	if weapon_data.RandomTracer.Enabled then
		return math.random(1, 100) <= weapon_data.RandomTracer.Chance
	end

	TracerShots += 1

	if TracerShots >= weapon_data.TracerEveryXShots then
		TracerShots = 0
		return true
	end

	return false
end

function BallisticsManager.SpawnProjectile()
	if not Character then return end
	if not WeaponData and not WeaponInHand then
		Util.LogTagged("BallisticsManager", "WeaponData & WeaponInHand is nil")
		return
	end

    local attachment_modifications = AttachmentManager.Data

    if WeaponData.IsLauncher then
        for _, part in pairs(WeaponInHand:GetChildren()) do
            if part.Name == "Warhead" then
                part.Transparency = 1
                break
            end
        end
    end

    local bullet = Instance.new("Part")
    bullet.Name = Player.Name .. "_Bullet"
    bullet.CanCollide = false
    bullet.Shape = Enum.PartType.Ball
    bullet.Transparency = 1
    bullet.Size = Vector3.new(1, 1, 1)
    bullet.Parent = ACS_Workspace.Client

    local muzzle = WeaponInHand.Handle.Muzzle
    local origin = muzzle.WorldPosition
    local walk_multiplier = WeaponData.WalkMult * WeaponData.WalkMult

    -- pre calculate direction components
    local look_vector 		 = muzzle.WorldCFrame.LookVector
	local up_vector   		 = muzzle.WorldCFrame.UpVector
	local bullet_drop_factor = ((WeaponData.BulletDrop * WeaponData.CurrentZero / 4) / WeaponData.MuzzleVelocity) / 2
	local direction 		 = look_vector + (up_vector * bullet_drop_factor)
	local bullet_cframe 	 = CFrame.new(origin, direction)
	local bullet_spread

    if WeaponState.IsAimming and WeaponData.Bullets <= 1 then
		bullet_spread = CFrame.Angles(
			math.rad(Util.RAND(-WeaponState.CurrentSpread - (PlayerStateManager.CharacterSpeed/1) * walk_multiplier, WeaponState.CurrentSpread + (PlayerStateManager.CharacterSpeed/1) * walk_multiplier) / (10 * WeaponData.AimSpreadReduction)),
			math.rad(Util.RAND(-WeaponState.CurrentSpread - (PlayerStateManager.CharacterSpeed/1) * walk_multiplier, WeaponState.CurrentSpread + (PlayerStateManager.CharacterSpeed/1) * walk_multiplier) / (10 * WeaponData.AimSpreadReduction)),
			math.rad(Util.RAND(-WeaponState.CurrentSpread - (PlayerStateManager.CharacterSpeed/1) * walk_multiplier, WeaponState.CurrentSpread + (PlayerStateManager.CharacterSpeed/1) * walk_multiplier) / (10 * WeaponData.AimSpreadReduction))
		)
	else
		bullet_spread = CFrame.Angles(
			math.rad(Util.RAND(-WeaponState.CurrentSpread - (PlayerStateManager.CharacterSpeed/1) * walk_multiplier, WeaponState.CurrentSpread + (PlayerStateManager.CharacterSpeed/1) * walk_multiplier) / 10),
			math.rad(Util.RAND(-WeaponState.CurrentSpread - (PlayerStateManager.CharacterSpeed/1) * walk_multiplier, WeaponState.CurrentSpread + (PlayerStateManager.CharacterSpeed/1) * walk_multiplier) / 10),
			math.rad(Util.RAND(-WeaponState.CurrentSpread - (PlayerStateManager.CharacterSpeed/1) * walk_multiplier, WeaponState.CurrentSpread + (PlayerStateManager.CharacterSpeed/1) * walk_multiplier) / 10)
		)
	end

    direction = bullet_spread * direction
	local tracer_color

	if WeaponData.RainbowMode then
		tracer_color = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
	else
		tracer_color = WeaponData.TracerColor or Color3.fromRGB(255,255,255)
	end

	if Config.ReplicatedBullets then
		Event.ServerBullet:FireServer(origin, direction, attachment_modifications)
	end

	local bullet_flare_properties = WeaponData.BulletFlareProperties
	local should_show_tracer = BallisticsManager.ShouldShowTracer()

	-- Bullet tracer
	if should_show_tracer then

		if WeaponData.Tracer then
			if WeaponData.TracerDelay then
				task.wait(WeaponData.TracerDelay)

				if not bullet or not bullet.Parent then return end
			end

			local tracer_width = WeaponData.TracerWidth or 0.05
			local tracer_lifetime = WeaponData.TracerLifeTime or 0.04
			local tracer_light_emission = WeaponData.TracerLightEmission or 1
			local tracer_light_influence = WeaponData.TracerLightInfluence or 0
			local tracer_style = WeaponData.TracerStyle
			local tracer_texture = WeaponData.TracerTexture or "rbxassetid://232918622"
			local tracer_light = WeaponData.TracerLight
			local tracer_light_brightness = WeaponData.TracerLightBrightness or 3
			local tracer_light_range = WeaponData.TracerLightRange or 10

			BulletEffects.Tracer(
				bullet,
				tracer_color,
				tracer_width,
				tracer_lifetime,
				tracer_light_emission,
				tracer_light_influence,
				tracer_style,
				tracer_texture,
				tracer_light,
				tracer_light_brightness,
				tracer_light_range
			)
		end
	end

	-- Bullet flare
	if WeaponData.BulletFlare then
		local bullet_flare_color = bullet_flare_properties.FlashColor
		local bullet_flare_size = bullet_flare_properties.FlareSize or 4
		local bullet_flare_light_influence = bullet_flare_properties.LightInfluence or 0
		local bullet_flare_flash_size = bullet_flare_properties.FlashSize or 1
		local bullet_flare_image = bullet_flare_properties.FlashImage or "rbxassetid://1047066405"
		local bullet_flash_transparency = bullet_flare_properties.FlashTransparency or 0.6
		local bullet_flare_glow_size = bullet_flare_properties.GlowSize or 1.5
		local bullet_flare_glow_image = bullet_flare_properties.GlowImage or "rbxassetid://1047066405"
		local bullet_flare_glow_transparency = bullet_flare_properties.GlowTransparency or 0.5

		BulletEffects.BulletFlare(
			bullet,
			bullet_flare_color,
			bullet_flare_size,
			bullet_flare_light_influence,
			bullet_flare_flash_size,
			bullet_flare_image,
			bullet_flash_transparency,
			bullet_flare_glow_size,
			bullet_flare_glow_image,
			bullet_flare_glow_transparency
		)
	end

	local bullet_mass = bullet:GetMass()
	local bullet_drop_force = Vector3.new(0, bullet_mass * (196.2) - (WeaponData.BulletDrop) * (196.2), 0)
	local body_force = Instance.new("BodyForce")

	bullet.CFrame = bullet_cframe
	bullet:ApplyImpulse(direction * WeaponData.MuzzleVelocity * attachment_modifications.MuzzleVelocity)
	body_force.Force = bullet_drop_force
	body_force.Parent = bullet

	Debris:AddItem(bullet, 5)
	BallisticsManager.ProcessBulletTrace(bullet, origin)
end

function BallisticsManager.ProcessBulletTrace(bullet, origin)
	if not bullet then return end

	local weapon_data = WeaponRegistry:GetWeaponData()
	local weapon_tool = WeaponRegistry:GetWeaponTool()

	local Bpos = bullet.Position
	local Bpos2 = CurrentCamera.CFrame.Position
	local TotalDistTraveled = 0
	local Debounce = false

	local raycast_params, ray_slot = ObjectPool.Acquire("BulletTrace")
	if not raycast_params then return end

	local local_ignore = RayIgnore:BuildIgnoreList()
	raycast_params.FilterDescendantsInstances = local_ignore

	local player_list 	 = game.Players:GetPlayers()
	local current_player = Player
	local _camera_pos 	 = Bpos2

	while bullet and bullet.Parent do
		Run.Heartbeat:Wait()

		Bpos = bullet.Position
		TotalDistTraveled = (bullet.Position - origin).Magnitude

		if TotalDistTraveled > 7000 then
			bullet:Destroy()
			Debounce = true
			break
		end

		-- Check for nearby players (suppression)
		if not Debounce then
			for i = 1, #player_list do
				local player = player_list[i]
				if player ~= current_player and player.Character and player.Character.Head then
					if (player.Character.Head.Position - Bpos).Magnitude <= 25 then
						Event.Whizz:FireServer(player)
						Event.Suppression:FireServer(player, 1 , nil, nil)
						Debounce = true
						break
					end
				end
			end
		end

		local direction = Bpos - Bpos2
		local raycast_result = workspace:Raycast(Bpos2, direction, raycast_params)

		if raycast_result then
			local Hit2 = raycast_result.Instance

			-- Handle special cases by updating ignore list and continuing
			if Hit2 and (Hit2.Parent:IsA("Accessory") or Hit2.Parent:IsA("Hat")) then
				for i = 1, #player_list do
					local char = player_list[i].Character
					if char then
						for _, hat in ipairs(char:GetChildren()) do
							if hat:IsA("Accessory") then
								local already = false
								for _, v in ipairs(local_ignore) do
									if v == hat then
										already = true
										break
									end
								end
								if not already then
									local_ignore[#local_ignore + 1] = hat
									RayIgnore:AddToIgnore(hat)
								end
							end
						end
					end
				end

				-- Re-apply updated filter and continue
				raycast_params.FilterDescendantsInstances = local_ignore
				_camera_pos = Bpos
				continue
			end

			local ignorable_names = {
                "Ignorable", "Glass", "Ignore", "Top", "Helmet", "Up", "Down", 
                "Face", "Olho", "Headset", "Numero", "Vest", "Chest", "Waist", 
                "Back", "Belt", "Leg1", "Leg2", "Arm1", "Arm2", 'Armor', 'EShield'
            }

			local should_ignore = false
			for _, name in ipairs(ignorable_names) do
				if Hit2 and (Hit2.Name == name or Hit2.Parent.Name == name) then
					local already = false
					for _, v in ipairs(local_ignore) do
						if v == Hit2 then
							already = true
							break
						end
					end

					if not already then
						local_ignore[#local_ignore + 1] = Hit2
					end

					if Hit2.Parent.Name == name then
						local already2 = false
						for _, v in ipairs(local_ignore) do
							if v == Hit2.Parent then
								already2 = true
							end
						end
						if not already2 then
							local_ignore[#local_ignore + 1] = Hit2.Parent
						end
					end

					should_ignore = true
					break
				end
			end

			if should_ignore and Hit2 and (Hit2.Transparency >= 1 or Hit2.CanCollide == false) then
				local body_parts = {
                    'Head', 'Right Arm', 'Left Arm', 'Right Leg', 'Left Leg', 
                    "UpperTorso", "LowerTorso", "RightUpperArm", "RightLowerArm",
                    "RightHand", "LeftUpperArm", "LeftLowerArm", "LeftHand",
                    "RightUpperLeg", "RightLowerLeg", "RightFoot", "LeftUpperLeg",
                    "LeftLowerLeg", "LeftFoot"
                }

				local is_body_part = false
				for _, part in ipairs(body_parts) do
					if Hit2.Name == part then
						is_body_part = true
						break
					end
				end

				if not is_body_part then
					local already = false
					for _, v in ipairs(local_ignore) do
						if v == Hit2 then
							already = true
							break
						end
					end
					if not already then
						local_ignore[#local_ignore+1] = Hit2
					end
					should_ignore = true
				end
			end

			if should_ignore then
				raycast_params.FilterDescendantsInstances = local_ignore
				_camera_pos = Bpos
				continue
			end

			bullet:Destroy()
			Debounce = true

			local FoundHuman, TargetHumanoid = Util.CheckForHumanoid(raycast_result.Instance)
			Hitmarker.HitEffect(local_ignore, raycast_result.Position, raycast_result.Instance , raycast_result.Normal, raycast_result.Material)
			Event.HitEffect:FireServer(raycast_result.Position, raycast_result.Instance , raycast_result.Normal, raycast_result.Material)

			if FoundHuman == true and TargetHumanoid.Health > 0 and weapon_data then
				local SKP_02 = PlayerStateManager.PlayerSessionId .. "-" .. Player.UserId
				local HitPart = raycast_result.Instance
				TotalDistTraveled = (raycast_result.Position - origin).Magnitude

				local damage_type = 2
				if HitPart.Name == "Head" or HitPart.Parent.Name == "Top" or HitPart.Parent.Name == "Headset" or HitPart.Parent.Name == "Olho" or HitPart.Parent.Name == "Face" or HitPart.Parent.Name == "Numero" then
					damage_type = 1
				elseif HitPart.Name == "Torso" or HitPart.Name == "UpperTorso" or HitPart.Name == "LowerTorso" or HitPart.Parent.Name == "Chest" or HitPart.Parent.Name == "Waist" or HitPart.Name == "Right Arm" or HitPart.Name == "Left Arm" or HitPart.Name == "RightUpperArm" or HitPart.Name == "RightLowerArm" or HitPart.Name == "RightHand" or HitPart.Name == "LeftUpperArm" or HitPart.Name == "LeftLowerArm" or HitPart.Name == "LeftHand" then				
					damage_type = 2
				elseif HitPart.Name == "Right Leg" or HitPart.Name == "Left Leg" or HitPart.Name == "RightUpperLeg" or HitPart.Name == "RightLowerLeg" or HitPart.Name == "RightFoot" or HitPart.Name == "LeftUpperLeg" or HitPart.Name == "LeftLowerLeg" or HitPart.Name == "LeftFoot" then
					damage_type = 3
				end

				Event.Damage:InvokeServer(weapon_tool, TargetHumanoid, TotalDistTraveled, damage_type, weapon_data, AttachmentModifications, nil, nil, SKP_02)
			end
		end

		_camera_pos = Bpos
	end

	ObjectPool.Release("BulletTrace", ray_slot)
end

return BallisticsManager