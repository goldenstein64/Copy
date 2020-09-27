return {

	CheckFunctionality = function(Copy)
		local someTable = {}

		Copy.Flags.Flush = false
		local newTable1 = Copy(someTable)
		local newTable2 = Copy(someTable)
		local storedTable = Copy.Transform[someTable]
		Copy:Flush()
		local newTable3 = Copy(someTable)

		assert(newTable1 == newTable2)
		assert(storedTable == newTable2)
		assert(newTable1 ~= newTable3)
	end,

}