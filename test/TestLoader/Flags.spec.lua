return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)
	local T = getfenv()
	local expect = T.expect

	local R = Random.new()

	local Copy
	T.beforeEach(function()
		Copy = CopyFactory()
	end)

	T.describe("Copy.Flags", function()
		T.it("does not allow for nonexistent flags", function()
			expect(function()
				Copy.Flags.NonFlag = true
			end).to.throw()
		end)

		T.it("Flush: respects true", function()
			Copy.Flags.Flush = true

			local dict = {
				sub = {}
			}

			local _ = Copy(dict)

			expect(next(Copy.Transform)).to.equal(nil)
		end)

		T.it("Flush: respects false", function()
			Copy.Flags.Flush = false

			local dict = {
				sub = {}
			}

			local _ = Copy(dict)

			expect(next(Copy.Transform)).never.to.equal(nil)
		end)

		T.it("Flush: preserves table relations", function()
			Copy.Flags.Flush = false

			local someTable = {
				sub = {}
			}

			local newSubTable = Copy(someTable.sub)
			local newTable = Copy(someTable)

			assert(newTable.sub == newSubTable)
		end)

		T.it("SetParent: respects true", function()
			Copy.Flags.SetParent = true

			local parent = Instance.new("Folder")
			local somePart = Instance.new("Part", parent)
			local array = {somePart}

			local newArray = Copy(array)

			expect(newArray[1].Parent).to.equal(parent)
		end)

		T.it("SetParent: respects false", function()
			Copy.Flags.SetParent = false

			local parent = Instance.new("Folder")
			local somePart = Instance.new("Part", parent)
			local array = {somePart}

			local newArray = Copy(array)

			expect(newArray[1].Parent).to.equal(nil)
		end)
	end)
end