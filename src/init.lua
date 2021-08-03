--[[

Copy
A module for copying any value with state.

Author: goldenstein64
Free Model: https://www.roblox.com/library/5089132938
GitHub: https://github.com/goldenstein64/Copy
Docs: https://goldenstein64.github.io/Copy

ver 1

--]]

-- Dependencies
local Instances = require(script.Instances)
local Behaviors = require(script.Behaviors)
local Reconcilers = require(script.Reconcilers)
local Contexts = require(script.Contexts)
local Symbol = require(script.Symbol)

Behaviors.Init()

-- Private Functions
local function attemptFlush(self)
	if self.Flags.Flush then
		self:Flush()
	end
end

-- Private Properties
local allFlags = {}

local CopyMt = {}

-- Module
local Copy = {
	_id = newproxy(),

	Flags = {
		Flush = true,
		SetInstanceParent = false,
	},

	GlobalContext = Contexts.Global,

	Transform = {},
	SymbolMap = setmetatable({}, { __mode = "k" }),
}

local flagsMt = {}
setmetatable(Copy.Flags, flagsMt)

for flagName in pairs(Copy.Flags) do
	allFlags[flagName] = true
end

function flagsMt:__newindex(flagName, value)
	if allFlags[flagName] then
		rawset(self, flagName, value)
	else
		error(string.format("Attempt to assign %q to Copy.Flags", tostring(flagName)), 2)
	end
end

function CopyMt:__tostring()
	return string.format("Copy: %s", tostring(self._id):sub(11))
end

-- Public Functions
function CopyMt:__call(value)
	local instanceTransform = rawget(self, "InstanceTransform")
	if instanceTransform then
		local newTransform = Instances.ApplyTransform(self, value)
		for oldInstance, newInstance in pairs(newTransform) do
			instanceTransform[oldInstance] = newInstance
		end
	else
		rawset(self, "InstanceTransform", Instances.ApplyTransform(self, value))
	end

	local result
	if self.SymbolMap[value] then
		result = select(2, value())
	else
		local valueBehavior = self.GlobalContext.Values
		result = select(2, Behaviors.HandleValue(self, valueBehavior, value, nil))
	end

	attemptFlush(self)

	return result
end

function Copy:Extend(object, ...)
	assert(type(object) == "table", "`base` can only be of type 'table'")

	local instanceTransform = rawget(self, "InstanceTransform")
	if not instanceTransform then
		rawset(self, "InstanceTransform", {})
	end

	for i = 1, select("#", ...) do
		local modifier = select(i, ...)
		assert(type(modifier) == "table", "All modifier arguments provided can only be of type 'table'")
		assert(not self.SymbolMap[modifier], "No modifier argument can directly be a symbol")

		local transform = Instances.ApplyTransform(self, modifier)
		for oldInstance, newInstance in pairs(transform) do
			self.InstanceTransform[oldInstance] = newInstance
		end

		if self.SymbolMap[modifier] then
			modifier(object)
		else
			Reconcilers.table(self, modifier, object)
		end
	end
	attemptFlush(self)

	return object
end

function Copy:BehaveAs(behaviors, value)
	behaviors = Behaviors.Convert(behaviors)

	local behaviorObj = {
		Name = tostring(value),
		Owner = self,
		Behaviors = behaviors,
		Value = value,
	}

	setmetatable(behaviorObj, Symbol)
	rawset(self.SymbolMap, behaviorObj, true)

	return behaviorObj
end

function Copy:Flush()
	table.clear(self.Transform)
	rawset(self, "InstanceTransform", nil)
end

setmetatable(Copy, CopyMt)

return Copy
