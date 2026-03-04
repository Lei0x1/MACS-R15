--[[
    AttachmentManager.lua
    Created by @ddydddd9 - Moonlight

    Centralized weapon attachment system for managing attachment instances, modifiers, and state
]]
    
local RS = game:GetService("ReplicatedStorage")

local Engine = RS:WaitForChild("ACS_Engine")
local Attachment		= Engine:WaitForChild("Attachments")
local AttachmentModels 	= Attachment:WaitForChild("Models")
local AttachmentModules = Attachment:WaitForChild("Modules")
local Modules = Engine:WaitForChild("Modules")
local WeaponModules = Modules:WaitForChild("Weapon")
local ClientModules = Modules:WaitForChild("Client")

local Util = require(Modules:WaitForChild("Utilities"))
local InputSystem = require(ClientModules:WaitForChild("InputSystem"))
local WeaponRegistry = require(WeaponModules:WaitForChild("WeaponRegistry"))

local AttachmentManager = {}
AttachmentManager.Server = {}
AttachmentManager.OperatorPack = {}

-- State table
AttachmentManager.Data = {
    CamRecoil 	= {
		RecoilTilt 	= 1,
		RecoilUp 	= 1,
		RecoilLeft 	= 1,
		RecoilRight = 1
	}

	,GunRecoil	= {
		RecoilUp 	= 1,
		RecoilTilt 	= 1,
		RecoilLeft 	= 1,
		RecoilRight = 1
	}

	,ZoomValue 		= 70
	,Zoom2Value 	= 70
	,AimRM 			= 1
	,SpreadRM 		= 1
	,DamageMod 		= 1
	,minDamageMod 	= 1

	,MinRecoilPower 			= 1
	,MaxRecoilPower 			= 1
	,RecoilPowerStepAmount 		= 1

	,MinSpread 					= 1
	,MaxSpread 					= 1
	,AimInaccuracyStepAmount 	= 1
	,AimInaccuracyDecrease 		= 1
	,WalkMult 					= 1
	,adsTime 					= 1
	,MuzzleVelocity 			= 1
}

AttachmentManager.Instances = {
    SightAtt = nil,
    BarrelAtt = nil,
    UnderBarrelAtt = nil,
    OtherAtt = nil,
    Reticle = nil,
    Pointer = nil
}

AttachmentManager.ModuleData = {
    SightData       = nil,
    BarrelData      = nil,
    UnderBarrelData = nil,
    OtherData       = nil
}

AttachmentManager.Flags = {
    Suppressor = false,
    FlashHider = false,
    LaserAtt = false,
    LaserActive = false,
    InfraredMode = false,
    InfraredEnabled = false,
    TorchAtt = false,
    TorchActive = false,
    HasBipodAttachment = false,
    IsBipodDeployable = false,
    BipodActive = false
}

function AttachmentManager.Reset()
    local attachment_modifier = AttachmentManager.Data
    local attachment_flags = AttachmentManager.Flags

    attachment_modifier.CamRecoil.RecoilUp 		= 1
	attachment_modifier.CamRecoil.RecoilLeft 	= 1
	attachment_modifier.CamRecoil.RecoilRight 	= 1
	attachment_modifier.CamRecoil.RecoilTilt 	= 1

	attachment_modifier.GunRecoil.RecoilUp 		= 1
	attachment_modifier.GunRecoil.RecoilTilt 	= 1
	attachment_modifier.GunRecoil.RecoilLeft 	= 1
	attachment_modifier.GunRecoil.RecoilRight 	= 1

	attachment_modifier.AimRM					= 1
	attachment_modifier.SpreadRM 				= 1
	attachment_modifier.DamageMod 				= 1
	attachment_modifier.minDamageMod 			= 1

	attachment_modifier.MinRecoilPower 			= 1
	attachment_modifier.MaxRecoilPower 			= 1
	attachment_modifier.RecoilPowerStepAmount 	= 1

	attachment_modifier.MinSpread 				= 1
	attachment_modifier.MaxSpread 				= 1
	attachment_modifier.AimInaccuracyStepAmount = 1
	attachment_modifier.AimInaccuracyDecrease 	= 1
	attachment_modifier.WalkMult 				= 1
	attachment_modifier.MuzzleVelocity 			= 1

    attachment_flags.Suppressor = false
    attachment_flags.FlashHider = false
    attachment_flags.LaserAtt = false
    attachment_flags.LaserActive = false
    attachment_flags.InfraredMode = false
    attachment_flags.InfraredEnabled = false
    attachment_flags.TorchAtt = false
    attachment_flags.TorchActive = false
    attachment_flags.HasBipodAttachment = false
    attachment_flags.IsBipodDeployable = false
    attachment_flags.BipodActive = false
end

