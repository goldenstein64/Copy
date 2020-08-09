return {
	
	Values = function(Copy)
		local array = { "value" }
		
		Copy.Transform["value"] = "some other value"
		local newArray = Copy(array)

		assert(newArray[1] == "some other value")
	end,
	
	Keys = function(Copy)
		local dict = { key = "value" }
		
		Copy.Flags.CopyKeys = true
		Copy.Transform["key"] = "someOtherKey"
		local newDict = Copy(dict)
		
		assert(newDict.key == nil)
		assert(newDict.someOtherKey == "value")
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
		
		Copy.Flags.CopyMeta = true
		Copy.Transform[addMeta] = otherMeta
		local newTable = Copy(someTable)
		
		assert(someTable + otherTable == 11)
		-- 2 * (   3     +     8    ) == 22
		assert(newTable + otherTable == 22)
	end,
	
	-- transforming values in subsequent tables
	SubValues = function(Copy)
		local obj = {
			sub = {
				key = "value"
			},
			key = "value"
		}
		
		Copy.Transform["value"] = "some other value"
		local newSubObj = Copy(obj.sub) -- this flushes the last line
		Copy.Transform[obj.sub] = newSubObj
		local newObj = Copy(obj)
		
		assert(newObj.key == "value")
		assert(newObj.sub.key == "some other value")
	end,
	
	-- preserving a value using Copy.Transform
	AltPreserve = function(Copy)
		local dict = {
			shared = {}
		}
		
		Copy.Transform[dict.shared] = dict.shared
		local newDict = Copy(dict)
		
		assert(newDict.shared == dict.shared)
	end,
	
}