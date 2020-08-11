local DEFAULT_ERROR = "assertion failed!"

return {

	CheckFunctionality = function(Copy)
		local someTable = {}

		Copy.Flags.Flush = false
		local newTable1 = Copy(someTable)
		local newTable2 = Copy(someTable)
		local storedTable = Copy.Transform[someTable]
		Copy:Flush()
		local newTable3 = Copy(someTable)

		assert(newTable1 == newTable2, DEFAULT_ERROR)
		assert(storedTable == newTable2, DEFAULT_ERROR)
		assert(newTable1 ~= newTable3, DEFAULT_ERROR)
	end,

}