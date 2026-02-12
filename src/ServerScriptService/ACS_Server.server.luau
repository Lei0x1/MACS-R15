local RS 			= game.ReplicatedStorage
local ACS_Workspace = workspace:WaitForChild("ACS_WorkSpace")
local Engine 		= RS:WaitForChild("ACS_Engine")
local Event 			= Engine:WaitForChild("Events")
local Mods 			= Engine:WaitForChild("Modules")
local ArmModel 		= Engine:WaitForChild("ArmModel")
local WeaponModels  = Engine:WaitForChild("WeaponModels")
local SVGunModels 	= Engine:WaitForChild("GrenadeModels")
local HUDs 			= Engine:WaitForChild("HUD")
local AttModels 	= Engine:WaitForChild("AttModels")
local AttModules  	= Engine:WaitForChild("AttModules")
local Rules			= Engine:WaitForChild("GameRules")

local gameRules		= require(Rules:WaitForChild("Config"))
local CombatLog		= require(Rules:WaitForChild("CombatLog"))
local SpringMod 	= require(Mods:WaitForChild("Spring"))
local HitMod 		= require(Mods:WaitForChild("Hitmarker"))
local Ultil			= require(Mods:WaitForChild("Utilities"))
local Ragdoll		= require(Mods:WaitForChild("Ragdoll"))

local WeaponMod		= Mods:WaitForChild("Weapon")
local Holster		= require(WeaponMod:WaitForChild("Holster"))

local HttpService 	= game:GetService("HttpService")
local PhysicsService= game:GetService("PhysicsService")
local TS 			= game:GetService('TweenService')
local Debris 		= game:GetService("Debris")
local PhysicsService= game:GetService("PhysicsService")
local Run 			= game:GetService("RunService")

local plr 			= game:GetService("Players")
local ACS_0 		= HttpService:GenerateGUID(true)
local Backup 		= 0

Holster.Init(WeaponModels, Ultil)

_G.TempBannedPlayers = {} --Local ban list

local Explosion = {"287390459"; "287390954"; "287391087"; "287391197"; "287391361"; "287391499"; "287391567";}
-----------------------------------------------------------------

game.StarterPlayer.CharacterWalkSpeed = gameRules.NormalWalkSpeed

local function AccessID(SKP_0,SKP_1)
	if SKP_0.UserId == SKP_1 then
		return ACS_0
	else
		SKP_0:kick("Exploit Protocol")
		warn(SKP_0.Name.." - Potential Exploiter! Case 0-A: Client Tried To Access Server Code")
		table.insert(_G.TempBannedPlayers, SKP_0)
	end
end

Event.AcessId.OnServerInvoke = AccessID

--Glenn's Anti-Exploit System (GAE for short). This code is very ugly, but does job done
local function compareTables(arr1, arr2)
	if	arr1.gunName==arr2.gunName 				and 
		arr1.Type==arr2.Type 					and
		arr1.ShootRate==arr2.ShootRate 			and
		arr1.Bullets==arr2.Bullets				and
		arr1.LimbDamage[1]==arr2.LimbDamage[1]	and
		arr1.LimbDamage[2]==arr2.LimbDamage[2]	and
		arr1.TorsoDamage[1]==arr2.TorsoDamage[1]and
		arr1.TorsoDamage[2]==arr2.TorsoDamage[2]and
		arr1.HeadDamage[1]==arr2.HeadDamage[1]	and
		arr1.HeadDamage[2]==arr2.HeadDamage[2]
	then
		return true
	else
		return false
	end
end

local function secureSettings(Player,Gun,Module)
	local PreNewModule = Gun:FindFirstChild("ACS_Settings")
	if Gun and PreNewModule then
		local NewModule = require(PreNewModule)
		if compareTables(Module, NewModule) == false then
			Player:kick("Exploit Protocol")
			warn(Player.Name.." - Potential Exploiter! Case 4: Exploiting Gun Stats")	
			table.insert(_G.TempBannedPlayers, Player)
			return false
		else
			return true
		end
	else
		Player:kick("Exploit Protocol")
		warn(Player.Name.." - Potential Exploiter! Case 2: Missing Gun And Module")	
		return false
	end
end

function CalculateDMG(SKP_0, SKP_1, SKP_2, SKP_4, SKP_5, SKP_6)

	local skp_0	= nil
	local skp_1 = 0
	local skp_2 = SKP_5.MinDamage * SKP_6.minDamageMod

	if game.Players:GetPlayerFromCharacter(SKP_1.Parent) ~= nil then
		skp_0 = game.Players:GetPlayerFromCharacter(SKP_1.Parent)
	end

	if SKP_4 == 1 then
		local skp_3 = math.random(SKP_5.HeadDamage[1], SKP_5.HeadDamage[2])
		skp_1 = math.max(skp_2 ,(skp_3 * SKP_6.DamageMod) - (SKP_2/25) * SKP_5.DamageFallOf)
	elseif SKP_4 == 2 then
		local skp_3 = math.random(SKP_5.TorsoDamage[1], SKP_5.TorsoDamage[2])
		skp_1 = math.max(skp_2 ,(skp_3 * SKP_6.DamageMod) - (SKP_2/25) * SKP_5.DamageFallOf)
	else
		local skp_3 = math.random(SKP_5.LimbDamage[1], SKP_5.LimbDamage[2])
		skp_1 = math.max(skp_2 ,(skp_3 * SKP_6.DamageMod) - (SKP_2/25) * SKP_5.DamageFallOf)
	end

	if SKP_1.Parent:FindFirstChild("ACS_Client") ~= nil and not SKP_5.IgnoreProtection then

		local skp_4 = SKP_1.Parent.ACS_Client.Protecao.VestProtect
		local skp_5 = SKP_1.Parent.ACS_Client.Protecao.HelmetProtect

		if SKP_4 == 1 then
			if SKP_5.BulletPenetration < skp_5.Value  then
				skp_1 = math.max(.5 ,skp_1 * (SKP_5.BulletPenetration/skp_5.Value))
			end
		else
			if SKP_5.BulletPenetration < skp_4.Value  then
				skp_1 = math.max(.5 ,skp_1 * (SKP_5.BulletPenetration/skp_4.Value))
			end
		end
	end		

	if skp_0 ~= nil then
		if skp_0.Team ~= SKP_0.Team or skp_0.Neutral == true then
			SKP_1:TakeDamage(skp_1)
		else
			if gameRules.TeamKill then
				SKP_1:TakeDamage(skp_1 * gameRules.TeamDmgMult)
			end
		end
	else
		SKP_1:TakeDamage(skp_1)
	end
