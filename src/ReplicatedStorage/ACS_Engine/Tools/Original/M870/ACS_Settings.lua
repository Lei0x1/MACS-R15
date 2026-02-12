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
self.Ammo 			= 7
self.StoredAmmo 	= 21
self.AmmoInGun 		= self.Ammo
self.MaxStoredAmmo	= 49
self.CanCheckMag 	= false
self.MagCount		= false
self.ShellInsert	= true
self.ShootRate 		= 800
self.Bullets 		= 8
self.BurstShot 		= 3
self.ShootType 		= 4				--[1 = SEMI; 2 = BURST; 3 = AUTO; 4 = PUMP ACTION; 5 = BOLT ACTION]
self.FireModes = {
	ChangeFiremode = false;		
	Semi = false;
	Burst = false;
	Auto = false;}

self.LimbDamage 	= {25,25}
self.TorsoDamage 	= {45,45} 
self.HeadDamage 	= {100,100} 
self.DamageFallOf 	= 2
self.MinDamage 		= 5
self.IgnoreProtection = false
self.BulletPenetration = 50

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
	camRecoilUp 	= {70,75}
	,camRecoilTilt 	= {90,100}
	,camRecoilLeft 	= {40,45}
	,camRecoilRight = {40,45}
}

self.gunRecoil = {
	gunRecoilUp 	= {150,200}
	,gunRecoilTilt 	= {50,75}
	,gunRecoilLeft 	= {100,175}
	,gunRecoilRight = {100,175}
}

self.AimRecoilReduction 		= 1
self.AimSpreadReduction 		= 1

self.MinRecoilPower 			= 1
self.MaxRecoilPower 			= 1
self.RecoilPowerStepAmount 		= 1

self.MinSpread 					= 20
self.MaxSpread 					= 75					
self.AimInaccuracyStepAmount 	= 2
self.AimInaccuracyDecrease 		= 1.5
self.WalkMult 					= 0

self.EnableZeroing 				= false
self.MaxZero 					= 500
self.ZeroIncrement 				= 50
self.CurrentZero 				= 0

self.BulletType 				= ".12 Gauge"
self.MuzzleVelocity 			= 1500 --m/s
self.BulletDrop 				= .25 --Between 0 - 1
self.Tracer						= true
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