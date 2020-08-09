local function getDictLen(dict)
	local result = 0
	for _ in pairs(dict) do
		result += 1
	end
	return result
end

local function toBinary(number)--Returns string n in binary
	local result = ""
	if number == 0 then
		result = "0"
	end
	while number > 0 do
		local digit = number % 2
		result = tostring(digit) .. result
		number = (number - digit) / 2
	end
	return result
end

return {
	
	PremiseSample = function(Copy)
		
		-- this is a table
		local array = { 1, 2, 3 }
		
		-- this is a copy of that table
		local newArray = Copy(array)
		
		-- these tables are not the same!
		assert(array ~= newArray)
	end,
	
	TechnicalSample = function(Copy)
		local parentFolder = Instance.new("Folder")
		
		local key = {}
		local dict = setmetatable({
			member = 8,
			userdata = newproxy(true),
			folder = Instance.new("Folder", parentFolder),
			[key] = "value",

			greet = function()
				print("hello world!")
			end,
		}, {
			__index = function()
				return "does not exist!"
			end
		})
		dict.part = Instance.new("Part", dict.folder)
		dict.cyclic = dict
		getmetatable(dict.userdata).__index = function(_, k)
			return "indexed with " .. k 
		end
		
		local newDict = Copy(dict)
		
		assert(dict ~= newDict) --> This table was copied!
		
		assert(newDict.member == 8) --> Copies stateless members
		assert(newDict.cyclic == newDict) --> Retains cyclic behavior
		assert(dict.part ~= newDict.part) --> Clones parts
		assert(dict.greet == newDict.greet) --> Retains functions

		assert(dict[key] == "value") --> Retains keys
		
		assert(getmetatable(dict) == getmetatable(newDict)) --> Retains metatables
		assert(newDict.fakeMember == "does not exist!") --> Retains metamethods
		
		assert(dict.userdata ~= newDict.userdata) --> Copies userdatas
		assert(newDict.userdata.key == "indexed with key") --> Retains metamethods
		
		assert(newDict.folder.Part == newDict.part) --> Retains hierarchy
		assert(newDict.folder.Parent == nil) --> Root ancestors are not parented
	end,
	
	-- Copying Copy
	SelfCopy = function(Copy)
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
					assert(newCopy[k] == v)
				elseif type_v == "table" then
					if getDictLen(newCopy[k]) ~= getDictLen(v) and v ~= Copy.Cache then
						error("Test failed for " .. toBinary(i) .. " at " .. tostring(k) 
							.. "\nwith " .. tostring(getDictLen(newCopy[k])) .. " == " 
							.. tostring(getDictLen(v))
						)
					end
				end
			end
		end
	end,
	
	-- These are copied
	CheckCopied = function(Copy)
		local copiedValues = {
			table = {},
			userdata = newproxy(false),
			instance = Instance.new("Part"),
			random = Random.new()
		}
		
		for key, value in pairs(copiedValues) do
			assert(rawequal(value, Copy(value)) == false, "value failed for " .. key)
		end
	end,
	
	-- These are returned
	CheckReturned = function(Copy)
		local nilValue = nil
		local returnedValues = {
			bool = true,
			number = 5,
			string = "some string",
			func = function() end,
			thread = coroutine.create(function() end),
			rblxType = Vector3.new(),
			
			-- one of the few services that won't error :D
			service = game:GetService("RunService") 
		}
		
		-- nil is tested separately since it can't be stored in a table
		assert(nilValue == Copy(nilValue))
		for key, value in pairs(returnedValues) do
			assert(rawequal(value, Copy(value)) == true, "value failed for " .. key)
		end
	end,
	
	-- Preserving hierarchy among Instances
	InstanceHierarchy = function(Copy)
		local folder = Instance.new("Folder")
		local someTable = {
			folder = folder,
			part = Instance.new("Part", folder)
		}
		
		local newTable = Copy(someTable)
		
		assert(newTable.folder.Part == newTable.part)
	end,
	
	TransformSafeguard = function(Copy)
		Copy.Transform["value"] = "other value"
		
		local newTransform = Copy(Copy.Transform)
		
		assert(newTransform["value"] == nil)
	end,
	
	-- for Copy:Extend
	TransformSafeguardAcross = function(Copy)
		Copy.Transform["value"] = "other value"
		local newTransform = {
			["different value"] = "separate value"
		}
		
		Copy:Extend(newTransform, Copy.Transform)
		
		assert(newTransform["value"] == nil)
	end,
	
	-- proper Transform duplication
	TransformSafeguardBypass = function(Copy)
		Copy.Transform["value"] = "other value"
		
		local oldTransform
		Copy.Transform, oldTransform = {}, Copy.Transform
		local newTransform = Copy(oldTransform)
		
		assert(newTransform["value"] == "other value")
	end,
	
	Cyclic = function(Copy)
		local someTable = {}
		someTable.cyclic = someTable
		
		local newTable = Copy(someTable)
		
		assert(newTable == newTable.cyclic)
	end,
	
	DuplicateValues = function(Copy)
		local subTable = {}
		local someTable = { subTable, subTable }
		
		local newTable = Copy(someTable)
		
		assert(newTable[1] == newTable[2])
	end,
	
	DuplicateKeys = function(Copy)
		local subKey = {}
		local someTable = {
			{ [subKey] = true },
			{ [subKey] = true }
		}
		
		local newTable = Copy(someTable)
		
		local key1 = next(newTable[1])
		
		assert(newTable[2][key1] == true)
	end,
	
	DuplicateMetatables = function(Copy)
		local subMeta = {}
		local someTable = {
			setmetatable({}, subMeta),
			setmetatable({}, subMeta)
		}
		
		local newTable = Copy(someTable)
		
		local meta1 = getmetatable(newTable[1])
		local meta2 = getmetatable(newTable[2])
		
		assert(meta1 == meta2)
	end,
}