
repeat
	wait()
until game.Players.LocalPlayer.Character
--// Variables
local L_1_ = game.Players.LocalPlayer
local L_2_ = L_1_.Character
local L_3_ = workspace.CurrentCamera
local L_4_ = L_1_:GetMouse()

local L_5_ = game.ReplicatedStorage:WaitForChild('ACS_Engine')
local L_6_ = L_5_:WaitForChild('Eventos')
local L_7_ = L_5_:WaitForChild('ServerConfigs')
local L_8_ = L_5_:WaitForChild('HUD')
local L_9_ = L_5_:WaitForChild('Assets')

--// Body Parts
local L_10_ = L_2_:WaitForChild('Humanoid')

--// Services
local L_11_ = game:GetService('UserInputService')
local L_12_ = game:GetService('TweenService')
local L_13_ = game:GetService('RunService').RenderStepped

--// Modules
local L_14_ = require(L_7_:WaitForChild('Config'))
local L_15_ = require(script.Parent:WaitForChild("Config"))

--// Declarables
local L_16_ = false
local L_17_ = nil

local L_18_ = nil
local L_19_ = CFrame.Angles(0, 0, 0)
local L_20_ = CFrame.new()
local L_21_ = 'Rotate'

local L_22_ = nil

--// Events
local L_23_ = L_6_:WaitForChild('PlaceEvent')

--// Functions
function placementVector(L_24_arg1, L_25_arg2, L_26_arg3, L_27_arg4)
	if L_25_arg2 then
		local L_28_ = L_26_arg3 + Vector3.new(0, 0.1, 0)

		local L_29_ = Ray.new(L_28_, Vector3.new(0, -1, 0))
		local L_30_, L_31_, L_32_ = workspace:FindPartOnRay(L_29_, L_24_arg1)

		local L_33_ = Vector3.new(0, 1, 0):Cross(L_32_)
		local L_34_ = math.asin(L_33_.magnitude)
 
		L_24_arg1:SetPrimaryPartCFrame(L_24_arg1.PrimaryPart.CFrame:lerp(CFrame.new(L_31_ + L_32_ * L_24_arg1.PrimaryPart.Size.y / 2) * CFrame.fromAxisAngle(L_33_.magnitude == 0 and Vector3.new(1) or L_33_.unit, L_34_) * L_20_ * L_19_, L_27_arg4))
	end
end

--// Connections
L_2_.ChildAdded:connect(function(L_35_arg1)
	if L_35_arg1:IsA('Tool') and L_35_arg1:FindFirstChild('ACS_Setup') and L_10_.Health > 0 and require(L_35_arg1.ACS_Setup).Type == 'Build' and L_14_.BuildingEnabled then
		L_17_ = L_35_arg1
		
		L_22_ = L_8_:WaitForChild('PlacementUI'):clone()
		L_22_.Parent = L_1_.PlayerGui
		L_22_.Frame.Visible = true
		
		for L_36_forvar1, L_37_forvar2 in pairs(L_9_:GetChildren()) do
			if L_37_forvar2:IsA('Model') and L_37_forvar2.PrimaryPart then
				local L_38_ = L_22_:WaitForChild('Template'):WaitForChild('TemplateButton'):clone()
				L_38_.Parent = L_22_:WaitForChild('Frame'):WaitForChild('AssetListFrame')
				L_38_.Visible = true
				L_38_.Name = L_37_forvar2.Name
				L_38_.Text = L_37_forvar2.Name
				
				L_38_.MouseButton1Click:connect(function()
					if not L_16_ then
						if L_15_.ResourcesEnabled then
							if L_1_.Team and L_1_.Team:FindFirstChild('Resources') and L_1_.Team.Resources.Value > 0 then
								L_18_ = L_9_:WaitForChild(L_38_.Name):clone()
								L_18_.Parent = workspace:FindFirstChild('Buildables') or workspace
								L_16_ = true
							end
						else
							L_18_ = L_9_:WaitForChild(L_38_.Name):clone()
							L_18_.Parent = workspace:FindFirstChild('Buildables') or workspace
							L_16_ = true
						end;
					end
				end)
			end
		end
	end;
end)

L_2_.ChildRemoved:connect(function(L_39_arg1)
	if L_39_arg1 == L_17_ and L_14_.BuildingEnabled then
		L_22_:Destroy()
	end;
end)

