local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")

local Cmdr = require(Packages:WaitForChild("Cmdr"))

Cmdr:RegisterDefaultCommands()