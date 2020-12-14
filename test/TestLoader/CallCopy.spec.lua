return function()
	local CopyFactory = require(script.Parent.Parent.CopyFactory)
	local T = getfenv()
	local expect = T.expect

	local function getDictLen(dict)
		local result = 0
		for _ in pairs(dict) do
			result += 1
		end
		return result
	end

	T.describe("__call samples", function()
		T.it("runs the basic sample successfully", function()
			local Copy = CopyFactory()
			
			-- this is a table
			local array = { 1, 2, 3 }

			-- this is a copy of that table
			local newArray = Copy(array)

			-- these tables are not the same!
			expect(newArray).never.to.equal(array)
		end)

		T.it("runs the technical sample successfully", function()
			local Copy = CopyFactory()

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
				end
			})
			dict.folder.Parent = parentFolder
			dict.part = Instance.new("Part")
			dict.part.Parent = dict.folder
			dict.cyclic = dict
			getmetatable(dict.userdata).__index = function(_, k)
				return "indexed with " .. k
			end

			local newDict = Copy(dict)

			expect(dict).never.to.equal(newDict) --> This table was copied!

			expect(newDict.member).to.equal(8) --> Copies stateless members
			expect(newDict.cyclic).to.equal(newDict) --> Retains cyclic behavior
			expect(dict.part).never.to.equal(newDict.part) --> Clones parts
			expect(dict.greet).to.equal(newDict.greet) --> Retains functions

			expect(newDict[key]).to.equal("value") --> Retains keys

			expect(getmetatable(dict)).to.equal(getmetatable(newDict)) --> Retains metatables
			expect(newDict.fakeMember).to.equal("does not exist!") --> Retains metamethods

			expect(dict.userdata).never.to.equal(newDict.userdata) --> Copies userdatas
			expect(newDict.userdata.key).to.equal("indexed with key") --> Retains metamethods

			expect(newDict.folder.Part).to.equal(newDict.part) --> Retains hierarchy
			expect(newDict.folder.Parent).to.equal(nil) --> Root ancestors are not parented
		end)
	end)

	T.describe("__call behavior on each type", function()
		T.it("copies tables", function()
			local Copy = CopyFactory()
			
			local someTable = {}
			expect(Copy(someTable)).never.to.equal(someTable)
		end)

		T.it("copies userdatas", function()
			local Copy = CopyFactory()

			local someUserdata = newproxy(false)
			expect(Copy(someUserdata)).never.to.equal(someUserdata)
		end)

		T.it("copies Instances", function()
			local Copy = CopyFactory()

			local someInstance = Instance.new("Part")
			expect(Copy(someInstance)).never.to.equal(someInstance)
		end)

		T.it("copies the Random roblox type", function()
			local Copy = CopyFactory()

			local someRandom = Random.new()
			expect(Copy(someRandom)).never.to.rawEqual(someRandom)
		end)

		T.it("preserves strings", function()
			local Copy = CopyFactory()

			local someString = "some string"
			expect(Copy(someString)).to.equal(someString)
		end)

		T.it("preserves numbers", function()
			local Copy = CopyFactory()

			local someNumber = 8
			expect(Copy(someNumber)).to.equal(someNumber)
		end)

		T.it("preserves booleans", function()
			local Copy = CopyFactory()

			local someBoolean = true
			expect(Copy(someBoolean)).to.equal(someBoolean)
		end)

		T.it("preserves functions", function()
			local Copy = CopyFactory()

			local someFunction = function() end
			expect(Copy(someFunction)).to.equal(someFunction)
		end)

		T.it("preserves threads", function()
			local Copy = CopyFactory()

			local someThread = coroutine.create(function() end)
			expect(Copy(someThread)).to.equal(someThread)
		end)

		T.it("preserves uncloneable Instances", function()
			local Copy = CopyFactory()

			local RunService = game:GetService("RunService")
			expect(Copy(RunService)).to.equal(RunService)
		end)

		T.it("preserves roblox types", function()
			local Copy = CopyFactory()

			local someRblxType = Vector3.new()
			expect(Copy(someRblxType)).to.rawEqual(someRblxType)
		end)

		T.it("copies itself under default settings", function()
			local Copy = CopyFactory()

			local allFlags = {}
			for flagName in pairs(Copy.Flags) do
				table.insert(allFlags, flagName)
			end
			local totalPermutations = 2^#allFlags
			for i = 0, totalPermutations - 1 do
				for index, flagName in ipairs(allFlags) do
					Copy.Flags[flagName] = (i / 2^index) % 1 >= 0.5
				end
				local newCopy = Copy(Copy)
				for k, v in pairs(Copy) do
					local type_v = type(v)
					if type_v == "function" then
						expect(newCopy[k]).to.equal(v)
					elseif type_v == "table" and v ~= Copy.Transform then
						expect(getDictLen(newCopy[k])).to.equal(getDictLen(v))
					end
				end
			end
		end)

		T.it("should properly copy cyclic tables", function()
			local Copy = CopyFactory()

			local someTable = {}
			someTable.cyclic = someTable

			local newTable = Copy(someTable)

			expect(newTable).to.equal(newTable.cyclic)
		end)
	end)

	T.describe("duplicate value handling", function()
		T.it("should keep duplicate values the same", function()
			local Copy = CopyFactory()
			Copy.GlobalBehavior.Values = "default"

			local subTable = {}
			local someTable = { subTable, subTable }

			local newTable = Copy(someTable)

			expect(newTable[1]).to.equal(newTable[2])
		end)

		T.it("should keep duplicate keys the same", function()
			local Copy = CopyFactory()
			Copy.GlobalBehavior.Keys = "default"

			local subKey = {}
			local someTable = {
				{ [subKey] = true },
				{ [subKey] = true }
			}

			local newTable = Copy(someTable)

			local key1 = next(newTable[1])

			expect(newTable[2][key1]).to.equal(true)
		end)

		T.it("should keep duplicate metatables the same", function()
			local Copy = CopyFactory()
			Copy.GlobalBehavior.Meta = "default"

			local subMeta = {}
			local someTable = {
				setmetatable({}, subMeta),
				setmetatable({}, subMeta)
			}

			local newTable = Copy(someTable)

			local meta1 = getmetatable(newTable[1])
			local meta2 = getmetatable(newTable[2])

			expect(meta1).to.equal(meta2)
		end)
	end)
end