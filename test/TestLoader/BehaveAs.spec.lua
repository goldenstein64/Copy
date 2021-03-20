return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)

	local Copy
	beforeEach(function()
		Copy = CopyFactory()
	end)

	describe("Exclusivity", function()
		it("allows different behavior in values", function()
			local someTable = {
				key = "value",
			}

			local baseTable = {
				key = Copy:BehaveAs("set", nil),
			}

			Copy:Extend(someTable, baseTable)
			local newValue = someTable.key

			expect(newValue).to.equal(nil)
		end)

		it("allows different behavior in keys", function()
			local key = newproxy(false)
			local someTable = {
				[Copy:BehaveAs("default", key)] = "value",
			}

			local newTable = Copy(someTable)
			local newKey = next(newTable)

			expect(newKey).to.be.a("userdata")
			expect(newKey).never.to.equal(key)
		end)

		it("allows different behavior in metatables", function()
			local meta = {}
			local someTable = setmetatable({}, Copy:BehaveAs("default", meta))

			local newTable = Copy(someTable)
			local newMeta = getmetatable(newTable)

			expect(newMeta).to.be.a("table")
			expect(newMeta).never.to.equal(meta)
		end)
	end)

	describe("Behaviors", function()
		it("can copy values in the same table using 'replace'", function()
			local subTable = {
				key = "value",
			}
			local someTable = {
				sub = subTable,
				sub2 = Copy:BehaveAs("replace", subTable),
			}

			local newTable = Copy(someTable)

			expect(newTable.sub).never.to.equal(newTable.sub2)
			expect(newTable.sub.key).to.equal("value")
			expect(newTable.sub2.key).to.equal("value")
		end)

		it("can copy fields in values using 'reconcile'", function()
			local someTable = {
				sub = {
					key = "value",
				},
			}

			local subBaseTable = {
				baseKey = "copied value",
			}
			local baseTable = {
				sub = Copy:BehaveAs("reconcile", subBaseTable),
			}

			Copy:Extend(someTable, baseTable)

			expect(someTable.sub).never.to.equal(nil)
			expect(someTable.sub).never.to.equal(subBaseTable)
			expect(someTable.sub.baseKey).to.equal("copied value")
			expect(someTable.sub.key).to.equal("value")
		end)

		it("can overwrite values using 'replace'", function()
			local someTable = {
				sub = {
					key = "value",
				},
			}

			local subBaseTable = {
				baseKey = "copied value",
			}
			local baseTable = {
				sub = Copy:BehaveAs("replace", Copy(subBaseTable)),
			}

			Copy:Extend(someTable, baseTable)

			expect(someTable.sub).never.to.equal(nil)
			expect(someTable.sub).never.to.equal(subBaseTable)
			expect(someTable.sub.key).to.equal(nil)
			expect(someTable.sub.baseKey).to.equal("copied value")
		end)

		it("can extend shared values using 'set'", function()
			local someTable = {
				shared = {
					key = "value",
				},
			}

			local sharedTable = {
				baseKey = "replaced value",
			}
			local baseTable = {
				shared = Copy:BehaveAs("set", sharedTable),
			}

			Copy:Extend(someTable, baseTable)

			expect(someTable.shared).to.equal(sharedTable)
		end)

		it("can skip extending values using 'pass'", function()
			local someTable = {
				key = "value",
			}

			local baseTable = {
				key = Copy:BehaveAs("pass"),
			}

			Copy:Extend(someTable, baseTable)

			expect(someTable.key).to.equal("value")
		end)

		it("can extend metatables using 'reconcile'", function()

			local meta = {}
			local someTable = setmetatable({}, meta)

			local baseTable = setmetatable({}, Copy:BehaveAs("reconcile", {
				key = "base value",
			}))

			Copy:Extend(someTable, baseTable)

			expect(meta.key).to.equal("base value")
		end)
	end)

	describe("BehaviorPriority", function()
		it("gives Copy:BehaveAs priority over global behavior", function()
			local someTable = Copy:BehaveAs("default", {
				key = Copy:BehaveAs("set", "value"),
			})

			Copy.GlobalContext.Values = "pass"
			local newTable = Copy(someTable)

			expect(newTable.key).to.equal("value")
		end)
	end)

	describe("CustomSymbols", function()
		it("can use custom symbols", function()
			local function symbol()
				return true, "some other value"
			end

			local someTable = {
				key = "value",
			}
			local baseTable = {
				key = symbol,
			}

			Copy.SymbolMap[symbol] = true
			Copy:Extend(someTable, baseTable)

			expect(someTable.key).to.equal("some other value")
		end)

		it("can make ducks", function()
			local function makeDuck(oldValue)
				local duck = {}

				function duck.quack()
					return "QUACK"
				end

				return true, duck
			end

			Copy.SymbolMap[makeDuck] = true

			local someTable = {
				duck = makeDuck,
			}

			local newTable = Copy(someTable)

			expect(newTable.duck.quack()).to.equal("QUACK")
		end)
	end)

	describe("Assertions", function()
		it("does not allow foreign symbols in :BehaveAs", function()
			expect(function()
				Copy:BehaveAs("not a real symbol!", true)
			end).to.throw()
		end)

		it("does not allow foreign symbols in global behavior", function()
			expect(function()
				Copy.GlobalContext.Values = "not a real symbol!"
			end).to.throw()
		end)

		it("does not allow foreign contexts in global behavior", function()
			expect(function()
				Copy.GlobalContext.FakeContext = "default"
			end).to.throw()
		end)
	end)

	describe("GarbageCollection", function()
		it("deletes itself once not referenced anymore", function()
			Copy:BehaveAs("set", nil)

			wait()

			expect(next(Copy.SymbolMap)).to.equal(nil)
		end)
	end)
end
