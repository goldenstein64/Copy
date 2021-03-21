return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)

	local Copy
	beforeEach(function()
		Copy = CopyFactory()
	end)

	describe("ContextTests", function()
		it("avoids searching unreachable values", function()
			Copy.GlobalContext.Values = "set"
			Copy.Flags.Flush = false

			local part = Instance.new("Part")
			local array = { part }

			local _ = Copy(array)
			local newPart = Copy.Transform[part]

			expect(newPart).to.equal(nil)
		end)

		it("avoids searching unreachable keys", function()
			Copy.GlobalContext.Keys = "set"
			Copy.Flags.Flush = false

			local part = Instance.new("Part")
			local dict = {
				[part] = "value",
			}

			local _ = Copy(dict)
			local newPart = Copy.Transform[part]

			expect(newPart).to.equal(nil)
		end)

		it("avoids searching unreachable metatables", function()
			Copy.GlobalContext.Meta = "set"
			Copy.Flags.Flush = false

			local part = Instance.new("Part")
			local meta = { part }
			local someTable = setmetatable({}, meta)

			local _ = Copy(someTable)
			local newPart = Copy.Transform[part]

			expect(newPart).to.equal(nil)
		end)

		it("avoids searching unreachable values in symbols", function()
			Copy.GlobalContext.Values = "default"
			Copy.Flags.Flush = false

			local part = Instance.new("Part")
			local someTable = {
				Copy:BehaveAs("set", part),
			}

			local _ = Copy(someTable)
			local newPart = Copy.Transform[part]

			expect(newPart).to.equal(nil)
		end)
	end)

	it("preserves instance hierarchy", function()
		local folder = Instance.new("Folder")
		local someTable = {
			folder = folder,
			part = Instance.new("Part"),
		}
		someTable.part.Parent = folder

		local newTable = Copy(someTable)

		expect(newTable.folder.Part).to.equal(newTable.part)
	end)
end
