--[[

The Copy Module
A library for copying any value with state.

Author: goldenstein64
Free Model: https://www.roblox.com/library/5089132938
GitHub: https://github.com/goldenstein64/Copy
Docs: TBD

ver 1

--]]

-- Dependencies
local Instances = require(script.Instances)
local Behaviors = require(script.Behaviors)
local CopyMt = require(script.CopyMeta)
local Reconcilers = require(script.Reconcilers)
local GlobalBehavior = require(script.GlobalBehavior)
local Symbol = require(script.Symbol)

Behaviors.init()

-- Private Functions
local function attemptFlush(self)
	if self.Flags.Flush then
		self:Flush()
	end
end

-- Private Properties
local allFlags = {}

-- Module
local Copy = {
	_id = newproxy(false),

	Flags = {
		Flush = true,
		SetParent = false,
	},

	GlobalBehavior = GlobalBehavior,

	Transform = {},
	BehaviorMap = setmetatable({}, { __mode = "k" }),
}

setmetatable(Copy, CopyMt)

local flagsMt = {}
setmetatable(Copy.Flags, flagsMt)

for flagName in pairs(Copy.Flags) do
	allFlags[flagName] = true
end
function flagsMt.__newindex(self, flagName, value)
	if allFlags[flagName] then
		rawset(self, flagName, value)
	else
		error(string.format("Attempt to assign %q to Copy.Flags", tostring(flagName)), 2)
	end
end

-- Public Functions
function CopyMt:__call(value)
	self.InstanceTransform = Instances.ApplyTransform(self, value)

	local result
	if self.BehaviorMap[value] then
		result = select(2, value())
	else
		local valueBehavior = self.GlobalBehavior.Values
		result = select(2, Behaviors.handleValue(self, valueBehavior, value, nil))
	end

	attemptFlush(self)

	return result
end

function Copy:Extend(object, ...)
	assert(type(object) == "table", "`base` can only be of type 'table'")

	for i = 1, select("#", ...) do
		local modifier = select(i, ...)
		assert(type(modifier) == "table", "All modifier arguments provided can only be of type 'table'")
		assert(not self.BehaviorMap[modifier], "No modifier argument can directly be a symbol")

		Instances.ApplyTransform(self, modifier)
		if self.BehaviorMap[modifier] then
			modifier(object)
		else
			Reconcilers.table(self, modifier, object)
		end
	end
	attemptFlush(self)

	return object
end

function Copy:BehaveAs(behaviors, value)
	local typeof_behaviors = typeof(behaviors)

	local found_behaviors = Behaviors.presets[behaviors]
	if found_behaviors then
		behaviors = found_behaviors
	elseif typeof_behaviors == "table" then
		for _, behavior in ipairs(behaviors) do
			Behaviors.assert(behavior)
		end
	elseif typeof_behaviors == "string" then
		Behaviors.assert(behaviors)
		behaviors = { behaviors }
	else
		Behaviors.assert(behaviors)
	end

	local behaviorObj = {
		Owner = self,
		Behaviors = behaviors,
		Value = value,
	}
	setmetatable(behaviorObj, Symbol)
	rawset(self.BehaviorMap, behaviorObj, true)

	return behaviorObj
end

function Copy:Flush()
	table.clear(self.Transform)
	self.InstanceTransform = nil
end

return Copy
