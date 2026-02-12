local TS = game:GetService('TweenService')
local self = {}

self.MainCFrame 	= CFrame.new(0.5,-0.75,-2)

self.GunModelFixed 	= true
self.GunCFrame 		= CFrame.new(0.15, -.2, .85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))
self.LArmCFrame 	= CFrame.new(-0.9,-0.4,1) * CFrame.Angles(math.rad(100),math.rad(15),math.rad(65))
self.RArmCFrame 	= CFrame.new(0.1,-0.15,1) * CFrame.Angles(math.rad(90),math.rad(5),math.rad(0))

self.EquipAnim = function(objs)
	--TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	--TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):inverse() }):Play()
	--wait(.25)
	TS:Create(objs[1], TweenInfo.new(.6,Enum.EasingStyle.Sine), {C1 = self.RArmCFrame:Inverse()}):Play()
	TS:Create(objs[2], TweenInfo.new(.6,Enum.EasingStyle.Sine), {C1 = self.LArmCFrame:Inverse()}):Play()
	wait(.6)
end;

self.IdleAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = self.RArmCFrame:Inverse()}):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = self.LArmCFrame:Inverse()}):Play()
end;

self.LowReady = function(objs)
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-0.1,-0.7,0.8) * CFrame.Angles(math.rad(80),math.rad(5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-1.2,-0.7,0.9) * CFrame.Angles(math.rad(90),math.rad(5),math.rad(60))):inverse() }):Play()
	wait(0.25)	
end;

self.HighReady = function(objs)
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.6,0,1.5) * CFrame.Angles(math.rad(140),math.rad(5),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-1.1,-1,1) * CFrame.Angles(math.rad(200),math.rad(5),math.rad(60))):inverse() }):Play()
	wait(0.25)	
end;

self.Patrol = function(objs)
	TS:Create(objs[1],TweenInfo.new(0.25,Enum.EasingStyle.Sine),{C1 = CFrame.new(0.1,-0.7,-1) * CFrame.Angles(math.rad(70),math.rad(5),math.rad(0)):inverse()}):Play()
	TS:Create(objs[2],TweenInfo.new(0.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-1,-0.4,1.5) * CFrame.Angles(math.rad(-180),math.rad(-30),math.rad(70))):inverse() }):Play()
	wait(.25)	
end;

self.SprintAnim = function(objs)
	TS:Create(objs[1],TweenInfo.new(0.3,Enum.EasingStyle.Sine),{C1 = CFrame.new(0.1,-0.7,-1) * CFrame.Angles(math.rad(70),math.rad(5),math.rad(0)):inverse()}):Play()
	TS:Create(objs[2],TweenInfo.new(0.3,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-1,-0.4,1.5) * CFrame.Angles(math.rad(-180),math.rad(-30),math.rad(70))):inverse() }):Play()
	wait(0.3)
	
	-- CFrame.new(0.1,-0.4,1) * CFrame.Angles(math.rad(70),math.rad(5),math.rad(00))
end;

self.ReloadAnim = function(objs)
	--TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(0))):inverse() }):Play()
	--TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0,.2) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	--wait(.3)

	--TS:Create(objs[1], TweenInfo.new(.5,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):inverse() }):Play()
	--TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.75,-0.15,1) * CFrame.Angles(math.rad(60),math.rad(-5),math.rad(15))):inverse() }):Play()
	--wait(.05)
	--objs[4].Handle.MagOut:Play()
	--objs[4].Mag.Transparency = 1
	--wait(.5)
	--objs[4].Handle.AimUp:Play()
	--wait(.75)
	--TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0,.2) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):inverse() }):Play()
	--wait(.25)
	--objs[4].Handle.MagIn:Play()
	--TS:Create(objs[1], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(101),math.rad(-6),math.rad(0))):inverse() }):Play()
	--objs[4].Mag.Transparency = 0
	--wait(.2)
	
	-- Position
	-- Side to side (Negative left)
	-- Up down
	-- Forward backwards inverse
	
	-- Rotation
	-- Barrel up down
	-- Gun tilt
	-- Side to side
	
	-- Grab mag
	TS:Create(objs[1], TweenInfo.new(0.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.2,-0.2,0.5) * CFrame.Angles(math.rad(80),math.rad(-15),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(0.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.5,-0.5,-0.2) * CFrame.Angles(math.rad(90),math.rad(-15),math.rad(30))):inverse() }):Play()
	
	wait(0.3)
	
	-- Pull out mag
	objs[4].Mag.Transparency = 1
	objs[4].Handle.MagOut:Play()
	TS:Create(objs[1], TweenInfo.new(0.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.2,-0.2,0.5) * CFrame.Angles(math.rad(70),math.rad(-15),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(0.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.5,-0.8,-0.2) * CFrame.Angles(math.rad(60),math.rad(-15),math.rad(30))):inverse() }):Play()
	
	wait(0.3)
	
	-- Grab next mag
	TS:Create(objs[1], TweenInfo.new(0.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.2,-0.2,0.5) * CFrame.Angles(math.rad(75),math.rad(-15),math.rad(0))):inverse() }):Play()
	
	wait(0.7)
	
	objs[4].Handle.MagPouch:Play()
	
	wait(1.3)
	
	-- Insert new mag
	objs[4].Mag.Transparency = 0
	objs[4].Handle.MagIn:Play()
	TS:Create(objs[2], TweenInfo.new(0.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.5,-0.5,-0.2) * CFrame.Angles(math.rad(90),math.rad(-15),math.rad(30))):inverse() }):Play()
	
	wait(0.3)
	
	TS:Create(objs[1], TweenInfo.new(0.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.2,-0.2,0.5) * CFrame.Angles(math.rad(90),math.rad(-15),math.rad(0))):inverse() }):Play()
	
	wait(0.3)
