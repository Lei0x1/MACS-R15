local TS = game:GetService('TweenService')
local self = {}

self.MainCFrame 	= CFrame.new(0,0,0)

self.GunModelFixed 	= true
self.GunCFrame 		= CFrame.new(0.35, -0.25, .85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))
self.LArmCFrame 	= CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))
self.RArmCFrame 	= CFrame.new(1,-.85,-.25) * CFrame.Angles(math.rad(100),math.rad(30),math.rad(-15))

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

self.LowReady = function(objs)

end;

self.HighReady = function(objs)

end;

self.Patrol = function(objs)

end;

self.SprintAnim = function(objs)

end;

self.ReloadAnim = function(objs)

end;

self.TacticalReloadAnim = function(objs)

end;

self.JammedAnim = function(objs)

end;

self.PumpAnim = function(objs)

end;

self.MagCheck = function(objs)

end;

self.meleeAttack = function(objs)

end;

self.GrenadeReady = function(objs)
	TS:Create(objs[1], TweenInfo.new(.2,Enum.EasingStyle.Linear), {C1 = (CFrame.new(1,-.85,-1) * CFrame.Angles(math.rad(175),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.2,Enum.EasingStyle.Linear), {C1 = (CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.2)
end;

self.GrenadeThrow = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(.5,-.85,-1) * CFrame.Angles(math.rad(90),math.rad(90),math.rad(0))):inverse() }):Play()
	wait(.1)
	objs[4].Handle.Transparency = 1
	objs[4].Handle.Swing:Play()
end;

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--//Server Animations
------//Idle Position
self.SV_GunPos = CFrame.new(-.3, -.2, -0.4) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))

self.SV_RightArmPos = CFrame.new(-0.575, 0.65, -1.185) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))	--Server
self.SV_LeftArmPos = CFrame.new(1.15,0.25,-1.3) * CFrame.Angles(math.rad(-95),math.rad(20),math.rad(-25))	--server

self.SV_RightElbowPos = CFrame.new(0,0,0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0))		--Client
self.SV_LeftElbowPos = CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))	--Client

self.SV_RightWristPos = CFrame.new(0,0,0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0))		--Client
self.SV_LeftWristPos = CFrame.new(0,0,0) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))

------//High Ready Animations
self.RightHighReady = CFrame.new(-1, .45, -1.15) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));
self.LeftHighReady = CFrame.new(.75,.45,-1.15) * CFrame.Angles(math.rad(-90),math.rad(45),math.rad(0));

self.RightElbowHighReady = CFrame.new(0,-0.45,-0.45)  * CFrame.Angles(math.rad(-75), math.rad(0), math.rad(0));
self.LeftElbowHighReady = CFrame.new(0,-.4,-.4)  * CFrame.Angles(math.rad(-60), math.rad(30), math.rad(0));

self.RightWristHighReady = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
self.LeftWristHighReady = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));	

------//Low Ready Animations
self.RightLowReady = CFrame.new(-1, 1.1, -0.5) * CFrame.Angles(math.rad(-30), math.rad(0), math.rad(0));
self.LeftLowReady = CFrame.new(1,1,-0.9) * CFrame.Angles(math.rad(-30),math.rad(35),math.rad(-25));

self.RightElbowLowReady = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
self.LeftElbowLowReady = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));

self.RightWristLowReady = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
self.LeftWristLowReady = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));	

------//Patrol Animations
self.RightPatrol = CFrame.new(-1, 1.1, -0.5) * CFrame.Angles(math.rad(-30), math.rad(0), math.rad(0));
self.LeftPatrol = CFrame.new(1,1,-0.9) * CFrame.Angles(math.rad(-30),math.rad(35),math.rad(-25));

self.RightElbowPatrol = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
self.LeftElbowPatrol = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));

self.RightWristPatrol = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
self.LeftWristPatrol = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));	

------//Aim Animations
self.RightAim = CFrame.new(-.575, .45, -1.15) * CFrame.Angles(math.rad(-105), math.rad(0), math.rad(0));
self.LeftAim = CFrame.new(1.3,0.2,-0.85) * CFrame.Angles(math.rad(-95),math.rad(35),math.rad(-25));

self.RightElbowAim = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
self.LeftElbowAim = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));

self.RightWristAim = CFrame.new(0,0,0.1)  * CFrame.Angles(math.rad(15), math.rad(0), math.rad(0));
self.LeftWristAim = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));

------//Sprinting Animations
self.RightSprint = CFrame.new(-1, 1.1, -0.5) * CFrame.Angles(math.rad(-30), math.rad(0), math.rad(0));
self.LeftSprint = CFrame.new(1,1,-0.9) * CFrame.Angles(math.rad(-30),math.rad(35),math.rad(-25));

self.RightElbowSprint = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
self.LeftElbowSprint = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));

self.RightWristSprint = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));
self.LeftWristSprint = CFrame.new(0,0,0)  * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0));

return self