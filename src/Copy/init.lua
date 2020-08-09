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
local function getTransform(self, context, value)
	local result = self.Transform[context][value]
	if result == self.NIL then
		return true, nil
	else
		return result ~= nil, result
	end
end

local copyAny
local function copyTable(self, context, oldTable, newTable)
	newTable = newTable or {}
	self.Transform[context][oldTable] = newTable
	if 
		oldTable == self.Transform.Keys 
		or oldTable == self.Transform.Values 
		or oldTable == self.Transform.Meta 
	then return newTable end

	for k, v in pairs(oldTable) do
		local newKey = copyAny(self, "Keys", k)
		if newKey == nil then
			newKey = k
		end
		local newValue = copyAny(self, "Values", v)

		rawset(newTable, newKey, newValue)
	end

	local meta = getmetatable(oldTable)
	if type(meta) == "table" then
		local success, copy = getTransform(self, "Meta", meta)
		if success then
			setmetatable(newTable, copy)
		else
			setmetatable(newTable, copyTable(self, "Meta", meta))
		end
	end

	return newTable
end

local function copyUserdata(self, context, userdata)
	local meta = getmetatable(userdata)
	local hasMeta = type(meta) == "table"
	local newUserdata = newproxy(hasMeta)
	self.Transform[context][userdata] = newUserdata
	if hasMeta then
		local newMeta = getmetatable(newUserdata)
		copyTable(self, "Meta", meta, newMeta)
	end
	return newUserdata
end

local function copyRandom(self, context, random)
	local newRandom = random:Clone()
	self.Transform[context][random] = newRandom
	return newRandom
end

local switchCopy = {
	table = copyTable,
	userdata = copyUserdata,
	Random = copyRandom,
}
function copyAny(self, context, value)
	local success, copy = getTransform(self, context, value)
	if success then return copy end
	
	local handler = switchCopy[typeof(value)]
	local result = handler and handler(self, context, value) or value
	return result
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
	Flags = {
		Flush = true,
		SetParent = false,
	},

	Transform = {
		Keys = {},
		Values = {},
		Meta = {},
	},

	NIL = newproxy(false),
	
}
local CopyMt = {}
local flagsMt = {}
local transformMt = {}
setmetatable(Copy, CopyMt)
setmetatable(Copy.Flags, flagsMt)
setmetatable(Copy.Transform, transformMt)


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

function transformMt:__index(key)
	if key == nil then
		return rawget(self, "Values")
	else
		error(string.format("Attempt to index Copy.Transform with %q", tostring(key)))
	end
end

-- Public Functions
function CopyMt:__call(value)
	Instances.ApplyTransform(self, value)
	local result = copyAny(self, "Values", value)
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
		copyTable(self, "Values", modifier, object)
	end
	attemptFlush(self)
	return object
end

function Copy:QueuePreserve(context, ...)
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value == nil then continue end
		rawset(self.Transform[context], value, value)
	end
end

function Copy:QueueDelete(context, ...)
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value == nil then continue end
		rawset(self.Transform[context], value, self.NIL)
	end
end

function Copy:Flush()
	for _, context in pairs(self.Transform) do
		for value in pairs(context) do
			rawset(context, value, nil)
		end
	end
end

return Copy