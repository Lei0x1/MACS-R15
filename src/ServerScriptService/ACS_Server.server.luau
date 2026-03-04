local RS 			= game.ReplicatedStorage
local HttpService 	= game:GetService("HttpService")
local TS 			= game:GetService('TweenService')
local Debris 		= game:GetService("Debris")
local Run 			= game:GetService("RunService")
local Players 		= game:GetService("Players")

local ACS_Workspace = workspace:WaitForChild("ACS_WorkSpace")
local Engine 		= RS:WaitForChild("ACS_Engine")

local Event 			= Engine:WaitForChild("Events")
local WeaponModels  	= Engine:WaitForChild("WeaponModels")
local SVGunModels 		= Engine:WaitForChild("GrenadeModels")
local HUDs 				= Engine:WaitForChild("HUD")
local Attachments   	= Engine:WaitForChild("Attachments")
local AttachmentModels 	= Attachments:WaitForChild("Models")
local Rules				= Engine:WaitForChild("GameRules")

local Mods 			= Engine:WaitForChild("Modules")
local WeaponMod		= Mods:WaitForChild("Weapon")

local Config		= require(Rules:WaitForChild("Config"))
local CombatLog		= require(Rules:WaitForChild("CombatLog"))
local Util			= require(Mods:WaitForChild("Utilities"))
local Ragdoll		= require(Mods:WaitForChild("Ragdoll"))
local WeaponHolster		= require(WeaponMod:WaitForChild("WeaponHolster"))
local AttachmentManager = require(WeaponMod:WaitForChild("AttachmentManager"))

local ACS_0 		= HttpService:GenerateGUID(true)
local Backup 		= 0

_G.TempBannedPlayers = {} --Local ban list

local Explosion = {"287390459"; "287390954"; "287391087"; "287391197"; "287391361"; "287391499"; "287391567";}
-----------------------------------------------------------------

game.StarterPlayer.CharacterWalkSpeed = Config.NormalWalkSpeed

local function AccessID(player, reqquesting_user_id)
	if player.UserId == reqquesting_user_id then
		return ACS_0
	else
		player:kick("Exploit Protocol")
		warn(player.Name.." - Potential Exploiter! Case 0-A: Client Tried To Access Server Code")
		table.insert(_G.TempBannedPlayers, player)

		return nil
	end
end

Event.AcessId.OnServerInvoke = AccessID

--Glenn's Anti-Exploit System (GAE for short). This code is very ugly, but does job done
-- Edited by @ddydddd9 - Moonlight: Same behavior just added iteration & safety checks.
local function CompareTables(arr1, arr2)
	if typeof(arr1) ~= "table" or typeof(arr2) ~= "table" then
		return false
	end

	local simple_field = { "gunName", "Type", "ShootRate", "Bullets" }

	for _, field in ipairs(simple_field) do
		if arr1[field] ~= arr2[field] then
			return false
		end
	end

	local damage_fields = { "LimbDamage", "TorsoDamage", "HeadDamage" }

	for _, field in ipairs(damage_fields) do
		if typeof(arr1[field]) ~= "table" or typeof(arr2[field]) ~= "table" then
			return false
		end

		if arr1[field][1] ~= arr2[field][1] then
			return false
		end

		if arr1[field][2] ~= arr2[field][2] then
			return false
		end
	end

	return true
end

function HandleSecurityViolation(player, reason, protocol)
	warn(string.format("[SECURITY] %s - %s: %s", protocol, player.Name, reason))

	-- Add to temp banned list like original
	table.insert(_G.TempBannedPlayers, player)

	-- Kick the player for severe violations
	if protocol == "Exploit Protocol" then
		player:Kick(string.format("Security Violation: %s", reason))
	end
end

local function SecureSettings(player, weapon_tool, weapon_data)
	if not weapon_tool or not weapon_tool:IsA("Tool") then
		HandleSecurityViolation(player, "0-2: Invalid Gun Object", "Exploit Protocol")
		return false
	end

	local has_acs_setting = weapon_tool:FindFirstChild("ACS_Settings")
	if not has_acs_setting or not has_acs_setting:IsA("ModuleScript") then
		HandleSecurityViolation(player, "0-2: Missing or Invalid ACS_Settings Module", "Exploit Protocol")
		return false
	end

	local success, acs_setting = pcall(require, has_acs_setting)
	if not success then
		HandleSecurityViolation(player, "0-2: Corrupted ACS_Settings Module", "Exploit Protocol")
		return false
	end

	if typeof(acs_setting) ~= "table" then
		HandleSecurityViolation(player, "0-2: ACS_Settings Must Return Table", "Exploit Protocl")
		return false
	end

	if not CompareTables(weapon_data, acs_setting) then
		HandleSecurityViolation(player, "0-4: Exploiting Weapon Stats", "Exploit Protocol")
		return false
	end

	return true
end

