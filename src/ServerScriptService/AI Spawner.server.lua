local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ACS_Workspace = Workspace:WaitForChild("ACS_WorkSpace")
local ACS_AI = RS:WaitForChild("ACS_AI")
local Event  = ACS_AI:WaitForChild("Events")
local EnemyContainer = ACS_AI:WaitForChild("EnemyContainer")

Event.Spawner.OnServerEvent:Connect(function(Player, pos, enemy_type)
    -- Validate enemy type
    if not enemy_type then
        return
    end

    local find_container = EnemyContainer:FindFirstChild(enemy_type)
    if not find_container then return end

    local clone_container = find_container:Clone()
    clone_container.Parent = ACS_Workspace:WaitForChild("AI")
    clone_container:MakeJoints()
    clone_container:MoveTo(pos)
end)