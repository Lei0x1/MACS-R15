local Debris = game:GetService("Debris")
--[[
    AI.lua

    Created by @ddydddd9 - Moonlight
]]

local AI = {}

local AITypes = require(script.Parent:WaitForChild("AITypes"))

-- Cache shared resources
local RS         = game:GetService("ReplicatedStorage")
local Debris     = game:GetService("Debris")
local PathFindingService = game:GetService("PathfindingService")
local Workspace  = game:GetService("Workspace")
local Players    = game:GetService("Players")

local ACS_Engine = RS:WaitForChild("ACS_Engine")
local Event      = ACS_Engine:WaitForChild("Events")
local GameRules  = ACS_Engine:WaitForChild("GameRules")
local Mods       = ACS_Engine:WaitForChild("Modules")

local Config     = require(GameRules:WaitForChild("Config"))
local HitMarker  = require(Mods:WaitForChild("Hitmarker"))
local Ragdoll    = require(Mods:WaitForChild("Ragdoll"))

-- Cache workspace references
local ACS_Workspace = Workspace:WaitForChild("ACS_WorkSpace")
local Ignore_Model  = ACS_Workspace:WaitForChild("Server")
local Bullet_Model  = ACS_Workspace:WaitForChild("Client")
local Ray_Ignore    = {Ignore_Model, Bullet_Model, ACS_Workspace}

-- Active AI Instances
local ActiveAI = {}

---------------------------------------------
--  R15/R6 Compatibility Functions
---------------------------------------------

-- Get the primary part
function AI:GetRootPart()
    return self.character:FindFirstChild("HumanoidRootPart") or self.character:FindFirstChild("Torso") or self.character.PrimaryPart
end

-- Get the head (works for both R6 and R15)
function AI:GetHead()
    return self.character:FindFirstChild("Head")
end

-- Get all limb parts for touch detection
function AI:GetLimbParts()
    local limbs = {}

    -- R6 limbs
    local leftLeg = self.character:FindFirstChild("Left Leg")
    local rightLeg = self.character:FindFirstChild("Right Leg")
    local leftArm = self.character:FindFirstChild("Left Arm")
    local rightArm = self.character:FindFirstChild("Right Arm")
    
    if leftLeg then table.insert(limbs, leftLeg) end
    if rightLeg then table.insert(limbs, rightLeg) end
    if leftArm then table.insert(limbs, leftArm) end
    if rightArm then table.insert(limbs, rightArm) end

    -- R15 limbs
    local humanoid = self.character:FindFirstChild("Humanoid")
    if humanoid then
        for _, part in pairs(self.character:GetChildren()) do
            if part:IsA("BasePart") and part.Name:find("Left") or part.Name:find("Right") or part.Name:find("L") or part.Name:find("R") then
                if not table.find(limbs, part) then
                    table.insert(limbs, part)
                end
            end
        end
    end
    
    return limbs
end

-- Get the grip/tool holder
function AI:GetGrip()
    return self.character:FindFirstChild("Grip") or 
           self.character:FindFirstChild("RightHand") or 
           self.character:FindFirstChild("Right Arm") or
           self.character:FindFirstChild("RightLowerArm") or
           self.character:FindFirstChild("ToolGrip")
end

---------------------------------------------
--  Helper functions
---------------------------------------------
function AI:CheckForHumanoid(part)
    local humanoid = false
    local human = nil
    
    if part then
        if part.Parent:FindFirstChild("Humanoid") then
            humanoid = true
            human = part.Parent.Humanoid
        elseif part.Parent.Parent and part.Parent.Parent:FindFirstChild("Humanoid") then
            humanoid=  true
            human = part.Parent.Parent.Humanoid
        end
    end

    return humanoid, human
end

