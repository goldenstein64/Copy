return {

	DeleteValues = function(Copy)
		local someVar = newproxy(false)
		local someTable = { key = someVar }

		Copy:ApplyContext(function(replace)
			return {
				key = replace({ value = Copy.NIL })
			}
		end)
		local newTable = Copy(someTable)

		assert(newTable.key == nil)
	end,

	DeleteMetatables = function(Copy)
		local someTable = {}
		local someMeta = {}
		setmetatable(someTable, someMeta)

		Copy:ApplyContext(function(replace)
			return setmetatable({}, replace({ value = Copy.NIL }))
		end)
		local newTable = Copy(someTable)

		assert(getmetatable(newTable) == nil)
	end,

	-- preserving a key if an attempt is made to make it nil
	DeleteKeySafeguard = function(Copy)
		local someTable = { key = "value" }

		Copy:ApplyContext(function(replace)
			return {
				key = replace({ key = Copy.NIL })
			}
		end)
		local newTable = Copy(someTable)

		assert(newTable.key == "value")
	end,

}