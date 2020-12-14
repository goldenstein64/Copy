return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)
	local T = getfenv()
	local expect = T.expect

	local Copy
	T.beforeEach(function()
		Copy = CopyFactory()
	end)

	T.describe("Copy:BehaveAs", function()

		T.it("can 'set' values to nil properly", function()
			local someTable = {
				key = "value"
			}

			local baseTable = {
				key = Copy:BehaveAs("set", nil)
			}

			Copy:Extend(someTable, baseTable)

			expect(someTable.key).to.equal(nil)
		end)

		T.it("can allow 'default' behavior in keys", function()
			local key = newproxy(false)
			local someTable = {
				[Copy:BehaveAs("default", key)] = "value"
			}

			local newTable = Copy(someTable)
			local newKey = next(newTable)

			expect(newKey).never.to.equal(key)
		end)

		T.it("can allow 'default' behavior in metatables", function()
			local meta = {}
			local someTable = setmetatable({}, Copy:BehaveAs("default", meta))

			local newTable = Copy(someTable)
			local newMeta = getmetatable(newTable)

			expect(newMeta).never.to.equal(meta)
		end)

		T.it("can 'copy' duplicate tables as one table", function()
			local subTable = {
				key = "value"
			}
			local someTable = {
				sub = subTable,
				sub2 = Copy:BehaveAs("copy", subTable)
			}

			local newTable = Copy(someTable)

			expect(newTable.sub).never.to.equal(newTable.sub2)
			expect(newTable.sub.key).to.equal("value")
			expect(newTable.sub2.key).to.equal("value")
		end)

		T.it("can extend copied values using 'copy'", function()
			local someTable = {
				sub = {
					key = "value"
				}
			}

			local subBaseTable = {
				baseKey = "copied value"
			}
			local baseTable = {
				sub = Copy:BehaveAs("copy", subBaseTable)
			}

			Copy:Extend(someTable, baseTable)

			expect(someTable.sub).never.to.equal(nil)
			expect(someTable.sub).never.to.equal(subBaseTable)
			expect(someTable.sub.key).to.equal(nil)
			expect(someTable.sub.baseKey).to.equal("copied value")
		end)

		T.it("can extend copied fields from values using 'default'", function()
			local someTable = {
				sub = {
					key = "value"
				}
			}

			local subBaseTable = {
				baseKey = "copied value"
			}
			local baseTable = {
				sub = Copy:BehaveAs("default", subBaseTable)
			}

			Copy:Extend(someTable, baseTable)

			expect(someTable.sub).never.to.equal(nil)
			expect(someTable.sub).never.to.equal(subBaseTable)
			expect(someTable.sub.baseKey).to.equal("copied value")
			expect(someTable.sub.key).to.equal("value")
		end)

		T.it("can extend copied values using 'set'", function()
			local someTable = {
				sub = {
					key = "value"
				}
			}

			local subBaseTable = {
				baseKey = "copied value"
			}
			local baseTable = {
				sub = Copy:BehaveAs("set", Copy(subBaseTable))
			}

			Copy:Extend(someTable, baseTable)

			expect(someTable.sub).never.to.equal(nil)
			expect(someTable.sub).never.to.equal(subBaseTable)
			expect(someTable.sub.key).to.equal(nil)
			expect(someTable.sub.baseKey).to.equal("copied value")
		end)

		T.it("can extend shared values using 'set'", function()
			local someTable = {
				shared = {
					key = "value"
				}
			}
			
			local sharedTable = {
				baseKey = "replaced value"
			}
			local baseTable = {
				shared = Copy:BehaveAs("set", sharedTable)
			}

			Copy:Extend(someTable, baseTable)

			expect(someTable.shared).to.equal(sharedTable)
		end)

		T.it("can extend metatables using 'default'", function()
			Copy.GlobalBehavior.Meta = "default"

			local meta = {}
			local someTable = setmetatable({}, meta)

			local baseTable = setmetatable({}, {
				key = "base value"
			})

			Copy:Extend(someTable, baseTable)

			expect(meta.key).to.equal("base value")
		end)

		T.it("can skip extending values using 'pass'", function()
			local someTable = {
				key = "value"
			}

			local baseTable = {
				key = Copy:BehaveAs("pass")
			}

			Copy:Extend(someTable, baseTable)

			expect(someTable.key).to.equal("value")
		end)

		T.it("gives :BehaveAs priority over global behavior", function()
			local someTable = Copy:BehaveAs("default", {
				key = Copy:BehaveAs("set", "value")
			})

			Copy.GlobalBehavior.Values = "pass"
			local newTable = Copy(someTable)

			expect(newTable.key).to.equal("value")
		end)

		T.it("can use custom symbols", function()
			local function symbol()
				return true, "some other value"
			end
			local someTable = {
				key = "value"
			}
			local baseTable = {
				key = symbol
			}

			Copy.BehaviorMap[symbol] = true
			Copy:Extend(someTable, baseTable)

			expect(someTable.key).to.equal("some other value")
		end)

		T.it("does not allow foreign symbols in :BehaveAs", function()
			expect(function()
				Copy:BehaveAs("not a real symbol!")
			end).to.throw()
		end)

		T.it("does not allow foreign symbols in global behavior", function()
			expect(function()
				Copy.GlobalBehavior.Values = "not a real symbol!"
			end).to.throw()
		end)

		T.it("does not allow foreign contexts in global behavior", function()
			expect(function()
				Copy.GlobalBehavior.FakeContext = "default"
			end).to.throw()
		end)
	end)

end