end;

self.TacticalReloadAnim = function(objs)
	-- Lower
	--TS:Create(objs[1], TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In), {C1 = (CFrame.new(0.1,-0.75,1) * CFrame.Angles(math.rad(80),math.rad(15),math.rad(-40))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(0.5,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.5,-1.4,2) * CFrame.Angles(math.rad(10),math.rad(-20),math.rad(0))):inverse() }):Play()
	wait(1)
	
	-- Flip up
	TS:Create(objs[1], TweenInfo.new(0.6,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.1,-1.75,0.7) * CFrame.Angles(math.rad(150),math.rad(-15),math.rad(-10))):inverse() }):Play()
	wait(1)
	
	-- Place warhead
	local rocketBase = Instance.new("Part")
	rocketBase.Size = Vector3.new(0.2,0.2,0.2)
	rocketBase.Transparency = 1
	rocketBase.CanCollide = false
	rocketBase.CFrame = objs[4].Handle.CFrame
	rocketBase.Parent = objs[4]
	
	local W = Instance.new("Motor6D")
	W.Part0 = objs[4].Handle
	W.Part1 = rocketBase
	local CJ = CFrame.new(W.Part0.Position)
	W.C0 = W.Part0.CFrame:ToObjectSpace(W.Part1.CFrame)
	W.Parent = rocketBase
	
	-- Create fake warhead
	for _, child in pairs(objs[4]:GetChildren()) do
		if child.Name == "Warhead" then
			local nPart = child:Clone()
			nPart.Transparency = 0
			nPart.Name = "TempModel"
			nPart.Anchored = true
			local W2 = Instance.new("Weld")
			W2.Part0 = nPart
			W2.Part1 = rocketBase
			local CJ = CFrame.new(W.Part0.Position)
			W2.C0 = W2.Part0.CFrame:ToObjectSpace(W.Part1.CFrame)
			W2.Parent = nPart
			nPart.Anchored = false
			nPart.Parent = rocketBase
		end
	end
	
	W.C1 = CFrame.new(0,1,-3)
	
	objs[2].C1 = (CFrame.new(-0.9,-2,0.5) * CFrame.Angles(math.rad(150),math.rad(-10),math.rad(20))):Inverse()
	TS:Create(objs[2], TweenInfo.new(0.5,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.9,0,0.5) * CFrame.Angles(math.rad(150),math.rad(-10),math.rad(20))):inverse() }):Play()
	TS:Create(W, TweenInfo.new(0.5,Enum.EasingStyle.Sine), {C1 = CFrame.new(0,0,1)}):Play()
	wait(0.7)

	
	-- Insert warhead
	objs[4].Handle.MagIn:Play()
	TS:Create(objs[2], TweenInfo.new(0.5,Enum.EasingStyle.Back), {C1 = (CFrame.new(-0.8,-0.5,0.7) * CFrame.Angles(math.rad(150),math.rad(-10),math.rad(20))):inverse() }):Play()
	TS:Create(W, TweenInfo.new(0.5,Enum.EasingStyle.Back), {C1 = CFrame.new(0,0,0)}):Play()

	wait(0.7)
	
	for _, cPart in pairs(objs[4]:GetChildren()) do
		if cPart.Name == "Warhead" then
			cPart.Transparency = 0
		end
	end
	
	rocketBase:Destroy()
end;

self.JammedAnim = function(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.75) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.5,-0.35,0.45) * CFrame.Angles(math.rad(160),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.25)
	objs[4].Bolt.SlidePull:Play()
	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.4):inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.4):inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.5,-0.35,0.45) * CFrame.Angles(math.rad(180),math.rad(0),math.rad(0))):inverse() }):Play()
	wait(.3)
	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.1,Enum.EasingStyle.Linear), {C0 =  CFrame.new():inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.1,Enum.EasingStyle.Linear), {C0 =  CFrame.new():inverse() }):Play()
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
self.SV_GunPos 		= CFrame.new(-.3, -1, -0.4) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));

self.SV_RightArmPos = CFrame.new(-0.85, 0.1, -1.2) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));
self.SV_LeftArmPos 	= CFrame.new(1.05,0.9,-1.4) * CFrame.Angles(math.rad(-100),math.rad(25),math.rad(-20));

------//High Ready Animations
self.RightHighReady = CFrame.new(-1, -1, -1.5) * CFrame.Angles(math.rad(-160), math.rad(0), math.rad(0));
self.LeftHighReady 	= CFrame.new(.85,-0.35,-1.15) * CFrame.Angles(math.rad(-170),math.rad(60),math.rad(15));

------//Low Ready Animations
self.RightLowReady 	= CFrame.new(-1, 0.5, -1.25) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0));
self.LeftLowReady 	= CFrame.new(1.25,1.15,-1.35) * CFrame.Angles(math.rad(-60),math.rad(35),math.rad(-25));

------//Patrol Animations
self.RightPatrol 	= CFrame.new(-1, -.35, -1.5) * CFrame.Angles(math.rad(-80), math.rad(-80), math.rad(0));
self.LeftPatrol 	= CFrame.new(1,1.25,-.75) * CFrame.Angles(math.rad(-90),math.rad(-45),math.rad(-25));

------//Aim Animations
self.RightAim 		= CFrame.new(-.575, 0.1, -1) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0));
self.LeftAim 		= CFrame.new(1.4,0.25,-1.45) * CFrame.Angles(math.rad(-120),math.rad(35),math.rad(-25));

------//Sprinting Animations
self.RighTSprint 	= CFrame.new(-1, 0.5, -1.25) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0));
self.LefTSprint 	= CFrame.new(1.25,1.15,-1.35) * CFrame.Angles(math.rad(-60),math.rad(35),math.rad(-25));

return self