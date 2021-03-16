local main = script.Parent
local reconcilers
local replacers

local function getTransform(self, value)
	local result = rawget(self.Transform, value)

	if self.BehaviorMap[result] then
		return true, result()
	else
		return result ~= nil, true, result
	end
end

local switchBehavior = {}

function switchBehavior.transform(self, value)
	local transSuccess, transDoSet, transCopy = getTransform(self, value)
	if transSuccess then
		return true, transDoSet, transCopy
	else
		return false
	end
end

function switchBehavior.reconcile(self, value, newValue)
	local typeof_value = typeof(value)
	local handler = reconcilers[typeof_value]
	if handler and typeof_value == typeof(newValue) then
		return handler(self, value, newValue)
	else
		return false
	end
end

function switchBehavior.replace(self, value)
	local typeof_value = typeof(value)
	local handler = replacers[typeof_value]
	if handler then
		return handler(self, value)
	else
		return false
	end
end

function switchBehavior.pass()
	return true, false, nil
end

local Behaviors = {
	handlers = switchBehavior,
	presets = {
		default = { "transform", "reconcile", "replace" },
		set = {},
	},
}

local behaviorEnumArray = {}
for key in pairs(switchBehavior) do
	table.insert(behaviorEnumArray, string.format("%q", key))
end
Behaviors.BEHAVIOR_ENUM = table.concat(behaviorEnumArray, ", ")

local function errorUnknownBehavior(behavior)
	error(
		string.format(
			"Unknown behavior (%q) found. The only allowed behaviors are %s.",
			tostring(behavior),
			Behaviors.BEHAVIOR_ENUM
		),
		2
	)
end

setmetatable(switchBehavior, {
	__index = function(_, behavior)
		errorUnknownBehavior(behavior)
	end,
})

function Behaviors.handleValue(self, behaviors, value, midValue)
	for _, behavior in ipairs(behaviors) do
		local success, doSet, newValue = switchBehavior[behavior](self, value, midValue)
		if success then
			return doSet, newValue
		end
	end
	return true, value
end

function Behaviors.assert(behavior)
	if rawget(switchBehavior, behavior) ~= nil then
		return behavior
	end
	errorUnknownBehavior(behavior)
end

function Behaviors.init()
	reconcilers = require(main.Reconcilers)
	replacers = require(main.Replacers)
end

return Behaviors
