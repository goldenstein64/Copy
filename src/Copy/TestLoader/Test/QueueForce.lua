local DEFAULT_ERROR = "assertion failed!"

return {

	ForceKeys = function(Copy)
		local key = newproxy(false)
		local someTable = { [key] = "value" }

		Copy.Flags.Flush = false
		Copy:QueueForce(key)
		local newTable = Copy(someTable)
		local newKey = Copy.Transform[key]

		assert(newKey ~= key, DEFAULT_ERROR)
		assert(newTable[newKey] == "value", DEFAULT_ERROR)
	end,

	ForceMultipleKeys = function(Copy)
		local key = newproxy(false)
		local someTable = {
			{
				[key] = "value 1"
			},
			{
				[key] = "value 2"
			}
		}

		Copy.Flags.Flush = false
		Copy:QueueForce(key)
		local newTable = Copy(someTable)
		local newKey = Copy.Transform[key]

		assert(newKey ~= key, DEFAULT_ERROR)
		assert(newTable[1][newKey] == "value 1", DEFAULT_ERROR)
		assert(newTable[2][newKey] == "value 2", DEFAULT_ERROR)
	end,

	ForceMeta = function(Copy)
		local meta = {}
		local someTable = setmetatable({}, meta)

		Copy.Flags.Flush = false
		Copy:QueueForce(meta)
		local newTable = Copy(someTable)
		local newMeta = getmetatable(newTable)
		local newMeta2 = Copy.Transform[meta]

		assert(newMeta ~= meta, DEFAULT_ERROR)
		assert(newMeta == newMeta2, DEFAULT_ERROR)
	end,

	AvoidNil = function(Copy)
		Copy:QueueForce(1, nil, 3)
	end,
}