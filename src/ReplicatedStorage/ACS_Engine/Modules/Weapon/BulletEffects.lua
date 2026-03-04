--[[
    BulletEffects.lua
    Created by @ddydddd9 - Moonlight

    Visual effects module for bullet tracers and muzzle flares with dynamic camera-based scaling
]]

local BulletEffects = {}

local Run = game:GetService("RunService")
local CurrentCamera = workspace.CurrentCamera

local Distance = {
    [Enum.FieldOfViewMode.Vertical.Name] = function()
        return CurrentCamera.ViewportSize.Y, CurrentCamera.FieldOfView
    end,

    [Enum.FieldOfViewMode.Diagonal.Name] = function()
		return CurrentCamera.ViewportSize.Magnitude, CurrentCamera.DiagonalFieldOfView
	end,
	
	[Enum.FieldOfViewMode.MaxAxis.Name] = function()
		local view_port_size = CurrentCamera.ViewportSize
		return math.max(view_port_size.X, view_port_size.Y), CurrentCamera.MaxAxisFieldOfView
	end,
}

function BulletEffects.Tracer(
    bullet,
    color,
    width,
    life,
    light_emit,
    light_influence,
    tracer_style,
    texture,
    light,
    light_brightness,
    light_range
)
    local bullet_att1 = Instance.new("Attachment")
    bullet_att1.Name = "At1"
    bullet_att1.Position = Vector3.new(-(width), 0, 0)

    local bullet_att2  = Instance.new("Attachment")
    bullet_att2.Name = "At2"
    bullet_att2.Position = Vector3.new((width), 0, 0)

    local bullet_trail = Instance.new("Trail")
    if tracer_style == "Full" then
        bullet_trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0);
            NumberSequenceKeypoint.new(1, 0);
        })
        bullet_trail.WidthScale = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5);
            NumberSequenceKeypoint.new(0.25, 1);
            NumberSequenceKeypoint.new(0.75, 1);
            NumberSequenceKeypoint.new(1, 0.5);
        })
    else
        bullet_trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0);
            NumberSequenceKeypoint.new(1, 1);
        })
        bullet_trail.WidthScale = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1);
            NumberSequenceKeypoint.new(1, 0.5);
        })
    end

    bullet_trail.Texture = texture or "rbxassetid://232918622" --"rbxassetid://4107607856"
    bullet_trail.TextureMode = Enum.TextureMode.Stretch
    bullet_trail.Color = ColorSequence.new(color)

    bullet_trail.FaceCamera = true
    bullet_trail.LightEmission = light_emit -- 1
    bullet_trail.LightInfluence = light_influence -- 0 
    bullet_trail.Lifetime = life -- 0.25
    bullet_trail.Attachment0 = bullet_att1
    bullet_trail.Attachment1 = bullet_att2

    local bullet_beam = Instance.new("Beam")
    bullet_beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0);
        NumberSequenceKeypoint.new(1, 0);
    })
    bullet_beam.Texture = texture or "rbxassetid://232918622" --"rbxassetid://4107607856"
    bullet_beam.TextureMode = Enum.TextureMode.Stretch
    bullet_beam.Color = ColorSequence.new(color)
    bullet_beam.TextureSpeed = 0
    bullet_beam:SetTextureOffset(0)
    
    bullet_beam.FaceCamera = true
    bullet_beam.LightEmission = light_emit
    bullet_beam.LightInfluence = light_influence
    bullet_beam.Attachment0 = bullet_att1
    bullet_beam.Attachment1 = bullet_att2
    bullet_beam.Width0 = width * 2
    bullet_beam.Width1 = width * 2
    
    bullet_att1.Parent = bullet
    bullet_att2.Parent = bullet
    bullet_trail.Parent = bullet
    bullet_beam.Parent = bullet
    bullet_beam.Enabled = true

    if light and light_range then
        local bullet_light = Instance.new("PointLight")
        bullet_light.Brightness = light_brightness
        bullet_light.Color = color
        bullet_light.Range = light_range
        bullet_light.Shadows = false
        bullet_light.Parent = bullet
    end

    local tracer_update_connection
    tracer_update_connection = Run.RenderStepped:Connect(function()
        if bullet and bullet:IsDescendantOf(workspace) then
            local distance_from_camera = (bullet.Position - CurrentCamera.CFrame.Position).Magnitude
            local screen_pixel, field_of_view = Distance[CurrentCamera.FieldOfViewMode.Name]()
            local fov_scale_factor = math.tan(math.rad(field_of_view))

            local scaled_width = width + distance_from_camera * fov_scale_factor / screen_pixel * math.sqrt(width * 4)
            bullet_att1.Position = Vector3.new(scaled_width, 0, 0)
            bullet_att2.Position = Vector3.new(-scaled_width, 0, 0)
            bullet_beam.Width0 = scaled_width * 2
            bullet_beam.Width1 = scaled_width * 2
        else
            tracer_update_connection:Disconnect()
        end
    end)
end

function BulletEffects.BulletFlare(
    bullet,
    flare_color,
    flare_size,
    flare_light_influence,
    flash_size,
    flash_image,
    flash_transparency,
    glow_size,
    glow_image,
    glow_transparency
)
    local billboard_gui = Instance.new("BillboardGui")
    billboard_gui.Name = "BulletBillboardGui"
    billboard_gui.Adornee = bullet
    billboard_gui.LightInfluence = flare_light_influence
    billboard_gui.AlwaysOnTop = false
    billboard_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboard_gui.Size = UDim2.fromScale(flare_size, flare_size)

    local flash = Instance.new("ImageLabel")
    flash.Name = "BulletFlash"
    flash.BackgroundTransparency = 1
    flash.Size = UDim2.fromScale(flash_size, flash_size)
    flash.Position = UDim2.new(0, 0, 0, 0)
    flash.Image = flash_image

    local color_variation = math.random(80, 120) / 100
    flash.ImageColor3 = Color3.new(
        math.min(1, flare_color.r * color_variation),
        math.min(1, flare_color.g * color_variation),
        math.min(1, flare_color.b * color_variation)
    )
    
    flash.ImageTransparency = flash_transparency

    local glow = Instance.new("ImageLabel")
    glow.Name = "BulletGlow"
    glow.BackgroundTransparency = 1
    glow.Size = UDim2.fromScale(glow_size, glow_size)
    glow.Position = UDim2.fromScale(-0.25, -0.25)
    glow.Image = glow_image
    glow.ImageColor3 = flare_color
    glow.ImageTransparency = glow_transparency
    glow.ZIndex = 0

    glow.Parent = flash
    flash.Parent = billboard_gui
    billboard_gui.Parent = bullet
    
    task.delay(0.1, function()
        billboard_gui.Enabled = true
    end)

    local start_time = tick()
    local update_bullet_flare

    update_bullet_flare = Run.Heartbeat:Connect(function()
        if not bullet or not bullet.Parent then
            update_bullet_flare:Disconnect()
            return
        end

        local elapsed = tick() - start_time
        local life_ratio = math.max(0, 1 - (elapsed / 0.15))

        if life_ratio <= 0 then
            if billboard_gui then
                billboard_gui:Destroy()
            end

            update_bullet_flare:Disconnect()
            return
        end

        local current_size = flash_size * life_ratio
        billboard_gui.Size = UDim2.fromScale(current_size, current_size)

        flash.ImageTransparency = flash_transparency + (0.8 * (1 - life_ratio))
        if glow then
            glow.ImageTransparency = glow_transparency + (0.4 * (1 - life_ratio))
        end
    end)
end

return BulletEffects