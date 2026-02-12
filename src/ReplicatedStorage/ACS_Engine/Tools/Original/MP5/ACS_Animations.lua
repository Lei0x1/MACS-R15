local TS = game:GetService('TweenService')
local self = {}

self.MainCFrame 	= CFrame.new(0.5,-.85,-0.75)

self.GunModelFixed 	= true
self.GunCFrame 		= CFrame.new(0.15, -.2, .85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))
self.LArmCFrame 	= CFrame.new(-.6,-0.1,-.2) * CFrame.Angles(math.rad(110),math.rad(15),math.rad(15))
self.RArmCFrame 	= CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))

self.EquipAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.25)
	TS:Create(objs[1], TweenInfo.new(.35,Enum.EasingStyle.Sine), {C1 = self.RArmCFrame:Inverse()}):Play()
	TS:Create(objs[2], TweenInfo.new(.35,Enum.EasingStyle.Sine), {C1 = self.LArmCFrame:Inverse()}):Play()
	wait(.35)
end;

self.IdleAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = self.RArmCFrame:Inverse()}):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = self.LArmCFrame:Inverse()}):Play()
end;

self.SprintAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(.75,-0.15,0) * CFrame.Angles(math.rad(90),math.rad(20),math.rad(-75))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.15,-0.75,0.4) * CFrame.Angles(math.rad(90),math.rad(20),math.rad(25))):inverse() }):Play()	
	wait(.25)
end;

self.LowReady = function(objs)
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(65), math.rad(0), math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.6,-0.5,0) * CFrame.Angles(math.rad(85),math.rad(15),math.rad(15))):inverse() }):Play()
	wait(0.25)	
end;

self.HighReady = function(objs)
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.35,-0.75,1) * CFrame.Angles(math.rad(135), math.rad(0), math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.2,-0.15,0.25) * CFrame.Angles(math.rad(155),math.rad(35),math.rad(15))):inverse() }):Play()
	wait(0.25)	
end;

self.Patrol = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(.75,-0.15,0) * CFrame.Angles(math.rad(90),math.rad(20),math.rad(-75))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.15,-0.75,0.4) * CFrame.Angles(math.rad(90),math.rad(20),math.rad(25))):inverse() }):Play()	
	wait(.25)	
end;

self.ReloadAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0,.2) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.3)

	TS:Create(objs[1], TweenInfo.new(.5,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.75,-0.15,1) * CFrame.Angles(math.rad(60),math.rad(-5),math.rad(15))):inverse() }):Play()
	wait(.05)
	objs[4].Handle.MagOut:Play()
	objs[4].Mag.Transparency = 1
	wait(.5)
	objs[4].Handle.AimUp:Play()
	wait(.75)
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0,.2) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.25)
	objs[4].Handle.MagIn:Play()
	TS:Create(objs[1], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(101),math.rad(-6),math.rad(0))):inverse() }):Play()
	objs[4].Mag.Transparency = 0
	wait(.2)
end;

self.TacticalReloadAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0.1,-0.15) * CFrame.Angles(math.rad(90),math.rad(60),math.rad(30))):inverse() }):Play()
	wait(.25)
	objs[4].Bolt.SlidePull:Play()
	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.3):inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.15,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.3):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0.1,0.15) * CFrame.Angles(math.rad(90),math.rad(60),math.rad(30))):inverse() }):Play()
	wait(.2)

	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0,.2) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.3)

	TS:Create(objs[1], TweenInfo.new(.5,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.75,-0.15,1) * CFrame.Angles(math.rad(60),math.rad(-5),math.rad(15))):inverse() }):Play()
	wait(.05)
	objs[4].Handle.MagOut:Play()
	objs[4].Mag.Transparency = 1
	wait(.5)
	objs[4].Handle.AimUp:Play()
	wait(.75)
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0,.2) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	wait(.25)
	objs[4].Handle.MagIn:Play()
	TS:Create(objs[1], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(101),math.rad(-6),math.rad(0))):inverse() }):Play()
	objs[4].Mag.Transparency = 0
	wait(.25)

	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.55,0.15,.2) * CFrame.Angles(math.rad(160),math.rad(0),math.rad(15))):inverse() }):Play()
	wait(.25)
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.6,-0.15,.2) * CFrame.Angles(math.rad(70),math.rad(-15),math.rad(15))):inverse() }):Play()
	wait(.05)
	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C0 =  CFrame.new():inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C0 =  CFrame.new():inverse() }):Play()
	objs[4].Bolt.SlideRelease:Play()
	TS:Create(objs[1], TweenInfo.new(.15,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(85),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.25)
end;

self.JammedAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0.1,-0.15) * CFrame.Angles(math.rad(90),math.rad(60),math.rad(30))):inverse() }):Play()
	wait(.25)
	objs[4].Bolt.SlidePull:Play()
	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.3):inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.3):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0.1,0.15) * CFrame.Angles(math.rad(90),math.rad(60),math.rad(30))):inverse() }):Play()
	wait(.3)
	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C0 =  CFrame.new():inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C0 =  CFrame.new():inverse() }):Play()
	objs[4].Bolt.SlideRelease:Play()
