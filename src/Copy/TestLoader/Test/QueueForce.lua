return {

	ForceKeys = function(Copy)
		local key = newproxy(false)
		local someTable = { [key] = "value" }

		Copy.GlobalBehavior.Keys = true
		Copy.Flags.FlushTransform = false
		Copy:QueueForce(key)
		local newTable = Copy(someTable)
		local newKey = Copy.Transform[key]

		assert(newKey ~= key)
		assert(newTable[newKey] == "value")
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

		Copy.GlobalBehavior.Keys = true
		Copy.Flags.FlushTransform = false
		Copy:QueueForce(key)
		local newTable = Copy(someTable)
		local newKey = Copy.Transform[key]

		assert(newKey ~= key)
		assert(newTable[1][newKey] == "value 1")
		assert(newTable[2][newKey] == "value 2")
	end,

	ForceMeta = function(Copy)
		local meta = {}
		local someTable = setmetatable({}, meta)

		Copy.GlobalBehavior.Meta = true
		Copy.Flags.FlushTransform = false
		Copy:QueueForce(meta)
		local newTable = Copy(someTable)
		local newMeta = getmetatable(newTable)
		local newMeta2 = Copy.Transform[meta]

		assert(newMeta ~= meta)
		assert(newMeta == newMeta2)
	end,

	AvoidNil = function(Copy)
		Copy:QueueForce(1, nil, 3)
	end,
}