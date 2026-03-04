local TS = game:GetService('TweenService')
local Anim = {}

--////////////////////////////////////////////////////////////
--// BASE OFFSETS
--////////////////////////////////////////////////////////////

Anim.MainCFrame 	= CFrame.new(0.5,-0.85,-0.75)

Anim.GunModelFixed 	= true
Anim.GunCFrame 		= CFrame.new(0.15, -.2, .85) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))
Anim.LArmCFrame 	= CFrame.new(-.4,-0.4,-0.4) * CFrame.Angles(math.rad(110),math.rad(15),math.rad(15))
Anim.RArmCFrame 	= CFrame.new(0.1,-0.15,1) * CFrame.Angles(math.rad(90),math.rad(5),math.rad(0))

function Anim.EquipAnim(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):Inverse() }):Play()
	task.wait(.25)

	TS:Create(objs[1], TweenInfo.new(.35,Enum.EasingStyle.Sine), {C1 = Anim.RArmCFrame:Inverse()}):Play()
	TS:Create(objs[2], TweenInfo.new(.35,Enum.EasingStyle.Sine), {C1 = Anim.LArmCFrame:Inverse()}):Play()
	task.wait(.35)
end

function Anim.IdleAnim(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = Anim.RArmCFrame:Inverse()}):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = Anim.LArmCFrame:Inverse()}):Play()
end

function Anim.LowReady(objs)
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(65), math.rad(0), math.rad(0))):Inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.6,-0.75,-.25) * CFrame.Angles(math.rad(85),math.rad(15),math.rad(15))):Inverse() }):Play()
	task.wait(0.25)
end

function Anim.HighReady(objs)
	TS:Create(objs[1],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(0.35,-0.75,1) * CFrame.Angles(math.rad(135), math.rad(0), math.rad(0))):Inverse() }):Play()
	TS:Create(objs[2],TweenInfo.new(.25,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-.2,-0.15,0.25) * CFrame.Angles(math.rad(155),math.rad(35),math.rad(15))):Inverse() }):Play()
	task.wait(0.25)
end

function Anim.Patrol(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(.75,-0.15,0) * CFrame.Angles(math.rad(90),math.rad(20),math.rad(-75))):Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-1.15,-0.75,0.4) * CFrame.Angles(math.rad(90),math.rad(20),math.rad(25))):Inverse() }):Play()	
	task.wait(.25)
end

function Anim.SprintAnim(objs)
	TS:Create(objs[1],TweenInfo.new(0.3,Enum.EasingStyle.Sine),{C1 = CFrame.new(0, -0.4, -0.4) * CFrame.Angles(math.rad(-80), math.rad(-35), math.rad(-15))}):Play()
	TS:Create(objs[2],TweenInfo.new(0.3,Enum.EasingStyle.Sine),{C1 = (CFrame.new(-0.7,-0.75,-.45) * CFrame.Angles(math.rad(85),math.rad(15),math.rad(-15))):Inverse() }):Play()
	task.wait(0.3)
end

