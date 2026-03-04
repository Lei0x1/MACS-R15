--[[
    InputBindingController.lua
    Created by @ddydddd9 - Moonlight

	Input binding manager for movement and weapon controls with dynamic action registration/unregistration
]]
    
local RS = game:GetService("ReplicatedStorage")

local Engine = RS:WaitForChild("ACS_Engine")
local Modules = Engine:WaitForChild("Modules")
local ClientModules = Modules:WaitForChild("Client")

local InputSystem = require(ClientModules:WaitForChild("InputSystem"))

local InputBindingController = {}

function InputBindingController.BindMovementActions()
	InputSystem.Bind("Run", { Enum.KeyCode.LeftShift })
	InputSystem.Bind("Stand", { Enum.KeyCode.X })
	InputSystem.Bind("Crouch", { Enum.KeyCode.C })
	InputSystem.Bind("ToggleWalk", { Enum.KeyCode.Z })
	InputSystem.Bind("LeanLeft", {Enum.KeyCode.Q })
	InputSystem.Bind("LeanRight", {Enum.KeyCode.E })
	InputSystem.Bind("NVG", { Enum.KeyCode.N })
end

function InputBindingController.UnBindMovementActions()
	InputSystem.Unbind("Run")
	InputSystem.Unbind("Stand")
	InputSystem.Unbind("Crouch")
	InputSystem.Unbind("ToggleWalk")
	InputSystem.Unbind("LeanLeft")
	InputSystem.Unbind("LeanRight")
end

function InputBindingController.BindWeaponActions()
	InputSystem.Bind("Fire", { Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2 })
	InputSystem.Bind("Aim", { Enum.UserInputType.MouseButton2, Enum.KeyCode.ButtonL2 })
	InputSystem.Bind("Reload", { Enum.KeyCode.R, Enum.KeyCode.ButtonB })
	InputSystem.Bind("CycleAimpart", { Enum.KeyCode.T })
	InputSystem.Bind("CycleLaserAtt", { Enum.KeyCode.H })
	InputSystem.Bind("CycleFlashLight", { Enum.KeyCode.J })
	InputSystem.Bind("CycleFireMode", { Enum.KeyCode.V })
	InputSystem.Bind("CheckMag", { Enum.KeyCode.M })
	InputSystem.Bind("ZeroDown", { Enum.KeyCode.LeftBracket })
	InputSystem.Bind("ZeroUp", { Enum.KeyCode.RightBracket })
end

function InputBindingController.UnbindWeaponActions()
	InputSystem.Unbind("Fire")
	InputSystem.Unbind("Aim")
	InputSystem.Unbind("Reload")
	InputSystem.Unbind("CycleAimpart")
	InputSystem.Unbind("CycleLaserAtt")
	InputSystem.Unbind("CycleFlashLight")
	InputSystem.Unbind("CycleFireMode")
	InputSystem.Unbind("CheckMag")
	InputSystem.Unbind("ZeroDown")
	InputSystem.Unbind("ZeroUp")
	InputSystem.Unbind("ToggleBipod")
end

return InputBindingController