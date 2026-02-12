local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.4)
self.SlideLock 		= false

self.canAim 		= true
self.Zoom 			= 60
self.Zoom2 			= 30

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 1
self.StoredAmmo 	= 3
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 3
self.CanCheckMag 	= false
self.MagCount		= true
self.ShellInsert	= true
self.ShootRate 		= 800
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 1				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = true;
	Burst = false;
	Auto = true;}

self.LimbDamage 	= {300,300}
self.TorsoDamage 	= {300,300}
self.HeadDamage 	= {300,300} 
self.DamageFallOf 	= 1
self.MinDamage 		= 5
self.IgnoreProtection = true
self.BulletPenetration = 72

self.adsTime 		= 1

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
	,camRecoilLeft 	= {0,0}
	,camRecoilRight = {0,0}
}

self.gunRecoil = {
	gunRecoilUp 	= {0,0}
	,gunRecoilTilt 	= {0,0}
	,gunRecoilLeft 	= {0,0}
	,gunRecoilRight = {0,0}
}

self.AimRecoilReduction 		= 4
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= 0
self.MaxRecoilPower 			= 0
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
self.MuzzleVelocity 			= 300 --m/s
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

self.WeaponWeight		= 6 -- Weapon weight must be enabled in the Config module

self.ShellEjectionMod	= false

self.Holster			= true
self.HolsterPoint		= "UpperTorso"
self.HolsterCFrame		= CFrame.new(0.8,1,0.9) * CFrame.Angles(math.rad(-90),math.rad(180),math.rad(10))

self.FlashChance 		= 10 -- 10 = Always muzzle flash, 0 = no muzzle flash

self.ADSEnabled 		= { -- Ignore this setting if not using an ADS Mesh
						true, -- Enabled for primary sight
						false} -- Enabled for secondary sight (T)

self.ExplosiveAmmo		= true -- Enables explosive ammo
self.ExplosionRadius	= 70 -- Radius of explosion damage in studs
self.ExplosionType		= "Default" -- Which explosion effect is used from the HITFX Explosion folder
self.IsLauncher			= true -- For RPG style rocket launchers

self.EjectionOverride	= nil -- Don't touch unless you know what you're doing with Vector3s

return self