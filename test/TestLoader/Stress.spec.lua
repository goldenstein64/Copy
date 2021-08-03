return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)

	local LUA_MAX_STACK_SIZE = 2 ^ 14

	-- removing 5 iterations because TestLoader implementation
	local NESTED_ITER = LUA_MAX_STACK_SIZE / 4 - 5 --> 4091
	local ITER = NESTED_ITER

	local Copy
	beforeEach(function()
		Copy = CopyFactory()
	end)

	it("copies primitives quickly", function()
		local R = Random.new()
		local someTable = {}
		do
			for i = 1, ITER do
				someTable[i] = R:NextNumber()
			end
		end
		local t = os.clock()

		local newTable = Copy(someTable)

		local finish = os.clock() - t
		expect(#newTable).to.equal(ITER)
		return "Primitives", string.format("%.6f", finish)
	end)

	it("copies tables quickly", function()
		local someTable = {}
		do
			for i = 1, ITER do
				someTable[i] = {}
			end
		end
		local t = os.clock()

		local newTable = Copy(someTable)

		local finish = os.clock() - t
		expect(#newTable).to.equal(ITER)
		return "Tables", string.format("%.6f", finish)
	end)

	it("copies shallow userdatas quickly", function()
		local someTable = {}
		do
			for i = 1, ITER do
				someTable[i] = newproxy()
			end
		end
		local t = os.clock()

		local newTable = Copy(someTable)

		local finish = os.clock() - t
		expect(#newTable).to.equal(ITER)
		return "Symbols", string.format("%.6f", finish)
	end)

	it("copies full userdatas quickly", function()
		local someTable = {}
		do
			for i = 1, ITER do
				someTable[i] = newproxy(true)
			end
		end
		local t = os.clock()

		local newTable = Copy(someTable)

		local finish = os.clock() - t
		expect(#newTable).to.equal(ITER)
		return "Userdatas", string.format("%.6f", finish)
	end)

	it("copies nested tables quickly", function()
		local someTable = {}
		do
			local current = someTable
			for _ = 1, NESTED_ITER do
				local new = {}
				current[1] = new
				current = new
			end
		end
		local t = os.clock()

		local newTable = Copy(someTable)

		local finish = os.clock() - t
		do
			local current = newTable
			for _ = 1, NESTED_ITER do
				current = current[1]
			end

			expect(current).to.never.equal(nil)
		end

		return "NestedTables", string.format("%.6f", finish)
	end)

	it("copies identical tables quickly", function()
		local subTable = {}
		local someTable = table.create(ITER, subTable)
		local t = os.clock()

		local newTable = Copy(someTable)

		local finish = os.clock() - t
		do
			local newSubTable = newTable[1]
			for i = 2, ITER do
				expect(newTable[i]).to.equal(newSubTable)
			end
		end

		return "IdenticalTables", string.format("%.6f", finish)
	end)
end
