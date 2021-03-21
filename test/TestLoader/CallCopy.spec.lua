return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)

	local function getDictLen(dict)
		local result = 0
		for _ in pairs(dict) do
			result += 1
		end
		return result
	end

	local Copy
	beforeEach(function()
		Copy = CopyFactory()
	end)

	describe("Samples", function()
		it("can run the basic sample", function()
			-- this is a table
			local array = { 1, 2, 3 }

			-- this is a copy of that table
			local newArray = Copy(array)

			-- these tables are not the same!
			expect(newArray).to.never.equal(array)
		end)

		it("can run the technical sample", function()
			local parentFolder = Instance.new("Folder")

			local key = {}
			local dict = setmetatable({
				member = 8,
				userdata = newproxy(true),
				folder = Instance.new("Folder"),
				[key] = "value",

				greet = function()
					print("hello world!")
				end,
			}, {
				__index = function()
					return "does not exist!"
				end,
			})
			dict.folder.Parent = parentFolder
			dict.part = Instance.new("Part")
			dict.part.Parent = dict.folder
			dict.cyclic = dict
			getmetatable(dict.userdata).__index = function(_, k)
				return "indexed with " .. k
			end

			local newDict = Copy(dict)

			expect(dict).to.never.equal(newDict) --> This table was copied!

			expect(newDict.member).to.equal(8) --> Copies stateless members
			expect(newDict.cyclic).to.equal(newDict) --> Retains cyclic behavior
			expect(dict.part).to.never.equal(newDict.part) --> Clones parts
			expect(dict.greet).to.equal(newDict.greet) --> Retains functions

			expect(newDict[key]).to.equal("value") --> Retains keys

			expect(getmetatable(dict)).to.equal(getmetatable(newDict)) --> Retains metatables
			expect(newDict.fakeMember).to.equal("does not exist!") --> Retains metamethods

			expect(dict.userdata).to.never.equal(newDict.userdata) --> Copies userdatas
			expect(dict.userdata.key).to.equal("indexed with key") --> Retains metamethods!

			expect(newDict.folder.Part).to.equal(newDict.part) --> Retains hierarchy
			expect(newDict.folder.Parent).to.equal(nil) --> Root ancestors are not parented
		end)
	end)

	describe("TypeTests", function()
		it("copies tables", function()
			local someTable = {}
			expect(Copy(someTable)).to.never.equal(someTable)
		end)

		it("copies userdatas", function()
			local someUserdata = newproxy(false)
			expect(Copy(someUserdata)).to.never.equal(someUserdata)
		end)

		it("copies Instances", function()
			local someInstance = Instance.new("Part")
			expect(Copy(someInstance)).to.never.equal(someInstance)
		end)

		it("copies the Random roblox type", function()
			local someRandom = Random.new()
			expect(Copy(someRandom)).to.never.rawEqual(someRandom)
		end)

		it("preserves strings", function()
			local someString = "some string"
			expect(Copy(someString)).to.equal(someString)
		end)

		it("preserves numbers", function()
			local someNumber = 8
			expect(Copy(someNumber)).to.equal(someNumber)
		end)

		it("preserves booleans", function()
			local someBoolean = true
			expect(Copy(someBoolean)).to.equal(someBoolean)
		end)

		it("preserves functions", function()
			local someFunction = function()
			end
			expect(Copy(someFunction)).to.equal(someFunction)
		end)

		it("preserves threads", function()
			local someThread = coroutine.create(function()
			end)
			expect(Copy(someThread)).to.equal(someThread)
		end)

		it("preserves uncloneable Instances", function()
			local RunService = game:GetService("RunService")
			expect(Copy(RunService)).to.equal(RunService)
		end)

		it("preserves roblox types", function()
			local someRblxType = Vector3.new()
			expect(Copy(someRblxType)).to.rawEqual(someRblxType)
		end)
	end)

	describe("Duplicates", function()
		it("keeps duplicate values the same", function()
			Copy.GlobalContext.Values = "default"

			local subTable = {}
			local someTable = { subTable, subTable }

			local newTable = Copy(someTable)

			expect(newTable[1]).to.equal(newTable[2])
		end)

		it("keeps duplicate keys the same", function()
			Copy.GlobalContext.Keys = "default"

			local subKey = {}
			local someTable = {
				{ [subKey] = true },
				{ [subKey] = true },
			}

			local newTable = Copy(someTable)

			local key1 = next(newTable[1])

			expect(newTable[2][key1]).to.equal(true)
		end)

		it("keeps duplicate metatables the same", function()
			Copy.GlobalContext.Meta = "default"

			local subMeta = {}
			local someTable = {
				setmetatable({}, subMeta),
				setmetatable({}, subMeta),
			}

			local newTable = Copy(someTable)

			local meta1 = getmetatable(newTable[1])
			local meta2 = getmetatable(newTable[2])

			expect(meta1).to.equal(meta2)
		end)

		it("copies cyclic tables without infinitely looping", function()
			local someTable = {}
			someTable.cyclic = someTable

			local newTable = Copy(someTable)

			expect(newTable).to.equal(newTable.cyclic)
		end)

		it("copies multi-level cyclic tables without infinitely looping", function()
			local someTable = {}
			local otherTable = {}
			local anotherTable = {}
			someTable.cyclic = otherTable
			otherTable.cyclic = anotherTable
			anotherTable.cyclic = someTable

			local newTable = Copy(someTable)

			expect(newTable).to.equal(newTable.cyclic.cyclic.cyclic)
		end)
	end)

	describe("default behavior", function()
		it("copies sub-table values as default behavior", function()
			local subTable = {
				key = "some value",
			}
			local someTable = {
				sub = subTable,
			}

			local newTable = Copy(someTable)

			expect(newTable.sub).to.never.equal(someTable.sub)
			expect(newTable.sub.key).to.equal("some value")
		end)

		it("doesn't copy keys as default behavior", function()
			local key = {}
			local someTable = {
				[key] = "table value",
			}

			local newTable = Copy(someTable)

			expect(newTable[key]).to.equal("table value")
		end)

		it("doesn't copy metatables as default behavior", function()
			local meta = {}
			local someTable = setmetatable({}, meta)

			local newTable = Copy(someTable)
			local newMeta = getmetatable(newTable)

			expect(newMeta).to.equal(meta)
		end)
	end)

	describe("SelfCopy", function()
		it("copies itself under default settings", function()
			local newCopy = Copy(Copy)

			for k, v in pairs(Copy) do
				local type_v = type(v)
				if type_v == "function" then
					expect(newCopy[k]).to.equal(v)

				elseif type_v == "table" and k ~= "Transform" then
					expect(getDictLen(newCopy[k])).to.equal(getDictLen(v))

				end
			end
		end)
	end)
end