end

local function Damage(SKP_0, SKP_1, SKP_2, SKP_3, SKP_4, SKP_5, SKP_6, SKP_7, SKP_8, SKP_9)
	if SKP_0 and SKP_0.Character and SKP_0.Character.Humanoid.Health > 0 then
		if SKP_9 == (ACS_0.."-"..SKP_0.UserId) then
			if not SKP_7 then
				if SKP_1 then
					local skp_0 = secureSettings(SKP_0,SKP_1, SKP_5)
					if skp_0 and SKP_2 then
						CalculateDMG(SKP_0, SKP_2, SKP_3, SKP_4, SKP_5, SKP_6)
						local skp_1	= Instance.new("ObjectValue")
						skp_1.Name	= "creator"
						skp_1.Value	= SKP_0
						skp_1.Parent= SKP_2
						game.Debris:AddItem(skp_1, 1)
					end
				else
					SKP_0:kick("Exploit Protocol")
					warn(SKP_0.Name.." - Potential Exploiter! Case 1: Tried To Access Damage Event")
					table.insert(_G.TempBannedPlayers, SKP_0)
				end
			else
				SKP_0.Character.Humanoid:TakeDamage(SKP_8)
			end
		else
			SKP_0:kick("Exploit Protocol")
			warn(SKP_0.Name.." - Potential Exploiter! Case 0-B: Wrong Permission Code")
			table.insert(_G.TempBannedPlayers, SKP_0)
		end
	end
end

local function GetBodyPart(character, part_name)
	if not character then return nil end
	return character:FindFirstChild(part_name)
end

Event.Damage.OnServerInvoke = Damage

Event.HitEffect.OnServerEvent:Connect(function(Player, Position, HitPart, Normal, Material, Settings)
	Event.HitEffect:FireAllClients(Player, Position, HitPart, Normal, Material, Settings)
end)

Event.CurrentGunStance.OnServerEvent:Connect(function(Player,stance,Data)
	Event.CurrentGunStance:FireAllClients(Player,stance,Data)
end)

Event.ServerBullet.OnServerEvent:Connect(function(Player,Origin,Direction,WeaponData,ModTable)
	Event.ServerBullet:FireAllClients(Player,Origin,Direction,WeaponData,ModTable)
end)


