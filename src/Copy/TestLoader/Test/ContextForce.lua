return {

	ForceKeys = function(Copy)
		local key = newproxy(false)
		local someTable = { [key] = "value" }

		Copy.Flags.FlushTransform = false
		Copy.Context = {
			[key] = Copy:repl{ key = Copy(key) }
		}
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

		Copy.Flags.FlushTransform = false
		local newKey = Copy(key)
		Copy.Context = {
			{
				[key] = Copy:repl{ key = newKey }
			},
			{
				[key] = Copy:repl{ key = newKey }
			}
		}
		local newTable = Copy(someTable)
		local newKey2 = Copy.Transform[key]

		assert(newKey2 ~= key)
		assert(newTable[1][newKey2] == "value 1")
		assert(newTable[2][newKey2] == "value 2")
	end,

	ForceMeta = function(Copy)
		local meta = {}
		local someTable = setmetatable({}, meta)

		Copy.Flags.FlushTransform = false
		Copy.Context = setmetatable({}, 
			Copy:repl{ value = Copy(meta) }
		)
		local newTable = Copy(someTable)
		local newMeta = getmetatable(newTable)
		local newMeta2 = Copy.Transform[meta]

		assert(newMeta ~= meta)
		assert(newMeta == newMeta2)
	end,

}