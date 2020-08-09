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
local function getCache(self, value)
	local result = self.Cache[value]
	return result ~= nil, result
end

local function getTransform(self, value)
	local result = self.Transform[value]

	if result == self.NIL then
		return true, nil
	else
		return result ~= nil, result
	end
end

local copyAny
local function copyTable(self, oldTable, newTable)
	newTable = newTable or {}
	self.Cache[oldTable] = newTable
	if oldTable == self.Cache then return newTable end
	for k, v in pairs(oldTable) do
		local newKey = k
		local success, copy_k = getTransform(self, k)
		if self.Flags.CopyKeys or success and copy_k ~= nil then
			newKey = copyAny(self, k)
		end
		local newValue = copyAny(self, v)

		rawset(newTable, newKey, newValue)
	end
	local meta = getmetatable(oldTable)
	if type(meta) == "table" then
		local newMeta = meta
		if self.Flags.CopyMeta or getTransform(self, meta) then
			newMeta = copyAny(self, meta)
		end
		
		setmetatable(newTable, newMeta)
	end
	
	return newTable
end

local function copyUserdata(self, userdata)
	local meta = getmetatable(userdata)
	local hasMeta = type(meta) == "table"
	local newUserdata = newproxy(hasMeta)
	self.Cache[userdata] = newUserdata
	if hasMeta then
		local newMeta = getmetatable(newUserdata)
		copyTable(self, meta, newMeta)
	end
	return newUserdata
end

local function copyRandom(self, random)
	local newRandom = random:Clone()
	self.Cache[random] = newRandom
	return newRandom
end

local switchCopy = {
	table = copyTable,
	userdata = copyUserdata,
	Random = copyRandom,
}
local retrievalFns = { getTransform, getCache }
function copyAny(self, value)
	for _, retriever in ipairs(retrievalFns) do
		local success, copy = retriever(self, value)
		if success then return copy end
	end
	
	local handler = switchCopy[typeof(value)]
	return handler and handler(self, value) or value
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
		CopyKeys = false,
		CopyMeta = false,
		Flush = true,
		SetParent = false,
	},
	Cache = {},
	Transform = {},

	NIL = newproxy(false),
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
		error(string.format("Attempt to assign %q to Copy.Flags", flagName))
	end
end

-- Public Functions
function CopyMt:__call(value)
	Instances.ApplyCache(self, value)
	local result = copyAny(self, value)
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
		Instances.ApplyCache(self, modifier)
		copyTable(self, modifier, object)
	end
	attemptFlush(self)
	return object
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
	local oldFlag = self.Flags.Flush
	self.Flags.Flush = false
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value == nil then continue end
		rawset(self.Transform, value, CopyMt.__call(self, value))
	end
	self.Flags.Flush = oldFlag
end

function Copy:MassTransform(dict)
	for value, copy in pairs(dict) do
		rawset(self.Transform, value, copy)
	end
end

function Copy:Flush()
	for value in pairs(self.Transform) do
		rawset(self.Transform, value, nil)
	end
	for value in pairs(self.Cache) do
		rawset(self.Cache, value, nil)
	end
end

return Copy