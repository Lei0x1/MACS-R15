--[[
    HUDController
    Created by @ddydddd9 - Moonlight

    HUD display controller for weapon stats, attachments, and
    combat indicators with real-time state synchronization
]]

local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Engine = RS:WaitForChild("ACS_Engine")
local Modules = Engine:WaitForChild("Modules")

local WeaponModules = Modules:WaitForChild("Weapon")
local WeaponRegistry = require(WeaponModules:WaitForChild("WeaponRegistry"))
local WeaponState = require(WeaponModules:WaitForChild("WeaponState"))
local AttachmentManager = require(WeaponModules:WaitForChild("AttachmentManager"))

local HUDController = {}
HUDController.StatusGui = {}

function HUDController.UpdateGui()
    if not HUDController.StatusGui or not HUDController.StatusGui.GunHUD then return end

    local WeaponData = WeaponRegistry.GetWeaponData()
    if not WeaponData then return end

    local GunHUD = HUDController.StatusGui.GunHUD
    local attachment_flags = AttachmentManager.Flags

    -- Jam Indicator
    if WeaponData.Jammed then
        GunHUD.B.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    else
        GunHUD.B.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end

    -- SafeMode Indicator
    if WeaponState.SafeMode then
        GunHUD.A.Visible = true
    else
        GunHUD.A.Visible = false
    end

    -- Sensitivity display
    if WeaponState.IsAimming then
        GunHUD.Sens.Text = "ADS " .. (WeaponState.ADSSens / 100)
        GunHUD.Sens.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif WeaponState.IsHipFiring then
        GunHUD.Sens.Text = "Hip " .. (WeaponState.HipFireSens / 100)
        GunHUD.Sens.TextColor3 = Color3.fromRGB(255,150, 0)
    else
        GunHUD.Sens.Text = "Cam " .. (WeaponState.CameraSens / 100)
        GunHUD.Sens.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    -- Ammo indicator visibility
    if WeaponState.Ammo > 0 then
        GunHUD.B.Visible = true
    else
        GunHUD.B.Visible = false
    end

    -- Fire mode display
    if WeaponData.ShootType == 1 then
        GunHUD.FText.Text = "Semi"
    elseif WeaponData.ShootType == 2 then
        GunHUD.FText.Text = "Burst"
    elseif WeaponData.ShootType == 3 then
        GunHUD.FText.Text = "Auto"
    elseif WeaponData.ShootType == 4 then
        GunHUD.FText.Text = "Pump-Action"
    elseif WeaponData.ShootType == 5 then
        GunHUD.FText.Text = "Bolt-Action"
    end

    -- Weapon info
    GunHUD.BText.Text = WeaponData.BulletType
    GunHUD.NText.Text = WeaponData.gunName

    -- Zeroing display
    if WeaponData.EnableZeroing then
        GunHUD.ZeText.Visible = true
        GunHUD.ZeText.Text = WeaponData.CurrentZero .." m"
    else
        GunHUD.ZeText.Visible = false
    end

    if WeaponData.MagCount then
        GunHUD.SAText.Text = math.ceil(WeaponState.StoredAmmo / WeaponData.Ammo)
        GunHUD.Magazines.Visible = true
        GunHUD.Bullets.Visible = false
    else
        GunHUD.SAText.Text = WeaponState.StoredAmmo
        GunHUD.Magazines.Visible = false
        GunHUD.Bullets.Visible = true
    end

    if attachment_flags.Suppressor then
        GunHUD.Att.Silencer.Visible = true
    else
        GunHUD.Att.Silencer.Visible = false
    end

    if attachment_flags.LaserAtt then
        GunHUD.Att.Laser.Visible = true
        if attachment_flags.LaserActive then
            if attachment_flags.InfraredMode then
                TS:Create(GunHUD.Att.Laser, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(0,255,0), ImageTransparency = .123}):Play()
            else
                TS:Create(GunHUD.Att.Laser, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = .123}):Play()
            end
        else
            TS:Create(GunHUD.Att.Laser, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,0,0), ImageTransparency = .5}):Play()
        end
    else
        GunHUD.Att.Laser.Visible = false
    end

    if attachment_flags.HasBipodAttachment then
        GunHUD.Att.Bipod.Visible = true
    else
        GunHUD.Att.Bipod.Visible = false
    end

    if attachment_flags.TorchAtt then
        GunHUD.Att.Flash.Visible = true
        if attachment_flags.TorchActive then
            TS:Create(GunHUD.Att.Flash, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = .123}):Play()
        else
            TS:Create(GunHUD.Att.Flash, TweenInfo.new(.1,Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255,0,0), ImageTransparency = .5}):Play()
        end
    else
        GunHUD.Att.Flash.Visible = false
    end

    if WeaponData.Type == "Grenade" then
        HUDController.StatusGui.GrenadeForce.Visible = true
    else
        HUDController.StatusGui.GrenadeForce.Visible = false
    end
end

function HUDController.WeaponReset()
    HUDController.StatusGui.GunHUD.Visible = false
    HUDController.StatusGui.GrenadeForce.Visible = false
end

return HUDController