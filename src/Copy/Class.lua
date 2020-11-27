local classPrototype = {}

-- reverses the resulting array so that super classes are applied to an object first
-- Note! This does not protect from cyclic inheritance
function classPrototype:gatherSupers()
	local result = self:_gatherSupers()

	-- reverse order of result
	local len = #result
	for i = 1, len/2 do
		local other = len - i + 1
		result[i], result[other] = result[other], result[i]
	end

	return table.unpack(result)
end

-- recursively searches through each inherited class and appends them to a returned array
function classPrototype:_gatherSupers()
	local result = { self }
	for _, super in ipairs(self.extends) do
		local gathered = super:_gatherSupers()
		table.move(gathered, 1, #gathered, #result + 1, result)
	end

	return result
end

local classMt = {
	__tostring = function(self)
		return self.name
	end,
	__index = classPrototype
}

local function class(name, ...)
	return setmetatable({
		extends = { ... },
		name = name
	}, classMt)
end

return class