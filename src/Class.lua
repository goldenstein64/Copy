local Copy = require(script.Parent)

local classPrototype = {}

-- recursively searches through each inherited class and appends them to a returned array
local function _gatherSupers(class)
	local result = { class.prototype }
	for _, super in ipairs(class.extends) do
		local gathered = _gatherSupers(super)
		table.move(gathered, 1, #gathered, #result + 1, result)
	end

	return result
end

-- reverses the resulting array so that super classes are applied to an object first
-- Note! This does not protect from cyclic inheritance
function classPrototype:gatherSupers()
	local result = _gatherSupers(self)

	-- reverse order of result
	local len = #result
	for i = 1, len / 2 do
		local other = len - i + 1
		result[i], result[other] = result[other], result[i]
	end

	return table.unpack(result)
end

local classMt = {
	__tostring = function(self)
		return self.name
	end,
	__index = classPrototype,
}

local function defaultInit(self)
	return self
end

local function class(name, ...)
	local newClass = {
		extends = { ... },
		prototype = {},
		init = defaultInit,

		name = name,
	}

	function newClass.new(...)
		local self = Copy:Extend({}, class:gatherSupers())
		return newClass.init(self, ...)
	end

	setmetatable(newClass, classMt)

	return newClass
end

return class
