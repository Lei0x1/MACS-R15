--[[
	Security.luau
	
	Made by @ddydddd9 - Moonlight
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Engine = ReplicatedStorage:WaitForChild("ACS_Engine")
local Events = Engine:WaitForChild("Events")
local GameRules = Engine:WaitForChild("GameRules")
local Config = require(GameRules:WaitForChild("Config"))

-- Security module
local Security = {}

-- Store temp banned players
Security.TempBannedPlayers = {}

-- Glenn's Anti-Exploit System (GAE for short). This code is very ugly, but does job done
-- Edited by @ddydddd9 - Moonlight: Same behavior just added iteration & safety checks.
function Security.CompareTables(arr1, arr2)
	if typeof(arr1) ~= "table" or typeof(arr2) ~= "table" then
		return false
	end

	local simple_field = {"gunName", "Type", "ShootRate", "Bullets"}

	for _, field in ipairs(simple_field) do
		if arr1[field] ~= arr2[field] then
			return false
		end
	end

	local damage_fields = {"LimbDamage", "TorsoDamage", "HeadDamage"}

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

-- Handle security violations (enhanced version)
function Security.HandleSecurityViolation(player, reason, protocol)
	warn(string.format("[SECURITY] %s - %s: %s", protocol, player.Name, reason))

	-- Add to temp banned list like original
	table.insert(Security.TempBannedPlayers, player)

	-- Kick the player for severe violations
	if protocol == "Exploit Protocol" then
		player:Kick(string.format("Security Violation: %s", reason))
	end
end

-- Original secureSettings function (renamed)
function Security.SecureSettings(player, gun, module)
	-- Check if gun exists
	if not gun or not gun:IsA("Tool") then
		Security.HandleSecurityViolation(player, "0-2: Invalid Gun Object", "Exploit Protocol")
		return false
	end

	-- Find the ACS_Settings module script
	local PreNewModule = gun:FindFirstChild("ACS_Settings")

	-- Validate it's actually a ModuleScript
	if not PreNewModule or not PreNewModule:IsA("ModuleScript") then
		Security.HandleSecurityViolation(player, "0-2: Missing or Invalid ACS_Settings Module", "Exploit Protocol")
		return false
	end

	-- Safely require the module with error handling
	local success, NewModule = pcall(require, PreNewModule)
	if not success then
		-- Module failed to load - could be corrupted or invalid
		Security.HandleSecurityViolation(player, "0-2: Corrupted ACS_Settings Module", "Exploit Protocol")
		return false
	end

	-- Validate the module returns a table
	if typeof(NewModule) ~= "table" then
		Security.HandleSecurityViolation(player, "0-2: ACS_Settings Must Return Table", "Exploit Protocol")
		return false
	end

	-- Compare tables using original GAE function
	if not Security.CompareTables(module, NewModule) then
		Security.HandleSecurityViolation(player, "0-4: Exploiting Weapon Stats", "Exploit Protocol")
		return false
	end

	-- If all checks pass, return true
	return true
end

-- Original damage calculation function
function Security.CalculateDamage(attacker, humanoid, distance, zone, weaponData, weaponMods)
	local skp_0 = game.Players:GetPlayerFromCharacter(humanoid.Parent) or nil
	local skp_1 = 0
	local skp_2 = weaponData.MinDamage * weaponMods.minDamageMod

	-- Calculate base damage based on hit zone
	if zone == 1 then -- Head
		local skp_3 = math.random(weaponData.HeadDamage[1], weaponData.HeadDamage[2])
		skp_1 = math.max(skp_2, (skp_3 * weaponMods.DamageMod) - (distance/25) * weaponData.DamageFallOf)
	elseif zone == 2 then -- Torso
		local skp_3 = math.random(weaponData.TorsoDamage[1], weaponData.TorsoDamage[2])
		skp_1 = math.max(skp_2, (skp_3 * weaponMods.DamageMod) - (distance/25) * weaponData.DamageFallOf)
	else -- Limbs
		local skp_3 = math.random(weaponData.LimbDamage[1], weaponData.LimbDamage[2])
		skp_1 = math.max(skp_2, (skp_3 * weaponMods.DamageMod) - (distance/25) * weaponData.DamageFallOf)
	end

	-- Apply armor protection
	if humanoid.Parent:FindFirstChild("ACS_Client") and not weaponData.IgnoreProtection then
		local protection = humanoid.Parent.ACS_Client.Protecao
		local vestProtect = protection.VestProtect.Value
		local helmetProtect = protection.HelmetProtect.Value

		if zone == 1 then -- Head hit
			if weaponData.BulletPenetration < helmetProtect then
				skp_1 = math.max(.5, skp_1 * (weaponData.BulletPenetration / helmetProtect))
			end
		else -- Body hit
			if weaponData.BulletPenetration < vestProtect then
				skp_1 = math.max(.5, skp_1 * (weaponData.BulletPenetration / vestProtect))
			end
		end
	end

	-- Apply damage with team checking
	local victimPlayer = game.Players:GetPlayerFromCharacter(humanoid.Parent)

	if victimPlayer then
		if victimPlayer.Team ~= attacker.Team or victimPlayer.Neutral then
			-- Regular damage for enemies
			local creator = Instance.new("ObjectValue")
			creator.Name = "creator"
			creator.Value = attacker
			creator.Parent = humanoid
			game.Debris:AddItem(creator, 1)

			humanoid:TakeDamage(skp_1)
			return
		end

		-- Team damage (if enabled)
		if not Config.TeamKill then return end

		local creator = Instance.new("ObjectValue")
		creator.Name = "creator"
		creator.Value = attacker
		creator.Parent = humanoid
		game.Debris:AddItem(creator, 1)
		humanoid:TakeDamage(skp_1 * Config.TeamDmgMult)
		return
	end

	-- Damage to NPCs
	local creator = Instance.new("ObjectValue")
	creator.Name = "creator"
	creator.Value = attacker
	creator.Parent = humanoid
	game.Debris:AddItem(creator, 1)

	humanoid:TakeDamage(skp_1)
end

-- Main damage handler (original Damage function)
function Security.ProcessDamage(attacker, weaponTool, humanoid, distance, zone, weaponData, weaponMods, isFallDamage, fallDamage, sessionKey)
	-- Validate attacker
	if not attacker or not attacker.Character then return end
	if not attacker.Character:FindFirstChild("Humanoid") or attacker.Character.Humanoid.Health <= 0 then return end

	-- Session key validation
	local expectedKey = Events.AccessId:InvokeServer(attacker.UserId) .. "-" .. attacker.UserId
	if sessionKey ~= expectedKey then
		Security.HandleSecurityViolation(attacker, "0-B: Wrong Permission Code", "Exploit Protocol")
		return
	end

	-- Handle fall damage
	if isFallDamage then
		attacker.Character.Humanoid:TakeDamage(math.max(fallDamage, 0))
		return
	end

	-- Handle weapon damage
	if weaponTool then
		-- Validate weapon settings
		local isSecure = Security.SecureSettings(attacker, weaponTool, weaponData)
		if not isSecure or not humanoid then return end

		-- Calculate and apply damage
		Security.CalculateDamage(attacker, humanoid, distance, zone, weaponData, weaponMods)
		return
	end

	-- No weapon tool but trying to deal damage = exploit
	Security.HandleSecurityViolation(attacker, "Case 1: Tried To Access Damage Event", "Exploit Protocol")
end

-- Original utility functions from GAE
function Security.SafeRequire(moduleScript)
	if not moduleScript or not moduleScript:IsA("ModuleScript") then
		return nil
	end

	local success, result = pcall(require, moduleScript)
	if not success then
		warn("Failed to require module: ", result)
		return nil
	end

	return result
end

-- Simple module validation
function Security.ValidateModule(moduleScript)
	if not moduleScript or not moduleScript:IsA("ModuleScript") then
		warn("Invalid module script")
		return false
	end

	local success, result = pcall(require, moduleScript)
	if not success then
		warn("Failed to require module: ", result)
		return false
	end

	-- Check if the result is valid (table or function)
	if typeof(result) ~= "table" and typeof(result) ~= "function" then
		warn("Module must return a table or function")
		return false
	end

	return true, result
end

-- Enhanced module loading with type checking
function Security.LoadModule(moduleScript, expectedType)
	local module = Security.SafeRequire(moduleScript)
	if not module then
		return nil
	end

	if expectedType and typeof(module) ~= expectedType then
		warn(string.format("Module returned %s, expected %s", typeof(module), expectedType))
		return nil
	end

	return module
end

-- Attachment module loading
function Security.LoadAttachmentModule(moduleName, modulesFolder)
	local modulescript = modulesFolder:FindFirstChild(moduleName)
	if not modulescript then
		warn("Attachment module not found: ", moduleName)
		return nil
	end

	return Security.SafeRequire(modulescript)
end

-- Validate weapon data
function Security.ValidateWeaponData(weaponData)
	if not weaponData or typeof(weaponData) ~= "table" then
		return false, "Invalid weapon data type"
	end

	-- Check required fields
	local requiredFields = {
		"Type", "gunName", "Ammo", "ShootRate", "ShootType", "MuzzleVelocity",
		"LimbDamage", "TorsoDamage", "HeadDamage" -- Added from original
	}

	for _, field in ipairs(requiredFields) do
		if weaponData[field] == nil then
			return false, string.format("Missing required field: %s", field)
		end
	end

	if typeof(weaponData.Type) ~= "string" then
		return false, string.format("Weapon Type must be a string, got: %s", typeof(weaponData.Type))
	end

	-- Validate weapon type
	local validTypes = {"Gun", "Melee", "Grenade"}
	local isValidType = false
	for _, validType in ipairs(validTypes) do
		if weaponData.Type == validType then
			isValidType = true
			break
		end
	end

	if not isValidType then
		return false, string.format("Invalid weapon type: %s", tostring(weaponData.Type))
	end

	return true, "Valid"
end

-- Validate animation data
function Security.ValidateAnimationData(animData)
	if not animData or typeof(animData) ~= "table" then
		return false, "Invalid animation data type"
	end

	-- Check for required animation functions
	local requiredAnimations = {
		"EquipAnim", "IdleAnim", "SprintAnim"
	}

	for _, anim in ipairs(requiredAnimations) do
		if not animData[anim] or typeof(animData[anim]) ~= "function" then
			return false, string.format("Missing or invalid animation function: %s", anim)
		end
	end

	return true, "Valid"
end

-- Session key validation
function Security.ValidateSessionKey(sessionKey, userId)
	if not sessionKey or type(sessionKey) ~= "string" then
		return false
	end

	-- Basic format check: should contain userId
	if not string.find(sessionKey, tostring(userId)) then
		return false
	end

	-- Check for proper formatting
	local parts = string.split(sessionKey, "-")
	if #parts ~= 2 then
		return false
	end

	return true
end

-- Input validation for damage events
function Security.ValidateDamageInput(weaponTool, humanoid, distance, zone, weaponData, sessionKey)
	-- Basic null checks
	if not weaponTool or not humanoid or not weaponData or not sessionKey then
		return false, "Missing required parameters"
	end

	-- Check if humanoid is valid
	if not humanoid:IsA("Humanoid") then
		return false, "Invalid humanoid"
	end

	-- Validate session key
	if not Security.ValidateSessionKey(sessionKey, game.Players.LocalPlayer.UserId) then
		return false, "Invalid session key"
	end

	-- Validate weapon data
	local isValid, message = Security.ValidateWeaponData(weaponData)
	if not isValid then
		return false, "Invalid weapon data: " .. message
	end

	return true, "Valid"
end

-- Rate limiting check (basic)
local lastEventTimes = {}
function Security.CheckRateLimit(eventName, cooldown)
	local currentTime = tick()
	local lastTime = lastEventTimes[eventName] or 0

	if currentTime - lastTime < cooldown then
		return false
	end

	lastEventTimes[eventName] = currentTime
	return true
end

-- Clean up function
function Security.Cleanup()
	lastEventTimes = {}
	Security.TempBannedPlayers = {}
end

return Security