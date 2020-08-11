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

local function searchForValue(self, context, returnType, value)
	local contextSuccess, contextCopy = getContext(self, context, returnType)
	local transformSuccess, transformCopy = getTransform(self, value)
	if contextSuccess then
		return true, contextCopy
	elseif transformSuccess then
		return true, transformCopy
	else
		return false, nil
	end
end

local copyAny
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

		local newKey
		local success_k, copy_k = searchForValue(self, context, "key", k)
		if success_k and copy_k ~= nil then
			newKey = copy_k
		else
			newKey = k
		end

		local newValue
		local success_v, copy_v = searchForValue(self, context, "value", v)
		if success_v then
			newValue = copy_v
		else
			newValue = copyAny(self, context, v)
		end

		rawset(newTable, newKey, newValue)
	end

	local meta = getmetatable(oldTable)
	if type(meta) == "table" then
		local metaCurrent = lastAllowed and getmetatable(lastCurrent)
		context.allowed = lastAllowed and metaCurrent ~= nil
		if context.allowed then
			context.current = metaCurrent
		end
		local newMeta
		local success_meta, copy_meta = searchForValue(self, context, "value", meta)
		if success_meta then
			newMeta = copy_meta
		else
			newMeta = copyTable(self, context, meta)
		end
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
		current = self.Context
	}
	Instances.ApplyTransform(self, value)

	local result
	local success, copy = searchForValue(self, context, "value", value)
	if success then
		result = copy
	else
		result = copyAny(self, context, value)
	end
	attemptFlush(self)
	return result
end

function Copy:Extend(object, ...)
	assert(type(object) == "table",
		"`base` can only be of type 'table'")
	local context = {
		explored = {},
		allowed = type(self.Context) == "table",
		current = self.Context
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

--[[ 
`modifier` should return a value that is modeled in the same shape as the value 
that will be copied.

`replace` is a function parameter that captures the context of the value and 
communicates to `Copy()` that the value should be transformed as specified by 
`replace's` arguments. Any value *not* in a replace() call should be treated as
a path through the value passed into Copy().

e.g:

This would directly replace the value passed into Copy().
```
function(replace)
	return replace({ value = newValue })
end
```

This would replace the value at `location` in the table passed into Copy().
```
function(replace)
	return {

		location = replace({ value = newValue })

	}
end
```

This would replace the metatable for the value found at `location` in the table
passed into Copy().
```
function(replace)
	return {

		location = replace({ meta = newMeta })

	}
end
```

This would assign a new key for the value found at `location` in the table
passed into Copy(). This would still copy the old value, since the `value` param
wasn't specified.
Keys are preserved by default unless you copy it in the `replace` call,
i.e. `replace({ key = Copy(oldKey) })`
```
function(replace)
	return {

		location = replace({ key = newKey })

	}
end
```

This would assign a new key AND value for the value found at `location` in the
table passed into Copy(). The metatable will still be set (but not copied) on the new 
value unless the `meta` param is specified.
```
function(replace)
	return {

		location = replace({ key = newKey, value = newValue })
		
	}
end
```

This would replace a value in the metatable of the table passed into Copy().
```
function(replace)
	return setmetatable({}, {

		location = replace({ value = newValue })

	}
end
```

`Copy:ApplyTransform` can be replaced with an assignment to `Copy.Context` like 
so:
```
Copy.Context = {

	location = {
		[Copy.Tag] = true,
			key = newKey,
			value = newValue,
			meta = newMeta,
	}
}
```

--]]

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

function Copy:Flush()
	for value in pairs(self.Transform) do
		rawset(self.Transform, value, nil)
	end
	self.Context = nil
end

return Copy