function CalculateDMG(player, target_humanoid, SKP_2, hit_zone, weapon_data, attachment_modifications)
	local target_player	= Players:GetPlayerFromCharacter(target_humanoid.Parent) or nil
	local final_damage = 0
	local minimum_damage = weapon_data.MinDamage * attachment_modifications.minDamageMod

	if hit_zone == 1 then
		local rolled_damage = math.random(weapon_data.HeadDamage[1], weapon_data.HeadDamage[2])
		final_damage = math.max(minimum_damage ,(rolled_damage * attachment_modifications.DamageMod) - (SKP_2/25) * weapon_data.DamageFallOf)
	elseif hit_zone == 2 then
		local rolled_damage = math.random(weapon_data.TorsoDamage[1], weapon_data.TorsoDamage[2])
		final_damage = math.max(minimum_damage ,(rolled_damage * attachment_modifications.DamageMod) - (SKP_2/25) * weapon_data.DamageFallOf)
	else
		local rolled_damage = math.random(weapon_data.LimbDamage[1], weapon_data.LimbDamage[2])
		final_damage = math.max(minimum_damage ,(rolled_damage * attachment_modifications.DamageMod) - (SKP_2/25) * weapon_data.DamageFallOf)
	end

	if target_humanoid.Parent:FindFirstChild("ACS_Client") ~= nil and not weapon_data.IgnoreProtection then
		local protection = target_humanoid.Parent.ACS_Client.Protecao
		local vest_protection = protection.VestProtect
		local helmet_protection = protection.HelmetProtect

		if hit_zone == 1 then
			if weapon_data.BulletPenetration < helmet_protection.Value  then
				final_damage = math.max(0.5 , final_damage * (weapon_data.BulletPenetration / helmet_protection.Value))
			end

		else
			if weapon_data.BulletPenetration < vest_protection.Value  then
				final_damage = math.max(0.5 , final_damage * (weapon_data.BulletPenetration / vest_protection.Value))
			end
		end
	end

	if target_player ~= nil then
		if target_player.Team ~= player.Team or target_player.Neutral then
			local creator_tag = Instance.new("ObjectValue")
			creator_tag.Name = "creator"
			creator_tag.Value = player
			creator_tag.Parent = target_humanoid

			target_humanoid:TakeDamage(final_damage)
			return
		end

		if not Config.TeamKill then return end

		local creator_tag = Instance.new("ObjectValue")
		creator_tag.Name = "creator"
		creator_tag.Value = player
		creator_tag.Parent = target_humanoid
		Debris:AddItem(creator_tag, 1)
		
		target_humanoid:TakeDamage(final_damage * Config.TeamDmgMult)
		return
	end

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Name = "creator"
	creator_tag.Value = player
	creator_tag.Parent = target_humanoid
	Debris:AddItem(creator_tag, 1)

	target_humanoid:TakeDamage(final_damage)
	return
end

local function Damage(player, weapon_tool, target_humanoid, SKP_3, hit_zone, weapon_data, attachment_modifications, SKP_7, SKP_8, player_session_id)
	local character = player.Character
	if not character then return end

	local humanoid = character.Humanoid
	if not humanoid or humanoid.Health <= 0 then return end
		
	if player_session_id ~= ACS_0 .. "-" .. player.UserId then
		player:kick("Exploit Protocol")
		warn(player.Name .. " - Potential Exploiter! Case 1: Tried To Access Damage Event")

		table.insert(_G.TempBannedPlayers, player)
		return
	end

	if SKP_7 then
		humanoid:TakeDamage(math.max(SKP_8, 0))
		return
	end

	if weapon_tool then
		local is_secure = SecureSettings(player, weapon_tool, weapon_data)
		if not is_secure or not target_humanoid then
			player:kick("Exploit Protocol")
			warn(player.Name .. " - Potential Exploiter! Case 0-B: Wrong Permission Code")

			table.insert(_G.TempBannedPlayers, player)
			return
		end

		CalculateDMG(player, target_humanoid, SKP_3, hit_zone, weapon_data, attachment_modifications)
	end
end

Event.Damage.OnServerInvoke = Damage

Event.HitEffect.OnServerEvent:Connect(function(player, position, hit_part, normal, material)
	Event.HitEffect:FireAllClients(player, position, hit_part, normal, material)
end)

Event.CurrentGunStance.OnServerEvent:Connect(function(player, stance, anim_data)
	Event.CurrentGunStance:FireAllClients(player, stance, anim_data)
end)

Event.ServerBullet.OnServerEvent:Connect(function(player, origin, direction, attachment_modifier)
	Event.ServerBullet:FireAllClients(player, origin, direction, attachment_modifier)
end)