function AI:CalculateDamage(base_damage, distance, victim, hit_type, settings)
    base_damage = tonumber(base_damage) or 0
    
    if not (victim and victim.Parent) then
        local traveled_damage = base_damage * (math.ceil(distance) / 40) * settings.FallOfDamage
        return math.max(traveled_damage, 1), 0, 0
    end

    local traveled_damage = base_damage * (math.ceil(distance) / 40) * settings.FallOfDamage
    local damage = traveled_damage or 0
    local vest_damage, helmet_damage = 0, 0

    -- Get protection components
    local health_folder = victim.Parent:FindFirstChild("Health")
    local protection = health_folder and health_folder:FindFirstChild("Protection")

    local penetration = settings.BulletPenetration

    if protection then
        local vest = protection:FindFirstChild("VestHealth")
        local vest_factor = protection:FindFirstChild("VestProtection")
        local helmet = protection:FindFirstChild("HelmetHealth")
        local helmet_factor = protection:FindFirstChild("HelmetProtection")

        if hit_type == "Head" and helmet and helmet_factor and helmet.Value > 0 then
            if penetration < helmet_factor.Value then
                damage = traveled_damage * (penetration / helmet_factor.Value)
                helmet_damage = traveled_damage * ((100 - penetration) / helmet_factor.Value)

                helmet_damage = helmet_damage > 0 and helmet_damage or 0.5
            else
                damage = traveled_damage
                helmet_damage = traveled_damage * ((100 - penetration) / helmet_factor.Value)
                helmet_damage = helmet_damage > 0 and helmet_damage or 1
            end
        elseif hit_type ~= "Head" and vest and vest_factor and vest.Value > 0 then
            if penetration < vest_factor.Value then
                damage = traveled_damage * (penetration / vest_factor.Value)
                vest_damage = traveled_damage * ((100 - penetration) / vest_factor.Value)

                vest_damage = vest_damage > 0 and vest_damage or 0.5
            else
                damage = traveled_damage
                vest_damage = traveled_damage * ((100 - penetration) / vest_factor.Value)
                vest_damage = vest_damage > 0 and vest_damage or 1
            end
        end
    end

    return math.max(damage, 1), vest_damage, helmet_damage
end

function AI:ApplyDamage(victim_humanoid, damage, vest_damage, helmet_damage)
    if not victim_humanoid or not victim_humanoid.Parent then return end

    local health_folder = victim_humanoid.Parent:FindFirstChild("Health")
    if health_folder then
        local protection = health_folder:FindFirstChild("Protection")
        if protection then
            local vest = protection:WaitForChild("VestHealth")
            local helmet = protection:WaitForChild("HelmetHealth")

            if vest then
                vest.Value = vest.Value - vest_damage
            end

            if helmet then
                helmet.Value = helmet.Value - helmet_damage
            end
        end
    end
    
    victim_humanoid:TakeDamage(damage)
end

function AI:FindNearestTorso(pos, settings)
    local torso = nil
    local distance = settings.WalkDistance.Value or 100
    
    -- Only players : No workspace models
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if character and character ~= self.character then
            local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
            local human = character:FindFirstChild("Humanoid")
            
            if root and human and human.Health > 0 then
                local magnitude = (root.Position - pos).magnitude
                if magnitude < distance then
                    torso = root
                    distance = magnitude
                end
            end
        end
    end

    return torso
end

function AI:NearPlayer(character, grip, settings)
    local dis = settings.ShotDistance.Value
    local target_player = nil
    local closest_distance = dis

    for _, v in ipairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("Humanoid") then
            local humanoid = v.Character.Humanoid

            if humanoid.Health > 0 then
                local root_part = v.Character:FindFirstChild("HumanoidRootPart") or v.Character:FindFirstChild("Torso")

                if root_part then
                    local distance = (root_part.Position - grip.Position).Magnitude
                    if distance < closest_distance then
                        closest_distance = distance
                        target_player = v
                    end
                end
            end
        end
    end

    if target_player and target_player.Character then
        local target_cframe = target_player.Character:GetModelCFrame()
        local root_part = target_player.Character:FindFirstChild("HumanoidRootPart") or target_player.Character:FindFirstChild("Torso")

        if root_part then
            local look_vector = root_part.CFrame.LookVector
            return target_cframe, closest_distance, look_vector
        end
    end

    return nil
