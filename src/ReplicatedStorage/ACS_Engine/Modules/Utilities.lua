local RS = game:GetService("ReplicatedStorage")

local Engine = RS:WaitForChild("ACS_Engine")
local Modules = Engine:WaitForChild("Modules")
local CoreModules = Modules:WaitForChild("Core")

local ObjectPool = require(CoreModules:WaitForChild("ObjectPool"))

local Utilities = {}

function Utilities.Weld(p1, p2, c0, c1)
	local w = Instance.new("Motor6D")
	w.Part0 = p1
	w.Part1 = p2
	w.Name = p2.Name
	w.Parent = p1
	w.C0 = c0 or p1.CFrame:inverse() * p2.CFrame
	w.C1 = c1 or CFrame.new()
	return w
end

function Utilities.WeldComplex(x,y,Name)
	local W = Instance.new("Motor6D")
	W.Name = Name
	W.Part0 = x
	W.Part1 = y
	local CJ = CFrame.new(x.Position)
	local C0 = x.CFrame:inverse()*CJ
	local C1 = y.CFrame:inverse()*CJ
	W.C0 = C0
	W.C1 = C1
	W.Parent = x
	return W
end

function Utilities.CheckForHumanoid(hit_part)
	local has_humanoid = false
	local target_humanoid = nil
	if hit_part then
		if hit_part.Parent:FindFirstChildOfClass("Humanoid" or hit_part.Parent.Parent:FindFirstChildOfClass("Humanoid")) then
			has_humanoid = true
			if hit_part.Parent:FindFirstChildOfClass('Humanoid') then
				target_humanoid = hit_part.Parent:FindFirstChildOfClass('Humanoid')
			elseif hit_part.Parent.Parent:FindFirstChildOfClass('Humanoid') then
				target_humanoid = hit_part.Parent.Parent:FindFirstChildOfClass('Humanoid')
			end
		else
			has_humanoid = false
		end
	end
	return has_humanoid, target_humanoid
end

function Utilities.RAND(min, max, accuracy)
	local inverse = 1 / (accuracy or 1)
	return (math.random(min * inverse, max * inverse) / inverse)
end

--================================================================
-- @ddydddd9 - Moonlight
--================================================================

-- Safe modulescript loading with validation
function Utilities.SafeRequire(module_script)
	if not module_script or not module_script:IsA("ModuleScript") then
		warn("Invalid module script")
		return nil
	end
	
	local success, result = pcall(require, module_script)
	if not success then
		warn("Failed to require module: ", result)
		return nil
	end
	
	if typeof(result) ~= "table" then
		warn("Module must return a table")
		return nil
	end
	
	return result
end

function Utilities.RegisterPool(pool_name, create_function, reset_function, default_size)
	pcall(function()
		ObjectPool.Register(pool_name, create_function, reset_function, default_size)
	end)
end

function Utilities.CountDictionary(dictionary)
	local count = 0
	for _ in pairs(dictionary) do
		count += 1
	end

	return count
end

function Utilities.Log(message: any)
	print(string.format("%s", tostring(message)))
end

function Utilities.LogTagged(title: string, description: string)
	assert(title and description ~= "string" , "Must be a string")
	print(string.format("[%s] %s", title, description))
end

return Utilities