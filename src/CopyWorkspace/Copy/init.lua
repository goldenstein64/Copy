--[[

The Copy Module
A module that copies any value with state.

Author: goldenstein64
Free Model: https://www.roblox.com/library/5089132938
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
local function copyTable(self, newTable, oldTable)
	self.Transform[oldTable] = newTable
	if oldTable == self.Transform then return newTable end
	for k, v in pairs(oldTable) do
		local newKey = k
		if self.Parameters.CopyKeys then
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
		if self.Parameters.CopyMeta then
			setmetatable(newTable, copyAny(self, meta))
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
		copyTable(self, newMeta, meta)
	end
	return newUserdata
end

local function copyRandom(self, random)
	local newRandom = random:Clone()
	self.Transform[random] = newRandom
	return newRandom
end

function copyAny(self, var)
	local success, copy = getTransform(self, var)
	if success then return copy end
	
	local type_var = typeof(var)
	if type_var == "table" then
		return copyTable(self, {}, var)
	elseif type_var == "userdata" then
		return copyUserdata(self, var)
	elseif type_var == "Random" then
		return copyRandom(self, var)
	else
		return var
	end
end

local function attemptFlush(self)
	if self.Parameters.Flush then
		self:Flush()
	end
end

local allFlags = {}

local function initializeParams(self)
	self.Parameters = setmetatable({}, { __index = self.Flags })
end

local function copyParams(self, argParams)
	if argParams then
		local params = self.Parameters
		for k, v in pairs(argParams) do
			params[k] = v
		end
	end
end

local function deleteParams(self)
	self.Parameters = nil
end

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
Copy.Parameters = nil
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
function CopyMt:__call(value, parameters)
	assert(type(parameters) == "table", "`parameters` can only be of type 'table'")
	initializeParams(self)
	copyParams(self, parameters)
	Instances.ApplyTransform(self, value)
	local result = copyAny(self, value)
	attemptFlush(self)
	deleteParams(self)
	return result
end

function Copy:Across(to, from, parameters)
	assert(type(parameters) == "table", "`parameters` can only be of type 'table'")
	assert(type(from) == "table" and type(to) == "table",
		"`to` and `from` can only be of type 'table'")
	initializeParams(self)
	copyParams(self, parameters)
	Instances.ApplyTransform(self, from)
	local result = copyTable(self, to, from)
	attemptFlush(self)
	deleteParams(self)
	return result
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