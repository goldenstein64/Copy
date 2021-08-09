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
			local key = newproxy()
			local someTable = {
				[Copy:BehaveAs("default", key)] = "value",
			}

			local newTable = Copy(someTable)
			local newKey = next(newTable)

			expect(newKey).to.be.a("userdata")
			expect(newKey).to.never.equal(key)
		end)

		it("allows different behavior in metatables", function()
			local meta = {}
			local someTable = setmetatable({}, Copy:BehaveAs("default", meta))

			local newTable = Copy(someTable)
			local newMeta = getmetatable(newTable)

			expect(newMeta).to.be.a("table")
			expect(newMeta).to.never.equal(meta)
		end)
	end)

	describe("Behaviors", function()
		it("can duplicate values using 'replace'", function()
			local subTable = {
				key = "value",
			}
			local someTable = {
				sub = subTable,
				sub2 = Copy:BehaveAs("replace", subTable),
			}

			local newTable = Copy(someTable)

			expect(newTable.sub).to.never.equal(newTable.sub2)
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

			expect(someTable.sub).to.never.equal(nil)
			expect(someTable.sub).to.never.equal(subBaseTable)
			expect(someTable.sub.baseKey).to.equal("copied value")
			expect(someTable.sub.key).to.equal("value")
		end)

		it("can overwrite values using 'replace'", function()
			local subSomeTable = {
				key = "value",
			}
			local someTable = {
				sub = subSomeTable,
			}

			local subBaseTable = {
				baseKey = "copied value",
			}
			local baseTable = {
				sub = Copy:BehaveAs("replace", Copy(subBaseTable)),
			}

			Copy:Extend(someTable, baseTable)

			-- stylua: ignore
			expect(someTable.sub)
				.to.never.equal(subSomeTable)
				.to.never.equal(subBaseTable)
				.to.never.equal(nil)
			expect(someTable.sub.key).to.equal(nil)
			expect(someTable.sub.baseKey).to.equal("copied value")
		end)

		it("can skip copying values using 'pass'", function()
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

			local baseTable = setmetatable(
				{},
				Copy:BehaveAs("reconcile", {
					key = "base value",
				})
			)

			Copy:Extend(someTable, baseTable)

			expect(meta.key).to.equal("base value")
		end)

		describe("Presets", function()
			it("always returns an array upon index", function()
				Copy.GlobalContext.Values = "default"

				local valuesContext = Copy.GlobalContext.Values

				expect(valuesContext).to.be.a("table")
				expect(valuesContext[1]).to.equal("transform")
				expect(valuesContext[2]).to.equal("reconcile")
				expect(valuesContext[3]).to.equal("replace")
			end)

			it("can normally copy values in other contexts using 'default'", function()
				local key = newproxy()
				local some = {
					[Copy:BehaveAs("default", key)] = "value",
				}

				local new = Copy(some)
				local newKey = next(new)

				expect(newKey).to.never.equal(key)
				expect(new[key]).to.equal(nil)
				expect(some[newKey]).to.equal(nil)
				expect(new[newKey]).to.equal("value")
			end)

			it("can move shared values using 'set'", function()
				local sub = {}

				local some = {
					owned = sub,
					shared = Copy:BehaveAs("set", sub),
				}

				local new = Copy(some)

				expect(new.owned).to.never.equal(sub)
				expect(new.shared).to.equal(sub)
			end)
		end)
	end)

	it("gives Copy:BehaveAs() priority over global behavior", function()
		local someTable = Copy:BehaveAs("default", {
			key = Copy:BehaveAs("set", "value"),
		})

		Copy.GlobalContext.Values = "pass"
		local newTable = Copy(someTable)

		expect(newTable.key).to.equal("value")
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
			local function makeDuck()
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

	it("deletes itself once not referenced anymore", function()
		Copy:BehaveAs("set", nil)

		wait(1)

		expect(next(Copy.SymbolMap)).to.equal(nil)
	end)
end
