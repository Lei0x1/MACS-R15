repeat
	wait()
until game.Players.LocalPlayer.Character

--// Variables
local L_1_ = game.Players.LocalPlayer
local L_2_ = L_1_.Character

local L_3_ = game.ReplicatedStorage:WaitForChild('ACS_Engine')
local L_5_ = L_3_:WaitForChild('GameRules')
local L_7_ = L_3_:WaitForChild('HUD')

--// Modules
local L_9_ = require(L_5_:WaitForChild('Config'))

--// Functions
function UpdateTag(plr)
	if plr ~= L_1_ and plr.Character and plr.Character:FindFirstChild("TeamTagUI") then
		local Tag = plr.Character:FindFirstChild("TeamTagUI")
		if plr.Team == L_1_.Team then
			Tag.Enabled = true
			if plr.Character:FindFirstChild("ACS_Client") and plr.Character.ACS_Client:FindFirstChild("FireTeam") and plr.Character.ACS_Client.FireTeam.SquadName.Value ~= "" then
				Tag.Frame.Icon.ImageColor3 = plr.Character.ACS_Client.FireTeam.SquadColor.Value
			else
				Tag.Frame.Icon.ImageColor3 = Color3.fromRGB(255,255,255)
			end
		else
			Tag.Enabled = false
		end
	end
end

--// Player Events

game:GetService("RunService").Heartbeat:connect(function()
	for _,v in pairs(game.Players:GetChildren()) do
		UpdateTag(v)
	end
end)