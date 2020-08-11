local DEFAULT_ERROR = "assertion failed!"

return {

	Values = function(Copy)
		local dict = {
			shared = {}
		}

		Copy:QueuePreserve(dict.shared)
		local newDict = Copy(dict)

		assert(newDict.shared == dict.shared, DEFAULT_ERROR)
	end,

	Keys = function(Copy)
		local keyTable = {}
		local someTable = { [keyTable] = 4 }

		Copy:QueuePreserve(keyTable)
		local newTable = Copy(someTable)

		assert(newTable[keyTable] == 4, DEFAULT_ERROR)
	end,

	Metatables = function(Copy)
		local obj = {}
		local mt = {}
		function mt:__index(k)
			return "indexed " .. tostring(self) ..  " with " .. k
		end
		setmetatable(obj, mt)

		Copy:QueuePreserve(mt)
		local newObj = Copy(obj)

		assert(getmetatable(newObj) == getmetatable(obj), DEFAULT_ERROR)
	end,

	MultipleValues = function(Copy)
		local someTable = {
			shared = {},
			sharedToo = {},
			notShared = {}
		}

		Copy:QueuePreserve(someTable.shared, someTable.sharedToo)
		local newTable = Copy(someTable)

		assert(newTable.shared == someTable.shared, DEFAULT_ERROR)
		assert(newTable.sharedToo == someTable.sharedToo, DEFAULT_ERROR)
		assert(newTable.notShared ~= someTable.notShared, DEFAULT_ERROR)
	end,

	AvoidNil = function(Copy)
		Copy:QueuePreserve(1, nil, 3)
	end,

}