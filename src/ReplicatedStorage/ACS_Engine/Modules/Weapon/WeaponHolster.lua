--[[
	WeaponHolster.lua
	Created by @ddydddd9 - Moonlight

	Weapon holster system for managing visible holstered weapons on character models with visibility toggling
]]

local RS = game:GetService("ReplicatedStorage")

local Engine = RS:WaitForChild("ACS_Engine")
local WeaponModels = Engine:WaitForChild("WeaponModels")

local WeaponHolster = {}

function WeaponHolster.SetVisible(holster_model, visible)
	if not holster_model then return end
	
	if not visible then
		for _, part in pairs(holster_model:GetDescendants()) do
			if part:IsA("BasePart") then
				-- Save the current transparency if not already saved
				if part:GetAttribute("OriginalTransparency") == nil then
					part:SetAttribute("OriginalTransparency", part.Transparency)
				end
				part.Transparency = 1
			end
		end
	else
		-- Restore original transparency
		for _, part in pairs(holster_model:GetDescendants()) do
			if part:IsA("BasePart") and part:GetAttribute("OriginalTransparency") ~= nil then
				part.Transparency = part:GetAttribute("OriginalTransparency")
			end
		end
	end
end

local function Equip(player, weapon_name, weapon_data, weapon_tool)
	local char = player.Character
	if not char then return end

	local holster_point = char:FindFirstChild(weapon_data.HolsterPoint)
	if not holster_point then return end

	local weapon_type_folder = WeaponModels:FindFirstChild(weapon_data.Type)
	if not weapon_type_folder then return end

	local model_check = weapon_type_folder:FindFirstChild(weapon_tool.Name)
	if not model_check then return end

	local holster_model = model_check:Clone()
	holster_model.Name = "Holster_" .. weapon_name

	if holster_model:FindFirstChild("Nodes") then
		holster_model.Nodes:Destroy()
	end

	for _, part in pairs(holster_model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
		end
	end

	for _, part in pairs(holster_model:GetChildren()) do
		if part:IsA("BasePart") then
			if part.Name == "SightMark" or part.Name == "Warhead" or part.Name == "Main" then
				part:Destroy()
			end
		end
	end

	local handle = holster_model:FindFirstChild("Handle")
	if not handle then
		warn("WeaponHolster model has no Handle part: " .. weapon_name)
		holster_model:Destroy()
		return
	end

	holster_model.Parent = char

	-- Weld all non-Handle BaseParts to Handle
	for _, part in pairs(holster_model:GetChildren()) do
		if part:IsA("BasePart") and part ~= handle then
			local wc = Instance.new("WeldConstraint")
			wc.Part0 = handle
			wc.Part1 = part
			wc.Parent = handle
			part.Anchored = false
		end
	end

	-- Use a Weld not WeldConstraint that way we can apply C0 offset
	local holster_weld = Instance.new("Weld")
	holster_weld.Name = "HolsterWeld"
	holster_weld.Part0 = holster_point
	holster_weld.Part1 = handle
	holster_weld.C0 = weapon_data.HolsterCFrame
	holster_weld.C1 = CFrame.new()
	holster_weld.Parent = holster_model
	handle.Anchored = false

	local tool_equipped = char:FindFirstChild(weapon_tool.Name)
	WeaponHolster.SetVisible(holster_model, not tool_equipped)
end

function WeaponHolster.Check(player, weapon_name, weapon_data, weapon_tool)
	if not player.Character then return end
	if not player.Character:FindFirstChild("Holster_" .. weapon_name) then
		Equip(player, weapon_name, weapon_data, weapon_tool)
	end
end


return WeaponHolster
