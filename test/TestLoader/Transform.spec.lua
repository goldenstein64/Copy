return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)
	local T = getfenv()
	local expect = T.expect

	local Copy
	T.beforeEach(function()
		Copy = CopyFactory()
	end)

	T.describe("Copy.Transform", function()

		T.it("transforms values", function()
			local array = { "value" }

			Copy.GlobalBehavior.Values = "default"
			Copy.Transform["value"] = "some other value"
			local newArray = Copy(array)

			expect(newArray[1]).to.equal("some other value")
		end)

		T.it("transforms keys", function()
			local dict = { key = "value" }

			Copy.GlobalBehavior.Keys = "default"
			Copy.Transform["key"] = "someOtherKey"
			local newDict = Copy(dict)

			expect(newDict.key).to.equal(nil)
			expect(newDict.someOtherKey).to.equal("value")
		end)

		T.it("transforms metatables", function()
			local addMeta = {
				__add = function(self, b)
					return self.Value + b.Value
				end
			}
			local otherMeta = {
				__add = function(self, b)
					return 2 * (self.Value + b.Value)
				end
			}
			local someTable = setmetatable({ Value = 3 }, addMeta)
			local otherTable = { Value = 8 }

			Copy.GlobalBehavior.Meta = "default"
			Copy.Transform[addMeta] = otherMeta
			local newTable = Copy(someTable)

			expect(someTable + otherTable).to.equal(11)
			-- 2 * (   3     +     8    ) == 22
			expect(newTable + otherTable).to.equal(22)
		end)

		T.it("can transform sub-values", function()
			local obj = {
				sub = {
					key = "value"
				},
				key = "value"
			}

			Copy.Transform["value"] = "some other value"
			local newSubObj = Copy(obj.sub) -- this flushes the last line
			Copy.Transform[obj.sub] = newSubObj
			local newObj = Copy(obj)

			expect(newObj.key).to.equal("value")
			expect(newObj.sub.key).to.equal("some other value")
		end)

		T.it("can delete values", function()
			local dict = {
				key = "value"
			}

			Copy.Transform["value"] = Copy:BehaveAs("set", nil)
			local newDict = Copy(dict)

			expect(newDict.key).to.equal(nil)
		end)

		T.it("can skip values", function()
			local dict = {
				key = "value"
			}

			Copy.Transform["value"] = Copy:BehaveAs("pass")
			local newDict = Copy(dict)

			expect(newDict.key).to.equal(nil)
		end)

		T.it("can preserve without a symbol", function()
			local dict = {
				shared = {}
			}

			Copy.Transform[dict.shared] = dict.shared
			local newDict = Copy(dict)

			expect(newDict.shared).to.equal(dict.shared)
		end)

		T.it("is safeguarded from Copy()", function()
			Copy.Transform["value"] = "other value"

			local newTransform = Copy(Copy.Transform)

			expect(next(newTransform)).to.equal(nil)
		end)

		T.it("is safeguarded from Copy:Extend", function()
			Copy.Transform["value"] = "other value"
			local newTransform = {
				["different value"] = "separate value"
			}

			Copy:Extend(newTransform, Copy.Transform)

			expect(newTransform["value"]).to.equal(nil)
		end)

		T.it("can bypass the safeguard", function()
			Copy.Transform["value"] = "other value"

			local oldTransform
			Copy.Transform, oldTransform = {}, Copy.Transform
			local newTransform = Copy(oldTransform)

			expect(newTransform["value"]).to.equal("other value")
		end)
	end)

end