function AttachmentManager.Apply(attachment_data)
    local attachment_modifier = AttachmentManager.Data

    attachment_modifier.CamRecoil.RecoilUp 		= attachment_modifier.CamRecoil.RecoilUp * attachment_data.camRecoil.RecoilUp
	attachment_modifier.CamRecoil.RecoilLeft 	= attachment_modifier.CamRecoil.RecoilLeft * attachment_data.camRecoil.RecoilLeft
	attachment_modifier.CamRecoil.RecoilRight 	= attachment_modifier.CamRecoil.RecoilRight * attachment_data.camRecoil.RecoilRight
	attachment_modifier.CamRecoil.RecoilTilt 	= attachment_modifier.CamRecoil.RecoilTilt * attachment_data.camRecoil.RecoilTilt

	attachment_modifier.GunRecoil.RecoilUp 		= attachment_modifier.GunRecoil.RecoilUp * attachment_data.gunRecoil.RecoilUp
	attachment_modifier.GunRecoil.RecoilTilt 	= attachment_modifier.GunRecoil.RecoilTilt * attachment_data.gunRecoil.RecoilTilt
	attachment_modifier.GunRecoil.RecoilLeft 	= attachment_modifier.GunRecoil.RecoilLeft * attachment_data.gunRecoil.RecoilLeft
	attachment_modifier.GunRecoil.RecoilRight 	= attachment_modifier.GunRecoil.RecoilRight * attachment_data.gunRecoil.RecoilRight

	attachment_modifier.AimRM					= attachment_modifier.AimRM * attachment_data.AimRecoilReduction
	attachment_modifier.SpreadRM 				= attachment_modifier.SpreadRM * attachment_data.AimSpreadReduction
	attachment_modifier.DamageMod 				= attachment_modifier.DamageMod * attachment_data.DamageMod
	attachment_modifier.minDamageMod 			= attachment_modifier.minDamageMod * attachment_data.minDamageMod

	attachment_modifier.MinRecoilPower 			= attachment_modifier.MinRecoilPower * attachment_data.MinRecoilPower
	attachment_modifier.MaxRecoilPower 			= attachment_modifier.MaxRecoilPower * attachment_data.MaxRecoilPower
	attachment_modifier.RecoilPowerStepAmount 	= attachment_modifier.RecoilPowerStepAmount * attachment_data.RecoilPowerStepAmount

	attachment_modifier.MinSpread 				= attachment_modifier.MinSpread * attachment_data.MinSpread
	attachment_modifier.MaxSpread 				= attachment_modifier.MaxSpread * attachment_data.MaxSpread
	attachment_modifier.AimInaccuracyStepAmount = attachment_modifier.AimInaccuracyStepAmount * attachment_data.AimInaccuracyStepAmount
	attachment_modifier.AimInaccuracyDecrease 	= attachment_modifier.AimInaccuracyDecrease * attachment_data.AimInaccuracyDecrease
	attachment_modifier.WalkMult 				= attachment_modifier.WalkMult * attachment_data.WalkMult
	attachment_modifier.MuzzleVelocity 			= attachment_modifier.MuzzleVelocity * attachment_data.MuzzleVelocityMod
end

local function LoadAttachmentModule(module_name)
	local module_script = AttachmentModules:FindFirstChild(module_name)
	if not module_script then
		warn("Attachment module not found: ", module_name)
		return nil
	end
	
	return Util.SafeRequire(module_script)
end