end

function AI:Hitmaker(hit_part, position, normal, material)
    self.Event.AI.Hit:FireAllClients(nil, position, hit_part, normal, material, nil)
end

---------------------------------------------
--  AI Instance Class
---------------------------------------------

function AI:New(character, ai_type)
    local instance = setmetatable({}, {__index = self})

    -- Get configuration based on AI type
    local config = AITypes.GetConfig(ai_type)

    -- Store references
    instance.character = character
    instance.humanoid = character:WaitForChild("Humanoid")
    
    -- R15/R6 compatible part detection
    instance.root_part = instance:GetRootPart()
    instance.head = instance:GetHead()
    instance.grip = instance:GetGrip()
    
    -- Store all limb parts for touch detection
    instance.limbs = instance:GetLimbParts()

    -- Store settings from config
    instance.settings = {}
    for k, v in pairs(config) do
        instance.settings[k] = v
    end

    -- Get weapon settings from Config (ACS Specific)
    local success, AIConfig = pcall(function()
        return character:WaitForChild("Config")
    end)

    if success then
        instance.ammo = AIConfig.Ammo.Value
        instance.settings.Ammo = AIConfig.Ammo
        instance.settings.ShotDistance = AIConfig.ShotDistance
        instance.settings.WalkDistance = AIConfig.WalkDistance
        instance.settings.TracerChance = AIConfig.TracerChance
        instance.settings.Level = AIConfig.Level
    else
        -- Fallback defaults
        instance.ammo = 30
		instance.settings.ShotDistance = Instance.new("NumberValue")
		instance.settings.ShotDistance.Value = 100
		instance.settings.WalkDistance = Instance.new("NumberValue")
		instance.settings.WalkDistance.Value = 100
		instance.settings.TracerChance = Instance.new("NumberValue")
		instance.settings.TracerChance.Value = 50
		instance.settings.Level = Instance.new("NumberValue")
		instance.settings.Level.Value = 1
    end

    -- State variables
    instance.Dead = false
    instance.CanSee = false
    instance.CurrentPart = nil
    instance.perception = 0
    instance.Memory = 0
    instance.reloading = false
    instance.RPM = 1 / (instance.settings.FireRate / 60)
    instance.RecoilSpread = instance.settings.Spread / 100
    instance.AIType = ai_type

    -- Pathfinding
    instance.path = PathFindingService:CreatePath()
    instance.waypoints = {}
    instance.currentWaypointIndex = nil
    instance.target = nil
    instance.destination = nil

    -- Cache
    instance.Event = Event
    instance.Ray_Ignore = Ray_Ignore
    instance.Debris = Debris

    -- Setup the AI
    task.spawn(function()
        instance:Setup()
    end)
    
    -- Store in active list
    ActiveAI[character] = instance

    return instance
end

function AI:Setup()
    -- Remove forcefield
    if self.character:FindFirstChild("ForceField") then
        self.character.ForceField:Destroy()
    end

    -- Death connection
    self.humanoid.Died:Connect(function()
        self:OnDied()
    end)

    -- Touch connection for All limb parts (R15 + R6)
    for _, limb in ipairs(self.limbs) do
        limb.Touched:Connect(function(hit)
            self:OnTouched(hit)
        end)
    end

    -- Pathfinding events
    self.path.Blocked:Connect(function(idx)
        self:OnPathBlocked(idx)
    end)

    self.humanoid.MoveToFinished:Connect(function(reached)
        self:OnWaypointReached(reached)
    end)

    -- Start AI loop
    task.spawn(function()
        self:AILoop()
    end)

    -- print(`[AI] Initialized {self.AIType} AI for {self.character.Name}`)
end

