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
local function getTransform(self, var)
	local result = self.Transform[var]
	
	if result == self.NIL then
		return true, nil
	else
		return result ~= nil, result
	end
end

local copyAny
local function copyTable(self, oldTable, newTable)
	newTable = newTable or {}
	self.Transform[oldTable] = newTable
	if oldTable == self.Transform then return newTable end
	for k, v in pairs(oldTable) do
		local newKey = k
		if self.Flags.CopyKeys then
			newKey = copyAny(self, k)
			if newKey == nil then
				newKey = k
			end
		end
		
		rawset(
			newTable,
			newKey,
			copyAny(self, v)
		)
	end
	local meta = getmetatable(oldTable)
	if type(meta) == "table" then
		if self.Flags.CopyMeta then
			local success, copy = getTransform(self, meta)
			if success then
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

do
	local switchCopy = {
		table = copyTable,
		userdata = copyUserdata,
		Random = copyRandom,
	}
	function copyAny(self, var)
		local success, copy = getTransform(self, var)
		if success then return copy end
		
		local handler = switchCopy[typeof(var)]
		return handler and handler(self, var) or var
	end
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
	NIL = newproxy(false),
}
local CopyMt = {}
local flagsMt = {}
setmetatable(Copy, CopyMt)
setmetatable(Copy.Flags, flagsMt)

function flagsMt:__newindex(k, v)
	if allFlags[k] then
		rawset(self, k, v)
	else
		error(string.format("Attempt to assign %q to Copy.Flags", k))
	end
end

-- Public Functions
function CopyMt:__call(value)
	Instances.ApplyTransform(self, value)
	local result = copyAny(self, value)
	attemptFlush(self)
	return result
end

function Copy:Extend(base, ...)
	assert(type(base) == "table",
		"`base` can only be of type 'table'")
	for i = 1, select("#", ...) do
		local modifier = select(i, ...)
		assert(type(modifier) == "table", 
			"All modifier arguments provided can only be of type 'table'")
		Instances.ApplyTransform(self, modifier)
		copyTable(self, modifier, base)
	end
	attemptFlush(self)
	return base
end

function Copy:Preserve(...)
	for i = 1, select("#", ...) do
		local var = select(i, ...)
		if var == nil then continue end
		rawset(self.Transform, var, var)
	end
end

function Copy:Flush()
	for k in pairs(self.Transform) do
		rawset(self.Transform, k, nil)
	end
end

return Copy