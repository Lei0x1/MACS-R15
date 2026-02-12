local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,-0.3)
self.SlideLock 		= true

self.canAim 		= true
self.Zoom 			= 70
self.Zoom2 			= 70

self.gunName 		= script.Parent.Name
self.Type 			= "Gun"
self.EnableHUD		= true
self.IncludeChamberedBullet = true
self.Ammo 			= 12
self.StoredAmmo 	= 60
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 84
self.CanCheckMag 	= true
self.MagCount		= true
self.ShellInsert	= false
self.ShootRate 		= 700
self.Bullets 		= 1
self.BurstShot 		= 3
self.ShootType 		= 1				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = false;
	Burst = false;
	Auto = false;}

self.LimbDamage 	= {22,26}
self.TorsoDamage 	= {34,38} 
self.HeadDamage 	= {120,120} 
self.DamageFallOf 	= 2
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 50.5

self.CrossHair 		= false
self.CenterDot 		= false
self.CrosshairOffset= 0
self.CanBreachDoor 	= false

self.SightAtt 		= ""
self.BarrelAtt		= ""
self.UnderBarrelAtt = ""
self.OtherAtt 		= ""

self.camRecoil = {
	camRecoilUp 	= {5,8}
	,camRecoilTilt 	= {10,15}
	,camRecoilLeft 	= {5,8}
	,camRecoilRight = {5,8}
}

self.gunRecoil = {
	gunRecoilUp 	= {150,150}
	,gunRecoilTilt 	= {25,50}
	,gunRecoilLeft 	= {10,20}
	,gunRecoilRight = {10,20}
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

self.BulletType 				= ".45 ACP"
self.MuzzleVelocity 			= 1000 --m/s
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

self.CanBreak	= true
self.Jammed		= false

return self