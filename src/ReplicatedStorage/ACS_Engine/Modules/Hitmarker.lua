local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")

local Glass = {"1565824613"; "1565825075";}
local Metal = {"282954522"; "282954538"; "282954576"; "1565756607"; "1565756818";}
local Grass = {"1565830611"; "1565831129"; "1565831468"; "1565832329";}
local Wood = {"287772625"; "287772674"; "287772718"; "287772829"; "287772902";}
local Concrete = {"287769261"; "287769348"; "287769415"; "287769483"; "287769538";}
local Explosion = {"287390459"; "287390954"; "287391087"; "287391197"; "287391361"; "287391499"; "287391567";}
local Cracks = {"342190504"; "342190495"; "342190488"; "342190510";} -- Bullet Cracks
local Hits = {"363818432"; "363818488"; "363818567"; "363818611"; "363818653";} -- Player
local Headshots = {"4459572527"; "4459573786";"3739364168";}
local Whizz = {"342190005"; "342190012"; "342190017"; "342190024";} -- Bullet Whizz

local Effects = RS.ACS_Engine.HITFX

local Hitmarker = {}

function CheckColor(Color,Add)
	Color = Color + Add
	if Color > 1 then
		Color = 1
	elseif Color < 0 then
		Color = 0
	end
	return Color
end

function CreateEffect(Type, Attachment, ColorAdjust, HitPart)
	local NewType
	if Effects:FindFirstChild(Type) then
		NewType = Effects:FindFirstChild(Type)
	else
		NewType = Effects.Stone -- Default to Stone/Concrete
	end
	local NewEffect = NewType:GetChildren()[math.random(1,#NewType:GetChildren())]:Clone()
	local MaxTime = 3 -- Placeholder for max time of total effect
	for _, Effect in pairs(NewEffect:GetChildren()) do
		Effect.Parent = Attachment
		Effect.Enabled = false

		if ColorAdjust and HitPart then
			local NewColor = HitPart.Color
			local Add = 0.3
			if HitPart.Material == Enum.Material.Fabric then
				Add = -0.2 -- Darker
			end

			NewColor = Color3.new(CheckColor(NewColor.R, Add),CheckColor(NewColor.G, Add),CheckColor(NewColor.B, Add)) -- Adjust new color

			Effect.Color = ColorSequence.new({ -- Set effect color
				ColorSequenceKeypoint.new(0,NewColor),
				ColorSequenceKeypoint.new(1,NewColor)
			})
		end

		Effect:Emit(Effect.Rate / 10) -- Calculate how many particles emit based on rate
		if Effect.Lifetime.Max > MaxTime then
			MaxTime = Effect.Lifetime.Max
		end
	end
	local HitSound = Instance.new("Sound")
	local SoundType -- Convert Type to equivalent sound table
	if Type == "Headshot" then
		SoundType = Headshots
	elseif Type == "Hit" then
		SoundType = Hits
	elseif Type == "Glass" then
		SoundType = Glass
	elseif Type == "Metal" then
		SoundType = Metal
	elseif Type == "Ground" then
		SoundType = Grass
	elseif Type == "Wood" then
		SoundType = Wood
	elseif Type == "Stone" then
		SoundType = Concrete
	else
		SoundType = Concrete -- Default to Stone/Concrete
	end
	HitSound.Parent = Attachment
	HitSound.Volume = math.random(5, 10) / 10
	HitSound.RollOffMaxDistance = 500
	HitSound.RollOffMinDistance = 10
	HitSound.PlaybackSpeed = math.random(34, 50) / 40
	HitSound.SoundId = "rbxassetid://" .. SoundType[math.random(1, #SoundType)]
	HitSound:Play()

	if HitSound.TimeLength > MaxTime then
		MaxTime = HitSound.TimeLength
	end

	Debris:AddItem(Attachment, MaxTime) -- Destroy attachment after all effects and sounds are done
end


function Hitmarker.HitEffect(ray_ignore, position, hit_part, normal, material, settings)
	--print(HitPart)
	local attachment = Instance.new("Attachment")
	attachment.CFrame = CFrame.new(position, position + normal)
	attachment.Parent = workspace.Terrain

	if hit_part then
		if (hit_part.Name == "Head" or hit_part.Parent.Name == "Top") then

			CreateEffect("Headshot", attachment)

		elseif hit_part:IsA("BasePart") and (hit_part.Parent:FindFirstChild("Humanoid") or hit_part.Parent.Parent:FindFirstChild("Humanoid") or (hit_part.Parent.Parent.Parent and hit_part.Parent.Parent.Parent:FindFirstChild("Humanoid"))) then

			CreateEffect("Hit", attachment)

		elseif hit_part.Parent:IsA("Accessory") then -- Didn't feel like putting this in the other one

			CreateEffect("Hit", attachment)

		elseif material == Enum.Material.Wood or material == Enum.Material.WoodPlanks then

			CreateEffect("Wood", attachment)

		elseif material == Enum.Material.Concrete -- Stone stuff
			or material == Enum.Material.Slate
			or material == Enum.Material.Brick
			or material == Enum.Material.Pebble
			or material == Enum.Material.Cobblestone
			or material == Enum.Material.Marble

			-- Terrain materials
			or material == Enum.Material.Basalt
			or material == Enum.Material.Asphalt
			or material == Enum.Material.Pavement
			or material == Enum.Material.Rock
			or material == Enum.Material.CrackedLava
			or material == Enum.Material.Sandstone
			or material == Enum.Material.Limestone
		then

			CreateEffect("Stone", attachment)

		elseif material == Enum.Material.Metal -- Metals
			or material == Enum.Material.CorrodedMetal
			or material == Enum.Material.DiamondPlate
			or material == Enum.Material.Neon

			-- Terrain materials
			or material == Enum.Material.Salt
		then

			CreateEffect("Metal", attachment)

		elseif material == Enum.Material.Grass -- Ground stuff

			-- Terrain materials
			or material == Enum.Material.Ground
			or material == Enum.Material.LeafyGrass
			or material == Enum.Material.Mud
		then

			CreateEffect("Ground", attachment)

		elseif material == Enum.Material.Sand -- Soft things
			or material == Enum.Material.Fabric

			-- Terrain materials
			or material == Enum.Material.Snow
		then

			CreateEffect("Sand", attachment, true, hit_part)

		elseif material == Enum.Material.Foil -- Brittle things
			or material == Enum.Material.Ice
			or material == Enum.Material.Glass
			or material == Enum.Material.ForceField
		then

			CreateEffect("Glass", attachment, true, hit_part)

		else

			CreateEffect("Stone", attachment)

		end
	end
end

function Hitmarker.Explosion(Position, HitPart, Normal)

	local Hitmark = Instance.new("Attachment")
	Hitmark.CFrame = CFrame.new(Position, Position + Normal)
	Hitmark.Parent = workspace.Terrain

	local S = Instance.new("Sound")
	S.RollOffMinDistance = 50
	S.RollOffMaxDistance = 1500
	S.SoundId = "rbxassetid://".. Explosion[math.random(1, 7)]
	S.PlaybackSpeed = math.random(30,55)/40
	S.Volume = 2
	S.Parent = Hitmark
	S.PlayOnRemove = true
	S:Destroy()

	local Exp = Instance.new("Explosion")
	Exp.BlastPressure = 0
	Exp.BlastRadius = 0
	Exp.DestroyJointRadiusPercent = 0
	Exp.Position = Hitmark.Position
	Exp.Parent = Hitmark

	Debris:AddItem(Hitmark, 5)

end

return Hitmarker