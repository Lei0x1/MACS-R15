--[[
    ViewModelManager.lua
    Created by @ddydddd9 - Moonlight

    Viewmodel manager for creating and managing arms and weapon
    attachments with dynamic welding
]]

local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local CurrentCamera = workspace.CurrentCamera

local Engine = RS:WaitForChild("ACS_Engine")
local ArmModels = Engine:WaitForChild("ArmModel")
local ArmModel = ArmModels:WaitForChild("Arms")
local Modules = Engine:WaitForChild("Modules")
local WeaponModules = Modules:WaitForChild("Weapon")

local Util = require(Modules:WaitForChild("Utilities"))
local WeaponRegistry = require(WeaponModules:WaitForChild("WeaponRegistry"))

local ViewModelManager = {}

ViewModelManager.LA = nil
ViewModelManager.RA = nil
ViewModelManager.LAW = nil
ViewModelManager.RAW = nil

ViewModelManager.AnimBase = nil
ViewModelManager.ViewModel = nil
ViewModelManager.GunWeld = nil

local DEFAULT_LA_C1 = CFrame.new(1,-1,-5) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0)):Inverse()
local DEFAULT_RA_C1 = CFrame.new(-1,-1,-5) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0)):Inverse()
local DEFAULT_C0 = CFrame.new()

function ViewModelManager:Create(character, gun_cframe, current_camera)
    local weapon_in_hand = WeaponRegistry:GetWeaponInHand()
    if not weapon_in_hand then
        Util.LogTagged("ViewModelManager", "WeaponInHand is nil")
        return
    end

    -- Clone arms
    self.ViewModel = ArmModel:Clone()
    self.ViewModel.Name = "Viewmodel"

    -- Copy appearance
    local body_colors = character:FindFirstChild("Body Colors")
    if body_colors then
        body_colors:Clone().Parent = self.ViewModel
    end

    local body_shirt = character:FindFirstChild("Shirt")
    if body_shirt then
        body_shirt:Clone().Parent = self.ViewModel
    end

    -- Create animation base
    local AnimBase = Instance.new("Part")
    AnimBase.Size = Vector3.new(0.1, 0.1, 0.1)
    AnimBase.Anchored = true
    AnimBase.CanCollide = false
    AnimBase.Transparency = 1
    AnimBase.Parent = self.ViewModel

    self.AnimBase = AnimBase
    self.ViewModel.PrimaryPart = AnimBase
    -- self.ViewModel.Parent = CurrentCamera

    -- Create gun weld
    local GunWeld = Instance.new("Motor6D")
	GunWeld.Name = "Handle"
	GunWeld.Parent = self.AnimBase
    self.GunWeld = GunWeld

    -- Setup arms
    self:SetupArms()

    -- Attach gun
    GunWeld.Part1 = weapon_in_hand:WaitForChild("Handle")
    GunWeld.C1 = gun_cframe

    weapon_in_hand.Parent = self.ViewModel
    self.ViewModel.Parent = workspace.CurrentCamera
end

function ViewModelManager:SetupArms()
    local AnimBase = self.AnimBase
    local GunWeld = self.GunWeld

    AnimBase.CFrame = workspace.CurrentCamera.CFrame

    local LAW = Instance.new("Motor6D")
    LAW.Name = "LeftArm"
    LAW.Part0 = AnimBase
    LAW.Parent = AnimBase

    local RAW = Instance.new("Motor6D")
    RAW.Name = "RightArm"
    RAW.Part0 = AnimBase
    RAW.Parent = AnimBase

    -- LA does not reset not back to the viewmodel whenever it died fix it
    local LA = self.ViewModel:WaitForChild("Left Arm")
    LAW.Part1 = LA
    LAW.C0 = DEFAULT_C0
    LAW.C1 = DEFAULT_LA_C1

    -- RA does not reset not back to the viewmodel whenever it died fix it
    local RA = self.ViewModel:WaitForChild("Right Arm")
	RAW.Part1 = RA
	RAW.C0 = DEFAULT_C0
	RAW.C1 = DEFAULT_RA_C1
	GunWeld.Part0 = RA

    LA.Anchored = false
    RA.Anchored = false

    self.LA = LA
    self.RA = RA
    self.LAW = LAW
    self.RAW = RAW
end

function ViewModelManager:ResetArms()
    if not self.LAW or not self.RAW then return end

    -- Reset Left Arm weld
    self.LAW.Part0 = self.AnimBase
    self.LAW.Part1 = self.ViewModel:FindFirstChild("Left Arm")
    self.LAW.C0 = DEFAULT_C0
    self.LAW.C1 = DEFAULT_LA_C1

    -- Reset Right Arm weld
    self.RAW.Part0 = self.AnimBase
    self.RAW.Part1 = self.ViewModel:FindFirstChild("Right Arm")
    self.RAW.C0 = DEFAULT_C0
    self.RAW.C1 = DEFAULT_RA_C1

    -- Reattach gun weld to right arm
    if self.GunWeld then
        self.GunWeld.Part0 = self.RAW.Part1
    end
    
    -- Make sure arms are unanchored
    if self.LA then
        self.LA.Anchored = false
    end
    
    if self.RA then
        self.RA.Anchored = false
    end
end

function ViewModelManager:Clear()
    self.LA = nil
    self.RA = nil
    self.LAW = nil
    self.RAW = nil
    self.AnimBase = nil
    self.GunWeld = nil

    if self.ViewModel and self.ViewModel.Parent then
        self.ViewModel:Destroy()
    end

    self.ViewModel = nil
end

return ViewModelManager