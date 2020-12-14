return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)
	local T = getfenv()
	local expect = T.expect

	local Copy
	T.beforeEach(function()
		Copy = CopyFactory()
	end)
	
	T.describe("Copy:Flush", function()
		T.it("should work", function()
			Copy.Flags.Flush = false

			local someTable = {}

			local newTable1 = Copy(someTable)
			local newTable2 = Copy(someTable)
			local storedTable = Copy.Transform[someTable]
			Copy:Flush()
			local newTable3 = Copy(someTable)

			expect(newTable1).to.equal(newTable2)
			expect(storedTable).to.equal(newTable2)
			expect(newTable1).never.to.equal(newTable3)
		end)
	end)
end