Event.Stance.OnServerEvent:Connect(function(player, stance_mode, lean_direction)
	if not player or not player.Character then
		return
	end

	if not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
		return
	end

	local character = player.Character

	local Humanoid = character:WaitForChild("Humanoid")
	local ACS_Client = character:WaitForChild("ACS_Client")
	if not ACS_Client then
		return
	end

	-- Body parts
	local UpperTorso = character:FindFirstChild("UpperTorso")
	local LowerTorso = character:FindFirstChild("LowerTorso")
	local RUA = character:FindFirstChild("RightUpperArm")
	local LUA = character:FindFirstChild("LeftUpperArm")
	local RUL = character:FindFirstChild("RightUpperLeg")
	local RLL = character:FindFirstChild("RightLowerLeg")
	local LUL = character:FindFirstChild("LeftUpperLeg")
	local LLL = character:FindFirstChild("LeftLowerLeg")

	if not UpperTorso or not LowerTorso or not RUA or not LUA then
		return
	end

	-- Joints
	local RootJoint = LowerTorso:FindFirstChild("Root")
	local WaistJ = UpperTorso:FindFirstChild("Waist")

	local RightShoulder = RUA:FindFirstChild("RightShoulder")
	local LeftShoulder = LUA:FindFirstChild("LeftShoulder")
	local RightHip = RUL:FindFirstChild("RightHip")
	local RightKnee = RLL:FindFirstChild("RightKnee")
	local LeftHip = LUL:FindFirstChild("LeftHip")
	local LeftKnee = LLL:FindFirstChild("LeftKnee")

	if not RootJoint or not WaistJ or not RightShoulder or not LeftShoulder or not RightHip or not RightKnee or not LeftHip or not LeftKnee then
		return
	end

	local RightArm = RUA
	local LeftArm = LUA
	local LeftLeg = LUL
	local RightLeg = RUL
	
	local TweenInfoFast = TweenInfo.new(0.3)

	if stance_mode == 2 and RootJoint and WaistJ and RightHip and LeftHip and RightKnee and LeftKnee then
		TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-Humanoid.HipHeight - LowerTorso.Size.Y,Humanoid.HipHeight/1.25)* CFrame.Angles(math.rad(-90),0,math.rad(0))} ):Play()
		TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
		TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
		TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
		TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
		TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

	end
	if lean_direction == 1 and RootJoint and WaistJ and RightHip and LeftHip and RightKnee and LeftKnee then
		if stance_mode == 0 then
			TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0) * CFrame.Angles(math.rad(0),0,math.rad(-30))} ):Play()
			TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-(Humanoid.HipHeight/2),0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

		elseif stance_mode == 1 then
			TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(-30))} ):Play()
			TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-Humanoid.HipHeight/1.05,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),math.rad(0),math.rad(0))} ):Play()

		end
	elseif lean_direction == -1 and RootJoint and WaistJ and RightHip and LeftHip and RightKnee and LeftKnee then
		if stance_mode == 0 then
			TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0) * CFrame.Angles(math.rad(0),0,math.rad(30))} ):Play()
			TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-(Humanoid.HipHeight/2),0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

		elseif stance_mode == 1 then
			TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(30))} ):Play()
			TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-Humanoid.HipHeight/1.05,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),math.rad(0),math.rad(0))} ):Play()

		end
	elseif lean_direction == 0 and RootJoint and WaistJ and RightHip and LeftHip and RightKnee and LeftKnee then
		if stance_mode == 0 then
			TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(-0),0,math.rad(0))} ):Play()
			TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-(Humanoid.HipHeight/2),0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

		elseif stance_mode == 1 then
			TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-Humanoid.HipHeight/1.05,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),math.rad(0),math.rad(0))} ):Play()

		end
	end

	if ACS_Client:GetAttribute("Surrender") then
		TS:Create(RightShoulder, TweenInfoFast, {C0 = CFrame.new(RightArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(179),math.rad(0),math.rad(0))} ):Play()
		TS:Create(LeftShoulder, TweenInfoFast, {C0 = CFrame.new(-LeftArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(179),math.rad(0),math.rad(0))} ):Play()
	elseif stance_mode == 2 then
		TS:Create(RightShoulder, TweenInfoFast, {C0 = CFrame.new(RightArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(170),math.rad(0),math.rad(0))} ):Play()
		TS:Create(LeftShoulder, TweenInfoFast, {C0 = CFrame.new(-LeftArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(170),math.rad(0),math.rad(0))} ):Play()
	else
		TS:Create(RightShoulder, TweenInfoFast, {C0 = CFrame.new(RightArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
		TS:Create(LeftShoulder, TweenInfoFast, {C0 = CFrame.new(-LeftArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
	end
end)

Event.Surrender.OnServerEvent:Connect(function(player, victim)
	local acs_client 	= nil

	if victim then
		acs_client = victim.Character:FindFirstChild("ACS_Client")

		if victim == player then
			return
		end

		if not acs_client then
			return
		end

		if acs_client:GetAttribute("Surrender") then
			acs_client:SetAttribute("Surrender",false)
		end
	else
		acs_client = player.Character:FindFirstChild("ACS_Client")

		if not acs_client then
			return
		end

		if not acs_client:GetAttribute("Surrender") then
			acs_client:SetAttribute("Surrender", true)
		end
	end
end)

Event.Grenade.OnServerEvent:Connect(function(player, weapon_tool, weapon_data, current_camera_cframe, current_camera_cf_lookvector, grenade_throw_power, player_session_id)
	local character = player.Character
	if not character then return end

	local humanoid =  character.Humanoid
	if not humanoid or humanoid.Health <= 0 then return end

	if player_session_id ~= ACS_0 .. "-" .. player.UserId then
		player:kick("Exploit Protocol")
		warn(player.Name.." - Potential Exploiter! Case 0-B: Wrong Permission Code")
		table.insert(_G.TempBannedPlayers, player)

		return
	end

	if not weapon_tool and not weapon_data then
		player:kick("Exploit Protocol")
		warn(player.Name.." - Potential Exploiter! Case 3: Tried To Access Grenade Event")
		Util.LogTagged("ACS_Server", "WeaponTool and WeaponData is nil")
		return
	end

	local is_secure = SecureSettings(player, weapon_tool, weapon_data)
	if is_secure and weapon_data.Type == "Grenade" then

		if SVGunModels:FindFirstChild(weapon_data.gunName) == nil then
			warn("ACS_Server Couldn't Find "..weapon_data.gunName.." In Grenade Model Folder")
			return
		end

		local grenade_model = SVGunModels[weapon_data.gunName]:Clone()

		for _, SKP_Arg1 in pairs(player.Character:GetChildren()) do
			if SKP_Arg1:IsA('BasePart')then
				local skp_1 = Instance.new("NoCollisionConstraint")
				skp_1.Parent= grenade_model
				skp_1.Part0 = grenade_model.PrimaryPart
				skp_1.Part1 = SKP_Arg1
			end
		end

		local skp_1	= Instance.new("ObjectValue")
		skp_1.Name	= "creator"
		skp_1.Value	= player
		skp_1.Parent= grenade_model.PrimaryPart

		grenade_model.Parent 	= ACS_Workspace.Server
		grenade_model.PrimaryPart.CFrame = current_camera_cframe
		grenade_model.PrimaryPart:ApplyImpulse(current_camera_cf_lookvector * grenade_throw_power * grenade_model.PrimaryPart:GetMass())
		--grenade_model.PrimaryPart:SetNetworkOwner(player)
		grenade_model.PrimaryPart.Damage.Disabled = false

		weapon_tool:Destroy()
	end
end)

Event.Equip.OnServerEvent:Connect(function(player, weapon_tool, equip_mode, weapon_data, anim_data)
	local character = player.Character
	if not character then return end

	if not weapon_tool or not weapon_tool.Name and not weapon_data then
		Util.LogTagged("ACS_Server", "WeaponTool or WeaponData is nil for player " .. player.Name)
		return
	end
	
	local Head = character:FindFirstChild('Head')
	local RUA = character:FindFirstChild('RightUpperArm')
	local LUA = character:FindFirstChild('LeftUpperArm')
	
	-- check if player has this
	if not Head or not RUA or not LUA then
		Util.LogTagged("ACS_Server", "Player tried to equip without Head, RUA, and LUA")
		return
	end

	local RSH = RUA:WaitForChild("RightShoulder")
	local RLA = character:FindFirstChild("RightLowerArm")
	local RH  = character:FindFirstChild("RightHand")
	local LSH = LUA:WaitForChild("LeftShoulder")
	local LLA = character:FindFirstChild("LeftLowerArm")
	local LH  = character:FindFirstChild("LeftHand")

	if not RSH or not RLA or not RH or not LSH or not LLA or not LH then
		Util.LogTagged("ACS_Server", "Player missing arms parts for, " .. player.Name)
		return
	end
	
	if equip_mode == 1 then -- EQUIP
		local holster = nil
		if weapon_tool.Name then
			holster = character:FindFirstChild("Holster_" .. weapon_tool.Name)
		end

		if holster then
			WeaponHolster.SetVisible(holster, false)
		end
		
		local weapon_type = weapon_data.Type

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

		local server_gun_model = model_check:Clone()
		server_gun_model.Name = "SG-" .. weapon_tool.Name

		-- Create animation base
		local AnimBase = Instance.new("Part")
		AnimBase.Name = "AnimBase"
		AnimBase.CanCollide = false
		AnimBase.Transparency = 1
		AnimBase.Anchored = false
		AnimBase.Size = Vector3.new(0.1, 0.1, 0.1)
		AnimBase.Parent = character

		-- Attach AnimBase to Head
		local AnimBaseW = Instance.new("Motor6D")
		AnimBaseW.Name = "AnimBaseW"
		AnimBaseW.Part0 = Head
		AnimBaseW.Part1 = AnimBase
		AnimBaseW.Parent = AnimBase
		--AnimBaseW.C0 = CFrame.new(0,-1.25,0)
		
		if RSH and RSH.Parent then
			RSH.Enabled = false
		end
		
		-- Right arm setup
		local RUAW = Instance.new("Motor6D")
		RUAW.Name = "RAW"
		RUAW.Part0 = RUA
		RUAW.Part1 = AnimBase
		RUAW.Parent = AnimBase
		RUAW.C0 = anim_data.SV_RightArmPos

		local RLAW = Instance.new("Motor6D")
		RLAW.Name = "RLAW"
		RLAW.Part0 = RLA
		RLAW.Part1 = RUA
		RLAW.Parent = AnimBase
		RLAW.C0 = CFrame.new(0, RUA.Size.Y / 2, 0) * (anim_data.SV_RightElbowPos or CFrame.new())

		local RHW = Instance.new("Motor6D")
		RHW.Name = "RHW"
		RHW.Part0 = RH
		RHW.Part1 = RLA
		RHW.Parent = AnimBase
		RHW.C0 = CFrame.new(0, RLA.Size.Y / 2, 0) * (anim_data.SV_RightWristPos or CFrame.new())
		
		if LSH then
			LSH.Enabled = false
		end

		-- Left arm setup
		local LUAW = Instance.new("Motor6D")
		LUAW.Name = "LUAW"
		LUAW.Part0 = LUA
		LUAW.Part1 = AnimBase
		LUAW.Parent = AnimBase
		LUAW.C0 = anim_data.SV_LeftArmPos
	
		local LLAW = Instance.new("Motor6D")
		LLAW.Name = "LLAW"
		LLAW.Part0 = character.LeftLowerArm
		LLAW.Part1 = LUA
		LLAW.Parent = AnimBase
		LLAW.C0 = CFrame.new(0,LUA.Size.Y/2,0) * (anim_data.SV_LeftElbowPos or CFrame.new())
	
		local LHW = Instance.new("Motor6D")
		LHW.Name = "LHW"
		LHW.Part0 = character.LeftHand
		LHW.Part1 = character.LeftLowerArm
		LHW.Parent = AnimBase
		LHW.C0 = CFrame.new(0,character.LeftLowerArm.Size.Y/2,0) * (anim_data.SV_LeftWristPos or CFrame.new())

		server_gun_model.Parent = character
		AttachmentManager.Server.Load(server_gun_model, weapon_data)

		if server_gun_model:FindFirstChild("Nodes") ~= nil then
			server_gun_model.Nodes:Destroy()
		end

		-- Clean up sight marks
		for _, part in pairs(server_gun_model:GetDescendants()) do
			if part.Name == "SightMark" then
				part:Destroy()
			end
		end

		-- Weld all parts to handle
		for _, part in pairs(server_gun_model:GetDescendants()) do
			if not part:IsA('BasePart') or part.Name == 'Handle' then
				continue
			end

			Util.WeldComplex(server_gun_model:WaitForChild("Handle"), part, part.Name)
		end

		-- Attach gun to hand
		if RH then
			local gun_weld = Instance.new('Motor6D')
			gun_weld.Name = 'Handle'
			gun_weld.Parent = server_gun_model.Handle
			gun_weld.Part0 = character['RightHand']
			gun_weld.Part1 = server_gun_model.Handle

			local gun_pos = anim_data.SV_GunPos
			local adjusted_pos = gun_pos * CFrame.new(0, 0, 1.1)

			gun_weld.C1 = adjusted_pos:Inverse()
		end

		for _, part in pairs(server_gun_model:GetDescendants()) do
			if part:IsA('BasePart') then
				part.Anchored = false
				part.CanCollide = false
			end
		end

	elseif equip_mode == 2 then -- UNEQUIP
		-- Clean up Weapon
		if weapon_tool and weapon_tool.Name and character then
			local server_gun = character:FindFirstChild("SG-" .. weapon_tool.Name)

			if server_gun then
				server_gun:Destroy()
			end
		end

		-- Cleanup Animation Base
		if character:FindFirstChild("AnimBase") then
			character.AnimBase:Destroy()
		end

		if character then
			if RUA then
				local rightShoulder = RUA:FindFirstChild("RightShoulder")
				if rightShoulder then
					rightShoulder.Enabled = true
				end
			end

			if LUA then
				local leftShoulder = LUA:FindFirstChild("LeftShoulder")
				if leftShoulder then
					leftShoulder.Enabled = true
				end
			end
		end
		
		-- Safely handle holster
		if weapon_tool and weapon_tool.Name and character then
			local holster = character:FindFirstChild("Holster_" .. weapon_tool.Name)
			if holster then
				task.spawn(function()
					-- Small delay to ensure everything is cleaned up
					task.wait(0.1)
					if holster and holster.Parent then
						WeaponHolster.SetVisible(holster, true)
					end
				end)
			end
		end
	end
end)

Event.Squad.OnServerEvent:Connect(function(player , squad_name, squad_color)
	local character = player.Character
	if not character then
		return
	end

	local fire_team = character.ACS_Client.FireTeam
	if not character:FindFirstChild("ACS_Client") then
		return
	end
	
	fire_team.SquadName.Value = squad_name
	fire_team.SquadColor.Value = squad_color
end)

Event.Weapon.Shoot.OnServerEvent:Connect(function(player, suppressor, flash_hider)
	Event.Weapon.Shoot:FireAllClients(player, suppressor, flash_hider)
end)

Event.Whizz.OnServerEvent:Connect(function(player, victim)
	Event.Whizz:FireClient(victim)
end)

Event.Suppression.OnServerEvent:Connect(function(player, victim, mode, intensity, time)
	Event.Suppression:FireClient(victim, mode, intensity, time)
end)

Event.Refil.OnServerEvent:Connect(function(player, stored, new_stored)
	stored.Value = stored.Value - new_stored
end)

Event.SVLaser.OnServerEvent:Connect(function(player, position, mode, Cor, IR_mode, weapon_tool)
	Event.SVLaser:FireAllClients(player, position, mode, Cor, IR_mode, weapon_tool)
end)

Event.SVFlash.OnServerEvent:Connect(function(player, weapon_tool, mode)
	Event.SVFlash:FireAllClients(player, weapon_tool, mode)
end)

----------------------------------------------------------------
--\\DOORS & BREACHING SYSTEM
----------------------------------------------------------------
local ServerStorage = game:GetService("ServerStorage")
local DoorsFolder = ACS_Workspace:FindFirstChild("Doors")
local DoorsFolderClone = DoorsFolder:Clone()
local BreachClone = ACS_Workspace.Breach:Clone()

BreachClone.Parent = ServerStorage
DoorsFolderClone.Parent = ServerStorage

function ToggleDoor(door)
	if not door then return end

	local Hinge = door.Door:FindFirstChild("Hinge")
	if not Hinge then return end
	local HingeConstraint = Hinge.HingeConstraint

	if HingeConstraint.TargetAngle == 0 then
		HingeConstraint.TargetAngle = -90
	elseif HingeConstraint.TargetAngle == -90 then
		HingeConstraint.TargetAngle = 0
	end
end

Event.DoorEvent.OnServerEvent:Connect(function(player, door, mode, key)
	local character = player.Character
	if not character then return end

	if door == nil then return end

	if mode == 1 then
		if door:FindFirstChild("Locked") ~= nil and door.Locked.Value == true then
			if door:FindFirstChild("RequiresKey") then
				if character:FindFirstChild(key) ~= nil or player.Backpack:FindFirstChild(key) ~= nil then
					if door.Locked.Value == true then
						door.Locked.Value = false
					end
					ToggleDoor(door)
				end	
			end
		else
			ToggleDoor(door)
		end

	elseif mode == 2 then
		if door:FindFirstChild("Locked") == nil or (door:FindFirstChild("Locked") ~= nil and door.Locked.Value == false) then
			ToggleDoor(door)
		end

	elseif mode == 3 then
		if door:FindFirstChild("RequiresKey") then
			key = door.RequiresKey.Value
			if character:FindFirstChild(key) ~= nil or player.Backpack:FindFirstChild(key) ~= nil then
				if door:FindFirstChild("Locked") ~= nil and door.Locked.Value == true then
					door.Locked.Value = false
				else
					door.Locked.Value = true
				end
			end
		end
		
	elseif mode == 4 then
		if door:FindFirstChild("Locked") ~= nil and door.Locked.Value == true then
			door.Locked.Value = false
		end
	end
end)

Event.MedSys.Collapse.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then return end

	local humanoid = character.Humanoid
	local acs_client = humanoid.Parent.ACS_Client
	local Dor = humanoid.Parent.ACS_Client.Variaveis.Dor
	local Sangue = humanoid.Parent.ACS_Client.Variaveis.Sangue

	if (Sangue.Value <= 3500) or (Dor.Value >= 200) or acs_client:GetAttribute("Collapsed") then -- Man this Guy's Really wounded,
		humanoid.PlatformStand = true
		humanoid.AutoRotate = false
		acs_client:SetAttribute("Collapsed",true)
	elseif (Sangue.Value > 3500) and (Dor.Value < 200) and not acs_client:GetAttribute("Collapsed")  then -- YAY A MEDIC ARRIVED! =D
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true	
		acs_client:SetAttribute("Collapsed",false)
	end
end)

Event.MedSys.MedHandler.OnServerEvent:Connect(function(player, Victim, mode)
	local character = player.Character
	if not character then return end

	local humanoid = character.Humanoid
	if not humanoid or humanoid.Health <= 0 then return end

	local P1_Client = character:FindFirstChild("ACS_Client")

	if P1_Client == nil then
		Util.LogTagged("ACS_Server", player.Name .. "'s Action failed: missing ACS_Client")
		return
	end

	if P1_Client:GetAttribute("Collapsed") then
		return
	end

	if Victim then --Multiplayer functions
		local victim_character = Victim.Character
		if not victim_character then return end

		local victim_humanoid = victim_character.Humanoid
		if not victim_humanoid then return end

		local close_player = (character.HumanoidRootPart.Position - victim_character.HumanoidRootPart.Position).Magnitude <= 15
		if not close_player then
			warn(player.Name .. " is too far to treat " .. Victim.Name)
			return
		end

		local P2_Client = victim_character:FindFirstChild("ACS_Client")
		if not P2_Client then
			warn(player.Name .. "'s Action Failed: Missing " .. Victim.Name .. "'s ACS_Client")
			return
		end

		if mode == 1 and P1_Client.Kit.Bandage.Value > 0 and P2_Client:GetAttribute("Bleeding") then
			P1_Client.Kit.Bandage.Value = P1_Client.Kit.Bandage.Value - 1
			P2_Client:SetAttribute("Bleeding",false)

		elseif mode == 2 and P1_Client.Kit.Splint.Value > 0 and P2_Client:GetAttribute("Injured") then
			P1_Client.Kit.Splint.Value = P1_Client.Kit.Splint.Value - 1
			P2_Client:SetAttribute("Injured",false)

		elseif mode == 3 and (P2_Client:GetAttribute("Bleeding") == true or P2_Client:GetAttribute("Tourniquet")) then --Tourniquet works a little different :T
			if P2_Client:GetAttribute("Tourniquet")then
				P1_Client.Kit.Tourniquet.Value = P1_Client.Kit.Tourniquet.Value + 1
				P2_Client:SetAttribute("Tourniquet",false)
			else
				if P1_Client.Kit.Tourniquet.Value > 0 then
					P1_Client.Kit.Tourniquet.Value = P1_Client.Kit.Tourniquet.Value - 1
					P2_Client:SetAttribute("Tourniquet",true)
				end
			end

		elseif mode == 4 and P1_Client.Kit.PainKiller.Value > 0 and P2_Client.Variaveis.Dor.Value > 0 then
			P1_Client.Kit.PainKiller.Value = P1_Client.Kit.PainKiller.Value - 1
			P2_Client.Variaveis.Dor.Value = math.clamp(P2_Client.Variaveis.Dor.Value - math.random(35,65),0,300)
			Event.MedSys.MedHandler:FireClient(Victim,4)

		elseif mode == 5 and P1_Client.Kit.EnergyShot.Value > 0 and victim_humanoid.Health < victim_humanoid.MaxHealth then
			P1_Client.Kit.EnergyShot.Value = P1_Client.Kit.EnergyShot.Value - 1
			local HealValue = math.random(15,25)
			if victim_humanoid.Health + HealValue < victim_humanoid.MaxHealth then
				victim_humanoid:TakeDamage(-HealValue)
			else
				victim_humanoid.Health = victim_humanoid.MaxHealth
			end
			Event.MedSys.MedHandler:FireClient(Victim,5)

		elseif mode == 6 and P1_Client.Kit.Morphine.Value > 0 and P2_Client.Variaveis.Dor.Value > 0 then
			P1_Client.Kit.Morphine.Value = P1_Client.Kit.Morphine.Value - 1
			P2_Client.Variaveis.Dor.Value = 0
			Event.MedSys.MedHandler:FireClient(Victim,6)

		elseif mode == 7 and P1_Client.Kit.Epinephrine.Value > 0 and P2_Client:GetAttribute("Collapsed")then
			P1_Client.Kit.Epinephrine.Value = P1_Client.Kit.Epinephrine.Value - 1
			local HealValue = math.random(45,55)
			if victim_humanoid.Health + HealValue < victim_humanoid.MaxHealth then
				victim_humanoid:TakeDamage(-HealValue)
			else
				victim_humanoid.Health = victim_humanoid.MaxHealth
			end
			P2_Client:SetAttribute("Collapsed",false)
			Event.MedSys.MedHandler:FireClient(Victim,7)

		elseif mode == 8 and P1_Client.Kit.BloodBag.Value > 0 and P2_Client.Variaveis.Sangue.Value < P2_Client.Variaveis.Sangue.MaxValue then
			P1_Client.Kit.BloodBag.Value = P1_Client.Kit.BloodBag.Value - 1
			P2_Client.Variaveis.Sangue.Value = P2_Client.Variaveis.Sangue.Value + 2000
		end
	else --Self treat
		if mode == 1 and P1_Client.Kit.Bandage.Value > 0 and P1_Client:GetAttribute("Bleeding") then
			P1_Client.Kit.Bandage.Value = P1_Client.Kit.Bandage.Value - 1
			P1_Client:SetAttribute("Bleeding",false)

		elseif mode == 2 and P1_Client.Kit.Splint.Value > 0 and P1_Client:GetAttribute("Injured") then
			P1_Client.Kit.Splint.Value = P1_Client.Kit.Splint.Value - 1
			P1_Client:SetAttribute("Injured",false)

		elseif mode == 3 and (P1_Client:GetAttribute("Bleeding") or P1_Client:GetAttribute("Tourniquet")) then --Tourniquet works a little diferent :T
			if P1_Client:GetAttribute("Tourniquet") then
				P1_Client.Kit.Tourniquet.Value = P1_Client.Kit.Tourniquet.Value + 1
				P1_Client:SetAttribute("Tourniquet",false)
			else
				if P1_Client.Kit.Tourniquet.Value > 0 then
					P1_Client.Kit.Tourniquet.Value = P1_Client.Kit.Tourniquet.Value - 1
					P1_Client:SetAttribute("Tourniquet",true)
				end
			end

		elseif mode == 4 and P1_Client.Kit.PainKiller.Value > 0 and P1_Client.Variaveis.Dor.Value > 0 then
			P1_Client.Kit.PainKiller.Value = P1_Client.Kit.PainKiller.Value - 1
			P1_Client.Variaveis.Dor.Value = math.clamp(P1_Client.Variaveis.Dor.Value - math.random(35,65),0,300)
			Event.MedSys.MedHandler:FireClient(player,4)

		elseif mode == 5 and P1_Client.Kit.EnergyShot.Value > 0 and humanoid.Health < humanoid.MaxHealth then
			P1_Client.Kit.EnergyShot.Value = P1_Client.Kit.EnergyShot.Value - 1
			local HealValue = math.random(15,25)
			if humanoid.Health + HealValue < humanoid.MaxHealth then
				humanoid:TakeDamage(-HealValue)
			else
				humanoid.Health = humanoid.MaxHealth
			end
			Event.MedSys.MedHandler:FireClient(player,5)

		elseif mode == 6 and P1_Client.Kit.Morphine.Value > 0 and P1_Client.Variaveis.Dor.Value > 0 then
			P1_Client.Kit.Morphine.Value = P1_Client.Kit.Morphine.Value - 1
			P1_Client.Variaveis.Dor.Value = math.clamp(P1_Client.Variaveis.Dor.Value - math.random(125,175),0,300)
			Event.MedSys.MedHandler:FireClient(player,6)

		elseif mode == 7 and P1_Client.Kit.Epinephrine.Value > 0 and humanoid.Health < humanoid.MaxHealth then
			P1_Client.Kit.Epinephrine.Value = P1_Client.Kit.Epinephrine.Value - 1
			local HealValue = math.random(45,55)
			if humanoid.Health + HealValue < humanoid.MaxHealth then
				humanoid:TakeDamage(-HealValue)
			else
				humanoid.Health = humanoid.MaxHealth
			end
			Event.MedSys.MedHandler:FireClient(player, 7)

		elseif mode == 8 and P1_Client.Kit.BloodBag.Value > 0 and P1_Client.Variaveis.Sangue.Value < P1_Client.Variaveis.Sangue.MaxValue then
			P1_Client.Kit.BloodBag.Value = P1_Client.Kit.BloodBag.Value - 1
			P1_Client.Variaveis.Sangue.Value = P1_Client.Variaveis.Sangue.Value + 2000
		end
	end
end)

Event.Drag.OnServerEvent:Connect(function(player, target_humanoid)

	local P1_Client = player.Character:FindFirstChild("ACS_Client")
	local Human 	= player.Character.Humanoid

	if not P1_Client then
		return
	end

	if target_humanoid then
		P1_Client:SetAttribute("DragPlayer", target_humanoid.Name)
	else
		P1_Client:SetAttribute("DragPlayer","")
		P1_Client:SetAttribute("Dragging",false)
	end

	local target = P1_Client:GetAttribute("DragPlayer")

	if not P1_Client:GetAttribute("Collapsed") and target ~= "" then

		local player2 = Players:FindFirstChild(target)
		local PlHuman = player2.Character.Humanoid
		local P2_Client = player2.Character:FindFirstChild("ACS_Client")
		if not P2_Client then
			return
		end
		if not P1_Client:GetAttribute("Dragging") then
			if P2_Client:GetAttribute("Collapsed") then 
				P1_Client:SetAttribute("Dragging",true)	
				while P1_Client:GetAttribute("Dragging") and target ~= "" and P2_Client:GetAttribute("Collapsed") and PlHuman.Health > 0 and Human.Health > 0 and not P1_Client:GetAttribute("Collapsed") do wait() 
					player2.Character.UpperTorso.Anchored = true
					player2.Character.UpperTorso.CFrame = Human.Parent.UpperTorso.CFrame*CFrame.new(0,0.75,1.5)*CFrame.Angles(math.rad(0), math.rad(0), math.rad(90))
				end
				player2.Character.UpperTorso.Anchored = false
			end	
		end	
	end
end)

function BreachFunction(player, breach_mode, breach_target, hit_position, surface_normal, hit_part)

	if breach_mode == 1 then
		if player.Character.ACS_Client.Kit.BreachCharges.Value > 0 then
			player.Character.ACS_Client.Kit.BreachCharges.Value = player.Character.ACS_Client.Kit.BreachCharges.Value - 1
			breach_target.Destroyed.Value = true
			local C4 = Engine.FX.SoundFX.BreachCharge:Clone()

			C4.Parent = breach_target.Destroyable
			C4.Center.CFrame = CFrame.new(hit_position, hit_position + surface_normal) * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))
			C4.Center.Place:Play()

			local charge_weld = Instance.new("WeldConstraint")
			charge_weld.Parent = C4
			charge_weld.Part0 = breach_target.Destroyable.Charge
			charge_weld.Part1 = C4.Center

			task.wait(1)
			C4.Center.Beep:Play()
			task.wait(4)
			if C4 and C4:FindFirstChild("Center") then
				local explosion_attachment = Instance.new("Attachment")
				explosion_attachment.CFrame = C4.Center.CFrame
				explosion_attachment.Parent = workspace.Terrain

				local explosion_effect = Engine.FX.VisualFX.Breach.ExplosionEffect:Clone()
				explosion_effect.Parent = explosion_attachment
				explosion_effect.Enabled = false
				explosion_effect:Emit(35)
				Debris:AddItem(explosion_effect,explosion_effect.Lifetime.Max)

				local explosion_instance = Instance.new("Explosion")
				explosion_instance.BlastPressure = 0
				explosion_instance.BlastRadius = 0
				explosion_instance.DestroyJointRadiusPercent = 0
				explosion_instance.Position = C4.Center.Position
				explosion_instance.Parent = workspace

				local explosion_sound = Instance.new("Sound")
				explosion_sound.RollOffMinDistance = 10
				explosion_sound.RollOffMaxDistance = 1000
				explosion_sound.SoundId = "rbxassetid://" .. Explosion[math.random(1, 7)]
				explosion_sound.PlaybackSpeed = math.random(30,55)/40
				explosion_sound.Volume = 2
				explosion_sound.Parent = explosion_attachment
				explosion_sound.PlayOnRemove = true
				explosion_sound:Destroy()

				for _, other_player in pairs(Players:GetChildren()) do
					if other_player:IsA('Player') and other_player.Character and other_player.Character:FindFirstChild('Head') and (other_player.Character.Head.Position - C4.Center.Position).magnitude <= 15 then
						local distance_multiplier = (((other_player.Character.Head.Position - C4.Center.Position).magnitude/35) - 1) * -1
						local intensity = distance_multiplier
						local duration = 15 * distance_multiplier

						Event.Suppression:FireClient(other_player, 2, intensity, duration)
					end
				end

				Debris:AddItem(breach_target.Destroyable,0)
			end
		end

	elseif breach_mode == 2 then

		local aw = Engine.FX.SoundFX.DoorBreachFX:Clone()
		aw.Parent = breach_target.Door.Door
		aw.RollOffMaxDistance = 100
		aw.RollOffMinDistance = 5
		aw:Play()

		breach_target.Destroyed.Value = true
		if breach_target.Door:FindFirstChild("Hinge") ~= nil then
			breach_target.Door.Hinge:Destroy()
		end
		if breach_target.Door:FindFirstChild("Knob") ~= nil then
			breach_target.Door.Knob:Destroy()
		end

		local forca = Instance.new("BodyForce")
		forca.Force = -surface_normal * breach_target.Door.Door:GetMass() * Vector3.new(50,0,50)
		forca.Parent = breach_target.Door.Door

		Debris:AddItem(breach_target,3)

	elseif breach_mode == 3 then
		if player.Character.ACS_Client.Kit.Fortifications.Value > 0 then
			player.Character.ACS_Client.Kit.Fortifications.Value = player.Character.ACS_Client.Kit.Fortifications.Value - 1
			breach_target.Fortified.Value = true
			local C4 = Instance.new('Part')

			C4.Parent = breach_target.Destroyable
			C4.Size =  Vector3.new(hit_part.Size.X + .05,hit_part.Size.Y + .05,hit_part.Size.Z + 0.5) 
			C4.Material = Enum.Material.DiamondPlate
			C4.Anchored = true
			C4.CFrame = hit_part.CFrame

			local sound = Engine.FX.SoundFX.FortFX:Clone()
			sound.PlaybackSpeed = math.random(30,55)/40
			sound.Volume = 1
			sound.Parent = C4
			sound.PlayOnRemove = true
			sound:Destroy()
		end
	end
end

Event.Breach.OnServerInvoke = BreachFunction

function UpdateLog(player, humanoid)
	local tag = humanoid:findFirstChild("creator")
	if not tag then return end

	local hours = os.date("*t")["hour"]
	local mins = os.date("*t")["min"]
	local sec = os.date("*t")["sec"]
	local tag_type = tag:findFirstChild("type")

	if tag.Value.Name == player.Name then
		local String = player.Name.." Died | "..hours..":"..mins..":"..sec
		table.insert(CombatLog,String)
	else
		local String = tag.Value.Name.." Killed "..player.Name.." | "..hours..":"..mins..":"..sec
		table.insert(CombatLog,String)
	end

	if #CombatLog > 50 then
		Backup = Backup + 1
		warn("ACS: Cleaning Combat Log | Backup: "..Backup)
		warn(CombatLog)
		CombatLog = {}
	end
end

Players.PlayerAdded:Connect(function(player)

	for _, banned_player in ipairs(_G.TempBannedPlayers) do
		if banned_player == player.Name then
			player:Kick('Blacklisted')
			warn(player.Name.." (Temporary Banned) tried to join to server")
			break
		end
	end

	for _, blacklisted_player in ipairs(Config.Blacklist) do
		if blacklisted_player == player.UserId then
			player:Kick('Blacklisted')
			warn(player.Name.." (Blacklisted) tried to join to server")
			break
		end
	end

	if Config.AgeRestrictEnabled and not Run:IsStudio() then
		if player.AccountAge < Config.AgeLimit then
			player:Kick('Age restricted server! Please wait: '..(Config.AgeLimit - player.AccountAge)..' Days')
		end
	end

	if game.CreatorType == Enum.CreatorType.User then
		if player.UserId == game.CreatorId or Run:IsStudio() then
			player.Chatted:Connect(function(Message)
				if string.lower(Message) == "/acslog" then
					Event.CombatLog:FireClient(player,CombatLog)
				end
			end)
		end
	elseif game.CreatorType == Enum.CreatorType.Group then
		if player:IsInGroupAsync(game.CreatorId) or Run:IsStudio() then
			player.Chatted:Connect(function(Message)
				if string.lower(Message) == "/acslog" then
					Event.CombatLog:FireClient(player,CombatLog)
				end
			end)
		end
	end

	player.CharacterAdded:Connect(function(character)
		if Config.TeamTags then
			local team_tag_ui = HUDs:WaitForChild('TeamTagUI'):Clone()
			team_tag_ui.Parent = character
			team_tag_ui.Adornee = character.Head
		end
		
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Accessory") then
				child:Destroy()
			end
		end

		local humanoid = character:WaitForChild("Humanoid", 5)
		if humanoid then
			for _, accessory in ipairs(humanoid:GetAccessories()) do
				accessory:Destroy()
			end
		end

		character.Humanoid.BreakJointsOnDeath = false
		character.Humanoid.Died:Connect(function()
			UpdateLog(player, character.Humanoid)
			pcall(function()
				Ragdoll(character)
			end)
		end)
		
		local backpack = player:WaitForChild("Backpack")
		
		for _, tool in pairs(backpack:GetChildren()) do
			if tool:IsA("Tool") and tool:FindFirstChild("ACS_Settings") then
				local settings = require(tool.ACS_Settings)
				if settings.Holster then
					task.defer(function()
						WeaponHolster.Check(player, tool.Name, settings, tool)
					end)
				end
			end
		end

		backpack.ChildRemoved:Connect(function(removed_tool)
			if not removed_tool:IsA("Tool") then return end
			if not removed_tool:FindFirstChild("ACS_Settings") then return end

			local holster_name = "Holster_" .. removed_tool.Name
			local holster = character:FindFirstChild(holster_name)
			if not holster then return end

			task.defer(function()
				if not character or not character.Parent then return end
				local tool_still_in_backpack = player.Backpack:FindFirstChild(removed_tool.Name)
				local tool_equipped = character:FindFirstChild(removed_tool.Name)

				if not tool_still_in_backpack and not tool_equipped then
					holster:Destroy()
				elseif tool_still_in_backpack then
					WeaponHolster.SetVisible(holster, true)
				end
			end)
		end)

		backpack.ChildAdded:Connect(function(added_tool)
			if not added_tool:IsA("Tool") then return end
			if not added_tool:FindFirstChild("ACS_Settings") then return end

			local settings = require(added_tool.ACS_Settings)
			if not settings.Holster then return end

			task.defer(function()
				if not character or not character.Parent then return end

				local holster_name = "Holster_" .. added_tool.Name
				local existing_holster = character:FindFirstChild(holster_name)

				if existing_holster then
					WeaponHolster.SetVisible(existing_holster, true)
				else
					WeaponHolster.Check(player, added_tool.Name, settings, added_tool)
				end
			end)
		end)
		
		character.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") and child:FindFirstChild("ACS_Settings") then
				local settings = require(child.ACS_Settings)
				if settings.Holster then
					local holster = character:FindFirstChild("Holster_" .. child.Name)
					if holster then
						WeaponHolster.SetVisible(holster, true)
					end
				end
			end
		end)
	end)
end)

Event.Shell.OnServerEvent:Connect(function(player, shell, origin)
	Event.Shell:FireAllClients(shell, origin)
end)

print(Config.Version)
print(Config.ModdedVersion)