function Anim.ReloadAnim(objs)
	--TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(0))):Inverse() }):Play()
	--TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0,.2) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):Inverse() }):Play()
	--task.wait(.3)

	--TS:Create(objs[1], TweenInfo.new(.5,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):Inverse() }):Play()
	--TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.75,-0.15,1) * CFrame.Angles(math.rad(60),math.rad(-5),math.rad(15))):Inverse() }):Play()
	--task.wait(.05)
	--objs[4].Handle.MagOut:Play()
	--objs[4].Mag.Transparency = 1
	--task.wait(.5)
	--objs[4].Handle.AimUp:Play()
	--task.wait(.75)
	--TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.65,0,.2) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):Inverse() }):Play()
	--task.wait(.25)
	--objs[4].Handle.MagIn:Play()
	--TS:Create(objs[1], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.85) * CFrame.Angles(math.rad(101),math.rad(-6),math.rad(0))):Inverse() }):Play()
	--objs[4].Mag.Transparency = 0
	--task.wait(.2)
	
	-- Position
	-- Side to side (Negative left)
	-- Up down
	-- Forward backwards Inverse
	
	-- Rotation
	-- Barrel up down
	-- Gun tilt
	-- Side to side
	
	--[[
	-- Grab mag
	TS:Create(objs[1], TweenInfo.new(0.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.2,-0.2,0.5) * CFrame.Angles(math.rad(80),math.rad(-15),math.rad(0))):Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(0.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.5,-0.5,-0.2) * CFrame.Angles(math.rad(90),math.rad(-15),math.rad(30))):Inverse() }):Play()
	
	task.wait(0.3)
	
	-- Pull out mag
	objs[4].Mag.Transparency = 1
	objs[4].Handle.MagOut:Play()
	TS:Create(objs[1], TweenInfo.new(0.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.2,-0.2,0.5) * CFrame.Angles(math.rad(70),math.rad(-15),math.rad(0))):Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(0.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.5,-0.8,-0.2) * CFrame.Angles(math.rad(60),math.rad(-15),math.rad(30))):Inverse() }):Play()
	
	task.wait(0.3)
	
	-- Grab next mag
	TS:Create(objs[1], TweenInfo.new(0.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.2,-0.2,0.5) * CFrame.Angles(math.rad(75),math.rad(-15),math.rad(0))):Inverse() }):Play()
	
	task.wait(0.7)
	
	objs[4].Handle.MagPouch:Play()
	
	task.wait(1.3)
	
	-- Insert new mag
	objs[4].Mag.Transparency = 0
	objs[4].Handle.MagIn:Play()
	TS:Create(objs[2], TweenInfo.new(0.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-0.5,-0.5,-0.2) * CFrame.Angles(math.rad(90),math.rad(-15),math.rad(30))):Inverse() }):Play()
	
	task.wait(0.3)
	
	TS:Create(objs[1], TweenInfo.new(0.3,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.2,-0.2,0.5) * CFrame.Angles(math.rad(90),math.rad(-15),math.rad(0))):Inverse() }):Play()
	
	task.wait(0.3)]]
	
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(0))):Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.75,-0.15,.5) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):Inverse() }):Play()
	task.wait(.3)

	TS:Create(objs[1], TweenInfo.new(.5,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.75,-0.15,.5) * CFrame.Angles(math.rad(60),math.rad(-5),math.rad(15))):Inverse() }):Play()
	task.wait(.05)

	objs[4].Handle.MagOut:Play()
	objs[4].Mag.Transparency = 1
	task.wait(.5)

	objs[4].Handle.AimUp:Play()
	task.wait(.75)

	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.75,-0.5,.25) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):Inverse() }):Play()
	task.wait(.25)

	objs[4].Handle.MagIn:Play()
	TS:Create(objs[1], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(101),math.rad(-6),math.rad(0))):Inverse() }):Play()
	objs[4].Mag.Transparency = 0
	task.wait(.2)

	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.75,-0.5,.25) * CFrame.Angles(math.rad(60),math.rad(-15),math.rad(30))):Inverse() }):Play()
	task.wait(.25)

	TS:Create(objs[2], TweenInfo.new(.1,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.75,-0.5,.25) * CFrame.Angles(math.rad(100),math.rad(-15),math.rad(30))):Inverse() }):Play()
	task.wait(.05)

	TS:Create(objs[1], TweenInfo.new(.1,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):Inverse() }):Play()
	task.wait(.1)
end

function Anim.TacticalReloadAnim(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(0))):Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.5,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.75,-0.15,.5) * CFrame.Angles(math.rad(60),math.rad(-5),math.rad(15))):Inverse() }):Play()
	task.wait(.3)

	TS:Create(objs[1], TweenInfo.new(.5,Enum.EasingStyle.Back), {C1 = (CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(100),math.rad(-5),math.rad(0))):Inverse() }):Play()
	task.wait(.05)
	
	objs[4].Handle.MagOut:Play()
	objs[4].Mag.Transparency = 1

	local FakeMag = objs[4]:WaitForChild("Mag"):Clone()
	FakeMag:ClearAllChildren()
	FakeMag.Transparency = 0
	FakeMag.Parent = objs[4]
	FakeMag.Anchored = false
	FakeMag.RotVelocity = Vector3.new(0,0,0)
	FakeMag.Velocity = (FakeMag.CFrame.UpVector * 25)
	task.wait(.5)

	objs[4].Handle.AimUp:Play()
	task.wait(.25)

	TS:Create(objs[2], TweenInfo.new(.3,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.75,-0.5,.25) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):Inverse() }):Play()
	task.wait(.25)

	objs[4].Handle.MagIn:Play()

	TS:Create(objs[1], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(101),math.rad(-6),math.rad(0))):Inverse() }):Play()
	objs[4].Mag.Transparency = 0
	task.wait(.2)

	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.75,-0.5,.25) * CFrame.Angles(math.rad(60),math.rad(-15),math.rad(30))):Inverse() }):Play()
	task.wait(.25)

	TS:Create(objs[2], TweenInfo.new(.1,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.75,-0.5,.25) * CFrame.Angles(math.rad(100),math.rad(-15),math.rad(30))):Inverse() }):Play()
	task.wait(.05)

	TS:Create(objs[1], TweenInfo.new(.1,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(105),math.rad(-5),math.rad(0))):Inverse() }):Play()
	task.wait(.15)

	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,1) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))):Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.85,0.05,.6) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(25))):Inverse() }):Play()
	task.wait(.25)

	objs[4].Bolt.SlideRelease:Play()

	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.15,Enum.EasingStyle.Linear), {C0 =  CFrame.new():Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.15,Enum.EasingStyle.Back), {C1 = (CFrame.new(-.8,0.05,.6) * CFrame.Angles(math.rad(110),math.rad(-15),math.rad(30))):Inverse() }):Play()
	task.wait(.15)
end

