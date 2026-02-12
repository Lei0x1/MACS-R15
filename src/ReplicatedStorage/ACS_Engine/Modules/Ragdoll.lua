local PhysicsService = game:GetService("PhysicsService")
local Players = game.Players

return function(char)
	if char ~= nil then
		local plr = Players:GetPlayerFromCharacter(char)

		if char.Humanoid.RigType == Enum.HumanoidRigType.R6 then

			local head = char:FindFirstChild('Head')
			local humanoid = char:FindFirstChild('Humanoid')
			local leftarm = char:FindFirstChild("Left Arm")
			local leftleg = char:FindFirstChild("Left Leg")
			local rightleg = char:FindFirstChild("Right Leg")
			local rightarm = char:FindFirstChild("Right Arm")
			local torso = char:FindFirstChild("Torso")

			humanoid.PlatformStand = true
			humanoid.AutoRotate = false

			local HeadA = Instance.new("Attachment")
			HeadA.Name = "HeadA"
			HeadA.Parent = head
			HeadA.Position = Vector3.new(0, -0.5, 0)
			HeadA.Orientation = Vector3.new(0, 0, -90)
			HeadA.Axis = Vector3.new(0, -1, 0)
			HeadA.SecondaryAxis = Vector3.new(1, 0, 0)

			local LeftArmA = Instance.new("Attachment")
			LeftArmA.Name = "LeftArmA"
			LeftArmA.Parent = leftarm
			LeftArmA.Position = Vector3.new(0.5, 0.6, 0)
			LeftArmA.Orientation = Vector3.new(0, 0, 0)
			LeftArmA.Axis = Vector3.new(1, 0, 0)
			LeftArmA.SecondaryAxis = Vector3.new(0, 1, 0)

			local LeftLegA = Instance.new("Attachment")
			LeftLegA.Name = "LeftLegA"
			LeftLegA.Parent = leftleg
			LeftLegA.Position = Vector3.new(0.1, 1, -0)
			LeftLegA.Orientation = Vector3.new(-0, -0, -90)
			LeftLegA.Axis = Vector3.new(-0, -1, 0)
			LeftLegA.SecondaryAxis = Vector3.new(1, 0, 0)

			local RightArmA = Instance.new("Attachment")
			RightArmA.Name = "RightArmA"
			RightArmA.Parent = rightarm
			RightArmA.Position = Vector3.new(-0.5, 0.6, 0)
			RightArmA.Orientation = Vector3.new(-180, 0, -180)
			RightArmA.Axis = Vector3.new(-1, 0, 0)
			RightArmA.SecondaryAxis = Vector3.new(0, 1, 0)

			local RightLegA = Instance.new("Attachment")
			RightLegA.Name = "RightLegA"
			RightLegA.Parent = rightleg
			RightLegA.Position = Vector3.new(-0.1, 1, 0)
			RightLegA.Orientation = Vector3.new(0, 0, -90)
			RightLegA.Axis = Vector3.new(-0, -1, -0)
			RightLegA.SecondaryAxis = Vector3.new(1, 0, -0)

			local TorsoA = Instance.new("Attachment")
			TorsoA.Name = "TorsoA"
			TorsoA.Parent = torso
			TorsoA.Position = Vector3.new(0.4, -1, 0)
			TorsoA.Orientation = Vector3.new(0, 0, -90)
			TorsoA.Axis = Vector3.new(0, -1, 0)
			TorsoA.SecondaryAxis = Vector3.new(1, 0, 0)

			local TorsoA1 = Instance.new("Attachment")
			TorsoA1.Name = "TorsoA1"
			TorsoA1.Parent = torso
			TorsoA1.Position = Vector3.new(-0.4, -1, 0)
			TorsoA1.Orientation = Vector3.new(0, 0, -90)
			TorsoA1.Axis = Vector3.new(0, -1, 0)
			TorsoA1.SecondaryAxis = Vector3.new(1, 0, 0)

			local TorsoA2 = Instance.new("Attachment")
			TorsoA2.Name = "TorsoA2"
			TorsoA2.Parent = torso
			TorsoA2.Position = Vector3.new(-1, 0.8, 0)
			TorsoA2.Orientation = Vector3.new(-0, 0, -0)
			TorsoA2.Axis = Vector3.new(1, -0, 0)
			TorsoA2.SecondaryAxis = Vector3.new(0, 1, -0)

			local TorsoA3 = Instance.new("Attachment")
			TorsoA3.Name = "TorsoA3"
			TorsoA3.Parent = torso
			TorsoA3.Position = Vector3.new(1, 0.8, 0)
			TorsoA3.Orientation = Vector3.new(180, 0, 180)
			TorsoA3.Axis = Vector3.new(-1, -0, 0)
			TorsoA3.SecondaryAxis = Vector3.new(-0, 1, -0)

			local TorsoA4 = Instance.new("Attachment")
			TorsoA4.Name = "TorsoA4"
			TorsoA4.Parent = torso
			TorsoA4.Position = Vector3.new(-0, 1, 0)
			TorsoA4.Orientation = Vector3.new(0, 0, -90)
			TorsoA4.Axis = Vector3.new(0, -1, 0)
			TorsoA4.SecondaryAxis = Vector3.new(1, 0, 0)


			local HA = Instance.new("BallSocketConstraint")
			HA.Parent = head
			HA.Attachment0 = HeadA
			HA.Attachment1 = TorsoA4
			HA.Enabled = true

			local LAT = Instance.new("BallSocketConstraint")
			LAT.Parent = leftarm
			LAT.Attachment0 = LeftArmA
			LAT.Attachment1 = TorsoA2
			LAT.Enabled = true

			local RAT = Instance.new("BallSocketConstraint")
			RAT.Parent = rightarm
			RAT.Attachment0 = RightArmA
			RAT.Attachment1 = TorsoA3
			RAT.Enabled = true

			local HA = Instance.new("BallSocketConstraint")
			HA.Parent = head
			HA.Attachment0 = HeadA
			HA.Attachment1 = TorsoA4
			HA.Enabled = true

			local TLL = Instance.new("BallSocketConstraint")
			TLL.Parent = torso
			TLL.Attachment0 = TorsoA1
			TLL.Attachment1 = LeftLegA
			TLL.Enabled = true

			local TRL = Instance.new("BallSocketConstraint")
			TRL.Parent = torso
			TRL.Attachment0 = TorsoA
			TRL.Attachment1 = RightLegA
			TRL.Enabled = true

		else
			------------------------------------------------
			-----------// R15 Ragdoll \\--------------------
			------------------------------------------------

			local head 		= char:FindFirstChild('Head')
			local humanoid 	= char:FindFirstChild('Humanoid') 
			local lua 		= char:FindFirstChild("LeftUpperArm") 
			local lla 		= char:FindFirstChild("LeftLowerArm") 
			local lh 		= char:FindFirstChild("LeftHand") 
			local lul 		= char:FindFirstChild("LeftUpperLeg") 
			local lll 		= char:FindFirstChild("LeftLowerLeg") 
			local lf 		= char:FindFirstChild("LeftFoot") 
			local rul 		= char:FindFirstChild("RightUpperLeg") 
			local rll 		= char:FindFirstChild("RightLowerLeg")
			local rf 		= char:FindFirstChild("RightFoot") 
			local rua 		= char:FindFirstChild("RightUpperArm") 
			local rla 		= char:FindFirstChild("RightLowerArm") 
			local rh 		= char:FindFirstChild("RightHand") 
			local ut 		= char:FindFirstChild("UpperTorso") 
			local lt 		= char:FindFirstChild("LowerTorso") 

			humanoid.PlatformStand = true
			humanoid.AutoRotate = false

			local HA = Instance.new("BallSocketConstraint")
			HA.Parent = head
			HA.Attachment0 = head.NeckRigAttachment
			HA.Attachment1 = ut.NeckRigAttachment
			HA.Enabled = true
			HA.LimitsEnabled = true
			HA.TwistLimitsEnabled = true
			HA.UpperAngle = 90
			HA.TwistLowerAngle = -60
			HA.TwistUpperAngle = 60

			local LAT = Instance.new("BallSocketConstraint")
			LAT.Parent = lua
			LAT.Attachment0 = lua.LeftShoulderRigAttachment
			LAT.Attachment1 = ut.LeftShoulderRigAttachment
			LAT.Enabled = true
			LAT.LimitsEnabled = false
			LAT.TwistLimitsEnabled = false
			LAT.UpperAngle = 180
			LAT.TwistLowerAngle = -90
			LAT.TwistUpperAngle = 0

			local LAT = Instance.new("BallSocketConstraint")
			LAT.Parent = lua
			LAT.Attachment0 = lla.LeftElbowRigAttachment
			LAT.Attachment1 = lua.LeftElbowRigAttachment
			LAT.Enabled = true
			LAT.LimitsEnabled = true
			LAT.TwistLimitsEnabled = true
			LAT.UpperAngle = 0
			LAT.TwistLowerAngle = -160
			LAT.TwistUpperAngle = 0		

			local LAT = Instance.new("BallSocketConstraint")
			LAT.Parent = lua
			LAT.Attachment0 = lla.LeftWristRigAttachment
			LAT.Attachment1 = lh.LeftWristRigAttachment
			LAT.Enabled = true
			LAT.LimitsEnabled = true
			LAT.TwistLimitsEnabled = true
			LAT.UpperAngle = 25
			LAT.TwistLowerAngle = -25
			LAT.TwistUpperAngle = 25

			local RAT = Instance.new("BallSocketConstraint")
			RAT.Parent = rua
			RAT.Attachment0 = rua.RightShoulderRigAttachment
			RAT.Attachment1 = ut.RightShoulderRigAttachment
			RAT.Enabled = true
			RAT.LimitsEnabled = false
			RAT.TwistLimitsEnabled = false
			RAT.UpperAngle = 90
			RAT.TwistLowerAngle = 0
			RAT.TwistUpperAngle = 0

			local RAT = Instance.new("BallSocketConstraint")
			RAT.Parent = rla
			RAT.Attachment0 = rla.RightElbowRigAttachment
			RAT.Attachment1 = rua.RightElbowRigAttachment
			RAT.Enabled = true
			RAT.LimitsEnabled = true
			RAT.TwistLimitsEnabled = true
			RAT.UpperAngle = 0
			RAT.TwistLowerAngle = -160
			RAT.TwistUpperAngle = 0

			local RAT = Instance.new("BallSocketConstraint")
			RAT.Parent = rh
			RAT.Attachment0 = rla.RightWristRigAttachment
			RAT.Attachment1 = rh.RightWristRigAttachment
			RAT.Enabled = true
			RAT.LimitsEnabled = true
			RAT.TwistLimitsEnabled = true
			RAT.UpperAngle = 25
			RAT.TwistLowerAngle = -25
			RAT.TwistUpperAngle = 25


			local TLL = Instance.new("BallSocketConstraint")
			TLL.Parent = ut
			TLL.Attachment0 = ut.WaistRigAttachment
			TLL.Attachment1 = lt.WaistRigAttachment
			TLL.Enabled = true
			TLL.LimitsEnabled = true
			TLL.TwistLimitsEnabled = true
			TLL.UpperAngle = 30
			TLL.TwistLowerAngle = -30
			TLL.TwistUpperAngle = 30

			local TLL = Instance.new("BallSocketConstraint")
			TLL.Parent = rul
			TLL.Attachment0 = rul.RightHipRigAttachment
			TLL.Attachment1 = lt.RightHipRigAttachment
			TLL.Enabled = true
			TLL.LimitsEnabled = true
			TLL.TwistLimitsEnabled = true
			TLL.UpperAngle = 20
			TLL.TwistLowerAngle = -75
			TLL.TwistUpperAngle = 75

			local TLL = Instance.new("BallSocketConstraint")
			TLL.Parent = rll
			TLL.Attachment0 = rll.RightKneeRigAttachment
			TLL.Attachment1 = rul.RightKneeRigAttachment
			TLL.Enabled = true
			TLL.LimitsEnabled = true
			TLL.TwistLimitsEnabled = true
			TLL.UpperAngle = 0
			TLL.TwistLowerAngle = 0
			TLL.TwistUpperAngle = 90

			local TLL = Instance.new("BallSocketConstraint")
			TLL.Parent = rf
			TLL.Attachment0 = rf.RightAnkleRigAttachment
			TLL.Attachment1 = rll.RightAnkleRigAttachment
			TLL.Enabled = true
			TLL.LimitsEnabled = true
			TLL.TwistLimitsEnabled = true
			TLL.UpperAngle = 25
			TLL.TwistLowerAngle = -25
			TLL.TwistUpperAngle = 25

			local TLL = Instance.new("BallSocketConstraint")
			TLL.Parent = lul
			TLL.Attachment0 = lul.LeftHipRigAttachment
			TLL.Attachment1 = lt.LeftHipRigAttachment
			TLL.Enabled = true
			TLL.LimitsEnabled = true
			TLL.TwistLimitsEnabled = true
			TLL.UpperAngle = 30
			TLL.TwistLowerAngle = -90
			TLL.TwistUpperAngle = 90

			local TLL = Instance.new("BallSocketConstraint")
			TLL.Parent = lll
			TLL.Attachment0 = lll.LeftKneeRigAttachment
			TLL.Attachment1 = lul.LeftKneeRigAttachment
			TLL.Enabled = true
			TLL.LimitsEnabled = true
			TLL.TwistLimitsEnabled = true
			TLL.UpperAngle = 0
			TLL.TwistLowerAngle = 0
			TLL.TwistUpperAngle = 90

			local TLL = Instance.new("BallSocketConstraint")
			TLL.Parent = lf
			TLL.Attachment0 = lf.LeftAnkleRigAttachment
			TLL.Attachment1 = lll.LeftAnkleRigAttachment
			TLL.Enabled = true
			TLL.LimitsEnabled = true
			TLL.TwistLimitsEnabled = true
			TLL.UpperAngle = 25
			TLL.TwistLowerAngle = -25
			TLL.TwistUpperAngle = 25
		end

		for i, v in pairs(char:GetDescendants()) do -- replace character with the character
			if not (v:IsA("Accessory") or v:IsA("Model")) and v:IsA("Motor6D") then
				v:Destroy()
			end
		end
		
		if char:FindFirstChild("HumanoidRootPart") ~= nil then
			char.HumanoidRootPart:Destroy()
		end
		
	end
end
