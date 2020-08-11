local DEFAULT_ERROR = "assertion failed!"

return {

	Values = function(Copy)
		local array = { "value" }

		Copy:ApplyContext(function(replace)
			return {
				replace({ value = "some other value" })
			}
		end)
		local newArray = Copy(array)

		assert(newArray[1] == "some other value", DEFAULT_ERROR)
	end,

	Keys = function(Copy)
		local dict = { key = "value" }

		Copy:ApplyContext(function(replace)
			return {
				key = replace({ key = "someOtherKey" })
			}
		end)
		local newDict = Copy(dict)

		assert(newDict.key == nil, DEFAULT_ERROR)
		assert(newDict.someOtherKey == "value", DEFAULT_ERROR)
	end,

	Metatables = function(Copy)
		local addMeta = {
			__add = function(self, b)
				return self.Value + b.Value
			end
		}
		local otherMeta = {
			__add = function(self, b)
				return 2 * (self.Value + b.Value)
			end
		}
		local someTable = setmetatable({ Value = 3 }, addMeta)
		local otherTable = { Value = 8 }

		Copy:ApplyContext(function(replace)
			return setmetatable({}, replace({ value = otherMeta }))
		end)
		local newTable = Copy(someTable)

		assert(someTable + otherTable == 11, DEFAULT_ERROR)
		-- 2 * (   3     +     8    ) == 22
		assert(newTable + otherTable == 22, DEFAULT_ERROR)
	end,

	-- transforming values in subsequent tables
	SubValues = function(Copy)
		local obj = {
			sub = {
				key = "value"
			},
			key = "value"
		}

		Copy:ApplyContext(function(replace)
			return {
				sub = {
					key = replace({ value = "some other value"})
				}
			}
		end)
		local newObj = Copy(obj)

		assert(newObj.key == "value", DEFAULT_ERROR)
		assert(newObj.sub.key == "some other value", DEFAULT_ERROR)
	end,

	MetatableValues = function(Copy)
		local meta = { key = "value" }
		local obj = setmetatable({}, meta)

		Copy:ApplyContext(function(replace)
			return setmetatable({}, {
				key = replace({ value = "some other value" })
			})
		end)
		local newObj = Copy(obj)

		assert(getmetatable(newObj).key == "some other value", DEFAULT_ERROR)
	end,

	-- preserving a value using Copy.Transform
	AltPreserve = function(Copy)
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

	AltValues = function(Copy)
		local array = { "value" }

		Copy.Context = {
			Copy:Replace({ value = "some other value" })
		}
		local newArray = Copy(array)

		assert(newArray[1] == "some other value", DEFAULT_ERROR)
	end,

	AltValues2 = function(Copy)
		local array = { "value" }

		Copy.Context = {
			{
				[Copy.Tag] = true,
				value = "some other value"
			}
		}
		local newArray = Copy(array)

		assert(newArray[1] == "some other value", DEFAULT_ERROR)
	end,

}