local main = script.Parent
local reconcilers
local replacers

local function getTransform(self, value)
	local result = rawget(self.Transform, value)

	if self.SymbolMap[result] then
		return true, result(value)
	else
		return result ~= nil, true, result
	end
end

local behaviorHandlers = {}

function behaviorHandlers.transform(self, value)
	local transSuccess, transDoSet, transCopy = getTransform(self, value)
	if transSuccess then
		return true, transDoSet, transCopy
	else
		return false, false, nil
	end
end

function behaviorHandlers.reconcile(self, value, newValue)
	local typeof_value = typeof(value)
	local handler = reconcilers[typeof_value]
	if handler and typeof_value == typeof(newValue) then
		return handler(self, value, newValue)
	else
		return false, false, nil
	end
end

function behaviorHandlers.replace(self, value)
	local typeof_value = typeof(value)
	local handler = replacers[typeof_value]
	if handler then
		return handler(self, value)
	else
		return false, false, nil
	end
end

function behaviorHandlers.pass()
	return true, false, nil
end

local Behaviors = {
	Behaviors = behaviorHandlers,

	Presets = {
		default = { "transform", "reconcile", "replace" },
		copy = { "replace" },
		set = {},
	},
}

Behaviors.Enum = {}
local enumString = {}
for behavior in pairs(behaviorHandlers) do
	Behaviors.Enum[behavior] = true
	table.insert(enumString, behavior)
end

enumString = table.concat(enumString, ", ")
local function errorUnknownBehavior(behavior)
	error(
		string.format(
			"Unknown behavior (%q) found. The only allowed behaviors are %s.",
			tostring(behavior),
			enumString
		),
		2
	)
end

setmetatable(behaviorHandlers, {
	__index = function(_, behavior)
		errorUnknownBehavior(behavior)
	end,
})

function Behaviors.HandleValue(self, behaviors, value, midValue)
	for _, behavior in ipairs(behaviors) do
		local success, doSet, newValue = behaviorHandlers[behavior](self, value, midValue)
		if success then
			return doSet, newValue
		end
	end
	return true, value
end

function Behaviors.Convert(behaviors)
	local typeof_behaviors = typeof(behaviors)
	local preset_behavior = Behaviors.Presets[behaviors]
	if preset_behavior then
		return preset_behavior

	elseif Behaviors.Enum[behaviors] then
		return { behaviors }

	elseif typeof_behaviors == "table" then
		for _, behavior in ipairs(behaviors) do
			if not Behaviors.Enum[behavior] then
				errorUnknownBehavior(behavior)
			end
		end
		return behaviors

	else
		errorUnknownBehavior(behaviors)
	end
end

function Behaviors.Init()
	reconcilers = require(main.Reconcilers)
	replacers = require(main.Replacers)
end

return Behaviors
