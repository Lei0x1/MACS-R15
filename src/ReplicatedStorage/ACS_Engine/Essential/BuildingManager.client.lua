
repeat
	wait()
until game.Players.LocalPlayer.Character
--// Variables
local Player = game.Players.LocalPlayer
local Character = Player.Character
local CurrentCamera = workspace.CurrentCamera
local PlayerMouse = Player:GetMouse()

local ACS_Engine = game.ReplicatedStorage:WaitForChild('ACS_Engine')
local Event = ACS_Engine:WaitForChild("Events")
local GameRules = ACS_Engine:WaitForChild("GameRules")
local HUD = ACS_Engine:WaitForChild('HUD')
local Assets = ACS_Engine:WaitForChild('Assets')

--// Body Parts
local Humanoid = Character:WaitForChild('Humanoid')

--// Services
local UIS = game:GetService('UserInputService')
local Tween = game:GetService('TweenService')
local Run = game:GetService('RunService').RenderStepped

--// Modules
local Config = require(GameRules:WaitForChild('Config'))
local EssenTialConfig = require(script.Parent:WaitForChild("Config"))

--// Declarables
local IsPlacing = false
local EquippedTool = nil

local ActivePreviewModel = nil
local RotationOffset = CFrame.Angles(0, 0, 0)
local TranslationOffset = CFrame.new()
local TransformMode = 'Rotate'

local PlacementUI = nil

--// Events
local PlaceEvent = Event:WaitForChild('PlaceEvent')

--// Functions
function placementVector(model, hit_part, hit_position, lerp_alpha)
	if hit_part then
		local ray_origin  = hit_position + Vector3.new(0, 0.1, 0)
		local ray = Ray.new(ray_origin , Vector3.new(0, -1, 0))

		local _, surface_position, surface_normal = workspace:FindPartOnRay(ray, model)

		local rotation_axis = Vector3.new(0, 1, 0):Cross(surface_normal)
		local rotation_angle = math.asin(rotation_axis.Magnitude)
 
		model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame:lerp(CFrame.new(surface_position + surface_normal * model.PrimaryPart.Size.y / 2) * CFrame.fromAxisAngle(rotation_axis.Magnitude == 0 and Vector3.new(1) or rotation_axis.Unit, rotation_angle) * TranslationOffset * RotationOffset, lerp_alpha))
	end
end

--// Connections
Character.ChildAdded:Connect(function(tool)
	if tool:IsA('Tool') and tool:FindFirstChild('ACS_Setup') and Humanoid.Health > 0 and require(tool.ACS_Setup).Type == 'Build' and Config.BuildingEnabled then
		EquippedTool = tool
		
		PlacementUI = HUD:WaitForChild('PlacementUI'):Clone()
		PlacementUI.Parent = Player.PlayerGui
		PlacementUI.Frame.Visible = true
		
		for _, asset in pairs(Assets:GetChildren()) do
			if asset:IsA('Model') and asset.PrimaryPart then
				local asset_button = PlacementUI:WaitForChild('Template'):WaitForChild('TemplateButton'):Clone()
				asset_button.Parent = PlacementUI:WaitForChild('Frame'):WaitForChild('AssetListFrame')
				asset_button.Visible = true
				asset_button.Name = asset.Name
				asset_button.Text = asset.Name
				
				asset_button.MouseButton1Click:connect(function()
					if not IsPlacing then
						if EssenTialConfig.ResourcesEnabled then
							if Player.Team and Player.Team:FindFirstChild('Resources') and Player.Team.Resources.Value > 0 then
								ActivePreviewModel = Assets:WaitForChild(asset_button.Name):Clone()
								ActivePreviewModel.Parent = workspace:FindFirstChild('Buildables') or workspace
								IsPlacing = true
							end
						else
							ActivePreviewModel = Assets:WaitForChild(asset_button.Name):Clone()
							ActivePreviewModel.Parent = workspace:FindFirstChild('Buildables') or workspace
							IsPlacing = true
						end;
					end
				end)
			end
		end
	end;
end)

Character.ChildRemoved:Connect(function(L_39_arg1)
	if L_39_arg1 == EquippedTool and Config.BuildingEnabled then
		PlacementUI:Destroy()
	end;
end)

