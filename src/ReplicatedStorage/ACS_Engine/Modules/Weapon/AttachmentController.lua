--[[
    AttachmentController.lua
    Created by @ddydddd9 - Moonlight

	Attachment controller for toggling weapon attachments (lasers, flashlights)
	with visual feedback and network synchronization
]]

local RS = game:GetService("ReplicatedStorage")

local Engine = RS:WaitForChild("ACS_Engine")
local Modules = Engine:WaitForChild("Modules")
local Event = Engine:WaitForChild("Events")
local GameRules = Engine:WaitForChild("GameRules")
local Config = require(GameRules:WaitForChild("Config"))

local ClientModules = Modules:WaitForChild("Client")
local HUDController = require(ClientModules:WaitForChild("HUDController"))

local WeaponModules = Modules:WaitForChild("Weapon")
local WeaponRegistry = require(WeaponModules:WaitForChild("WeaponRegistry"))
local AttachmentManager = require(WeaponModules:WaitForChild("AttachmentManager"))

local AttachmentController = {}

function AttachmentController.ToggleLaserAttachment()
    local weapon_in_hand = WeaponRegistry.GetWeaponInHand()
    local weapon_tool = WeaponRegistry.GetWeaponTool()

    local attachment_flags = AttachmentManager.Flags

    if Config.RealisticLaser and attachment_flags.InfraredEnabled then
		if not attachment_flags.LaserActive and not attachment_flags.InfraredMode then
			attachment_flags.LaserActive  = true
			attachment_flags.InfraredMode = false

		elseif attachment_flags.LaserActive and not attachment_flags.InfraredMode then
			attachment_flags.LaserActive = false
			attachment_flags.InfraredMode = true

		elseif not attachment_flags.LaserActive and attachment_flags.InfraredMode then
			attachment_flags.LaserActive = false
			attachment_flags.InfraredMode = false
		end
	else
		attachment_flags.LaserActive = not attachment_flags.LaserActive
		attachment_flags.InfraredMode = false
	end

	if attachment_flags.Pointer then
        if attachment_flags.InfraredMode then
            attachment_flags.Pointer.Transparency = 1

            local beam = attachment_flags.Pointer:FindFirstChild("Beam")
            if beam then
                beam.Enabled = false
            end
        else
            attachment_flags.Pointer.Transparency = 0

            local beam = attachment_flags.Pointer:FindFirstChild("Beam")
            if beam then
                beam.Enabled = not Config.RealisticLaser
            end
        end
    end

	if attachment_flags.LaserActive then
		if not attachment_flags.Pointer then
			for _, part in pairs(weapon_in_hand:GetDescendants()) do
				if part:IsA("BasePart") and part.Name == "LaserPoint" then
					local laser_pointer = Instance.new('Part')
					laser_pointer.Shape = Enum.PartType.Ball
					laser_pointer.Size = Vector3.new(0.2, 0.2, 0.2)
					laser_pointer.CanCollide = false
					laser_pointer.Anchored = false
					laser_pointer.Color = part.Color
					laser_pointer.Material = Enum.Material.Neon
					laser_pointer.Parent = part

					local start_attachment = Instance.new('Attachment')
					start_attachment.Parent = part

					local end_attachment = Instance.new('Attachment')
					end_attachment.Parent = laser_pointer

					local laser_beam = Instance.new('Beam')
					laser_beam.Name = "Beam"
					laser_beam.Transparency = NumberSequence.new(0)
					laser_beam.LightEmission = 1
					laser_beam.LightInfluence = 1
					laser_beam.Attachment0 = start_attachment
					laser_beam.Attachment1 = end_attachment
					laser_beam.Color = ColorSequence.new(part.Color)
					laser_beam.FaceCamera = true
					laser_beam.Width0 = 0.01
					laser_beam.Width1 = 0.01
					laser_beam.Parent = laser_pointer

					if Config.RealisticLaser then
						laser_beam.Enabled = false
					end

					attachment_flags.Pointer = laser_pointer
					break
				end
			end
		end
	else
		for _, part in pairs(weapon_in_hand:GetDescendants()) do
			if part:IsA("BasePart") and part.Name == "LaserPoint" then
				part:ClearAllChildren()
				break
			end
		end
		attachment_flags.Pointer = nil

		if Config.ReplicatedLaser then
			Event.SVLaser:FireServer(nil, 2, nil, false, weapon_tool)
		end
	end
	
	if weapon_in_hand:FindFirstChild("Handle") and weapon_in_hand.Handle:FindFirstChild("Click") then
		weapon_in_hand.Handle.Click:play()
	end

	HUDController.UpdateGui()
end

function AttachmentController.ToggleFlashlight()
    local weapon_in_hand = WeaponRegistry.GetWeaponInHand()
    local weapon_tool = WeaponRegistry.GetWeaponTool()

	local attachment_flags = AttachmentManager.Flags
	attachment_flags.TorchActive = not attachment_flags.TorchActive

	for _, part in pairs(weapon_in_hand:GetDescendants()) do
		if part:IsA("BasePart") and part.Name == "FlashPoint" then
			part.Light.Enabled = attachment_flags.TorchActive
		end
	end

	Event.SVFlash:FireServer(weapon_tool, attachment_flags.TorchActive)
	weapon_in_hand.Handle.Click:play()
	HUDController.UpdateGui()
end

return AttachmentController