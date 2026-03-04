--[[
    CrosshairController.lua
    Created by @ddydddd9 - Moonlight

    Crosshair controller managing dynamic weapon reticle positioning, color changes, and aiming states
]]

local CrosshairController = {}

local TS = game:GetService("TweenService")

-- Module state
local CrosshairElements = {}
local CurrentWeaponData = nil
local IsAimming = false
local PlayerMouse = nil
local Humanoid = nil

-- Tween animations
local CrosshairTweens = {
    Up = nil,
    Down = nil,
    Left = nil,
    Right = nil,
    Center = nil
}

-- CrosshairController positions
local CrosshairPositions = {
    Up = UDim2.new(),
    Down = UDim2.new(),
    Left = UDim2.new(),
    Right = UDim2.new()
}

local CROSSHAIR_TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Linear)

function CrosshairController:Initialize(crosshair_gui, mouse, humanoid)
    CrosshairElements = {
        Up = crosshair_gui:FindFirstChild("Up"),
        Down = crosshair_gui:FindFirstChild("Down"),
        Left = crosshair_gui:FindFirstChild("Left"),
        Right = crosshair_gui:FindFirstChild("Right"),
        Center = crosshair_gui:FindFirstChild("Center"),
        Container = crosshair_gui
    }

    PlayerMouse = mouse
    Humanoid = humanoid

    self:Reset()
end

function CrosshairController:CreateTweens()
    if not CrosshairElements.Up then return end

    CrosshairTweens.Up = TS:Create(CrosshairElements.Up, CROSSHAIR_TWEEN_INFO, {BackgroundTransparency = 0})
	CrosshairTweens.Down = TS:Create(CrosshairElements.Down, CROSSHAIR_TWEEN_INFO, {BackgroundTransparency = 0})
	CrosshairTweens.Left = TS:Create(CrosshairElements.Left, CROSSHAIR_TWEEN_INFO, {BackgroundTransparency = 0})
	CrosshairTweens.Right = TS:Create(CrosshairElements.Right, CROSSHAIR_TWEEN_INFO, {BackgroundTransparency = 0})
	CrosshairTweens.Center = TS:Create(CrosshairElements.Center, CROSSHAIR_TWEEN_INFO, {ImageTransparency = 0})
end

function CrosshairController:UpdateWeaponData(weapon_data)
    CurrentWeaponData = weapon_data

    if not CurrentWeaponData or not CrosshairElements.Up then return end

    if CurrentWeaponData.CrossHair then
        self:ShowCrosshairElements()
    else
        self:HideCrosshairElements()
    end

    if CurrentWeaponData.CenterDot then
        CrosshairElements.Center.ImageTransparency = 0
    else
        CrosshairElements.Center.ImageTransparency = 1
    end

    if CurrentWeaponData.Bullets > 1 then
        CrosshairElements.Up.Rotation = 90
        CrosshairElements.Down.Rotation = 90
        CrosshairElements.Left.Rotation = 90
        CrosshairElements.Right.Rotation = 90
    else
        CrosshairElements.Up.Rotation = 0
        CrosshairElements.Down.Rotation = 0
        CrosshairElements.Left.Rotation = 0
        CrosshairElements.Right.Rotation = 0
    end
end

function CrosshairController:ShowCrosshairElements()
    if not CrosshairElements.Up then return end
	
	TS:Create(CrosshairElements.Up, CROSSHAIR_TWEEN_INFO, {BackgroundTransparency = 0}):Play()
	TS:Create(CrosshairElements.Down, CROSSHAIR_TWEEN_INFO, {BackgroundTransparency = 0}):Play()
	TS:Create(CrosshairElements.Left, CROSSHAIR_TWEEN_INFO, {BackgroundTransparency = 0}):Play()
	TS:Create(CrosshairElements.Right, CROSSHAIR_TWEEN_INFO, {BackgroundTransparency = 0}):Play()
end

function CrosshairController:HideCrosshairElements()
    if not CrosshairElements.Up then return end

    TS:Create(CrosshairElements.Up, CROSSHAIR_TWEEN_INFO, {BackgroundTransparency = 1}):Play()
	TS:Create(CrosshairElements.Down, CROSSHAIR_TWEEN_INFO, {BackgroundTransparency = 1}):Play()
	TS:Create(CrosshairElements.Left, CROSSHAIR_TWEEN_INFO, {BackgroundTransparency = 1}):Play()
	TS:Create(CrosshairElements.Right, CROSSHAIR_TWEEN_INFO, {BackgroundTransparency = 1}):Play()
	TS:Create(CrosshairElements.Center, CROSSHAIR_TWEEN_INFO, {ImageTransparency = 1}):Play()
