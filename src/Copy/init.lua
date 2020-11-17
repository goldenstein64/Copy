--[[

The Copy Module
A module that copies any value with state.

Author: goldenstein64
Free Model: https://www.roblox.com/library/5089132938
GitHub: https://github.com/goldenstein64/Copy
Docs: TBD

ver 1

--]]

-- Dependencies
local Instances = require(script.Instances)

-- Private Functions
local function getTransform(self, value)
	local result = rawget(self.Transform, value)

	if self.BehaviorMap[result] then
		return true, result()
	else
		return result ~= nil, true, result
	end
end

local switchCopy = {}

local switchBehavior
switchBehavior = {
	default = function(self, value, newValue)
		local transSuccess, transDoSet, transCopy = getTransform(self, value)
		if transSuccess then
			return transDoSet, transCopy
		else
			local typeof_value = typeof(value)
			local handler = switchCopy[typeof_value]
			if handler then
				if newValue == nil or typeof_value ~= typeof(newValue) then
					return true, handler(self, value)
				else
					return true, handler(self, value, newValue)
				end
			else
				return true, value
			end
		end
	end,

	copy = function(self, value)
		local typeof_value = typeof(value)
		local handler = switchCopy[typeof_value]
		if handler then
			return true, handler(self, value)
		else
			return true, value
		end
	end,

	set = function(_, value)
		return true, value
	end,

	pass = function()
		return false, nil
	end,
}

local BEHAVIOR_ENUM = {}
for key in pairs(switchBehavior) do
	table.insert(BEHAVIOR_ENUM, string.format("%q", key))
end
BEHAVIOR_ENUM = table.concat(BEHAVIOR_ENUM, ", ")

setmetatable(switchBehavior, {
	__index = function(_, behavior)
		error(string.format(
			"Unknown behavior (%q) found. The only allowed behaviors are %s.",
			tostring(behavior), BEHAVIOR_ENUM
		), 2)
	end,
})

function switchCopy.table(self, oldTable, newTable)
	if newTable == nil then
		newTable = {}
	end
	if oldTable == self.Transform then
		return newTable
	end
	self.Transform[oldTable] = newTable

	local keyBehavior = self.GlobalBehavior.Keys
	local valueBehavior = self.GlobalBehavior.Values
	local metaBehavior = self.GlobalBehavior.Meta

	for k, v in pairs(oldTable) do
		local doSet_k, newKey
		if self.BehaviorMap[k] then
			doSet_k, newKey = k(nil)
		else
			doSet_k, newKey = switchBehavior[keyBehavior](self, k)
		end
		if not doSet_k or newKey == nil then
			newKey = k
		end

		local doSet_v, newValue
		if self.BehaviorMap[v] then
			doSet_v, newValue = v(rawget(newTable, k))
		else
			doSet_v, newValue = switchBehavior[valueBehavior](self, v, 
				rawget(newTable, k))
		end
		if doSet_v then
			rawset(newTable, newKey, newValue)
		end
	end

	local meta = getmetatable(oldTable)
	if type(meta) == "table" then
		local doSet_m, newMeta
		if self.BehaviorMap[meta] then
			doSet_m, newMeta = meta(getmetatable(newTable))
		else
			doSet_m, newMeta = switchBehavior[metaBehavior](self,	meta,
				getmetatable(newTable))
		end
		if doSet_m then
			setmetatable(newTable, newMeta)
		end
	end

	return newTable
end

function switchCopy.userdata(self, userdata)
	local meta = getmetatable(userdata)
	local hasMeta = type(meta) == "table"
	local newUserdata = newproxy(hasMeta)
	self.Transform[userdata] = newUserdata
	if hasMeta then
		local newMeta = getmetatable(newUserdata)
		switchCopy.table(self, meta, newMeta)
	end
	return newUserdata
end

function switchCopy.Random(self, random)
	local newRandom = random:Clone()
	self.Transform[random] = newRandom
	return newRandom
end

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
	GlobalBehavior = {
		[newproxy(false)] = {
			Keys = "set",
			Values = "default",
			Meta = "set"
		}
	},
	Transform = {},
	BehaviorMap = setmetatable({}, { __mode = "k" }),
}

local CopyMt = {}
local flagsMt = {}
setmetatable(Copy, CopyMt)
setmetatable(Copy.Flags, flagsMt)

for flagName in pairs(Copy.Flags) do
	allFlags[flagName] = true
end
function flagsMt.__newindex(self, flagName, value)
	if allFlags[flagName] then
		rawset(self, flagName, value)
	else
		error(string.format("Attempt to assign %q to Copy.Flags", flagName), 2)
	end
end

local CONTEXT_ENUM = {}
for context in pairs(select(2, next(Copy.GlobalBehavior))) do
	table.insert(CONTEXT_ENUM, string.format("%q", context))
end
CONTEXT_ENUM = table.concat(CONTEXT_ENUM, ", ")

setmetatable(Copy.GlobalBehavior, {
	__index = function(self, context)
		local real = select(2, next(self))
		local behavior = rawget(real, context)
		if behavior == nil then
			error(string.format(
				"Unknown context (%q) found. The only allowed contexts are %s,",
				tostring(context), CONTEXT_ENUM
			), 2)
		else
			return behavior
		end
	end,
	__newindex = function(self, context, behavior)
		local real = select(2, next(self))
		if rawget(real, context) == nil then
			error(string.format(
				"Unknown context (%q) found. The only allowed contexts are %s,",
				tostring(context), CONTEXT_ENUM
			), 2)
		elseif rawget(switchBehavior, behavior) == nil then
			error(string.format(
				"Unknown behavior (%q) found. The only allowed behaviors are %s.",
				tostring(behavior), BEHAVIOR_ENUM
			), 2)
		else
			rawset(real, context, behavior)
		end
	end
})

function CopyMt.__tostring(self)
	return "Copy: " .. tostring(self._id):sub(11)
end

-- Public Functions
function CopyMt.__call(self, value)
	Instances.ApplyTransform(self, value)

	local result
	if self.BehaviorMap[value] then
		result = select(2, value())
	else
		result = select(2, switchBehavior[self.GlobalBehavior.Values](self, value))
	end

	attemptFlush(self)

	return result
end

function Copy:Extend(object, ...)
	assert(type(object) == "table",
		"`base` can only be of type 'table'")

	for i = 1, select("#", ...) do
		local modifier = select(i, ...)
		assert(type(modifier) == "table",
			"All modifier arguments provided can only be of type 'table'")
		assert(not self.BehaviorMap[modifier],
			"No modifier argument can directly be a symbol")

		Instances.ApplyTransform(self, modifier)
		if self.BehaviorMap[modifier] then
			modifier(object)
		else
			switchCopy.table(self, modifier, object)
		end
	end
	attemptFlush(self)

	return object
end

local symbolMt = {
	__tostring = function(self)
		return string.format("Symbol(%s)", self.Name)
	end,

	__call = function(self, newValue)
		return switchBehavior[self.Name](self.Owner, self.Value, newValue)
	end,
}

function Copy:BehaveAs(name, value)
	local _ = switchBehavior[name]
	local behaviorObj = setmetatable({
		Owner = self,
		Name = name,
		Value = value,
	}, symbolMt)
	rawset(self.BehaviorMap, behaviorObj, true)
	return behaviorObj
end

function Copy:Flush()
	for value in pairs(self.Transform) do
		rawset(self.Transform, value, nil)
	end
end

return Copy