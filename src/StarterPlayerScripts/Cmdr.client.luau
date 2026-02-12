local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")

local Cmdr = require(RS:WaitForChild("CmdrClient"))

Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })