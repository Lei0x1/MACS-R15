local TS = game:GetService('TweenService')
local self = {}

self.SlideEx 		= CFrame.new(0,0,0)
self.SlideLock 		= false

self.canAim 		= false
self.Zoom 			= 70
self.Zoom2 			= 70

self.gunName 		= script.Parent.Name
self.Type 			= "Melee"
self.EnableHUD		= false
self.BladeRange 	= 7
self.IncludeChamberedBullet = false
self.Ammo 			= 0
self.StoredAmmo 	= 0
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 0
self.CanCheckMag 	= false
self.MagCount		= false
self.ShellInsert	= false
self.ShootRate 		= 0
self.Bullets 		= 0
self.ShootType 		= 1				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = false;
	Burst = false;
	Auto = false;}

self.LimbDamage 	= {32,32}
self.TorsoDamage 	= {32,32} 
self.HeadDamage 	= {75,75} 
self.DamageFallOf 	= 0
self.MinDamage 		= 0
self.IgnoreProtection = true
self.BulletPenetration = 0

self.CrossHair 		= false
self.CenterDot 		= true
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

self.AimRecoilReduction 		= 1
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= 0
self.MaxRecoilPower 			= 0
self.RecoilPowerStepAmount 		= 0

self.MinSpread 					= 0
self.MaxSpread 					= 0					
self.AimInaccuracyStepAmount 	= 0
self.AimInaccuracyDecrease 		= 0
self.WalkMult 					= 0

self.EnableZeroing 				= false
self.MaxZero 					= 500
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= ""
self.MuzzleVelocity 			= 0 --m/s
self.BulletDrop 				= 0 --Between 0 - 1
self.Tracer						= false
self.BulletFlare 				= false
self.TracerColor				= Color3.fromRGB(255,255,255)
self.RandomTracer				= {
	Enabled = false
	,Chance = 25 -- 0-100%
}
self.TracerEveryXShots			= 0
self.RainbowMode 				= false
self.InfraRed 					= false

self.CanBreak	= false
self.Jammed		= false

return self