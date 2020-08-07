return {

	DeleteValues = function(Copy)
		local someVar = newproxy(false)
		local someTable = { key = someVar }
		
		Copy:Delete(someVar)
		local newTable = Copy(someTable)
		
		assert(newTable.key == nil)
	end,
	
	DeleteMetatables = function(Copy)
		local someTable = {}
		local someMeta = {}
		setmetatable(someTable, someMeta)
		
		Copy.Flags.CopyMeta = true
		Copy:Delete(someMeta)
		local newTable = Copy(someTable)
		
		assert(getmetatable(newTable) == nil)
	end,
	
	-- preserving a key if an attempt is made to make it nil
	DeleteKeySafeguard = function(Copy)
		local someTable = { key = "value" }
		
		Copy.Flags.CopyKeys = true
		Copy:Delete("key")
		local newTable = Copy(someTable)
		
		assert(newTable.key == "value")
	end,

}