function AttachmentManager.Server.Load(weapon_in_hand, weapon_data)
    if not weapon_in_hand and not weapon_data then return end

    local weapon_node = weapon_in_hand:FindFirstChild("Nodes")
    if not weapon_node then return end

    -- Load sight Att
	if weapon_node:FindFirstChild("Sight") ~= nil and weapon_data.SightAtt ~= "" then

		local SightAtt = AttachmentModels[weapon_data.SightAtt]:Clone()
		SightAtt.Parent = weapon_in_hand
		SightAtt:SetPrimaryPartCFrame(weapon_node.Sight.CFrame)

		for _, key in pairs(weapon_in_hand:GetChildren()) do
			if key.Name == "IS" then
				key.Transparency = 1
			end
		end

		for _, key in pairs(SightAtt:GetChildren()) do
			if key:IsA('BasePart') then
				Util.Weld(weapon_in_hand:WaitForChild("Handle"), key )
				key.Anchored = false
				key.CanCollide = false
			end
			if key.Name == "SightMark" or key.Name == "Main" then
				key:Destroy()
			end
		end

	end

	-- Load Barrel Att
	if weapon_node:FindFirstChild("Barrel") ~= nil and weapon_data.BarrelAtt ~= "" then

		local BarrelAtt = AttachmentModels[weapon_data.BarrelAtt]:Clone()
		BarrelAtt.Parent = weapon_in_hand
		BarrelAtt:SetPrimaryPartCFrame(weapon_node.Barrel.CFrame)

		if BarrelAtt:FindFirstChild("BarrelPos") ~= nil then
			weapon_in_hand.Handle.Muzzle.WorldCFrame = BarrelAtt.BarrelPos.CFrame
		end

		for _, key in pairs(BarrelAtt:GetChildren()) do
			if key:IsA('BasePart') then
				Util.Weld(weapon_in_hand:WaitForChild("Handle"), key )
				key.Anchored = false
				key.CanCollide = false
			end
		end
	end

	-- Load Under Barrel Att
	if weapon_node:FindFirstChild("UnderBarrel") ~= nil and weapon_data.UnderBarrelAtt ~= "" then

		local UnderBarrelAtt = AttachmentModels[weapon_data.UnderBarrelAtt]:Clone()
		UnderBarrelAtt.Parent = weapon_in_hand
		UnderBarrelAtt:PivotTo(weapon_node.UnderBarrel.CFrame)


		for _, key in pairs(UnderBarrelAtt:GetChildren()) do
			if key:IsA('BasePart') then
				Util.Weld(weapon_in_hand:WaitForChild("Handle"), key )
				key.Anchored = false
				key.CanCollide = false
			end
		end
	end

	if weapon_node:FindFirstChild("Other") ~= nil and weapon_data.OtherAtt ~= "" then

		local OtherAtt = AttachmentModels[weapon_data.OtherAtt]:Clone()
		OtherAtt.Parent = weapon_in_hand
		OtherAtt:PivotTo(weapon_node.Other.CFrame)

		for _, key in pairs(OtherAtt:GetChildren()) do
			if key:IsA('BasePart') then
				Util.Weld(weapon_in_hand:WaitForChild("Handle"), key )
				key.Anchored = false
				key.CanCollide = false
			end
		end
	end
end

