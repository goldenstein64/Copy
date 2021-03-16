return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)

	local Copy
	beforeEach(function()
		Copy = CopyFactory()
	end)

	describe("Copy:Flush", function()
		it("should work", function()
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
