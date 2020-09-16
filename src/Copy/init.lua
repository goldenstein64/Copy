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

	if result == self.NIL then
		return true, nil
	else
		return result ~= nil, result
	end
end

local switchCopy = {}

local handle = {}

for _, behaviorScope in ipairs{"Values", "Keys", "Meta"} do
	handle[behaviorScope] = function(self, value, newValue)
		if self.GlobalBehavior[behaviorScope] then
			local transformSuccess, transformCopy = getTransform(self, value)
			local handler = switchCopy[typeof(value)]
			if transformSuccess then
				return transformCopy
			elseif handler then
				if newValue == nil or typeof(value) ~= typeof(newValue) then
					return handler(self, value)
				else
					return handler(self, value, newValue)
				end
			else
				return value
			end
		else
			return value
		end
	end
end

function switchCopy.table(self, oldTable, newTable)
	if newTable == nil then
		newTable = {}
	end
	if oldTable == self.Transform then return newTable end
	self.Transform[oldTable] = newTable

	for k, v in pairs(oldTable) do
		local newKey = handle.Keys(self, k)
		if newKey == nil then
			newKey = k
		end

		local newTableValue = rawget(newTable, k)
		local isStruct = type(v) == "table" and rawget(v, self.Struct)
		if isStruct then
			rawset(v, self.Struct, nil)
			handle.Values(self, v, newTableValue)
		else
			local newValue = handle.Values(self, v)
			rawset(newTable, newKey, newValue)
		end
	end

	local meta = getmetatable(oldTable)
	local newTableMeta = getmetatable(newTable)
	if type(meta) == "table" then
		local isStruct = rawget(meta, self.Struct)
		if isStruct then
			rawset(newTableMeta, self.Struct, nil)
			handle.Meta(self, meta, newTableMeta)
		else
			local newMeta = handle.Meta(self, meta, newTableMeta)
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
	if self.Flags.FlushTransform then
		self:Flush()
	end
end

-- Private Properties
local allFlags = {}

-- Module
local Copy = {
	Flags = {
		FlushTransform = true,
		SetParent = false,
	},
	GlobalBehavior = {
		Keys = false,
		Values = true,
		Meta = false,
	},
	Transform = {},

	NIL = newproxy(false)
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
	Instances.ApplyTransform(self, value)
	local result = handle.Values(self, value)
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

		Instances.ApplyTransform(self, modifier)
		switchCopy.table(self, modifier, object)

	end
	attemptFlush(self)

	return object
end

function Copy:Struct(value)
	value[self.Struct] = true
	return value
end

function Copy:Flush()
	for value in pairs(self.Transform) do
		rawset(self.Transform, value, nil)
	end
end

return Copy