function AttachmentManager.Load(weapon_in_hand)
    local weapon_data = WeaponRegistry:GetWeaponData()
    if not weapon_data then return end

    local att_instances = AttachmentManager.Instances
    local att_data = AttachmentManager.Data
    local module_data = AttachmentManager.ModuleData
    local flags = AttachmentManager.Flags

    flags.Suppressor = false
    flags.FlashHider = false
    flags.LaserAtt = false
    flags.TorchAtt = false
    flags.HasBipodAttachment = false
    flags.InfraredEnabled = weapon_data.InfraRed or false

    local weapon_node = weapon_in_hand:FindFirstChild("Nodes")
    if not weapon_node then return end
    
    -- Load sight att
    if weapon_node:FindFirstChild("Sight") ~= nil and weapon_data.SightAtt ~= "" then
        module_data.SightData = LoadAttachmentModule(weapon_data.SightAtt)

        att_instances.SightAtt = AttachmentModels[weapon_data.SightAtt]:Clone()
        att_instances.SightAtt.Parent = weapon_in_hand

        att_instances.SightAtt.PrimaryPart = att_instances.SightAtt:FindFirstChildWhichIsA("BasePart")

        task.wait()
        att_instances.SightAtt:SetPrimaryPartCFrame(weapon_node.Sight.CFrame)
        weapon_in_hand.AimPart.CFrame = att_instances.SightAtt.AimPos.CFrame

        if module_data.SightData.SightZoom > 0 then
            att_data.ZoomValue = module_data.SightZoom
        end

        if module_data.SightData.SightZoom2 > 0 then
            att_data.Zoom2Value = module_data.SightZoom2
        end

        AttachmentManager.Apply(module_data.SightData)

        for _, part in pairs(weapon_in_hand:GetChildren()) do
            if part.Name == "IS" then
                part.Transparency = 1
            end
        end

        for _, part in pairs(att_instances.SightAtt:GetChildren()) do
            if part:IsA("BasePart") then
                Util.Weld(weapon_in_hand:WaitForChild("Handle"), part)
                part.Anchored = false
                part.CanCollide = false
            end
        end
    end

    -- Load barrel att
    if weapon_node:FindFirstChild("Barrel") ~= nil and weapon_data.BarrelAtt ~= "" then
        module_data.BarrelData =  LoadAttachmentModule(weapon_data.BarrelAtt)

        att_instances.BarrelAtt = AttachmentModels[weapon_data.BarrelAtt]:Clone()
        att_instances.BarrelAtt.Parent = weapon_in_hand

        if att_instances.BarrelAtt:FindFirstChildWhichIsA("BasePart") then
            att_instances.BarrelAtt.PrimaryPart = att_instances.BarrelAtt:FindFirstChildWhichIsA("BasePart")
        end
        
        task.wait()

        att_instances.BarrelAtt:SetPrimaryPartCFrame(weapon_node.Barrel.CFrame)

        if att_instances.BarrelAtt:FindFirstChild("BarrelPos") ~= nil then
            weapon_in_hand.Handle.Muzzle.WorldCFrame = att_instances.BarrelAtt.BarrelPos.CFrame
        end

        flags.Suppressor 		= module_data.BarrelData.IsSuppressor
        flags.FlashHider 		= module_data.BarrelData.IsFlashHider

        AttachmentManager.Apply(module_data.BarrelData)

        for _, part in pairs(att_instances.BarrelAtt:GetChildren()) do
            if part:IsA('BasePart') then
                Util.Weld(weapon_in_hand:WaitForChild("Handle"), part)
                part.Anchored = false
                part.CanCollide = false
            end
        end
    end

    -- Load under barrel att
    if weapon_node:FindFirstChild("UnderBarrel") ~= nil and weapon_data.UnderBarrelAtt ~= "" then
        module_data.UnderBarrelData =  LoadAttachmentModule(weapon_data.UnderBarrelAtt)

        att_instances.UnderBarrelAtt = AttachmentModels[weapon_data.UnderBarrelAtt]:Clone()
        att_instances.UnderBarrelAtt.Parent = weapon_in_hand

        if att_instances.UnderBarrelAtt:FindFirstChildWhichIsA("BasePart") then
            att_instances.UnderBarrelAtt.PrimaryPart = att_instances.UnderBarrelAtt:FindFirstChildWhichIsA("BasePart")
        end
        
        task.wait()

        att_instances.UnderBarrelAtt:SetPrimaryPartCFrame(weapon_node.UnderBarrel.CFrame)

        AttachmentManager.Apply(module_data.UnderBarrelData)
        flags.HasBipodAttachment = module_data.UnderBarrelData.IsBipod

        if flags.HasBipodAttachment then
            InputSystem.Bind("ToggleBipod", {Enum.KeyCode.B})
        end

        for _, part in pairs(att_instances.UnderBarrelAtt:GetChildren()) do
            if part:IsA('BasePart') then
                Util.Weld(weapon_in_hand:WaitForChild("Handle"), part )
                part.Anchored = false
                part.CanCollide = false
            end
        end
    end

    -- Load other att
    if weapon_node:FindFirstChild("Other") ~= nil and weapon_data.OtherAtt ~= "" then
        module_data.OtherData =  LoadAttachmentModule(weapon_data.OtherAtt)

        att_instances.OtherAtt = AttachmentModels[weapon_data.OtherAtt]:Clone()
        att_instances.OtherAtt.Parent = weapon_in_hand

        if att_instances.OtherAtt:FindFirstChildWhichIsA("BasePart") then
            att_instances.OtherAtt.PrimaryPart = att_instances.OtherAtt:FindFirstChildWhichIsA("BasePart")
        end
        
        task.wait()

        att_instances.OtherAtt:SetPrimaryPartCFrame(weapon_node.Other.CFrame)

        AttachmentManager.Apply(module_data.OtherData)
        flags.LaserAtt = module_data.OtherData.EnableLaser
        flags.TorchAtt = module_data.OtherData.EnableFlashlight

        if module_data.OtherData.InfraRed then
            flags.InfraredEnabled = true
        end
        
        for _, part in pairs(att_instances.OtherAtt:GetChildren()) do
            if part:IsA('BasePart') then
                Util.Weld(weapon_in_hand:WaitForChild("Handle"), part )
                part.Anchored = false
                part.CanCollide = false
            end
        end
    end
end

function AttachmentManager.Clear()
    local att_instances = AttachmentManager.Instances
    local module_data = AttachmentManager.ModuleData

    -- Destroy attachment instances
    if att_instances.SightAtt then
        att_instances.SightAtt:Destroy()
        att_instances.SightAtt = nil
    end

    if att_instances.BarrelAtt then
        att_instances.BarrelAtt:Destroy()
        att_instances.BarrelAtt = nil
    end

    if att_instances.UnderBarrelAtt then
        att_instances.UnderBarrelAtt:Destroy()
        att_instances.UnderBarrelAtt = nil
    end

    if att_instances.OtherAtt then
        att_instances.OtherAtt:Destroy()
        att_instances.OtherAtt = nil
    end
    
    -- Clear references
    att_instances.Reticle = nil
    att_instances.Pointer = nil
    
    -- Clear module data
    module_data.SightData = nil
    module_data.BarrelData = nil
    module_data.UnderBarrelData = nil
    module_data.OtherData = nil
    
    -- Reset flags
    for flag, _ in pairs(AttachmentManager.Flags) do
        AttachmentManager.Flags[flag] = false
    end

    AttachmentManager.Reset()
end

return AttachmentManager