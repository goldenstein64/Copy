return {

	Values = function(Copy)
		local dict = {
			shared = {}
		}

		Copy.Context = {
			shared = Copy:repl{ value = dict.shared }
		}
		local newDict = Copy(dict)

		assert(newDict.shared == dict.shared)
	end,

	Keys = function(Copy)
		local keyTable = {}
		local someTable = { [keyTable] = 4 }

		Copy.Context = {
			[keyTable] = Copy:repl{ key = keyTable }
		}
		local newTable = Copy(someTable)

		assert(newTable[keyTable] == 4)
	end,

	Metatables = function(Copy)
		local obj = {}
		local meta = {}
		function meta:__index(k)
			return "indexed " .. tostring(self) ..  " with " .. k
		end
		setmetatable(obj, meta)

		Copy.Context = setmetatable({}, 
			Copy:repl{ value = meta }
		)
		local newObj = Copy(obj)

		assert(getmetatable(newObj) == getmetatable(obj))
	end,

	MultipleValues = function(Copy)
		local someTable = {
			shared = {},
			sharedToo = {},
			notShared = {}
		}

		Copy.Context = {
			shared = Copy:repl{ value = someTable.shared },
			sharedToo = Copy:repl{ value = someTable.sharedToo }
		}
		local newTable = Copy(someTable)

		assert(newTable.shared == someTable.shared)
		assert(newTable.sharedToo == someTable.sharedToo)
		assert(newTable.notShared ~= someTable.notShared)
	end,

}