function AI:OnTouched(hit)
    if hit.Parent == nil then return end
    if hit.Parent:FindFirstChild("Humanoid") == nil then
        self.CurrentPart = hit
    end
end

function AI:OnDied()
    Ragdoll(self.character)

    if self.character:FindFirstChild("Gun") then
        self.character.Gun.CanCollide = true
    end

    self.Dead = true
    self.Debris:AddItem(self.character, Players.RespawnTime)

    -- Remove from active AI list
    ActiveAI[self.character] = nil


    -- print(`[AI] {self.character.Name} has died`)
end

function AI:Reload()
    if self.reloading then return end

    if (self.ammo ~= self.settings.Ammo.Value) or self.ammo == 0 then
        self.reloading = true
        self.grip.Reload:Play()
        
        task.wait(3) -- Reload timer
        
        self.ammo = self.settings.Ammo.Value
        self.reloading = false
    end
end

function AI:FollowPath(destination_object)
    local root = self:GetRootPart()
    if not root then return end

    self.destination = destination_object

    self.path:ComputeAsync(root.Position, destination_object)
    self.waypoints = {}

    if self.path.Status == Enum.PathStatus.Success then
        self.waypoints = self.path:GetWaypoints()
        if #self.waypoints > 0 then
            self.currentWaypointIndex = 1
            self.humanoid:MoveTo(self.waypoints[self.currentWaypointIndex].Position)
        end
    else
        self.humanoid:MoveTo(root.Position)
    end
end

function AI:OnWaypointReached(reached)
    if reached and self.waypoints and self.currentWaypointIndex then
        if self.currentWaypointIndex < #self.waypoints then
           self.currentWaypointIndex = self.currentWaypointIndex + 1
           self.humanoid:MoveTo(self.waypoints[self.currentWaypointIndex].Position)
        end
    end
end

function AI:OnPathBlocked(blocked_way_point_index)
    if self.destination and blocked_way_point_index > (self.currentWaypointIndex or 0) then
        self:FollowPath(self.destination)
    end
end

function AI:Lookat(target, eye)
    local forward_vector = (eye - target).Unit
    local up_vector = Vector3.new(0, 1, 0)
    local right_vector = forward_vector:Cross(up_vector)
    local up_vector2 = right_vector:Cross(forward_vector)

    return CFrame.fromMatrix(eye, right_vector, up_vector2)
end

