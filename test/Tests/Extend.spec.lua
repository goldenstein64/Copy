return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)

	local function isOfClass(value, className)
		local typeof_value = typeof(value)
		if typeof_value ~= "Instance" then
			return {
				pass = false,
				message = string.format("Expected value of type 'Instance', got '%s'", typeof_value),
			}
		end

		return {
			pass = value.ClassName == className,
			message = string.format("Expected Instance of class '%s', got '%s'", tostring(className), value.ClassName),
		}
	end

	local Copy
	beforeEach(function()
		Copy = CopyFactory()
	end)

	local function getExtenders()
		local base = {
			Key = "base value",
			BaseKey = "inherited value",
		}

		local modifier = {
			Key = "modified value",
			ModKey = "extended value",
		}

		local modifier2 = {
			Key = "modified 2 value",
			Mod2Key = "extended 2 value",
		}

		return base, modifier, modifier2
	end

	it("errors if the arguments aren't tables", function()
		local userdata = newproxy(true)
		local otherUserdata = newproxy(true)
		local otherMt = getmetatable(otherUserdata)
		otherMt.__index = {}

		expect(function()
			Copy:Extend(userdata, otherUserdata)
		end).to.throw()
	end)

	describe("table types", function()
		it("works on arrays", function()
			local completeArray = { "a", "b", "c" }
			local array = { nil, "b", nil }

			Copy:Extend(array, completeArray)

			expect(array[1]).to.equal("a")
			expect(array[2]).to.equal("b")
			expect(array[3]).to.equal("c")
		end)

		it("works on dictionaries", function()
			local namespace = {}
			function namespace.Method()
				return "method"
			end

			local otherNamespace = {}
			function otherNamespace.OtherMethod()
				return "other method"
			end

			Copy:Extend(namespace, otherNamespace)

			expect(namespace.OtherMethod).to.never.equal(nil)
			expect(namespace.OtherMethod()).to.equal("other method")
		end)

		it("works on metatables", function()
			local someTable = setmetatable({}, { key = "value" })
			local otherTable = setmetatable({}, { otherKey = "other value" })

			Copy:Extend(otherTable, someTable)
			local someMt = getmetatable(someTable)
			local otherMt = getmetatable(otherTable)

			expect(otherMt).to.equal(someMt)
		end)
	end)

	it("copies instances", function()
		expect.extend({ ofClass = isOfClass })

		local parent = Instance.new("Folder")

		local some = {
			key = "value",
		}

		local base = {
			folder = parent,
			part = Instance.new("Part"),
		}

		base.part.Parent = parent

		Copy:Extend(some, base)

		expect(some.part).to.be.ofClass("Part").to.never.equal(base.part)
	end)

	describe("inheritance", function()
		it("allows inheritance among tables", function()
			local object = {
				objectKey = "object value",
			}

			Copy:Extend(object, getExtenders())

			expect(object.objectKey).to.equal("object value")
			expect(object.Key).to.equal("modified 2 value")
			expect(object.BaseKey).to.equal("inherited value")
			expect(object.ModKey).to.equal("extended value")
			expect(object.Mod2Key).to.equal("extended 2 value")
		end)

		it("allows inheritance among sub-tables", function()
			local base, modifier, modifier2 = getExtenders()

			local object = {
				sub = {
					objectKey = "object value",
				},
			}

			Copy:Extend(object, { sub = base }, { sub = modifier }, { sub = modifier2 })

			expect(object.sub.objectKey).to.equal("object value")
			expect(object.sub.Key).to.equal("modified 2 value")
			expect(object.sub.BaseKey).to.equal("inherited value")
			expect(object.sub.ModKey).to.equal("extended value")
			expect(object.sub.Mod2Key).to.equal("extended 2 value")
		end)
	end)
end