--// Input Connections
UIS.InputBegan:Connect(function(L_40_arg1, L_41_arg2)
	if not L_41_arg2 and Config.BuildingEnabled then
		if L_40_arg1.KeyCode == Enum.KeyCode.Q then
			if TransformMode == 'Rotate' then
				RotationOffset = RotationOffset * CFrame.Angles(0, math.rad(EssenTialConfig.RotInc), 0)
			elseif TransformMode == 'Move' then
				TranslationOffset = TranslationOffset * CFrame.new(0, EssenTialConfig.MoveInc, 0)
			end
		end;
		
		if L_40_arg1.KeyCode == Enum.KeyCode.E then
			if TransformMode == 'Rotate' then
				RotationOffset = RotationOffset * CFrame.Angles(0, math.rad(-EssenTialConfig.RotInc), 0)
			elseif TransformMode == 'Move' then
				TranslationOffset = TranslationOffset * CFrame.new(0, -EssenTialConfig.MoveInc, 0)
			end
		end;
		
		if L_40_arg1.KeyCode == Enum.KeyCode.G then
			if TransformMode == 'Rotate' then
				RotationOffset = RotationOffset * CFrame.Angles(0, 0, math.rad(EssenTialConfig.RotInc))
			elseif TransformMode == 'Move' then
				TranslationOffset = TranslationOffset * CFrame.new(0, 0, EssenTialConfig.MoveInc)
			end
		end;
		
		if L_40_arg1.KeyCode == Enum.KeyCode.H then
			if TransformMode == 'Rotate' then
				RotationOffset = RotationOffset * CFrame.Angles(0, 0, math.rad(-EssenTialConfig.RotInc))
			elseif TransformMode == 'Move' then
				TranslationOffset = TranslationOffset * CFrame.new(0, 0, -EssenTialConfig.MoveInc)
			end
		end;
		
		if L_40_arg1.KeyCode == Enum.KeyCode.V then
			if TransformMode == 'Rotate' then
				RotationOffset = RotationOffset * CFrame.Angles(math.rad(EssenTialConfig.RotInc), 0, 0)
			elseif TransformMode == 'Move' then
				TranslationOffset = TranslationOffset * CFrame.new(EssenTialConfig.MoveInc, 0, 0)
			end
		end;
		
		if L_40_arg1.KeyCode == Enum.KeyCode.B then
			if TransformMode == 'Rotate' then	
				RotationOffset = RotationOffset * CFrame.Angles(math.rad(-EssenTialConfig.RotInc), 0, 0)
			elseif TransformMode == 'Move' then
				TranslationOffset = TranslationOffset * CFrame.new(-EssenTialConfig.MoveInc, 0, 0)
			end
		end;
	
		if L_40_arg1.KeyCode == Enum.KeyCode.F then
			if TransformMode == 'Rotate' then
				TransformMode = 'Move'
			elseif TransformMode == 'Move' then
				TransformMode = 'Rotate'
			end
		end;
		
		if L_40_arg1.UserInputType == Enum.UserInputType.MouseButton1 then
			if not ActivePreviewModel and not IsPlacing then
					
			elseif ActivePreviewModel and IsPlacing then
				local L_42_ = 'HalfRot'
				local L_43_ = false
				local L_44_ = ActivePreviewModel:GetDescendants()
				for L_45_forvar1, L_46_forvar2 in pairs(L_44_) do
					if L_46_forvar2:IsA('Seat') and L_46_forvar2.Name == 'WBTurretSeat' then
						L_43_ = true
						local L_47_ = Player.PlayerGui:WaitForChild('PlacementUI'):WaitForChild('OptionFrame')
						L_47_.Position = UDim2.new(0, PlayerMouse.X - L_47_.AbsoluteSize.X, 0, PlayerMouse.Y - L_47_.AbsoluteSize.Y)
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
				
				if (PlayerMouse.Hit.Position - Character:WaitForChild('HumanoidRootPart').Position).magnitude <= EssenTialConfig.MaxDist then
					PlaceEvent:FireServer(ActivePreviewModel.Name, ActivePreviewModel.PrimaryPart.CFrame, PlayerMouse.Target, L_43_, L_42_, 'Place')
					ActivePreviewModel:Destroy()
					RotationOffset = CFrame.Angles(0, 0, 0)
					TranslationOffset = CFrame.new()
					IsPlacing = false
				end;
			end
		end;
	end
end)

--// Renders
Run:connect(function(L_50_arg1)
	if IsPlacing and Config.BuildingEnabled then
		PlayerMouse.TargetFilter = ActivePreviewModel
		placementVector(ActivePreviewModel, PlayerMouse.Target, PlayerMouse.Hit.Position, L_50_arg1 * EssenTialConfig.SpeedMult)
	end;
end)