function AI:Shoot(target_cframe, mag, hum)
    if self.reloading or self.Dead then return end
    if not self.grip or not self.head then return end

    local aim = target_cframe.p + Vector3.new(
        math.random(-mag * self.RecoilSpread, mag * self.RecoilSpread),
        math.random(-mag * self.RecoilSpread, mag * self.RecoilSpread),
        math.random(-mag * self.RecoilSpread, mag * self.RecoilSpread)
    ) + hum

    local raycast_params = RaycastParams.new()
    raycast_params.FilterType = Enum.RaycastFilterType.Exclude
    raycast_params.FilterDescendantsInstances = {self.character, Ignore_Model, Bullet_Model, ACS_Workspace}

    local direction = (aim - self.grip.Position).Unit * 999
    local raycast_result = Workspace:Raycast(self.grip.Position, direction, raycast_params)

    if raycast_result and not self.Dead then
        local hit_part = raycast_result.Instance
        local pos = raycast_result.Position
        local norm = raycast_result.Normal
        local mat = raycast_result.Material

        local found_human, victim_humanoid = self:CheckForHumanoid(hit_part)

        if found_human and victim_humanoid.Health > 0 and Players:GetPlayerFromCharacter(victim_humanoid.Parent) then
            -- Fire effects
            self.Event.AI.Shoot:FireAllClients(self.grip)

            if self.grip:FindFirstChild("Echo") then
                self.grip.Echo:Play()
            end
            if self.grip:FindFirstChild("Fire") then
                self.grip.Fire:Play()
            end

            -- Hit effect
            self:Hitmaker(hit_part, pos, norm, mat)

            -- Calculate damage
            local total_dist_traveled = (pos - self.grip.Position).Magnitude
            local base_damage
            local hit_type = "Body"

            -- Determine hit location (R15 + R6 compatible)
            if hit_part.Name == "Head" or 
               hit_part.Name:find("Head") or
               hit_part.Parent.Name == "Top" or 
               hit_part.Parent.Name == "Headset" or 
               hit_part.Parent.Name == "Olho" or 
               hit_part.Parent.Name == "Face" or 
               hit_part.Parent.Name == "Numero" or 
               hit_part.Parent:IsA("Accessory") or 
               hit_part.Parent:IsA("Hat") then
                base_damage = math.random(self.settings.HeadDamage[1], self.settings.HeadDamage[2])
                hit_type = "Head"
            elseif hit_part.Name == "Torso" or 
                   hit_part.Name == "UpperTorso" or 
                   hit_part.Name == "LowerTorso" or
                   hit_part.Parent.Name == "Chest" or 
                   hit_part.Parent.Name == "Waist" then
                base_damage = math.random(self.settings.TorsoDamage[1], self.settings.TorsoDamage[2])
            else
                base_damage = math.random(self.settings.LimbsDamage[1], self.settings.LimbsDamage[2])
            end

            local damage, vest_damage, helmet_damage = self:CalculateDamage(
                base_damage,
                total_dist_traveled,
                victim_humanoid,
                hit_type,
                self.settings
            )

            self:ApplyDamage(victim_humanoid, damage, vest_damage, helmet_damage)

            self.ammo = self.ammo - 1

            -- Tracer effect
            if math.random(1, 100) <= self.settings.TracerChance.Value then
                self.Event.AI.Bullet:FireAllClients(
                    nil, self.head.CFrame, self.settings.Tracer, 0, 2200,
                    (aim - self.grip.Position).Unit, self.settings.TracerColor,
                    self.Ray_Ignore, self.settings.BulletFlare, self.settings.BulletFlareColor                
                )
            end
        end
    end
end

