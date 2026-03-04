local TS = game:GetService('TweenService')
local Config = {}

--////////////////////////////////////////////////////////////
--// WEAPON INFO
--////////////////////////////////////////////////////////////

Config.gunName 		= script.Parent.Name
Config.Type 		= "Gun"
Config.EnableHUD	= true
Config.WeaponWeight = 4 -- requires weight system enabled

--////////////////////////////////////////////////////////////
--// SLIDE / MECHANICAL
--////////////////////////////////////////////////////////////

Config.SlideEx 			= CFrame.new(0,0,-0.4)
Config.SlideLock 		= true
Config.CanBreak			= true
Config.Jammed			= false
Config.ShellEjectionMod = true

--////////////////////////////////////////////////////////////
--// AIM / ZOOM
--////////////////////////////////////////////////////////////

Config.canAim 		= true
Config.Zoom 			= 60
Config.Zoom2 			= 60
Config.adsTime 		= 1

Config.Sensitivity = {
	Camera 	= 35,
	HipFire = 40,
	ADS 	= 30
}

Config.ShootingBlur  = 8
Config.ShootingBloom = true
Config.BloomSize 	 = 20
Config.BloomThresh   = 1.5

Config.ADSEnabled = {
	-- Ignore this setting if not using an ADS Mesh
	true, -- Enabled for primary sight
	false -- Enabled for secondary sight (T)
}

--////////////////////////////////////////////////////////////
--// AMMO SYSTEM
--////////////////////////////////////////////////////////////

Config.IncludeChamberedBullet = true

Config.Ammo 			= 30
Config.StoredAmmo 	= 90
Config.AmmoInGun 		= Config.Ammo
Config.MaxStoredAmmo	= 210

Config.CanCheckMag 	= true
Config.MagCount		= true
Config.ShellInsert	= false

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

Config.LimbDamage 	= {35,40}
Config.TorsoDamage 	= {57,62}
Config.HeadDamage 	= {150,150}

Config.DamageFallOf 	= 1
Config.MinDamage 		= 5
Config.IgnoreProtection = false
Config.BulletPenetration = 72

--////////////////////////////////////////////////////////////
--// RECOIL
--////////////////////////////////////////////////////////////

Config.camRecoil = {
	camRecoilUp 	= {12,15}
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
Config.RecoilPowerStepAmount 	= .1

--////////////////////////////////////////////////////////////
--// SPREAD / ACCURACY
--////////////////////////////////////////////////////////////

Config.MinSpread 					= 0.75
Config.MaxSpread 					= 100
Config.AimInaccuracyStepAmount 		= 0.75
Config.AimInaccuracyDecrease 		= .25
Config.WalkMult 					= 0

--////////////////////////////////////////////////////////////
--// CROSSHAIR / UI
--////////////////////////////////////////////////////////////

Config.CrossHair 		= false
Config.CenterDot 		= true
Config.CrosshairOffset	= 0
Config.CanBreachDoor 	= false
Config.FlashChance		= 0 -- 0 = no muzzle flash, 10 = Always muzzle flash

--////////////////////////////////////////////////////////////
--// ATTACHMENTS
--////////////////////////////////////////////////////////////

Config.SightAtt 		= ""
Config.BarrelAtt		= ""
Config.UnderBarrelAtt 	= ""
Config.OtherAtt 		= ""

--////////////////////////////////////////////////////////////
--// HOLSTER
--////////////////////////////////////////////////////////////
Config.Holster 		 = true
Config.HolsterPoint  = "UpperTorso"
Config.HolsterCFrame = CFrame.new(0.65,0.1,-0.8)
	* CFrame.Angles(
		math.rad(-90),
		math.rad(15),
		math.rad(75)
	)

--////////////////////////////////////////////////////////////
--// ZEROING
--////////////////////////////////////////////////////////////

Config.EnableZeroing 				= true
Config.MaxZero 					= 500
Config.ZeroIncrement 				= 50
Config.CurrentZero 				= 0

--////////////////////////////////////////////////////////////
--// BALLISTICS
--////////////////////////////////////////////////////////////

Config.BulletType 				= "5.56x45mm"
Config.MuzzleVelocity 			= 1500 --m/s
Config.BulletDrop 				= .25 --Between 0 - 1

Config.Tracer					= true
Config.BulletFlare 				= false
Config.TracerColor				= Color3.fromRGB(255,255,255)
Config.TracerEveryXShots		= 3
Config.RainbowMode 				= false
Config.InfraRed 				= true

Config.RandomTracer				= {
	Enabled = false
	,Chance = 25 -- 0-100%
}

--////////////////////////////////////////////////////////////
--// ADVANCED OVERRIDES
--////////////////////////////////////////////////////////////

Config.EjectionOverride = nil -- Do not modify unless handling custom Vector3 logic

return Config