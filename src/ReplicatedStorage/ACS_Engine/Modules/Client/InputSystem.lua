--[[
	InputSystem.lua
	Created by @ddydddd9 - Moonlight

	Core input dispatcher with gamepad support, action binding,
	and listener management for unified input handling
]]

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local InputSystem = {}
InputSystem.__index = InputSystem

local Binds = {}
local Listeners = {}
local AxisListeners = {}

local function Fire(action, state, input)
	if not Listeners[action] then return end
	for _, callback in ipairs(Listeners[action]) do
		callback(state, input)
	end
end

local function FireAxis(action, vector, input)
	if not AxisListeners[action] then return end
	for _, callback in ipairs(AxisListeners[action]) do
		callback(vector, input)
	end
end

function InputSystem.Bind(action, inputs)
	if Binds[action] then
		warn("Action '" .. action .. "' is already bound. Unbind it first.")
		return
	end

	for _, input in ipairs(inputs) do
		for existing_action, existing_inputs in pairs(Binds) do
			for _, ex_input in ipairs(existing_inputs) do
				if ex_input == input then
					warn(string.format("[InputSystem] Input '%s' is already bound to action '%s'", tostring(input), existing_action))
				end
			end
		end
	end

	ContextActionService:BindAction(action, function(_, state, input)
		Fire(action, state, input)
		return Enum.ContextActionResult.Sink
	end, false, unpack(inputs))

	Binds[action] = inputs
end

function InputSystem.Unbind(action)
	ContextActionService:UnbindAction(action)
	Binds[action] = nil
end

function InputSystem.BindAxis(action, inputType)
	if AxisListeners[action] then return end
	AxisListeners[action] = {}

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == inputType then
			FireAxis(action, input.Position, input)
		end
	end)
end

function InputSystem.Listen(action, callback)
	if not Listeners[action] then
		Listeners[action] = {}
	end

	table.insert(Listeners[action], callback)

	return function()
		for i, v in ipairs(Listeners[action]) do
			if v == callback then
				table.remove(Listeners[action], i)
				break
			end
		end
	end
end

function InputSystem.ListenAxis(action, callback)
	if not AxisListeners[action] then
		AxisListeners[action] = {}
	end

	table.insert(AxisListeners[action], callback)

	return function()
		for i, v in ipairs(AxisListeners[action]) do
			if v == callback then
				table.remove(AxisListeners[action], i)
				break
			end
		end
	end
end

function InputSystem.IsDown(keycode)
	return UserInputService:IsKeyDown(keycode)
end

function InputSystem.ClearAll()
	for action in pairs(Binds) do
		ContextActionService:UnbindAction(action)
	end

	Binds = {}
	Listeners = {}
	AxisListeners = {}
end

return InputSystem
