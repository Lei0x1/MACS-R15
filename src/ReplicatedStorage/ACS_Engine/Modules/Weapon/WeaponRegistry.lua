--[[
    WeaponRegistry.lua
    Created by @ddydddd9 - Moonlight

	Centralized weapon registry for storing and accessing equipped weapon data with change events and convenience methods
	Access to 4 types of Weapon Data's (WeaponInHand, WeaponTool, WeaponData, AnimData)
]]

local WeaponRegistry = {}

-- Private Registry - ONLY the four objects you requested
local Registry = {
	WeaponInHand = nil,
	WeaponTool = nil,
	WeaponData = nil,
	AnimData = nil,
	isEquipped = false
}

-- Event for data changes (optional, but useful)
local DataChangedEvent = Instance.new("BindableEvent")
WeaponRegistry.Changed = DataChangedEvent.Event

-- Store all four objects when weapon is equipped
function WeaponRegistry:StoreEquippedWeapon(weapon_in_hand, weapon_tool, weapon_data, anim_data)
	if not weapon_in_hand or not weapon_tool or not weapon_data or not anim_data then
		warn("WeaponRegistry: Missing required data")
		return false
	end
	
	Registry.WeaponInHand = weapon_in_hand
	Registry.WeaponTool = weapon_tool
	Registry.WeaponData = weapon_data
	Registry.AnimData = anim_data
	Registry.isEquipped = true
	
	-- Fire event
	DataChangedEvent:Fire("Equipped", {
		weapon_in_hand = weapon_in_hand,
		weapon_tool = weapon_tool,
		weapon_data = weapon_data,
		anim_data = anim_data
	})

	return true
end

-- Clear all data when weapon is unequipped
function WeaponRegistry:ClearWeaponData()
	Registry.WeaponInHand = nil
	Registry.WeaponTool = nil
	Registry.WeaponData = nil
	Registry.AnimData = nil
	Registry.isEquipped = false
	
	DataChangedEvent:Fire("Unequipped", nil)
end

-- Get all four objects at once
function WeaponRegistry:GetAll()
	if not Registry.isEquipped then
		return nil
	end
	
	return {
		WeaponInHand = Registry.WeaponInHand,
		WeaponTool = Registry.WeaponTool,
		WeaponData = Registry.WeaponData,
		AnimData = Registry.AnimData,
		isEquipped = Registry.isEquipped
	}
end

-- Individual getters
function WeaponRegistry:GetWeaponInHand()
	return Registry.WeaponInHand
end

function WeaponRegistry:GetWeaponTool()
	return Registry.WeaponTool
end

function WeaponRegistry:GetWeaponData()
	return Registry.WeaponData
end

function WeaponRegistry:GetAnimData()
	return Registry.AnimData
end

-- Check if weapon is equipped
function WeaponRegistry:IsEquipped()
	return Registry.isEquipped
end

-- Get weapon name (convenience)
function WeaponRegistry:GetWeaponName()
	return Registry.WeaponData and Registry.WeaponData.gunName or "No Weapon"
end

-- Get weapon type (convenience)
function WeaponRegistry:GetWeaponType()
	return Registry.WeaponData and Registry.WeaponData.Type or nil
end

-- Wait for weapon to be equipped (useful for scripts that need to run after equip)
function WeaponRegistry:WaitForWeapon()
	if Registry.isEquipped then
        
		return self:GetAll()
	end
	
	local event = Instance.new("BindableEvent")
	local connection = DataChangedEvent.Event:Connect(function(eventType, data)
		if eventType == "Equipped" then
			event:Fire(data)
		end
	end)
	
	local result = event.Event:Wait()
	connection:Disconnect()
	event:Destroy()
	
	return result
end

-- Simple debug
function WeaponRegistry:DebugPrint()
	print("=== WeaponRegistry ===")
	if not Registry.isEquipped then
		print("Status: No weapon equipped")
	else
		print("Status: EQUIPPED")
		print("Weapon:", Registry.WeaponData and Registry.WeaponData.gunName or "Unknown")
		print("Type:", Registry.WeaponData and Registry.WeaponData.Type or "Unknown")
		print("WeaponInHand:", Registry.WeaponInHand and "Valid" or "nil")
		print("WeaponTool:", Registry.WeaponTool and "Valid" or "nil")
		print("WeaponData:", Registry.WeaponData and "Loaded" or "nil")
		print("AnimData:", Registry.AnimData and "Loaded" or "nil")
	end
	print("========================")
end

return WeaponRegistry