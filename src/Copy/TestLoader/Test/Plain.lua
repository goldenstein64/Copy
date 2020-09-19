return {
	Default = function(Copy)
		local someTable = {
			key = "some value"
		}

		local baseTable = Copy:Plain {
			key = Copy.NIL
		}

		local newTable = Copy:Extend(someTable, baseTable)
		local newNIL = Copy.Transform[Copy.NIL]

		assert(newTable.key == newNIL)
	end,

	AntiDefault = function(Copy)
		local someTable = {
			key = "some value"
		}

		local baseTable = {
			key = Copy.NIL
		}

		local newTable = Copy:Extend(someTable, baseTable)

		assert(newTable.key == nil)
	end,
}