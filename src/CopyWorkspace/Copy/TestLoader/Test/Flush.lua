--[[

(a child of) The Copy Module
A module that copies any value with state. No more, no less.

Author: goldenstein64
Free Model: https://www.roblox.com/library/5089132938
Docs: TBD

ver 1

--]]

return {

	CheckFunctionality = function(Copy)
		local someTable = {}
		
		Copy.Flags.flush = false
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