--// Input Connections
L_11_.InputBegan:connect(function(L_40_arg1, L_41_arg2)
	if not L_41_arg2 and L_14_.BuildingEnabled then
		if L_40_arg1.KeyCode == Enum.KeyCode.Q then
			if L_21_ == 'Rotate' then
				L_19_ = L_19_ * CFrame.Angles(0, math.rad(L_15_.RotInc), 0)
			elseif L_21_ == 'Move' then
				L_20_ = L_20_ * CFrame.new(0, L_15_.MoveInc, 0)
			end
		end;
		
		if L_40_arg1.KeyCode == Enum.KeyCode.E then
			if L_21_ == 'Rotate' then
				L_19_ = L_19_ * CFrame.Angles(0, math.rad(-L_15_.RotInc), 0)
			elseif L_21_ == 'Move' then
				L_20_ = L_20_ * CFrame.new(0, -L_15_.MoveInc, 0)
			end
		end;
		
		if L_40_arg1.KeyCode == Enum.KeyCode.G then
			if L_21_ == 'Rotate' then
				L_19_ = L_19_ * CFrame.Angles(0, 0, math.rad(L_15_.RotInc))
			elseif L_21_ == 'Move' then
				L_20_ = L_20_ * CFrame.new(0, 0, L_15_.MoveInc)
			end
		end;
		
		if L_40_arg1.KeyCode == Enum.KeyCode.H then
			if L_21_ == 'Rotate' then
				L_19_ = L_19_ * CFrame.Angles(0, 0, math.rad(-L_15_.RotInc))
			elseif L_21_ == 'Move' then
				L_20_ = L_20_ * CFrame.new(0, 0, -L_15_.MoveInc)
			end
		end;
		
		if L_40_arg1.KeyCode == Enum.KeyCode.V then
			if L_21_ == 'Rotate' then
				L_19_ = L_19_ * CFrame.Angles(math.rad(L_15_.RotInc), 0, 0)
			elseif L_21_ == 'Move' then
				L_20_ = L_20_ * CFrame.new(L_15_.MoveInc, 0, 0)
			end
		end;
		
		if L_40_arg1.KeyCode == Enum.KeyCode.B then
			if L_21_ == 'Rotate' then	
				L_19_ = L_19_ * CFrame.Angles(math.rad(-L_15_.RotInc), 0, 0)
			elseif L_21_ == 'Move' then
				L_20_ = L_20_ * CFrame.new(-L_15_.MoveInc, 0, 0)
			end
		end;
	
		if L_40_arg1.KeyCode == Enum.KeyCode.F then
			if L_21_ == 'Rotate' then
				L_21_ = 'Move'
			elseif L_21_ == 'Move' then
				L_21_ = 'Rotate'
			end
		end;
		
		if L_40_arg1.UserInputType == Enum.UserInputType.MouseButton1 then
			if not L_18_ and not L_16_ then
					
			elseif L_18_ and L_16_ then
				local L_42_ = 'HalfRot'
				local L_43_ = false
				local L_44_ = L_18_:GetDescendants()
				for L_45_forvar1, L_46_forvar2 in pairs(L_44_) do
					if L_46_forvar2:IsA('Seat') and L_46_forvar2.Name == 'WBTurretSeat' then
						L_43_ = true
						local L_47_ = L_1_.PlayerGui:WaitForChild('PlacementUI'):WaitForChild('OptionFrame')
						L_47_.Position = UDim2.new(0, L_4_.X - L_47_.AbsoluteSize.X, 0, L_4_.Y - L_47_.AbsoluteSize.Y)
						L_47_.Visible = true
						
						for L_48_forvar1, L_49_forvar2 in pairs(L_47_:GetChildren()) do
							if L_49_forvar2:IsA('TextButton') then
								L_49_forvar2.MouseButton1Click:connect(function()
									if L_49_forvar2.Name == 'FRot' then
										L_42_ = 'FullRot'
									elseif L_49_forvar2.Name == 'HRot' then
										L_42_ = 'HalfRot'
									end
									L_47_.Visible = false
									L_47_.Position = UDim2.new(0, 0, 0, 0)
								end)
							end
						end
					end
				end;
				
				if (L_4_.Hit.p - L_2_:WaitForChild('HumanoidRootPart').Position).magnitude <= L_15_.MaxDist then
					L_23_:FireServer(L_18_.Name, L_18_.PrimaryPart.CFrame, L_4_.Target, L_43_, L_42_, 'Place')
					L_18_:Destroy()
					L_19_ = CFrame.Angles(0, 0, 0)
					L_20_ = CFrame.new()
					L_16_ = false
				end;
			end
		end;
	end
end)

--// Renders
L_13_:connect(function(L_50_arg1)
	if L_16_ and L_14_.BuildingEnabled then
		L_4_.TargetFilter = L_18_
		placementVector(L_18_, L_4_.Target, L_4_.Hit.p, L_50_arg1 * L_15_.SpeedMult)
	end;
end)