Event.Stance.OnServerEvent:connect(function(Player, Stance, Virar)
	if not Player or not Player.Character then
		return
	end

	if not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health <= 0 then
		return
	end

	local char = Player.Character

	local Humanoid = char:WaitForChild("Humanoid")
	local ACS_Client = char:WaitForChild("ACS_Client")
	if not ACS_Client then
		return
	end

	-- Body parts
	local UpperTorso = GetBodyPart(char, "UpperTorso")
	local LowerTorso = GetBodyPart(char, "LowerTorso")
	local RightUpperArm = GetBodyPart(char, "RightUpperArm")
	local LeftUpperArm = GetBodyPart(char, "LeftUpperArm")

	if not UpperTorso or not LowerTorso or not RightUpperArm or not LeftUpperArm then 
		return
	end

	-- Joints
	local RootJoint = char["LowerTorso"]:FindFirstChild("Root")
	local WaistJ = char["UpperTorso"]:FindFirstChild("Waist")

	local RightShoulder = char["RightUpperArm"]:FindFirstChild("RightShoulder")
	local LeftShoulder = char["LeftUpperArm"]:FindFirstChild("LeftShoulder")
	local RightHip = char["RightUpperLeg"]:FindFirstChild("RightHip")
	local RightKnee = char["RightLowerLeg"]:FindFirstChild("RightKnee")
	local LeftHip = char["LeftUpperLeg"]:FindFirstChild("LeftHip")
	local LeftKnee = char["LeftLowerLeg"]:FindFirstChild("LeftKnee")

	if not RootJoint or not WaistJ or not RightShoulder or not LeftShoulder or not RightHip or not RightKnee or not LeftHip or not LeftKnee then
		return
	end

	local RightArm = char["RightUpperArm"]
	local LeftArm = char["LeftUpperArm"]
	local LeftLeg = char["LeftUpperLeg"]
	local RightLeg = char["RightUpperLeg"]
	
	local TweenInfoFast = TweenInfo.new(0.3)

	if Stance == 2 and RootJoint and WaistJ and RightHip and LeftHip and RightKnee and LeftKnee then
		TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-Humanoid.HipHeight - LowerTorso.Size.Y,Humanoid.HipHeight/1.25)* CFrame.Angles(math.rad(-90),0,math.rad(0))} ):Play()
		TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
		TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
		TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
		TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
		TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

	end
	if Virar == 1 and RootJoint and WaistJ and RightHip and LeftHip and RightKnee and LeftKnee then
		if Stance == 0 then
			TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0) * CFrame.Angles(math.rad(0),0,math.rad(-30))} ):Play()
			TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-(Humanoid.HipHeight/2),0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

		elseif Stance == 1 then
			TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(-30))} ):Play()
			TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-Humanoid.HipHeight/1.05,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),math.rad(0),math.rad(0))} ):Play()

		end
	elseif Virar == -1 and RootJoint and WaistJ and RightHip and LeftHip and RightKnee and LeftKnee then
		if Stance == 0 then
			TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0) * CFrame.Angles(math.rad(0),0,math.rad(30))} ):Play()
			TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-(Humanoid.HipHeight/2),0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

		elseif Stance == 1 then
			TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(0),0,math.rad(30))} ):Play()
			TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-Humanoid.HipHeight/1.05,0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(75),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/2,0)* CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3.5,0)* CFrame.Angles(math.rad(-60),math.rad(0),math.rad(0))} ):Play()

		end
	elseif Virar == 0 and RootJoint and WaistJ and RightHip and LeftHip and RightKnee and LeftKnee then
		if Stance == 0 then
			TS:Create(WaistJ, TweenInfoFast, {C0 = CFrame.new(0,LowerTorso.Size.Y/2.5,0)* CFrame.Angles(math.rad(-0),0,math.rad(0))} ):Play()
			TS:Create(RootJoint, TweenInfoFast, {C0 = CFrame.new(0,-(Humanoid.HipHeight/2),0)* CFrame.Angles(math.rad(0),0,math.rad(0))} ):Play()
			TS:Create(RightHip, TweenInfoFast, {C0 = CFrame.new(RightLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftHip, TweenInfoFast, {C0 = CFrame.new(-LeftLeg.Size.X/2, -LowerTorso.Size.Y/2,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(RightKnee, TweenInfoFast, {C0 = CFrame.new(0, -RightLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
			TS:Create(LeftKnee, TweenInfoFast, {C0 = CFrame.new(0, -LeftLeg.Size.Y/3,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()

		elseif Stance == 1 then
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
	elseif Stance == 2 then
		TS:Create(RightShoulder, TweenInfoFast, {C0 = CFrame.new(RightArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(170),math.rad(0),math.rad(0))} ):Play()
		TS:Create(LeftShoulder, TweenInfoFast, {C0 = CFrame.new(-LeftArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(170),math.rad(0),math.rad(0))} ):Play()
	else
		TS:Create(RightShoulder, TweenInfoFast, {C0 = CFrame.new(RightArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
		TS:Create(LeftShoulder, TweenInfoFast, {C0 = CFrame.new(-LeftArm.Size.X/1.15, UpperTorso.Size.Y/2.8,0)* CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))} ):Play()
	end
end)

Event.Surrender.OnServerEvent:Connect(function(Player,Victim)

	local PClient 	= nil

	if Victim then
		PClient = Victim.Character:FindFirstChild("ACS_Client")

		if Victim == Player then
			return
		end

		if not PClient then
			return
		end

		if PClient:GetAttribute("Surrender") then
			PClient:SetAttribute("Surrender",false)
		end
	else
		PClient = Player.Character:FindFirstChild("ACS_Client")

		if not PClient then
			return
		end

		if not PClient:GetAttribute("Surrender") then
			PClient:SetAttribute("Surrender",true)
		end
	end
end)

Event.Grenade.OnServerEvent:Connect(function(SKP_0, SKP_1, SKP_2, SKP_3, SKP_4, SKP_5, SKP_6)

	if SKP_0 and SKP_0.Character and SKP_0.Character.Humanoid.Health > 0 then
		if SKP_6 == (ACS_0.."-"..SKP_0.UserId) then
			if SKP_1 and SKP_2 then
				local skp_0 = secureSettings(SKP_0, SKP_1, SKP_2)
				if skp_0 and SKP_2.Type == "Grenade" then

					if SVGunModels:FindFirstChild(SKP_2.gunName) == nil then
						warn("ACS_Server Couldn't Find "..SKP_2.gunName.." In Grenade Model Folder")
						return
					end

					local skp_0 = SVGunModels[SKP_2.gunName]:Clone()

					for SKP_Arg0, SKP_Arg1 in pairs(SKP_0.Character:GetChildren()) do
						if SKP_Arg1:IsA('BasePart')then
							local skp_1 = Instance.new("NoCollisionConstraint")
							skp_1.Parent= skp_0
							skp_1.Part0 = skp_0.PrimaryPart
							skp_1.Part1 = SKP_Arg1
						end
					end

					local skp_1	= Instance.new("ObjectValue")
					skp_1.Name	= "creator"
					skp_1.Value	= SKP_0
					skp_1.Parent= skp_0.PrimaryPart

					skp_0.Parent 	= ACS_Workspace.Server
					skp_0.PrimaryPart.CFrame = SKP_3
					skp_0.PrimaryPart:ApplyImpulse(SKP_4 * SKP_5 * skp_0.PrimaryPart:GetMass())
					--skp_0.PrimaryPart:SetNetworkOwner(SKP_0)
					skp_0.PrimaryPart.Damage.Disabled = false

					SKP_1:Destroy()
				end
			else
				SKP_0:kick("Exploit Protocol")
				warn(SKP_0.Name.." - Potential Exploiter! Case 3: Tried To Access Grenade Event")
			end
		else
			SKP_0:kick("Exploit Protocol")
			warn(SKP_0.Name.." - Potential Exploiter! Case 0-B: Wrong Permission Code")
			table.insert(_G.TempBannedPlayers, SKP_0)
		end
	end

end)

function LoadAttachment(weapon,WeaponData)
	if weapon and WeaponData and weapon:FindFirstChild("Nodes") ~= nil then

		--load sight Att
		if weapon.Nodes:FindFirstChild("Sight") ~= nil and WeaponData.SightAtt ~= "" then

			local SightAtt = AttModels[WeaponData.SightAtt]:Clone()
			SightAtt.Parent = weapon
			SightAtt:SetPrimaryPartCFrame(weapon.Nodes.Sight.CFrame)

			for index, key in pairs(weapon:GetChildren()) do
				if key.Name == "IS" then
					key.Transparency = 1
				end
			end

			for index, key in pairs(SightAtt:GetChildren()) do
				if key:IsA('BasePart') then
					Ultil.Weld(weapon:WaitForChild("Handle"), key )
					key.Anchored = false
					key.CanCollide = false
				end
				if key.Name == "SightMark" or key.Name == "Main" then
					key:Destroy()
				end
			end

		end

		--load Barrel Att
		if weapon.Nodes:FindFirstChild("Barrel") ~= nil and WeaponData.BarrelAtt ~= "" then

			local BarrelAtt = AttModels[WeaponData.BarrelAtt]:Clone()
			BarrelAtt.Parent = weapon
			BarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.Barrel.CFrame)

			if BarrelAtt:FindFirstChild("BarrelPos") ~= nil then
				weapon.Handle.Muzzle.WorldCFrame = BarrelAtt.BarrelPos.CFrame
			end

			for index, key in pairs(BarrelAtt:GetChildren()) do
				if key:IsA('BasePart') then
					Ultil.Weld(weapon:WaitForChild("Handle"), key )
					key.Anchored = false
					key.CanCollide = false
				end
			end
		end

		--load Under Barrel Att
		if weapon.Nodes:FindFirstChild("UnderBarrel") ~= nil and WeaponData.UnderBarrelAtt ~= "" then

			local UnderBarrelAtt = AttModels[WeaponData.UnderBarrelAtt]:Clone()
			UnderBarrelAtt.Parent = weapon
			UnderBarrelAtt:SetPrimaryPartCFrame(weapon.Nodes.UnderBarrel.CFrame)


			for index, key in pairs(UnderBarrelAtt:GetChildren()) do
				if key:IsA('BasePart') then
					Ultil.Weld(weapon:WaitForChild("Handle"), key )
					key.Anchored = false
					key.CanCollide = false
				end
			end
		end

		if weapon.Nodes:FindFirstChild("Other") ~= nil and WeaponData.OtherAtt ~= "" then

			local OtherAtt = AttModels[WeaponData.OtherAtt]:Clone()
			OtherAtt.Parent = weapon
			OtherAtt:SetPrimaryPartCFrame(weapon.Nodes.Other.CFrame)

			for index, key in pairs(OtherAtt:GetChildren()) do
				if key:IsA('BasePart') then
					Ultil.Weld(weapon:WaitForChild("Handle"), key )
					key.Anchored = false
					key.CanCollide = false
				end
			end
		end
	end
end

Event.Equip.OnServerEvent:Connect(function(Player, WeaponTool, Mode, WeaponData, Anim)
	if not Player or not Player.Character then return end
	
	local char = Player.Character
	
	local Head = Player.Character:FindFirstChild('Head')
	local RA = Player.Character:FindFirstChild('RightUpperArm')
	local LA = Player.Character:FindFirstChild('LeftUpperArm')
	
	if not Head or not RA or not LA then
		return
	end
	
	if Mode == 1 then -- EQUIP				
		local holster = Player.Character:FindFirstChild("Holster_" .. WeaponTool.Name)
		if holster then
			Holster.SetVisible(holster, false)
		end
		
		local weapon_type = WeaponData.Type

		local weapon_type_folder = WeaponModels:FindFirstChild(weapon_type)
		if not weapon_type_folder then
			warn("Weapon type folder not found: " .. weapon_type)
			return
		end

		local model_check = weapon_type_folder:FindFirstChild(WeaponTool.Name)
		if not model_check then
			warn("Model " .. WeaponTool.Name .. " not found in " .. weapon_type .. " folder")
			return
		end

		local ServerGun = model_check:Clone()
		ServerGun.Name = 'S' .. WeaponTool.Name

		-- Create animation base
		local AnimBase = Instance.new("Part")
		AnimBase.CanCollide = false
		AnimBase.Transparency = 1
		AnimBase.Anchored = false
		AnimBase.Name = "AnimBase"
		AnimBase.Size = Vector3.new(0.1, 0.1, 0.1)
		AnimBase.Parent = Player.Character

		-- Attach AnimBase to Head
		local AnimBaseW = Instance.new("Motor6D")
		AnimBaseW.Part0 = Head
		AnimBaseW.Part1 = AnimBase
		AnimBaseW.Parent = AnimBase
		AnimBaseW.Name = "AnimBaseW"
		--AnimBaseW.C0 = CFrame.new(0,-1.25,0)

		local RightShoulder = RA:WaitForChild("RightShoulder")
		local RightLowerArm = Player.Character:FindFirstChild("RightLowerArm")
		local RightHand 	= Player.Character:FindFirstChild("RightHand")
		local LeftShoulder  = LA:WaitForChild("LeftShoulder")
		local LeftLowerArm 	= Player.Character:FindFirstChild("LeftLowerArm")
		local LeftHand 		= Player.Character:FindFirstChild("LeftHand")
		
		if not RightShoulder or not RightLowerArm or not RightHand or not LeftShoulder or not LeftLowerArm or not LeftHand then
			warn("Missing arm parts for", Player.Name)
			return
		end
		
		if RightShoulder then
			RightShoulder.Enabled = false
		end
		
		-- Right arm setup
		local ruaw = Instance.new("Motor6D")
		ruaw.Name = "RAW"
		ruaw.Part0 = RA
		ruaw.Part1 = AnimBase
		ruaw.Parent = AnimBase
		ruaw.C0 = Anim.SV_RightArmPos

		local rlaw = Instance.new("Motor6D")
		rlaw.Name = "RLAW"
		rlaw.Part0 = RightLowerArm
		rlaw.Part1 = RA
		rlaw.Parent = AnimBase
		rlaw.C0 = CFrame.new(0,RA.Size.Y/2,0) * (Anim.SV_RightElbowPos or CFrame.new())

		local rhw = Instance.new("Motor6D")
		rhw.Name = "RHW"
		rhw.Part0 = RightHand
		rhw.Part1 = RightLowerArm
		rhw.Parent = AnimBase
		rhw.C0 = CFrame.new(0, RightLowerArm.Size.Y / 2, 0) * (Anim.SV_RightWristPos or CFrame.new())
		
		if LeftShoulder then
			LeftShoulder.Enabled = false
		end

		-- Left arm setup
		local luaw = Instance.new("Motor6D")
		luaw.Name = "LAW"
		luaw.Part0 = LA
		luaw.Part1 = AnimBase
		luaw.Parent = AnimBase
		luaw.C0 = Anim.SV_LeftArmPos
	
		local llaw = Instance.new("Motor6D")
		llaw.Name = "LLAW"
		llaw.Part0 = Player.Character.LeftLowerArm
		llaw.Part1 = LA
		llaw.Parent = AnimBase
		llaw.C0 = CFrame.new(0,LA.Size.Y/2,0) * (Anim.SV_LeftElbowPos or CFrame.new())
	
		local lhw = Instance.new("Motor6D")
		lhw.Name = "LHW"
		lhw.Part0 = Player.Character.LeftHand
		lhw.Part1 = Player.Character.LeftLowerArm
		lhw.Parent = AnimBase
		lhw.C0 = CFrame.new(0,Player.Character.LeftLowerArm.Size.Y/2,0) * (Anim.SV_LeftWristPos or CFrame.new())

		ServerGun.Parent = Player.Character

		LoadAttachment(ServerGun, WeaponData)

		if ServerGun:FindFirstChild("Nodes") ~= nil then
			ServerGun.Nodes:Destroy()
		end

		-- Clean up sight marks
		for _, part in pairs(ServerGun:GetDescendants()) do
			if part.Name == "SightMark" then
				part:Destroy()
			end
		end

		-- Weld all parts to handle
		for _, part in pairs(ServerGun:GetDescendants()) do
			if not part:IsA('BasePart') or part.Name == 'Handle' then
				continue
			end

			Ultil.WeldComplex(ServerGun:WaitForChild("Handle"), part, part.Name)
		end

		-- Attach gun to hand
		if RightHand then
			local gun_weld = Instance.new('Motor6D')
			gun_weld.Name = 'Handle'
			gun_weld.Parent = ServerGun.Handle
			gun_weld.Part0 = Player.Character['RightHand']
			gun_weld.Part1 = ServerGun.Handle

			local gun_pos = Anim.SV_GunPos
			local adjusted_pos = gun_pos * CFrame.new(0, 0, 1.1)

			gun_weld.C1 = adjusted_pos:Inverse()
		end

		for _, part in pairs(ServerGun:GetDescendants()) do
			if part:IsA('BasePart') then
				part.Anchored = false
				part.CanCollide = false
			end
		end

	elseif Mode == 2 then -- UNEQUIP	
		-- Clean up Weapon
		if WeaponTool and Player.Character:FindFirstChild('S' .. WeaponTool.Name) ~= nil then
			Player.Character['S' .. WeaponTool.Name]:Destroy()
		end
		
		-- Cleanup ANimation Base
		if Player.Character:FindFirstChild("AnimBase") then
			Player.Character.AnimBase:Destroy()
		end

		if Player.Character:FindFirstChild("RightUpperArm") and Player.Character.RightUpperArm:FindFirstChild("RightShoulder") then
			Player.Character.RightUpperArm:WaitForChild("RightShoulder").Enabled = true
		end

		if Player.Character:FindFirstChild("LeftUpperArm") and Player.Character.LeftUpperArm:FindFirstChild("LeftShoulder") then
			Player.Character.LeftUpperArm:WaitForChild("LeftShoulder").Enabled = true
		end
		
		local holster = Player.Character:FindFirstChild("Holster_" .. WeaponTool.Name)
		if holster then
			Holster.SetVisible(holster, true)
		end
	end
end)

Event.Squad.OnServerEvent:Connect(function(Player,SquadName,SquadColor)
	if not Player or not Player.Character then
		return
	end
	
	if not Player.Character:FindFirstChild("ACS_Client") then
		return
	end
	
	Player.Character.ACS_Client.FireTeam.SquadName.Value = SquadName
	Player.Character.ACS_Client.FireTeam.SquadColor.Value = SquadColor
end)

Event.Atirar.OnServerEvent:Connect(function(Player, Arma, Suppressor, FlashHider)
	Event.Atirar:FireAllClients(Player, Arma, Suppressor, FlashHider)
end)

Event.Whizz.OnServerEvent:Connect(function(Player, Victim)
	Event.Whizz:FireClient(Victim)
end)

Event.Suppression.OnServerEvent:Connect(function(Player,Victim,Mode,Intensity,Time)
	Event.Suppression:FireClient(Victim,Mode,Intensity,Time)
end)

Event.Refil.OnServerEvent:Connect(function(Player, Stored, NewStored)
	Stored.Value = Stored.Value - NewStored
end)

Event.SVLaser.OnServerEvent:Connect(function(Player,Position,Modo,Cor,IRmode,Arma)
	Event.SVLaser:FireAllClients(Player,Position,Modo,Cor,IRmode,Arma)
end)

Event.SVFlash.OnServerEvent:Connect(function(Player,Arma,Mode)
	Event.SVFlash:FireAllClients(Player,Arma,Mode)
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

function ToggleDoor(Door)
	local Hinge = Door.Door:FindFirstChild("Hinge")
	if not Hinge then return end
	local HingeConstraint = Hinge.HingeConstraint

	if HingeConstraint.TargetAngle == 0 then
		HingeConstraint.TargetAngle = -90
	elseif HingeConstraint.TargetAngle == -90 then
		HingeConstraint.TargetAngle = 0
	end	
end

Event.DoorEvent.OnServerEvent:Connect(function(Player,Door,Mode,Key)
	if Door ~= nil then
		if Mode == 1 then
			if Door:FindFirstChild("Locked") ~= nil and Door.Locked.Value == true then
				if Door:FindFirstChild("RequiresKey") then
					local Character = Player.Character
					if Character:FindFirstChild(Key) ~= nil or Player.Backpack:FindFirstChild(Key) ~= nil then
						if Door.Locked.Value == true then
							Door.Locked.Value = false
						end
						ToggleDoor(Door)
					end	
				end
			else
				ToggleDoor(Door)
			end
		elseif Mode == 2 then
			if Door:FindFirstChild("Locked") == nil or (Door:FindFirstChild("Locked") ~= nil and Door.Locked.Value == false) then
				ToggleDoor(Door)
			end
		elseif Mode == 3 then
			if Door:FindFirstChild("RequiresKey") then
				local Character = Player.Character
				Key = Door.RequiresKey.Value
				if Character:FindFirstChild(Key) ~= nil or Player.Backpack:FindFirstChild(Key) ~= nil then
					if Door:FindFirstChild("Locked") ~= nil and Door.Locked.Value == true then
						Door.Locked.Value = false
					else
						Door.Locked.Value = true
					end
				end
			end
		elseif Mode == 4 then
			if Door:FindFirstChild("Locked") ~= nil and Door.Locked.Value == true then
				Door.Locked.Value = false
			end
		end
	end
end)

Event.MedSys.Collapse.OnServerEvent:Connect(function(Player)

	local Human = Player.Character.Humanoid
	local PClient = Human.Parent.ACS_Client
	local Dor = Human.Parent.ACS_Client.Variaveis.Dor
	local Sangue = Human.Parent.ACS_Client.Variaveis.Sangue

	if (Sangue.Value <= 3500) or (Dor.Value >= 200) or PClient:GetAttribute("Collapsed") then -- Man this Guy's Really wounded,
		Human.PlatformStand = true
		Human.AutoRotate = false	
		PClient:SetAttribute("Collapsed",true)
	elseif (Sangue.Value > 3500) and (Dor.Value < 200) and not PClient:GetAttribute("Collapsed")  then -- YAY A MEDIC ARRIVED! =D
		Human.PlatformStand = false
		Human.AutoRotate = true	
		PClient:SetAttribute("Collapsed",false)
	end
end)

Event.MedSys.MedHandler.OnServerEvent:Connect(function(Player, Victim, Mode)
	if Player and Player.Character and Player.Character.Humanoid.Health > 0 then

		local P1_Client = Player.Character:FindFirstChild("ACS_Client")

		if P1_Client == nil then
			warn(Player.Name.."'s Action Failed: Missing ACS_Client")
			return
		end

		if P1_Client:GetAttribute("Collapsed") then
			return
		end

		if Victim then --Multiplayer functions
			if Player.Character and Victim.Character and (Player.Character.HumanoidRootPart.Position - Victim.Character.HumanoidRootPart.Position).Magnitude <= 15 then

				local P2_Client = Victim.Character:FindFirstChild("ACS_Client")

				if P2_Client == nil then
					warn(Player.Name.."'s Action Failed: Missing "..Victim.Name.."'s ACS_Client")
					return
				end

				if Mode == 1 and P1_Client.Kit.Bandage.Value > 0 and P2_Client:GetAttribute("Bleeding") then
					P1_Client.Kit.Bandage.Value = P1_Client.Kit.Bandage.Value - 1
					P2_Client:SetAttribute("Bleeding",false)

				elseif Mode == 2 and P1_Client.Kit.Splint.Value > 0 and P2_Client:GetAttribute("Injured") then
					P1_Client.Kit.Splint.Value = P1_Client.Kit.Splint.Value - 1
					P2_Client:SetAttribute("Injured",false)

				elseif Mode == 3 and (P2_Client:GetAttribute("Bleeding") == true or P2_Client:GetAttribute("Tourniquet")) then --Tourniquet works a little different :T
					if P2_Client:GetAttribute("Tourniquet")then
						P1_Client.Kit.Tourniquet.Value = P1_Client.Kit.Tourniquet.Value + 1
						P2_Client:SetAttribute("Tourniquet",false)
					else
						if P1_Client.Kit.Tourniquet.Value > 0 then
							P1_Client.Kit.Tourniquet.Value = P1_Client.Kit.Tourniquet.Value - 1
							P2_Client:SetAttribute("Tourniquet",true)
						end
					end

				elseif Mode == 4 and P1_Client.Kit.PainKiller.Value > 0 and P2_Client.Variaveis.Dor.Value > 0 then
					P1_Client.Kit.PainKiller.Value = P1_Client.Kit.PainKiller.Value - 1
					P2_Client.Variaveis.Dor.Value = math.clamp(P2_Client.Variaveis.Dor.Value - math.random(35,65),0,300)
					Event.MedSys.MedHandler:FireClient(Victim,4)

				elseif Mode == 5 and P1_Client.Kit.EnergyShot.Value > 0 and Victim.Character.Humanoid.Health < Victim.Character.Humanoid.MaxHealth then
					P1_Client.Kit.EnergyShot.Value = P1_Client.Kit.EnergyShot.Value - 1
					local HealValue = math.random(15,25)
					if Victim.Character.Humanoid.Health + HealValue < Victim.Character.Humanoid.MaxHealth then
						Victim.Character.Humanoid:TakeDamage(-HealValue)
					else
						Victim.Character.Humanoid.Health = Victim.Character.Humanoid.MaxHealth
					end
					Event.MedSys.MedHandler:FireClient(Victim,5)

				elseif Mode == 6 and P1_Client.Kit.Morphine.Value > 0 and P2_Client.Variaveis.Dor.Value > 0 then
					P1_Client.Kit.Morphine.Value = P1_Client.Kit.Morphine.Value - 1
					P2_Client.Variaveis.Dor.Value = 0
					Event.MedSys.MedHandler:FireClient(Victim,6)

				elseif Mode == 7 and P1_Client.Kit.Epinephrine.Value > 0 and P2_Client:GetAttribute("Collapsed")then
					P1_Client.Kit.Epinephrine.Value = P1_Client.Kit.Epinephrine.Value - 1
					local HealValue = math.random(45,55)
					if Victim.Character.Humanoid.Health + HealValue < Victim.Character.Humanoid.MaxHealth then
						Victim.Character.Humanoid:TakeDamage(-HealValue)
					else
						Victim.Character.Humanoid.Health = Victim.Character.Humanoid.MaxHealth
					end
					P2_Client:SetAttribute("Collapsed",false)
					Event.MedSys.MedHandler:FireClient(Victim,7)

				elseif Mode == 8 and P1_Client.Kit.BloodBag.Value > 0 and P2_Client.Variaveis.Sangue.Value < P2_Client.Variaveis.Sangue.MaxValue then
					P1_Client.Kit.BloodBag.Value = P1_Client.Kit.BloodBag.Value - 1
					P2_Client.Variaveis.Sangue.Value = P2_Client.Variaveis.Sangue.Value + 2000
				end
			else
				warn(Player.Name.." is too far to treat "..Victim.Name)
			end
		else --Self treat
			if Mode == 1 and P1_Client.Kit.Bandage.Value > 0 and P1_Client:GetAttribute("Bleeding") then
				P1_Client.Kit.Bandage.Value = P1_Client.Kit.Bandage.Value - 1
				P1_Client:SetAttribute("Bleeding",false)

			elseif Mode == 2 and P1_Client.Kit.Splint.Value > 0 and P1_Client:GetAttribute("Injured") then
				P1_Client.Kit.Splint.Value = P1_Client.Kit.Splint.Value - 1
				P1_Client:SetAttribute("Injured",false)

			elseif Mode == 3 and (P1_Client:GetAttribute("Bleeding") or P1_Client:GetAttribute("Tourniquet")) then --Tourniquet works a little diferent :T
				if P1_Client:GetAttribute("Tourniquet") then
					P1_Client.Kit.Tourniquet.Value = P1_Client.Kit.Tourniquet.Value + 1
					P1_Client:SetAttribute("Tourniquet",false)
				else
					if P1_Client.Kit.Tourniquet.Value > 0 then
						P1_Client.Kit.Tourniquet.Value = P1_Client.Kit.Tourniquet.Value - 1
						P1_Client:SetAttribute("Tourniquet",true)
					end
				end

			elseif Mode == 4 and P1_Client.Kit.PainKiller.Value > 0 and P1_Client.Variaveis.Dor.Value > 0 then
				P1_Client.Kit.PainKiller.Value = P1_Client.Kit.PainKiller.Value - 1
				P1_Client.Variaveis.Dor.Value = math.clamp(P1_Client.Variaveis.Dor.Value - math.random(35,65),0,300)
				Event.MedSys.MedHandler:FireClient(Player,4)

			elseif Mode == 5 and P1_Client.Kit.EnergyShot.Value > 0 and Player.Character.Humanoid.Health < Player.Character.Humanoid.MaxHealth then
				P1_Client.Kit.EnergyShot.Value = P1_Client.Kit.EnergyShot.Value - 1
				local HealValue = math.random(15,25)
				if Player.Character.Humanoid.Health + HealValue < Player.Character.Humanoid.MaxHealth then
					Player.Character.Humanoid:TakeDamage(-HealValue)
				else
					Player.Character.Humanoid.Health = Player.Character.Humanoid.MaxHealth
				end
				Event.MedSys.MedHandler:FireClient(Player,5)

			elseif Mode == 6 and P1_Client.Kit.Morphine.Value > 0 and P1_Client.Variaveis.Dor.Value > 0 then
				P1_Client.Kit.Morphine.Value = P1_Client.Kit.Morphine.Value - 1
				P1_Client.Variaveis.Dor.Value = math.clamp(P1_Client.Variaveis.Dor.Value - math.random(125,175),0,300)
				Event.MedSys.MedHandler:FireClient(Player,6)

			elseif Mode == 7 and P1_Client.Kit.Epinephrine.Value > 0 and Player.Character.Humanoid.Health < Player.Character.Humanoid.MaxHealth then
				P1_Client.Kit.Epinephrine.Value = P1_Client.Kit.Epinephrine.Value - 1
				local HealValue = math.random(45,55)
				if Player.Character.Humanoid.Health + HealValue < Player.Character.Humanoid.MaxHealth then
					Player.Character.Humanoid:TakeDamage(-HealValue)
				else
					Player.Character.Humanoid.Health = Player.Character.Humanoid.MaxHealth
				end
				Event.MedSys.MedHandler:FireClient(Player,7)

			elseif Mode == 8 and P1_Client.Kit.BloodBag.Value > 0 and P1_Client.Variaveis.Sangue.Value < P1_Client.Variaveis.Sangue.MaxValue then
				P1_Client.Kit.BloodBag.Value = P1_Client.Kit.BloodBag.Value - 1
				P1_Client.Variaveis.Sangue.Value = P1_Client.Variaveis.Sangue.Value + 2000

			end
		end
	end
end)

Event.Drag.OnServerEvent:Connect(function(player,Victim)

	local P1_Client = player.Character:FindFirstChild("ACS_Client")
	local Human 	= player.Character.Humanoid

	if not P1_Client then
		return
	end

	if Victim then
		P1_Client:SetAttribute("DragPlayer",Victim.Name)
	else
		P1_Client:SetAttribute("DragPlayer","")
		P1_Client:SetAttribute("Dragging",false)
	end

	local target = P1_Client:GetAttribute("DragPlayer")

	if not P1_Client:GetAttribute("Collapsed") and target ~= "" then

		local player2 = game.Players:FindFirstChild(target)
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

function BreachFunction(Player,Mode,BreachPlace,Pos,Norm,Hit)

	if Mode == 1 then
		if Player.Character.ACS_Client.Kit.BreachCharges.Value > 0 then
			Player.Character.ACS_Client.Kit.BreachCharges.Value = Player.Character.ACS_Client.Kit.BreachCharges.Value - 1
			BreachPlace.Destroyed.Value = true
			local C4 = Engine.FX.BreachCharge:Clone()

			C4.Parent = BreachPlace.Destroyable
			C4.Center.CFrame = CFrame.new(Pos, Pos + Norm) * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))
			C4.Center.Place:Play()

			local weld = Instance.new("WeldConstraint")
			weld.Parent = C4
			weld.Part0 = BreachPlace.Destroyable.Charge
			weld.Part1 = C4.Center

			wait(1)
			C4.Center.Beep:Play()
			wait(4)
			if C4 and C4:FindFirstChild("Center") then
				local att = Instance.new("Attachment")
				att.CFrame = C4.Center.CFrame
				att.Parent = workspace.Terrain

				local aw = Engine.FX.ExpEffect:Clone()
				aw.Parent = att
				aw.Enabled = false
				aw:Emit(35)
				Debris:AddItem(aw,aw.Lifetime.Max)

				local Exp = Instance.new("Explosion")
				Exp.BlastPressure = 0
				Exp.BlastRadius = 0
				Exp.DestroyJointRadiusPercent = 0
				Exp.Position = C4.Center.Position
				Exp.Parent = workspace

				local S = Instance.new("Sound")
				S.RollOffMinDistance = 10
				S.RollOffMaxDistance = 1000
				S.SoundId = "rbxassetid://"..Explosion[math.random(1, 7)]
				S.PlaybackSpeed = math.random(30,55)/40
				S.Volume = 2
				S.Parent = att
				S.PlayOnRemove = true
				S:Destroy()

				for SKP_001, SKP_002 in pairs(game.Players:GetChildren()) do
					if SKP_002:IsA('Player') and SKP_002.Character and SKP_002.Character:FindFirstChild('Head') and (SKP_002.Character.Head.Position - C4.Center.Position).magnitude <= 15 then
						local DistanceMultiplier = (((SKP_002.Character.Head.Position - C4.Center.Position).magnitude/35) - 1) * -1
						local intensidade = DistanceMultiplier
						local Tempo = 15 * DistanceMultiplier
						Event.Suppression:FireClient(SKP_002,2,intensidade,Tempo)
					end
				end

				Debris:AddItem(BreachPlace.Destroyable,0)
			end
		end

	elseif Mode == 2 then

		local aw = Engine.FX.DoorBreachFX:Clone()
		aw.Parent = BreachPlace.Door.Door
		aw.RollOffMaxDistance = 100
		aw.RollOffMinDistance = 5
		aw:Play()

		BreachPlace.Destroyed.Value = true
		if BreachPlace.Door:FindFirstChild("Hinge") ~= nil then
			BreachPlace.Door.Hinge:Destroy()
		end
		if BreachPlace.Door:FindFirstChild("Knob") ~= nil then
			BreachPlace.Door.Knob:Destroy()
		end

		local forca = Instance.new("BodyForce")
		forca.Force = -Norm * BreachPlace.Door.Door:GetMass() * Vector3.new(50,0,50)
		forca.Parent = BreachPlace.Door.Door

		Debris:AddItem(BreachPlace,3)

	elseif Mode == 3 then
		if Player.Character.ACS_Client.Kit.Fortifications.Value > 0 then
			Player.Character.ACS_Client.Kit.Fortifications.Value = Player.Character.ACS_Client.Kit.Fortifications.Value - 1
			BreachPlace.Fortified.Value = true
			local C4 = Instance.new('Part')

			C4.Parent = BreachPlace.Destroyable
			C4.Size =  Vector3.new(Hit.Size.X + .05,Hit.Size.Y + .05,Hit.Size.Z + 0.5) 
			C4.Material = Enum.Material.DiamondPlate
			C4.Anchored = true
			C4.CFrame = Hit.CFrame

			local S = Engine.FX.FortFX:Clone()
			S.PlaybackSpeed = math.random(30,55)/40
			S.Volume = 1
			S.Parent = C4
			S.PlayOnRemove = true
			S:Destroy()
		end
	end
end

Event.Breach.OnServerInvoke = BreachFunction

function UpdateLog(Player,humanoid)

	local tag = humanoid:findFirstChild("creator")

	if tag ~= nil then

		local hours = os.date("*t")["hour"]
		local mins = os.date("*t")["min"]
		local sec = os.date("*t")["sec"]
		local TagType = tag:findFirstChild("type")

		if tag.Value.Name == Player.Name then
			local String = Player.Name.." Died | "..hours..":"..mins..":"..sec
			table.insert(CombatLog,String)
		else
			local String = tag.Value.Name.." Killed "..Player.Name.." | "..hours..":"..mins..":"..sec
			table.insert(CombatLog,String)
		end

		if #CombatLog > 50 then
			Backup = Backup + 1
			warn("ACS: Cleaning Combat Log | Backup: "..Backup)
			warn(CombatLog)
			CombatLog = {}
		end
	end
end


plr.PlayerAdded:Connect(function(player)

	for i,v in ipairs(_G.TempBannedPlayers) do
		if v == player.Name then
			player:Kick('Blacklisted')
			warn(player.Name.." (Temporary Banned) tried to join to server")
			break
		end
	end

	for i,v in ipairs(gameRules.Blacklist) do
		if v == player.UserId then
			player:Kick('Blacklisted')
			warn(player.Name.." (Blacklisted) tried to join to server")
			break
		end
	end

	if gameRules.AgeRestrictEnabled and not Run:IsStudio() then
		if player.AccountAge < gameRules.AgeLimit then
			player:Kick('Age restricted server! Please wait: '..(gameRules.AgeLimit - player.AccountAge)..' Days')
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


	player.CharacterAdded:Connect(function(char)

		if gameRules.TeamTags then
			local L_17_ = HUDs:WaitForChild('TeamTagUI'):Clone()
			L_17_.Parent = char
			L_17_.Adornee = char.Head
		end
		
		for _, child in ipairs(char:GetChildren()) do
			if child:IsA("Accessory") then
				child:Destroy()
			end
		end

		local humanoid = char:WaitForChild("Humanoid", 5)
		if humanoid then
			for _, accessory in ipairs(humanoid:GetAccessories()) do
				accessory:Destroy()
			end
		end

		char.Humanoid.BreakJointsOnDeath = false
		char.Humanoid.Died:Connect(function()
			UpdateLog(player,char.Humanoid)
			pcall(function()
				Ragdoll(char)
			end)
		end)
		
		local backpack = player:WaitForChild("Backpack")
		
		for _, tool in pairs(backpack:GetChildren()) do
			if tool:IsA("Tool") and tool:FindFirstChild("ACS_Settings") then
				local settings = require(tool.ACS_Settings)
				if settings.Holster then
					task.defer(function()
						Holster.Check(player, tool.Name, settings, tool)
					end)
				end
			end
		end

		backpack.ChildRemoved:Connect(function(removed_tool)
			if not removed_tool:IsA("Tool") then return end
			if not removed_tool:FindFirstChild("ACS_Settings") then return end
			
			local holster_name = "Holster_" .. removed_tool.Name
			local holster = char:FindFirstChild(holster_name)
			if not holster then return end
			
			task.defer(function()
				if not char or not char.Parent then return end
				local tool_still_in_backpack = player.Backpack:FindFirstChild(removed_tool.Name)
				local tool_equipped = char:FindFirstChild(removed_tool.Name)

				if not tool_still_in_backpack and not tool_equipped then
					holster:Destroy()
				elseif tool_still_in_backpack then
					Holster.SetVisible(holster, true)
				end
			end)
		end)
		
		backpack.ChildAdded:Connect(function(added_tool)
			if not added_tool:IsA("Tool") then return end
			if not added_tool:FindFirstChild("ACS_Settings") then return end
			
			local settings = require(added_tool.ACS_Settings)
			if not settings.Holster then return end
			
			task.defer(function()
				if not char or not char.Parent then return end

				local holster_name = "Holster_" .. added_tool.Name
				local existing_holster = char:FindFirstChild(holster_name)

				if existing_holster then
					Holster.SetVisible(existing_holster, true)
				else
					Holster.Check(player, added_tool.Name, settings, added_tool)
				end
			end)
		end)
		
		char.ChildRemoved:Connect(function(child)
			if child:IsA("Tool") and child:FindFirstChild("ACS_Settings") then
				local settings = require(child.ACS_Settings)
				if settings.Holster then
					local holster = char:FindFirstChild("Holster_" .. child.Name)
					if holster then
						Holster.SetVisible(holster, true)
					end
				end
			end
		end)
	end)
end)

Event.Shell.OnServerEvent:Connect(function(player, shell, origin)
	Event.Shell:FireAllClients(shell, origin)
end)

print(gameRules.Version)