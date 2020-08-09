return {
	
	Values = function(Copy)
		local array = { "value" }
		
		Copy.Transform.Values["value"] = "some other value"
		
		assert(Copy(array)[1] == "some other value")
	end,
	
	Keys = function(Copy)
		local dict = { key = "value" }
		
		Copy.Transform.Keys["key"] = "someOtherKey"
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
		
		Copy.Transform.Meta[addMeta] = otherMeta
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
		
		Copy.Transform.Values["value"] = "some other value"
		local newSubObj = Copy(obj.sub) -- this flushes the last line
		Copy.Transform.Values[obj.sub] = newSubObj
		local newObj = Copy(obj)
		
		assert(newObj.key == "value")
		assert(newObj.sub.key == "some other value")
	end,
	
	-- preserving a value using Copy.Transform
	AltPreserve = function(Copy)
		local dict = {
			shared = {}
		}
		
		Copy.Transform.Values[dict.shared] = dict.shared
		local newDict = Copy(dict)
		
		assert(newDict.shared == dict.shared)
	end,
	
}