return {

	ForceKeys = function(Copy)
		local key = newproxy(false)
		local someTable = { [key] = "value" }

		Copy.Flags.Flush = false
		Copy:ApplyContext(function(replace)
			return {
				[key] = replace({ key = Copy(key) })
			}
		end)
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

		Copy.Flags.Flush = false
		Copy:ApplyContext(function(replace)
			local newKey = Copy(key)
			return {
				{
					[key] = replace({ key = newKey })
				},
				{
					[key] = replace({ key = newKey })
				}
			}
		end)
		local newTable = Copy(someTable)
		local newKey = Copy.Transform[key]

		assert(newKey ~= key)
		assert(newTable[1][newKey] == "value 1")
		assert(newTable[2][newKey] == "value 2")
	end,

	ForceMeta = function(Copy)
		local meta = {}
		local someTable = setmetatable({}, meta)

		Copy.Flags.Flush = false
		Copy:ApplyContext(function(replace)
			return setmetatable({}, replace({ value = Copy(meta) }))
		end)
		local newTable = Copy(someTable)
		local newMeta = getmetatable(newTable)
		local newMeta2 = Copy.Transform[meta]

		assert(newMeta ~= meta)
		assert(newMeta == newMeta2)
	end,

}