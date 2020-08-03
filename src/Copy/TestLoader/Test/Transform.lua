return {
	
	Values = function(Copy)
		local array = { "value" }
		
		Copy.Transform["value"] = "some other value"
		
		assert(Copy(array)[1] == "some other value")
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
	
	DeleteValues = function(Copy)
		local someVar = newproxy(false)
		local someTable = { key = someVar }
		
		Copy.Transform[someVar] = Copy.NIL
		local newTable = Copy(someTable)
		
		assert(newTable.key == nil)
	end,
	
	DeleteMetatables = function(Copy)
		local someTable = {}
		local someMeta = {}
		setmetatable(someTable, someMeta)
		
		Copy.Flags.CopyMeta = true
		Copy.Transform[someMeta] = Copy.NIL
		local newTable = Copy(someTable)
		
		assert(getmetatable(newTable) == nil)
	end,
	
	-- preserving a key if an attempt is made to make it nil
	DeleteKeySafeguard = function(Copy)
		local someTable = { key = "value" }
		
		Copy.Flags.CopyKeys = true
		Copy.Transform["key"] = Copy.NIL
		local newTable = Copy(someTable)
		
		assert(newTable.key == "value")
	end,

	ForceKeys = function(Copy)
		local key = newproxy(false)
		local someTable = { [key] = "value" }

		Copy.Flags.Flush = false
		Copy.Flags.CopyKeys = false
		Copy.Transform[key] = Copy.FORCE
		local newTable = Copy(someTable)
		local newKey = Copy.Transform[key]

		assert(newKey ~= key)
		assert(newTable[newKey] == "value")
	end,

	ForceMeta = function(Copy)
		local meta = {}
		local someTable = setmetatable({}, meta)

		Copy.Flags.Flush = false
		Copy.Flags.CopyMeta = false
		Copy.Transform[meta] = Copy.FORCE
		local newTable = Copy(someTable)
		local newMeta = getmetatable(newTable)
		local newMeta2 = Copy.Transform[meta]

		assert(newMeta ~= meta)
		assert(newMeta == newMeta2)
	end,
	
	-- copying Copy.NIL
	CheckNIL = function(Copy)
		local someTable = { Copy.NIL }
		
		Copy.Flags.Flush = false
		local newTable = Copy(someTable)
		local newNIL = Copy.Transform[Copy.NIL]
		
		assert(newTable[1] == newNIL)
	end,
}