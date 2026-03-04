local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ACS_AI = RS:WaitForChild("ACS_AI")
local Event  = ACS_AI:WaitForChild("Events")

local Player = Players.LocalPlayer
local mouse = Player:GetMouse()
local Tool = script.Parent
local EnemyType = Tool:WaitForChild("EnemyType")

Tool.Activated:Connect(function()
    Event.Spawner:FireServer(mouse.Hit.Position, EnemyType.Value)
end)
