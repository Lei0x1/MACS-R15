--[[
    AITypes.lua

    Created by @ddydddd9 - Moonlight
]]

local AITypes = {}

AITypes.Types = {
    CQC = {
        Name                = "CQC",
        FireRate            = 400,
        LimbsDamage         = {45, 50},
        TorsoDamage         = {67, 72},
        HeadDamage          = {130, 140},
        FallOfDamage        = 1,
        BulletPenetration   = 65,
        RegularWalkspeed    = 12,
        SearchingWalkspeed  = 8,
        ShootingWalkspeed   = 4,
        Spread              = 4,
        MinDistance         = 100,
        MaxInc              = 16,
        Mode                = 2,
        Tracer              = true,
        TracerColor         = Color3.fromRGB(255,255,255),
        BulletFlare         = false,
        BulletFlareColor    = Color3.fromRGB(255,255,255),
    },

    Gunner = {
        Name                = "Gunner",
        FireRate            = 600,
        LimbsDamage         = {52, 54},
        TorsoDamage         = {70, 86},
        HeadDamage          = {140, 145},
        FallOfDamage        = 1,
        BulletPenetration   = 75,
        RegularWalkspeed    = 12,
        SearchingWalkspeed  = 8,
        ShootingWalkspeed   = 4,
        Spread              = 6,
        MinDistance         = 100,
        MaxInc              = 16,
        Mode                = 2,
        Tracer              = true,
        TracerColor         = Color3.fromRGB(255,255,255),
        BulletFlare         = false,
        BulletFlareColor    = Color3.fromRGB(255,255,255),
    },

    HMG = {
        Name                = "HMG",
        FireRate            = 650,
        LimbsDamage         = {57, 62},
        TorsoDamage         = {72, 87},
        HeadDamage          = {140, 145},
        FallOfDamage        = 1,
        BulletPenetration   = 78,
        RegularWalkspeed    = 0,
        SearchingWalkspeed  = 0,
        ShootingWalkspeed   = 0,
        Spread              = 5.5,
        MinDistance         = 100,
        MaxInc              = 16,
        Mode                = 3,
        Tracer              = true,
        TracerColor         = Color3.fromRGB(255,255,255),
        BulletFlare         = false,
        BulletFlareColor    = Color3.fromRGB(255,255,255),
    },

    Sniper = {
        Name                = "Sniper",
        FireRate            = 25,
        LimbsDamage         = {75, 90},
        TorsoDamage         = {125, 150},
        HeadDamage          = {350, 400},
        FallOfDamage        = 0.65,
        BulletPenetration   = 75,
        RegularWalkspeed    = 12,
        SearchingWalkspeed  = 6,
        ShootingWalkspeed   = 0,
        Spread              = 1,
        MinDistance         = 500,
        MaxInc              = 16,
        Mode                = 2,
        Tracer              = true,
        TracerColor         = Color3.fromRGB(255,255,255),
        BulletFlare         = false,
        BulletFlareColor    = Color3.fromRGB(255,255,255),
    },

    Unarmed = {
        Name                = "Unarmed",
        FireRate            = 1,
        LimbsDamage         = {0, 0},
        TorsoDamage         = {0, 0},
        HeadDamage          = {0, 0},
        FallOfDamage        = 1,
        BulletPenetration   = 65,
        RegularWalkspeed    = 16,
        SearchingWalkspeed  = 8,
        ShootingWalkspeed   = 4,
        Spread              = 4,
        MinDistance         = 100,
        MaxInc              = 16,
        Mode                = 0,
        Tracer              = true,
        TracerColor         = Color3.fromRGB(255,255,255),
        BulletFlare         = false,
        BulletFlareColor    = Color3.fromRGB(255,255,255),
    }
}

---------------------------------------------
--  Helper functions
---------------------------------------------

-- Get config by name
function AITypes.GetConfig(typename: string)
    return AITypes.Types[typename]
end

-- Get all type names
function AITypes.GetAllTypes()
    local types = {}
    
    for name, _ in pairs(AITypes.Types) do
        table.insert(types, name)
    end

    return types
end

return AITypes