--[[
    PlayerStateManager.lua
    Created by @ddydddd9 - Moonlight

	Centralized character state manager for movement, stances, leaning,
	and weapon states plus etc... with modular reset functionality
]]

local PlayerStateManager = {
    -- Movement / Locomotion
    CharacterSpeed  = 0,        -- Current humanoid velocity magnitude
	IsRunning       = false,    -- Humanoid.Running speed > 0.1
	RunKeyDown      = false,    -- Shift held by the player
	IsMouseButton1Down = false,
	IsSteady        = false,    -- Toggle-walk (slow pace) active
	IsSitting       = false,    -- Humanoid seated on a non-vehicle seat
	IsSwimming      = false,    -- Humanoid in swimming state
	IsFalling       = false,    -- Humanoid in freefall state
	IsTired         = false,    -- Reserved / unused
	JumpDelay       = false,    -- Anti-bunny-hop cooldown flag

    -- Stances / Posture
	Stances         = 0,        -- 0 = standing, 1 = crouch, 2 = prone
	IsCrouched      = false,
	IsProned        = false,
	ChangeStance    = true,     -- False while dying; blocks stance changes

	-- Leaning
	LeanDirection   = 0,        -- -1 = left, 0 = none, 1 = right
	CanLean         = true,
	CameraX         = 0,        -- Horizontal camera offset (leaning)
	CameraY         = 0,        -- Vertical camera offset (crouch / prone)

	-- POV
	IsFirstPersonView = false,
	IsThirdPersonView = false,

	-- Weapon states
	IsReloading 	= false,
	IsCheckingAmmo 	= false
}

PlayerStateManager.PlayerSessionId = {}
PlayerStateManager.NVG = nil
PlayerStateManager.NVGdebounce = false


-- Movement / Locomotion
function PlayerStateManager:ResetMovement()
    self.CharacterSpeed  = 0
	self.IsRunning       = false
	self.RunKeyDown      = false
	self.IsMouseButton1Down = false
	self.IsSteady        = false
	self.IsSitting       = false
	self.IsSwimming      = false
	self.IsFalling       = false
	self.IsTired         = false
	self.JumpDelay       = false
end

-- Stances / Posture
function PlayerStateManager:ResetStances()
	self.Stances         = 0
	self.IsCrouched      = false
	self.IsProned        = false
	self.ChangeStance    = true
end

-- Leaning
function PlayerStateManager:ResetLeaning()
	self.LeanDirection   = 0
	self.CanLean         = true
	self.CameraX         = 0
	self.CameraY         = 0
end

-- POV
function PlayerStateManager:ResetPOV()
	self.IsFirstPersonView = false
	self.IsThirdPersonView = false
end

-- Weapon states
function PlayerStateManager:ResetWeapon()
	self.IsReloading 		 = false
	self.IsCheckingAmmo 	 = false
end

-- Reset All
function PlayerStateManager.Reset()
	PlayerStateManager:ResetMovement()
	PlayerStateManager:ResetStances()
	PlayerStateManager:ResetLeaning()
	PlayerStateManager:ResetPOV()
	PlayerStateManager:ResetWeapon()
end

return PlayerStateManager