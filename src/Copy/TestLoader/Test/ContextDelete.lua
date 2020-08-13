return {

	DeleteValues = function(Copy)
		local someVar = newproxy(false)
		local someTable = { key = someVar }

		Copy.Context = {
			key = Copy:repl{ value = Copy.NIL }
		}
		local newTable = Copy(someTable)

		assert(newTable.key == nil)
	end,

	DeleteMetatables = function(Copy)
		local someTable = {}
		local someMeta = {}
		setmetatable(someTable, someMeta)

		Copy.Context = setmetatable({}, 
			Copy:repl{ value = Copy.NIL }
		)
		local newTable = Copy(someTable)

		assert(getmetatable(newTable) == nil)
	end,

	-- preserving a key if an attempt is made to make it nil
	DeleteKeySafeguard = function(Copy)
		local someTable = { key = "value" }

		Copy.Context = {
			key = Copy:repl{ key = Copy.NIL }
		}
		local newTable = Copy(someTable)

		assert(newTable.key == "value")
	end,

}