--[[
    RayIgnore.lua
    Created by @ddydddd9 - Moonlight

    Utility module for managing raycast ignore lists
]]

local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local CurrentCamera = workspace.CurrentCamera
local ACS_Workspace = workspace.ACS_WorkSpace

local RayIgnore = {}
RayIgnore.SessionIgnoreExtras = {}

Player.CharacterAdded:Connect(function(new_character)
    Character = new_character
    CurrentCamera = workspace.CurrentCamera
    ACS_Workspace = workspace.ACS_WorkSpace
    RayIgnore.SessionIgnoreExtras = {}
end)

-- Ignore list for raycasts

function RayIgnore:BuildIgnoreList()
    local ignore_list = {
        CurrentCamera,
        Character,
        ACS_Workspace.Client,
        ACS_Workspace.Server
    }

	for _, item in ipairs(self.SessionIgnoreExtras) do
		ignore_list[#ignore_list + 1] = item
	end

	return ignore_list
end

function RayIgnore:AddToIgnore(part)
    for _, item in ipairs(self.SessionIgnoreExtras) do
        if item == part then return end
    end

    self.SessionIgnoreExtras[#self.SessionIgnoreExtras + 1] = part
end

function RayIgnore:Reset()
    self.SessionIgnoreExtras = {}
end

return RayIgnore