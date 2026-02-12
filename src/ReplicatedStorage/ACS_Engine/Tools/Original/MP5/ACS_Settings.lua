local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.3)
self.SlideLock 		= false

self.canAim 		= true
self.Zoom 			= 60
self.Zoom2 			= 60

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 30
self.StoredAmmo 	= 90
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 210
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

self.LimbDamage 	= {18,22}
self.TorsoDamage 	= {33,36} 
self.HeadDamage 	= {110,110} 
self.DamageFallOf 	= 2
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 62.5

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {8,12}
	,camRecoilTilt 	= {10,15}
	,camRecoilLeft 	= {4,6}
	,camRecoilRight = {4,6}
}

self.gunRecoil = {
	gunRecoilUp 	= {15,20}
	,gunRecoilTilt 	= {10,15}
	,gunRecoilLeft 	= {10,15}
	,gunRecoilRight = {10,15}
}

self.AimRecoilReduction 		= 4
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= .25
self.MaxRecoilPower 			= 1.5
self.RecoilPowerStepAmount 		= .05

self.MinSpread 					= 2.5
self.MaxSpread 					= 100					
self.AimInaccuracyStepAmount 	= 1
self.AimInaccuracyDecrease 		= .25
self.WalkMult 					= 0

self.EnableZeroing 				= true
self.MaxZero 					= 200
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= "9x19mm"
self.MuzzleVelocity 			= 1250 --m/s
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

self.CanBreak	= true
self.Jammed		= false

return self