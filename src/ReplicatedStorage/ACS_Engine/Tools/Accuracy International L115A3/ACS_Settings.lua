local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.4)
self.SlideLock 		= false

self.canAim 		= true
self.Zoom 			= 40
self.Zoom2 			= 10


self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= false
self.IncludeChamberedBullet = true
self.Ammo 			= 5
self.StoredAmmo 	= 210
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 210
self.CanCheckMag 	= true
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 99999
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 5				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = true;
	Burst = false;
	Auto = false;}

self.LimbDamage 	= {70,89}
self.TorsoDamage 	= {99,108} 
self.HeadDamage 	= {450,650} 
self.DamageFallOf 	= 1
self.MinDamage 		= 5
self.IgnoreProtection = true
self.BulletPenetration = 100

self.adsTime 		= 1.5

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= true

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {50,55}
	,camRecoilTilt 	= {70,87}
	,camRecoilLeft 	= {20,33}
	,camRecoilRight = {20,35}
}

self.gunRecoil = {
	gunRecoilUp 	= {100,115}
	,gunRecoilTilt 	= {50,99}
	,gunRecoilLeft 	= {50,99}
	,gunRecoilRight = {50,99}
}

self.AimRecoilReduction 		= 3
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

self.BulletType 				= ".338 Lapua Magnum SP"
self.MuzzleVelocity 			= 1002 --m/s
self.BulletDrop 				= .18 --Between 0 - 1
self.Tracer						= false
self.BulletFlare 				= false
self.TracerColor				= Color3.fromRGB(0,0,0)
self.RandomTracer				= {
	Enabled = false
	,Chance = 25 -- 0-100%
}
self.TracerEveryXShots			= 0
self.RainbowMode 				= false
self.InfraRed 					= false

self.CanBreak	= false
self.Jammed		= false

-- RCM Settings V

self.WeaponWeight		= 3-- Weapon weight must be enabled in the Config module

self.ShellEjectionMod	= true

self.Holster			= true
self.HolsterPoint		= "UpperTorso"
self.HolsterCFrame		= CFrame.new(0.65,0.1,-0.8) * CFrame.Angles(math.rad(-90),math.rad(15),math.rad(75))

self.FlashChance = 3 -- 0 = no muzzle flash, 10 = Always muzzle flash

self.ADSEnabled 		= { -- Ignore this setting if not using an ADS Mesh
	true, -- Enabled for primary sight
	true} -- Enabled for secondary sight (T)

self.ExplosiveAmmo		= false -- Enables explosive ammo
self.ExplosionRadius	= 70 -- Radius of explosion damage in studs
self.ExplosionType		= "Default" -- Which explosion effect is used from the HITFX Explosion folder
self.IsLauncher			= false -- For RPG style rocket launchers

self.EjectionOverride	= nil -- Don't touch unless you know what you're doing with Vector3s

return self