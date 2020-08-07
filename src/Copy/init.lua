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
local switchCopy

local copyAny
local function copyTable(self, oldTable, newTable)
	newTable = newTable or {}
	self.Transform[oldTable] = newTable
	if oldTable == self.Transform then return newTable end
	for k, v in pairs(oldTable) do
		local newKey, newValue

		if self.Flags.CopyKeys or self.Operations.Force[k] then
			newKey = copyAny(self, k)
		else
			newKey = k
		end
		if self.Operations.Delete[v] then
			newValue = nil
		else
			newValue = copyAny(self, v)
		end

		rawset(newTable, newKey, newValue)
	end
	local meta = getmetatable(oldTable)
	if type(meta) == "table" then
		if self.Operations.Delete[meta] then
			setmetatable(newTable, nil)
		elseif self.Flags.CopyMeta or self.Operations.Force[meta] then
			local copy = self.Transform[meta]
			if copy ~= nil then
				setmetatable(newTable, copy)
			else
				setmetatable(newTable, copyTable(self, meta))
			end
		else
			setmetatable(newTable, meta)
		end
	end
	
	return newTable
end

local function copyUserdata(self, userdata)
	local meta = getmetatable(userdata)
	local hasMeta = type(meta) == "table"
	local newUserdata = newproxy(hasMeta)
	self.Transform[userdata] = newUserdata
	if hasMeta then
		local newMeta = getmetatable(newUserdata)
		copyTable(self, meta, newMeta)
	end
	return newUserdata
end

local function copyRandom(self, random)
	local newRandom = random:Clone()
	self.Transform[random] = newRandom
	return newRandom
end

switchCopy = {
	table = copyTable,
	userdata = copyUserdata,
	Random = copyRandom,
}
function copyAny(self, value)
	local copy = self.Transform[value]
	if copy ~= nil then return copy end
	
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
	Transform = {},

	Operations = {
		Delete = {},
		Force = {},
	},
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
	Instances.ApplyTransform(self, value)
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
		Instances.ApplyTransform(self, modifier)
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
		rawset(self.Operations.Delete, value, true)
	end
end

function Copy:QueueForce(...)
	for i = 1, select("#", ...) do
		local value = select(i, ...)
		if value == nil then continue end
		rawset(self.Operations.Force, value, true)
	end
end

function Copy:Flush()
	for value in pairs(self.Transform) do
		rawset(self.Transform, value, nil)
	end
end

return Copy