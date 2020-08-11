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
local function getContext(self, context, returnType)
	if context.allowed and rawget(context.current, self.Tag) ~= nil then
		local result = rawget(context.current, returnType)

		if result == self.NIL then
			return true, nil
		else
			return result ~= nil, result
		end
	else
		return false, nil
	end
end

local function getTransform(self, value)
	local result = rawget(self.Transform, value)

	if result == self.NIL then
		return true, nil
	else
		return result ~= nil, result
	end
end

local copyAny
local function handleValue(self, context, returnType, behaviorScope, value)
	local contextSuccess, contextCopy = getContext(self, context, returnType)
	local transformSuccess, transformCopy = getTransform(self, value)
	if contextSuccess then
		return contextCopy
	elseif transformSuccess then
		return transformCopy
	elseif self.GlobalBehavior[behaviorScope] then
		return copyAny(self, context, value)
	else
		return value
	end
end

local function copyTable(self, context, oldTable, newTable)
	newTable = newTable or {}
	if self.Transform[oldTable] ~= nil then return newTable end
	self.Transform[oldTable] = newTable
	local lastCurrent, lastAllowed = context.current, context.allowed
	for k, v in pairs(oldTable) do
		local subCurrent = lastAllowed and rawget(lastCurrent, k)
		context.allowed = lastAllowed and subCurrent ~= nil
		if context.allowed then
			context.current = subCurrent
		end

		local newKey = handleValue(self, context, "key", "Keys", k)
		if newKey == nil then
			newKey = k
		end
		local newValue = handleValue(self, context, "value", "Values", v)
		rawset(newTable, newKey, newValue)
	end

	local meta = getmetatable(oldTable)
	if type(meta) == "table" then
		local metaCurrent = lastAllowed and getmetatable(lastCurrent)
		context.allowed = lastAllowed and metaCurrent ~= nil
		if context.allowed then
			context.current = metaCurrent
		end
		local newMeta = handleValue(self, context, "value", "Meta", meta)
		setmetatable(newTable, newMeta)
	end

	context.current, context.allowed = lastCurrent, lastAllowed

	return newTable
end

local function copyUserdata(self, context, userdata)
	local meta = getmetatable(userdata)
	local hasMeta = type(meta) == "table"
	local newUserdata = newproxy(hasMeta)
	self.Transform[userdata] = newUserdata
	if hasMeta then
		local newMeta = getmetatable(newUserdata)
		copyTable(self, context, meta, newMeta)
	end
	return newUserdata
end

local function copyRandom(self, _, random)
	local newRandom = random:Clone()
	self.Transform[random] = newRandom
	return newRandom
end

local switchCopy = {
	table = copyTable,
	userdata = copyUserdata,
	Random = copyRandom
}
function copyAny(self, context, value)
	local handler = switchCopy[typeof(value)]
	return handler and handler(self, context, value) or value
end

local function attemptFlush(self)
	if self.Flags.FlushTransform then
		self:FlushTransform()
	end
	if self.Flags.FlushContext then
		self.Context = nil
	end
end

-- Private Properties
local allFlags = {}

-- Module
local Copy = {
	Flags = {
		FlushTransform = true,
		FlushContext = true,
		SetParent = false,
	},
	GlobalBehavior = {
		Keys = false,
		Values = true,
		Meta = false,
	},
	Transform = {},
	Context = nil,

	NIL = newproxy(false),
	Tag = newproxy(false),
}
local CopyMt = {}
local flagsMt = {}
setmetatable(Copy, CopyMt)
setmetatable(Copy.Flags, flagsMt)

for flagName in pairs(Copy.Flags) do
	allFlags[flagName] = true
end
function flagsMt:__newindex(flagName, value)
	if allFlags[flagName] then
		rawset(self, flagName, value)
	else
		error(string.format("Attempt to assign %q to Copy.Flags", flagName), 2)
	end
end

-- Public Functions
function CopyMt:__call(value)
	local context = {
		allowed = type(self.Context) == "table",
		current = self.Context,
	}
	Instances.ApplyTransform(self, value)

	local result = handleValue(self, context, "value", "Values", value)
	attemptFlush(self)
	return result
end

function Copy:Extend(object, ...)
	assert(type(object) == "table",
		"`base` can only be of type 'table'")
	local context = {
		allowed = type(self.Context) == "table",
		current = self.Context,
	}
	for i = 1, select("#", ...) do
		local modifier = select(i, ...)
		assert(type(modifier) == "table", 
			"All modifier arguments provided can only be of type 'table'")
		Instances.ApplyTransform(self, modifier)
		copyTable(self, context, modifier, object)
	end
	attemptFlush(self)
	return object
end

function Copy:Replace(dict)
	dict[self.Tag] = true
	return dict
end

function Copy:ApplyContext(modifier)
	local function context(dict)
		return self:Replace(dict)
	end

	self.Context = modifier(context)
end

function Copy:QueuePreserve(...)
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value == nil then continue end
		rawset(self.Transform, value, value)
	end
end

function Copy:QueueDelete(...)
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value == nil then continue end
		rawset(self.Transform, value, self.NIL)
	end
end

function Copy:QueueForce(...)
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value == nil then continue end
		rawset(self.Transform, value, CopyMt.__call(self, value))
	end
end

function Copy:FlushTransform()
	for value in pairs(self.Transform) do
		rawset(self.Transform, value, nil)
	end
end

function Copy:Flush()
	self:FlushTransform()
	self.Context = nil
end

return Copy