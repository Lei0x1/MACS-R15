local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.3)
self.SlideLock 		= true

self.canAim 		= true
self.Zoom 			= 70
self.Zoom2 			= 90

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 17
self.StoredAmmo 	= 51
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 51
self.CanCheckMag 	= true
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 1400
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 1				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = false;
	Burst = false;
	Auto = false;}

self.LimbDamage 	= {12,26}
self.TorsoDamage 	= {24,38} 
self.HeadDamage 	= {120,120} 
self.DamageFallOf 	= 2
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 40

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {0,0}
	,camRecoilTilt 	= {0,0}
	,camRecoilLeft 	= {5,8}
	,camRecoilRight = {5,8}
}

self.gunRecoil = {
	gunRecoilUp 	= {110,120}
	,gunRecoilTilt 	= {25,40}
	,gunRecoilLeft 	= {10,15}
	,gunRecoilRight = {10,15}
}

self.AimRecoilReduction 		= 1
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= 1
self.MaxRecoilPower 			= 1.5
self.RecoilPowerStepAmount 		= .1

self.MinSpread 					= 5
self.MaxSpread 					= 50					
self.AimInaccuracyStepAmount 	= 5.75
self.AimInaccuracyDecrease 		= 1
self.WalkMult 					= 0

self.EnableZeroing 				= false
self.MaxZero 					= 500
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= "9x19mm"
self.MuzzleVelocity 			= 375 --m/s
self.BulletDrop 				= .25 --Between 0 - 1
self.Tracer						= false
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

self.WeaponWeight		= 0 -- Weapon weight must be enabled in the Config module

self.ShellEjectionMod	= true

self.Holster			= true
self.HolsterPoint		= "RightUpperLeg"
self.HolsterCFrame 		= CFrame.new(0.65,0.8,0.2) * CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))

self.FlashChance = 3 -- 0 = no muzzle flash, 10 = Always muzzle flash

self.ADSEnabled 		= { -- Ignore this setting if not using an ADS Mesh
	true, -- Enabled for primary sight
	false} -- Enabled for secondary sight (T)

self.ExplosiveAmmo		= false -- Enables explosive ammo
self.ExplosionRadius	= 70 -- Radius of explosion damage in studs
self.ExplosionType		= "Default" -- Which explosion effect is used from the HITFX Explosion folder
self.IsLauncher			= false -- For RPG style rocket launchers

self.EjectionOverride	= nil -- Don't touch unless you know what you're doing with Vector3s

return self