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

	if self.SymbolMap[result] then
		return true, result()
	else
		return result ~= nil, true, result
	end
end

local switchCopy = {}
local handleValue

local switchSymbol = {
	["nil"] = function()
		return true, nil
	end,

	pass = function()
		return false, nil
	end,

	replace = function(_, value)
		return true, value
	end,

	copy = function(self, value)
		return handleValue("Values", self, value)
	end,
}

local switchGlobalBehavior = {
	copy = function(self, value, newValue)
		if self.SymbolMap[value] then
			return value()
		else
			local transSuccess, transDoSet, transCopy = getTransform(self, value)
			local typeof_value = typeof(value)
			local handler = switchCopy[typeof_value]
			if transSuccess then
				return transDoSet, transCopy
			elseif handler then
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

	assign = function(_, value)
		return true, value
	end,

	pass = function()
		return false, nil
	end,
}

local SYMBOL_ENUM = { "\"nil\"", "\"pass\"", "\"replace\"", "\"copy\"" }
local GLOBAL_BEHAVIOR_ENUM = { "\"assign\"", "\"copy\"", "\"pass\"" }

setmetatable(switchSymbol, {
	__index = function(_, symbolName)
		error(string.format(
			"Unknown symbol (%q) found. The only allowed symbols are %s.",
			tostring(symbolName), table.concat(SYMBOL_ENUM, ", ")
		), 2)
	end,
})

setmetatable(switchGlobalBehavior, {
	__index = function(_, behavior)
		error(string.format(
			"Unknown global behavior (%q) found. The only allowed behaviors are %s.",
			tostring(behavior), table.concat(GLOBAL_BEHAVIOR_ENUM, ", ")
		), 2)
	end,
})

function handleValue(behaviorScope, self, value, newValue)
	local behavior = self.GlobalBehavior[behaviorScope]
	return switchGlobalBehavior[behavior](self, value, newValue)
end

function switchCopy.table(self, oldTable, newTable)
	if newTable == nil then
		newTable = {}
	end
	if oldTable == self.Transform then return newTable end
	self.Transform[oldTable] = newTable

	for k, v in pairs(oldTable) do
		local doSet_k, newKey = handleValue("Keys", self, k)
		if not doSet_k or newKey == nil then
			newKey = k
		end

		local doSet_v, newValue = handleValue("Values", self, v, rawget(newTable, k))
		if doSet_v then
			rawset(newTable, newKey, newValue)
		end
	end

	local meta = getmetatable(oldTable)
	if type(meta) == "table" then
		local doSet_m, newMeta = handleValue("Meta", self, meta, getmetatable(newTable))
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
	for k in pairs(self.SymbolMap) do
		rawset(self.SymbolMap, k, nil)
	end
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
		Keys = "assign",
		Values = "copy",
		Meta = "assign",
	},
	Transform = {},
	SymbolMap = {},
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

function CopyMt:__tostring()
	return "Copy object" .. tostring(self):sub(6)
end

-- Public Functions
function CopyMt:__call(value)
	Instances.ApplyTransform(self, value)
	local _, result = handleValue("Values", self, value)
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
		assert(not self.SymbolMap[modifier],
			"No modifier argument can directly be a symbol")

		Instances.ApplyTransform(self, modifier)
		switchCopy.table(self, modifier, object)

	end
	attemptFlush(self)

	return object
end

local symbolMt = {
	__tostring = function(self)
		return string.format("Symbol(%s)", self.Name)
	end,

	__call = function(self)
		return switchSymbol[self.Name](self.Owner, self.Value)
	end,
}
function Copy:Symbol(name, value)
	local _ = switchSymbol[name]
	local symbol = setmetatable({
		Owner = self,
		Name = name,
		Value = value,
	}, symbolMt)
	rawset(self.SymbolMap, symbol, true)
	return symbol
end

function Copy:Flush(keepSymbols)
	for value in pairs(self.Transform) do
		rawset(self.Transform, value, nil)
	end
	if not keepSymbols then
		for symbol in pairs(self.SymbolMap) do
			rawset(self.SymbolMap, symbol, nil)
		end
	end
end

return Copy