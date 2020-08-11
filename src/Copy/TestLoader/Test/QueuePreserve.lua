return {

	Values = function(Copy)
		local dict = {
			shared = {}
		}

		Copy:QueuePreserve(dict.shared)
		local newDict = Copy(dict)

		assert(newDict.shared == dict.shared)
	end,

	Keys = function(Copy)
		local keyTable = {}
		local someTable = { [keyTable] = 4 }

		Copy:QueuePreserve(keyTable)
		local newTable = Copy(someTable)

		assert(newTable[keyTable] == 4)
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

		assert(getmetatable(newObj) == getmetatable(obj))
	end,

	MultipleValues = function(Copy)
		local someTable = {
			shared = {},
			sharedToo = {},
			notShared = {}
		}

		Copy:QueuePreserve(someTable.shared, someTable.sharedToo)
		local newTable = Copy(someTable)

		assert(newTable.shared == someTable.shared)
		assert(newTable.sharedToo == someTable.sharedToo)
		assert(newTable.notShared ~= someTable.notShared)
	end,

	AvoidNil = function(Copy)
		Copy:QueuePreserve(1, nil, 3)
	end,

}