local TS = game:GetService('TweenService')
local Config = {}

--////////////////////////////////////////////////////////////
--// WEAPON INFO
--////////////////////////////////////////////////////////////

Config.gunName 		= script.Parent.Name
Config.Type 		= "Gun"
Config.EnableHUD	= true
Config.WeaponWeight	= 4 -- requires weight system enabled

--////////////////////////////////////////////////////////////
--// SLIDE / MECHANICAL
--////////////////////////////////////////////////////////////

Config.SlideEx 			= CFrame.new(0,0,-0.4)
Config.SlideLock 		= true
Config.CanBreak			= false
Config.Jammed			= false
Config.ShellEjectionMod	= true

--////////////////////////////////////////////////////////////
--// AIM / ZOOM
--////////////////////////////////////////////////////////////

Config.canAim   = true
Config.Zoom 	= 60
Config.Zoom2 	= 60
Config.adsTime 	= 1

Config.Sensitivity = {
	Camera 	= 35,
	HipFire = 40,
	ADS 	= 30
}

Config.AimBlur		 	= false		-- Enables aimblur
Config.ShootingBlur  	= true
Config.ShootingBlurSize = 8			-- value == nil then fallback value == 5

Config.ShootingBloom 	= true
Config.BloomSize 	 	= 20
Config.BloomThresh   	= 1.5

Config.ADSEnabled = { -- Ignore this setting if not using an ADS Mesh
	true, -- Enabled for primary sight
	false -- Enabled for secondary sight (T)
}

--////////////////////////////////////////////////////////////
--// AMMO SYSTEM
--////////////////////////////////////////////////////////////

Config.IncludeChamberedBullet = true

Config.Ammo 		 = 30
Config.StoredAmmo 	 = 240
Config.AmmoInGun 	 = Config.Ammo
Config.MaxStoredAmmo = 180

Config.CanCheckMag 		= true
Config.MagCount			= true
Config.ShellInsert		= false
Config.EjectionOverride	= nil -- Don't touch unless you know what you're doing with Vector3s

--////////////////////////////////////////////////////////////
--// EXPLOSIVE / LAUNCHER
--////////////////////////////////////////////////////////////

Config.ExplosiveAmmo	= false 	-- Enables explosive ammo
Config.ExplosionRadius	= 70 		-- Radius of explosion damage in studs
Config.ExplosionType	= "Default" -- Which explosion effect is used from the HITFX Explosion folder
Config.IsLauncher		= false 	-- For RPG style rocket launchers

--////////////////////////////////////////////////////////////
--// FIRE CONTROL
--////////////////////////////////////////////////////////////
-- 1 = Semi
-- 2 = Burst
-- 3 = Auto
-- 4 = Pump Action
-- 5 = Bolt Action

Config.ShootType 	= 3
Config.ShootRate 	= 800
Config.Bullets 		= 1
Config.BurstShot 	= 3

Config.FireModes = {
	ChangeFiremode = true,
	Semi 		   = true,
	Burst 		   = false,
	Auto 		   = true,
}

--////////////////////////////////////////////////////////////
--// DAMAGE
--////////////////////////////////////////////////////////////

Config.LimbDamage 	= {20, 30}
Config.TorsoDamage 	= {30, 40}
Config.HeadDamage 	= {150, 150}

Config.DamageFallOf 	= 1
Config.MinDamage 		= 5
Config.IgnoreProtection = false
Config.BulletPenetration = 72

--////////////////////////////////////////////////////////////
--// RECOIL
--////////////////////////////////////////////////////////////

Config.camRecoil = {
	camRecoilUp 	= {5,10}
	,camRecoilTilt 	= {10,15}
	,camRecoilLeft 	= {7,10}
	,camRecoilRight = {6,9}
}

Config.gunRecoil = {
	gunRecoilUp 	= {20,25}
	,gunRecoilTilt 	= {10,20}
	,gunRecoilLeft 	= {15,20}
	,gunRecoilRight = {15,20}
}

Config.AimRecoilReduction 		= 4
Config.AimSpreadReduction 		= 1

Config.MinRecoilPower 			= .5
Config.MaxRecoilPower 			= 1.5
Config.RecoilPowerStepAmount 		= .1

--////////////////////////////////////////////////////////////
--// SPREAD / ACCURACY
--////////////////////////////////////////////////////////////

Config.MinSpread 					= 0.75
Config.MaxSpread 					= 100					
Config.AimInaccuracyStepAmount 	= 0.75
Config.AimInaccuracyDecrease 		= .25
Config.WalkMult 					= 0

--////////////////////////////////////////////////////////////
--// CROSSHAIR / UI
--////////////////////////////////////////////////////////////

Config.CrossHair 		= false
Config.CenterDot 		= true
Config.CrosshairOffset	= 1
Config.CanBreachDoor 	= false
Config.FlashChance 		= 10 -- 0 = no muzzle flash, 10 = Always muzzle flash

Config.LensDarkenIntensity = 0 -- 0 = very strong 1 = transparent
Config.LensDarkenSpeed = 0.01 -- Don't change this

--////////////////////////////////////////////////////////////
--// ATTACHMENTS
--////////////////////////////////////////////////////////////

Config.SightAtt 		= ""
Config.BarrelAtt		= ""
Config.UnderBarrelAtt 	= ""
Config.OtherAtt 		= ""

--////////////////////////////////////////////////////////////
--// ZEROING
--////////////////////////////////////////////////////////////

Config.EnableZeroing 	= true
Config.MaxZero 			= 500
Config.ZeroIncrement 	= 50
Config.CurrentZero 		= 0

--////////////////////////////////////////////////////////////
--// HOLSTER
--////////////////////////////////////////////////////////////

Config.Holster			= true
Config.HolsterPoint		= "UpperTorso"
Config.HolsterCFrame	= CFrame.new(0.65,0.1,-0.8) * CFrame.Angles(math.rad(-90),math.rad(15),math.rad(75))

--////////////////////////////////////////////////////////////
--// BALLISTICS
--////////////////////////////////////////////////////////////

Config.BulletType 			= "5.56x45mm"
Config.MuzzleVelocity 		= 914 --m/s
Config.BulletDrop 			= .25 --Between 0 - 1

Config.Tracer				= true
Config.TracerDelay			= 0
Config.TracerColor		 	= Color3.fromRGB(255,63,63)
Config.TracerWidth 			= 0.05
Config.TracerLifeTime		= 0.04
Config.TracerLightEmission  = 1
Config.TracerLightInfluence = 0
Config.TracerEveryXShots 	= 1
Config.TracerStyle			= "Full"
Config.TracerTexture		= "rbxassetid://232918622"
Config.TracerLight 			= false
Config.TracerLightBrightness= 3
Config.TracerLightRange		= 10

Config.RandomTracer			= {
	Enabled = false, 		-- Wont work when Tracer is Off
	Chance = 25 			-- 0-100%
}

Config.BulletFlare 			= true
Config.BulletFlareProperties = {
	-- BillboardGui
	LightInfluence = 0,
	FlareSize = 4,
	-- Flash
	FlashSize = 1,
	FlashColor = Color3.fromRGB(255,63,63),
	FlashImage = "rbxassetid://1047066405",
	FlashTransparency = 0.6,
	-- Glow
	GlowSize = 1.5,
	GlowImage = "rbxassetid://1047066405",
	GlowTransparency = 0.5
}

Config.RainbowMode 			= false
Config.InfraRed 			= false

return Config