function Anim.JammedAnim(objs)
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.05,-0.15,.75) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))):Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.5,-0.35,0.45) * CFrame.Angles(math.rad(160),math.rad(0),math.rad(0))):Inverse() }):Play()
	task.wait(.25)

	objs[4].Bolt.SlidePull:Play()

	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.4):Inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.2,Enum.EasingStyle.Sine), {C0 =  CFrame.new(0,0,-0.4):Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.2,Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.5,-0.35,0.45) * CFrame.Angles(math.rad(180),math.rad(0),math.rad(0))):Inverse() }):Play()
	task.wait(.3)

	TS:Create(objs[4].Handle.Slide, TweenInfo.new(.1,Enum.EasingStyle.Linear), {C0 =  CFrame.new():Inverse() }):Play()
	TS:Create(objs[4].Handle.Bolt, TweenInfo.new(.1,Enum.EasingStyle.Linear), {C0 =  CFrame.new():Inverse() }):Play()

	objs[4].Bolt.SlideRelease:Play()
end

function Anim.FireMode(objs)
	TS:Create(objs[1], TweenInfo.new(0.95, Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.1, -0.15, 1)* CFrame.Angles(math.rad(95),math.rad(5),math.rad(0))):Inverse()}):Play()
	TS:Create(objs[2], TweenInfo.new(0.95, Enum.EasingStyle.Sine), {C1 = (CFrame.new(-.75, -0.15, 0.5) * CFrame.Angles(math.rad(110), math.rad(-15), math.rad(30))):Inverse()}):Play()

	task.wait(0.15)

	TS:Create(objs[1],TweenInfo.new(0.15, Enum.EasingStyle.Sine), {C1 = Anim.RArmCFrame:Inverse()}):Play()
	TS:Create(objs[2], TweenInfo.new(0.15, Enum.EasingStyle.Sine), {C1 = Anim.LArmCFrame:Inverse()}):Play()
end

function Anim.PumpAnim(objs)

end

function Anim.MagCheck(objs)
	objs[4].Handle.AimUp:Play()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.5,-0.15,0) * CFrame.Angles(math.rad(100),math.rad(0),math.rad(-45))):Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):Inverse() }):Play()
	task.wait(2.5)

	objs[4].Handle.AimDown:Play()
	TS:Create(objs[1], TweenInfo.new(.25,Enum.EasingStyle.Sine), {C1 = (CFrame.new(0.5,-0.15,0) * CFrame.Angles(math.rad(160),math.rad(60),math.rad(-45))):Inverse() }):Play()
	TS:Create(objs[2], TweenInfo.new(.25,Enum.EasingStyle.Linear), {C1 = (CFrame.new(-1,-1,1) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))):Inverse() }):Play()
	task.wait(2.5)
	
	objs[4].Handle.AimUp:Play()
end

function Anim.meleeAttack(objs)

end

function Anim.GrenadeReady(objs)

end

function Anim.GrenadeThrow(objs)

end

--////////////////////////////////////////////////////////////
--// SERVER ANIMATION
--////////////////////////////////////////////////////////////

------//Idle Position
Anim.SV_GunPos 		= CFrame.new(-.3, -1, -0.4) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))
Anim.SV_RightArmPos = CFrame.new(-0.85, 0.1, -1.2) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))
Anim.SV_LeftArmPos 	= CFrame.new(1.05,0.9,-1.4) * CFrame.Angles(math.rad(-100),math.rad(25),math.rad(-20))

------//High Ready Animations
Anim.RightHighReady = CFrame.new(-1, -1, -1.5) * CFrame.Angles(math.rad(-160), math.rad(0), math.rad(0))
Anim.LeftHighReady 	= CFrame.new(.85,-0.35,-1.15) * CFrame.Angles(math.rad(-170),math.rad(60),math.rad(15))

------//Low Ready Animations
Anim.RightLowReady 	= CFrame.new(-1, 0.5, -1.25) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0))
Anim.LeftLowReady 	= CFrame.new(1.25,1.15,-1.35) * CFrame.Angles(math.rad(-60),math.rad(35),math.rad(-25))

------//Patrol Animations
Anim.RightPatrol 	= CFrame.new(-1, -.35, -1.5) * CFrame.Angles(math.rad(-80), math.rad(-80), math.rad(0))
Anim.LeftPatrol 	= CFrame.new(1,1.25,-.75) * CFrame.Angles(math.rad(-90),math.rad(-45),math.rad(-25))

------//Aim Animations
Anim.RightAim 		= CFrame.new(-.575, 0.1, -1) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))
Anim.LeftAim 		= CFrame.new(1.4,0.25,-1.45) * CFrame.Angles(math.rad(-120),math.rad(35),math.rad(-25))

------//Sprinting Animations
Anim.RighTSprint 	= CFrame.new(-1, 0.5, -1.25) * CFrame.Angles(math.rad(-60), math.rad(0), math.rad(0))
Anim.LefTSprint 	= CFrame.new(1.25,1.15,-1.35) * CFrame.Angles(math.rad(-60),math.rad(35),math.rad(-25))

return Anim