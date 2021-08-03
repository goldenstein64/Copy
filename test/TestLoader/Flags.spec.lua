return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)

	local Copy
	beforeEach(function()
		Copy = CopyFactory()
	end)

	describe("Flush", function()
		it("respects true", function()
			Copy.Flags.Flush = true

			local dict = {
				sub = {},
			}

			local _ = Copy(dict)

			expect(next(Copy.Transform)).to.equal(nil)
		end)

		it("respects false", function()
			Copy.Flags.Flush = false

			local dict = {
				sub = {},
			}

			local _ = Copy(dict)

			expect(next(Copy.Transform)).to.never.equal(nil)
		end)

		it("preserves table relations", function()
			Copy.Flags.Flush = false

			local someTable = {
				sub = {},
			}

			local newSubTable = Copy(someTable.sub)
			local newTable = Copy(someTable)

			expect(newTable.sub).to.equal(newSubTable)
		end)
	end)

	describe("SetInstanceParent", function()
		it("respects true", function()
			Copy.Flags.SetInstanceParent = true

			local parent = Instance.new("Folder")
			local somePart = Instance.new("Part")
			somePart.Parent = parent
			local array = { somePart }

			local newArray = Copy(array)

			expect(newArray[1].Parent).to.equal(parent)
		end)

		it("respects false", function()
			Copy.Flags.SetInstanceParent = false

			local parent = Instance.new("Folder")
			local somePart = Instance.new("Part")
			somePart.Parent = parent
			local array = { somePart }

			local newArray = Copy(array)

			expect(newArray[1].Parent).to.equal(nil)
		end)
	end)

	it("does not allow nonexistent flags", function()
		expect(function()
			Copy.Flags.FakeFlag = true
		end).to.throw()
	end)
end