end;

self.PumpAnim = function(objs)

end;

self.MagCheck = function(objs)
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.5,-0.15,0) * CFrame.Angles(math.rad(100),math.rad(0),math.rad(-45))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(2.5)
	objs[4].Handle.AimDown:Play()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.5,-0.15,0) * CFrame.Angles(math.rad(160),math.rad(60),math.rad(-45))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(2.5)
	objs[4].Handle.AimUp:Play()
end;

self.meleeAttack = function(objs)

end;

self.GrenadeReady = function(objs)

end;

self.GrenadeThrow = function(objs)

end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--//Server Animations
------//Idle Position
self.SV_GunPos = CFrame.new(-.3, -.2, -0.4) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))

self.SV_RightArmPos = CFrame.new(-.9, 1.25, -0.35) * CFrame.Angles(math.rad(-30), math.rad(0), math.rad(0))	--Server
self.SV_LeftArmPos = CFrame.new(1,1,-1) * CFrame.Angles(math.rad(-80),math.rad(30),math.rad(-10))	--server

self.SV_RightElbowPos = CFrame.new(0,-0.45,-.25) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(0))		--Client
self.SV_LeftElbowPos = CFrame.new(0,0, -0.1) * CFrame.Angles(math.rad(-15),math.rad(0),math.rad(0))	--Client

self.SV_RightWristPos = CFrame.new(0,0,0.15) * CFrame.Angles(math.rad(20), math.rad(0), math.rad(0))		--Client
self.SV_LeftWristPos = CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(-15),math.rad(0))	

------//High Ready Animations
self.RightHighReady = CFrame.new(-1.1, .5, -1.1) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));
self.LeftHighReady = CFrame.new(0.65,0.4,-1.3) * CFrame.Angles(math.rad(-140),math.rad(30),math.rad(30));

self.RightElbowHighReady = CFrame.new(0,-0.25,-.35) * CFrame.Angles(math.rad(-45), math.rad(0), math.rad(0));
self.LeftElbowHighReady = CFrame.new(0,0, -0.1) * CFrame.Angles(math.rad(-15),math.rad(0),math.rad(0));

self.RightWristHighReady = CFrame.new(0,0,0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
self.LeftWristHighReady = CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(-15),math.rad(0));	

------//Low Ready Animations
self.RightLowReady = CFrame.new(-.9, 1.25, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
self.LeftLowReady = CFrame.new(1,1,-0.6) * CFrame.Angles(math.rad(-45),math.rad(15),math.rad(-25));

self.RightElbowLowReady = CFrame.new(0,-0.45,-.25) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(0));
self.LeftElbowLowReady = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));

self.RightWristLowReady = CFrame.new(0,0,0.15) * CFrame.Angles(math.rad(20), math.rad(0), math.rad(0));
self.LeftWristLowReady = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));	

------//Patrol Animations
self.RightPatrol = CFrame.new(-.85, 0.75, -1.3) * CFrame.Angles(math.rad(-30), math.rad(-90), math.rad(0));
self.LeftPatrol = CFrame.new(1.5,1.1,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0));

self.RightElbowPatrol = CFrame.new(0,-0.2,-.1) * CFrame.Angles(math.rad(-40), math.rad(0), math.rad(0));
self.LeftElbowPatrol = CFrame.new(0,-0.15,-0.25)  * CFrame.Angles(math.rad(-50), math.rad(0), math.rad(0));

self.RightWristPatrol = CFrame.new(0,0,0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-15));
self.LeftWristPatrol = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0));	

------//Aim Animations
self.RightAim = CFrame.new(-.6, 0.85, -0.5) * CFrame.Angles(math.rad(-50), math.rad(0), math.rad(0));
self.LeftAim = CFrame.new(1.6,0.6,-0.85) * CFrame.Angles(math.rad(-95),math.rad(35),math.rad(-25));

self.RightElbowAim = CFrame.new(0,-0.2,-.25) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0));
self.LeftElbowAim = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));

self.RightWristAim = CFrame.new(0,0,0.15) * CFrame.Angles(math.rad(20), math.rad(0), math.rad(0));
self.LeftWristAim = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));

------//Sprinting Animations
self.RightSprint = CFrame.new(-.9, 1.25, 0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
self.LeftSprint = CFrame.new(1,1,-0.6) * CFrame.Angles(math.rad(-45),math.rad(15),math.rad(-25));

self.RightElbowSprint = CFrame.new(0,-0.45,-.25) * CFrame.Angles(math.rad(-80), math.rad(0), math.rad(0));
self.LeftElbowSprint = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));

self.RightWristSprint = CFrame.new(0,0,0.15) * CFrame.Angles(math.rad(20), math.rad(0), math.rad(0));
self.LeftWristSprint = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));

return self