local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.4)
self.SlideLock 		= true

self.canAim 		= true
self.Zoom 			= 60
self.Zoom2 			= 60

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 30
self.StoredAmmo 	= 30
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 180
self.CanCheckMag 	= true
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 800
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 3				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = true;		
	Semi = true;
	Burst = false;
	Auto = true;}

self.LimbDamage 	= {20,30}
self.TorsoDamage 	= {30,40} 
self.HeadDamage 	= {150,150} 
self.DamageFallOf 	= 1
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 72

self.adsTime 		= 1
self.Sensitivity = {
	Camera = 35,
	HipFire = 40,
	ADS = 30
}

self.CrossHair 		= false
self.CenterDot 		= true
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {5,10}
	,camRecoilTilt 	= {10,15}
	,camRecoilLeft 	= {7,10}
	,camRecoilRight = {6,9}
}

self.gunRecoil = {
	gunRecoilUp 	= {20,25}
	,gunRecoilTilt 	= {10,20}
	,gunRecoilLeft 	= {15,20}
	,gunRecoilRight = {15,20}
}

self.AimRecoilReduction 		= 4
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= .5
self.MaxRecoilPower 			= 1.5
self.RecoilPowerStepAmount 		= .1

self.MinSpread 					= 0.75
self.MaxSpread 					= 100					
self.AimInaccuracyStepAmount 	= 0.75
self.AimInaccuracyDecrease 		= .25
self.WalkMult 					= 0

self.EnableZeroing 				= true
self.MaxZero 					= 500
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= "5.56x45mm"
self.MuzzleVelocity 			= 914 --m/s
self.BulletDrop 				= .25 --Between 0 - 1
self.Tracer						= true
self.BulletFlare 				= false
self.TracerColor				= Color3.fromRGB(255,255,255)
self.RandomTracer				= {
	Enabled = false
	,Chance = 25 -- 0-100%
}
self.TracerEveryXShots			= 3
self.RainbowMode 				= false
self.InfraRed 					= false

self.CanBreak	= false
self.Jammed		= false

-- RCM Settings V

self.WeaponWeight		= 4 -- Weapon weight must be enabled in the Config module

self.ShellEjectionMod	= true

self.Holster			= true
self.HolsterPoint		= "UpperTorso"
self.HolsterCFrame		= CFrame.new(0.65,0.1,-0.8) * CFrame.Angles(math.rad(-90),math.rad(15),math.rad(75))

self.FlashChance = 0 -- 0 = no muzzle flash, 10 = Always muzzle flash

self.ADSEnabled 		= { -- Ignore this setting if not using an ADS Mesh
	true, -- Enabled for primary sight
	false} -- Enabled for secondary sight (T)

self.ExplosiveAmmo		= false -- Enables explosive ammo
self.ExplosionRadius	= 70 -- Radius of explosion damage in studs
self.ExplosionType		= "Default" -- Which explosion effect is used from the HITFX Explosion folder
self.IsLauncher			= false -- For RPG style rocket launchers

self.EjectionOverride	= nil -- Don't touch unless you know what you're doing with Vector3s

return self