function AI:AIBehavior()
    local mode = self.settings.Mode
    local root = self:GetRootPart()
    if not root then return end

    if mode == 0 then
        -- Patrol mode
        task.wait(math.random(5, 15) / 10)
        self:FollowPath(root.Position + Vector3.new(
            math.random(-self.settings.MaxInc, self.settings.MaxInc),
            0,
            math.random(-self.settings.MaxInc, self.settings.MaxInc)
        ))

    elseif mode == 1 or mode == 2 then
        self.target = self:FindNearestTorso(root.Position, self.settings)
        
        if self.target then
            local distance = (root.Position - self.target.Position).Magnitude

            if self.CanSee and distance <= self.settings.MinDistance then
                self.waypoints = nil
            elseif (mode == 2 and self.Memory > 0) or mode == 1 then
                self.path:ComputeAsync(root.Position, self.target.Position)
                self.waypoints = self.path:GetWaypoints()

                if self.path.Status == Enum.PathStatus.Success and #self.waypoints > 0 then
                    self.humanoid.WalkToPart = nil

                    local waypoint_index = math.min(3, #self.waypoints)
                    local target_waypoint = self.waypoints[waypoint_index]

                    if target_waypoint and target_waypoint.Action == Enum.PathWaypointAction.Walk then
                        self.humanoid:MoveTo(target_waypoint.Position)
                    end
                else
                    task.wait(math.random(5, 15) / 10)
                    self:FollowPath(root.Position + Vector3.new(
                        math.random(-self.settings.MaxInc, self.settings.MaxInc),
                        0,
                        math.random(-self.settings.MaxInc, self.settings.MaxInc)
                    ))
                end
            else
                self.waypoints = nil
                task.wait(math.random(5, 15) / 10)
                self:FollowPath(root.Position + Vector3.new(
                    math.random(-self.settings.MaxInc, self.settings.MaxInc),
                    0,
                    math.random(-self.settings.MaxInc, self.settings.MaxInc)
                ))
            end
        else
            --  No target found, patrol
            self.waypoints = nil
            task.wait(math.random(5, 15) / 10)
            self:FollowPath(root.Position + Vector3.new(
                math.random(-self.settings.MaxInc, self.settings.MaxInc),
                0,
                math.random(-self.settings.MaxInc, self.settings.MaxInc)
            ))
        end
    elseif mode == 3 then
        -- Guard mode; do nothing; stay inp place
        self.humanoid.WalkSpeed = 0
        self.waypoints = nil
    end
end

function AI:AILoop()
    while not self.Dead do
        -- Run AI behavior
        self:AIBehavior()

        -- Combat logic
        local target_cframe, mag, hum = self:NearPlayer(self.character, self.grip, self.settings)

        if target_cframe and not self.Dead then
            local root = self:GetRootPart()
            if root then
                -- Rotate to face the target
                if self.character.PrimaryPart then
                    local currentCF = self.character:GetPrimaryPartCFrame()

                    -- Calculate look position (keep Y the same to prevent looking up/down)
                    local look_at = Vector3.new(target_cframe.p.X, root.Position.Y, target_cframe.p.Z)

                    -- Target rotation CFrame
                    local target_rotation = CFrame.lookAt(root.Position, look_at)

                    -- OPTION 1: Smooth rotation
                    self.character:SetPrimaryPartCFrame(currentCF:Lerp(target_rotation, 0.3))

                    -- OPTION 2: Simple instant rotation:
                    -- self.character:SetPrimaryPartCFrame(target_rotation)
                end

                -- Check line of sight and shoot
                local raycast_params = RaycastParams.new()
                raycast_params.FilterType = Enum.RaycastFilterType.Exclude
                raycast_params.FilterDescendantsInstances = {self.character}

                local direction = (target_cframe.p - root.Position).Unit * 999
                local raycast_result = Workspace:Raycast(root.Position, direction, raycast_params)

                if raycast_result then
                    local hit_part = raycast_result.Instance
                    local found_human, victim_humanoid = self:CheckForHumanoid(hit_part)
                    
                    -- Verify the victom is still alive and valid
                    if found_human and victim_humanoid and victim_humanoid.Health > 0 then
                        local player = Players:GetPlayerFromCharacter(victim_humanoid.Parent) 
                        if player then
                            if self.perception >= 10 then
                                self:Shoot(target_cframe, mag, hum)

                                self.humanoid.WalkSpeed = self.settings.ShootingWalkspeed
                                self.CanSee = true
                            else
                                self.perception = self.perception + self.settings.Level.Value
                                self.humanoid.WalkSpeed = self.settings.SearchingWalkspeed
                                self.Memory = self.settings.Level.Value * 100
                                self.CanSee = true
                            end
                        else
                            self.CanSee = false
                        end
                    else
                        self.CanSee = false
                    end
                else
                    self.CanSee = false
                end 
            end
        else
            self.CanSee = false
        end

        -- Perception decay
        if self.perception > 0 and not self.CanSee then
            self.perception = self.perception - (1 / self.settings.Level.Value * 2)
            self.humanoid.WalkSpeed = self.settings.SearchingWalkspeed
        elseif self.perception <=0 then
            self.perception = 0
            self.humanoid.WalkSpeed = self.settings.RegularWalkspeed
            self.Memory = self.Memory - 0.25
            self.CanSee = false
        end

        -- Reload if needed
        if self.ammo <= 0 and not self.reloading and self.settings.FireRate > 1 then
            self:Reload()
        end

        task.wait(self.RPM)
    end
end

-- Cleanup function for when game ends
function AI.CleanupAll()
    for character, instance in pairs(ActiveAI) do
        instance.Dead = true
        ActiveAI[character] = nil
    end
end

-- Get active AI count
function AI.GetActiveCount()
    local count = 0
    for _ in pairs(ActiveAI) do
        count = count + 1
    end

    return count
end

return AI