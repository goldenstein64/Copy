local DEFAULT_ERROR = "assertion failed!"

return {

	Values = function(Copy)
		local dict = {
			shared = {}
		}

		Copy:ApplyContext(function(replace)
			return {
				shared = replace({ value = dict.shared })
			}
		end)
		local newDict = Copy(dict)

		assert(newDict.shared == dict.shared, DEFAULT_ERROR)
	end,

	Keys = function(Copy)
		local keyTable = {}
		local someTable = { [keyTable] = 4 }

		Copy:ApplyContext(function(replace)
			return {
				[keyTable] = replace({ key = keyTable })
			}
		end)
		local newTable = Copy(someTable)

		assert(newTable[keyTable] == 4, DEFAULT_ERROR)
	end,

	Metatables = function(Copy)
		local obj = {}
		local meta = {}
		function meta:__index(k)
			return "indexed " .. tostring(self) ..  " with " .. k
		end
		setmetatable(obj, meta)

		Copy:ApplyContext(function(replace)
			return setmetatable({}, replace({ value = meta }))
		end)
		local newObj = Copy(obj)

		assert(getmetatable(newObj) == getmetatable(obj))
	end,

	MultipleValues = function(Copy)
		local someTable = {
			shared = {},
			sharedToo = {},
			notShared = {}
		}

		Copy:ApplyContext(function(replace)
			return {
				shared = replace({ value = someTable.shared }),
				sharedToo = replace({ value = someTable.sharedToo })
			}
		end)
		local newTable = Copy(someTable)

		assert(newTable.shared == someTable.shared, DEFAULT_ERROR)
		assert(newTable.sharedToo == someTable.sharedToo, DEFAULT_ERROR)
		assert(newTable.notShared ~= someTable.notShared, DEFAULT_ERROR)
	end,

}