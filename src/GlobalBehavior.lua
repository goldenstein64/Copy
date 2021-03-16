local main = script.Parent
local Behaviors = require(main.Behaviors)

local globalBehavior = {
	[newproxy(false)] = {
		Keys = {},
		Values = { "transform", "reconcile", "replace" },
		Meta = {},
	},
}

local CONTEXT_ENUM = {}
local allContexts = {}
do
	local real = select(2, next(globalBehavior))

	for context in pairs(real) do
		allContexts[context] = true
		table.insert(CONTEXT_ENUM, string.format("%q", context))
	end

	CONTEXT_ENUM = table.concat(CONTEXT_ENUM, ", ")
end

local errorFormats = {
	Context = string.format("Unknown context %%q found. The only allowed contexts are %s.", CONTEXT_ENUM),
	Behavior = string.format("Unknown behavior %%q found. The only allowed behaviors are %s.", Behaviors.BEHAVIOR_ENUM),
}

local function errorContext(context)
	error(string.format(errorFormats.Context, tostring(context)), 2)
end

local function errorBehavior(behavior)
	error(string.format(errorFormats.Behavior, tostring(behavior)), 2)
end

local globalBehaviorMt = {}

function globalBehaviorMt:__index(context)
	local real = select(2, next(self))
	local behavior = rawget(real, context)
	if behavior == nil then
		errorContext(context)
	else
		return behavior
	end
end

function globalBehaviorMt:__newindex(context, behaviors)
	local real = select(2, next(self))
	local typeof_behaviors = typeof(behaviors)

	local found_behaviors = Behaviors.presets[behaviors]
	if allContexts[context] == nil then
		errorContext(context)
	elseif found_behaviors then
		rawset(real, context, found_behaviors)
	elseif typeof_behaviors == "string" then
		if rawget(Behaviors.handlers, behaviors) ~= nil then
			rawset(real, context, { behaviors })
		else
			errorBehavior(behaviors)
		end
	elseif typeof_behaviors == "table" then
		for _, behavior in ipairs(behaviors) do
			if rawget(Behaviors.handlers, behavior) == nil then
				errorBehavior(behavior)
			end
		end

		rawset(real, context, behaviors)
	else
		errorBehavior(behaviors)
	end
end

setmetatable(globalBehavior, globalBehaviorMt)

return globalBehavior
