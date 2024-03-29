return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)

	local Copy
	beforeEach(function()
		Copy = CopyFactory()
	end)

	it("should work", function()
		Copy.Flags.Flush = false

		local someTable = {}

		local newTable1 = Copy(someTable)
		local newTable2 = Copy(someTable)
		local storedTable = Copy.Transform[someTable]
		Copy:Flush()
		local newTable3 = Copy(someTable)

		-- stylua: ignore
		expect(newTable1)
			.to.equal(newTable2)
			.to.never.equal(newTable3)
		expect(storedTable).to.equal(newTable2)
	end)
end