end

function CrosshairController:ShowCenterDot()
    if not CrosshairElements.Center then return end
	TS:Create(CrosshairElements.Center, CROSSHAIR_TWEEN_INFO, {ImageTransparency = 0}):Play()
end

function CrosshairController:HideCenterDot()
	if not CrosshairElements.Center then return end
	TS:Create(CrosshairElements.Center, CROSSHAIR_TWEEN_INFO, {ImageTransparency = 1}):Play()
end

function CrosshairController:SetAimingState(aiming)
    IsAimming = aiming

    if aiming then
        self:HideCrosshairElements()
        self:HideCenterDot()
    elseif CurrentWeaponData then
        if CurrentWeaponData.CrossHair then
            self:ShowCrosshairElements()
        end

        if CurrentWeaponData.CenterDot then
            self:ShowCenterDot()
        end
    end
end

function CrosshairController:UpdateColor()
    if not CrosshairElements.Center or not PlayerMouse or not Humanoid then
        return
    end

    local mouse_target = PlayerMouse.Target
    local target_humanoid = nil

    if mouse_target then
        target_humanoid = mouse_target.Parent:FindFirstChildOfClass("Humanoid") or (mouse_target.Parent.Parent and mouse_target.Parent.Parent:FindFirstChildOfClass("Humanoid"))
    end

    if target_humanoid and target_humanoid ~= Humanoid then
        -- Red on enemy
		CrosshairElements.Center.ImageColor3 = Color3.fromRGB(255, 0, 0)
		CrosshairElements.Up.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		CrosshairElements.Down.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		CrosshairElements.Left.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		CrosshairElements.Right.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	else
		-- White normally
		CrosshairElements.Center.ImageColor3 = Color3.fromRGB(255, 255, 255)
		CrosshairElements.Up.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		CrosshairElements.Down.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		CrosshairElements.Left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		CrosshairElements.Right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end
end

function CrosshairController:UpdatePosition(mouse_x, mouse_y, current_spread, character_speed)
    if not CrosshairElements.Container or not CurrentWeaponData then return end

    CrosshairElements.Container.Position = UDim2.fromOffset(mouse_x, mouse_y)

    if IsAimming then
        -- Center crosshair when aiming
		CrosshairPositions.Up = CrosshairPositions.Up:Lerp(UDim2.fromScale(0.5, 0.5), 0.2)
		CrosshairPositions.Down = CrosshairPositions.Down:Lerp(UDim2.fromScale(0.5, 0.5), 0.2)
		CrosshairPositions.Left = CrosshairPositions.Left:Lerp(UDim2.fromScale(0.5, 0.5), 0.2)
		CrosshairPositions.Right = CrosshairPositions.Right:Lerp(UDim2.fromScale(0.5, 0.5), 0.2)
	elseif CurrentWeaponData.CrossHair then
		-- Calculate spread-based offset
		local normalized = ((CurrentWeaponData.CrosshairOffset + current_spread + character_speed) / 50) / 10
		
		CrosshairPositions.Up = CrosshairPositions.Up:Lerp(UDim2.fromScale(0.5, 0.5 - normalized), 0.5)
		CrosshairPositions.Down = CrosshairPositions.Down:Lerp(UDim2.fromScale(0.5, 0.5 + normalized), 0.5)
		CrosshairPositions.Left = CrosshairPositions.Left:Lerp(UDim2.fromScale(0.5 - normalized, 0.5), 0.5)
		CrosshairPositions.Right = CrosshairPositions.Right:Lerp(UDim2.fromScale(0.5 + normalized, 0.5), 0.5)
    end

	CrosshairElements.Up.Position = CrosshairPositions.Up
	CrosshairElements.Down.Position = CrosshairPositions.Down
	CrosshairElements.Left.Position = CrosshairPositions.Left
	CrosshairElements.Right.Position = CrosshairPositions.Right
end

function CrosshairController:Reset()
    if not CrosshairElements.Up then return end

    CrosshairPositions.Up = UDim2.fromScale(0.5, 0.5)
	CrosshairPositions.Down = UDim2.fromScale(0.5, 0.5)
	CrosshairPositions.Left = UDim2.fromScale(0.5, 0.5)
	CrosshairPositions.Right = UDim2.fromScale(0.5, 0.5)

    self:HideCrosshairElements()
    self:HideCenterDot()

    IsAimming = false
    CurrentWeaponData = nil
end

function CrosshairController:Destroy()
    self:Reset()

    CrosshairElements = {}
    CrosshairPositions = {}
    CurrentWeaponData = nil
    PlayerMouse = nil
    Humanoid = nil
end

return CrosshairController