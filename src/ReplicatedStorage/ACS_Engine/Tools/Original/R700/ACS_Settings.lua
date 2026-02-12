local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.2)
self.SlideLock 		= false

self.canAim 		= true
self.Zoom 			= 60
self.Zoom2 			= 60

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 10
self.StoredAmmo 	= 30
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 70
self.CanCheckMag 	= true
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 800
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 5				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = false;
	Burst = false;
	Auto = false;}

self.LimbDamage 	= {75,90}
self.TorsoDamage 	= {100,125} 
self.HeadDamage 	= {300,300} 
self.DamageFallOf 	= .5
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 75

self.adsTime 		= 1

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= true

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {35,45}
	,camRecoilTilt 	= {100,100}
	,camRecoilLeft 	= {40,50}
	,camRecoilRight = {40,50}
}

self.gunRecoil = {
	gunRecoilUp 	= {150,175}
	,gunRecoilTilt 	= {25,50}
	,gunRecoilLeft 	= {75,150}
	,gunRecoilRight = {75,150}
}

self.AimRecoilReduction 		= 1
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= 1
self.MaxRecoilPower 			= 1
self.RecoilPowerStepAmount 		= 1

self.MinSpread 					= 0.25
self.MaxSpread 					= 100					
self.AimInaccuracyStepAmount 	= 5
self.AimInaccuracyDecrease 		= 1.5
self.WalkMult 					= 0

self.EnableZeroing 				= true
self.MaxZero 					= 1000
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= ".338 Lapua Magnum"
self.MuzzleVelocity 			= 2000 --m/s
self.BulletDrop 				= .5 --Between 0 - 1
self.Tracer						= true
self.BulletFlare 				= true
self.TracerColor				= Color3.fromRGB(255,255,255)
self.RandomTracer				= {
	Enabled = false
	,Chance = 25 -- 0-100%
}
self.TracerEveryXShots			= 0
self.RainbowMode 				= false
self.InfraRed 					= false

self.CanBreak	= true
self.Jammed		= false

return self