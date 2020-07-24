--[[

(a child of) The Copy Module
A module that copies any value with state. No more, no less.

Author: goldenstein64
Free Model: https://www.roblox.com/library/5089132938
Docs: TBD

ver 1

--]]

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
		local dict = setmetatable({
			member = 8,
			userdata = newproxy(true),
			folder = Instance.new("Folder", workspace),
		
			greet = function()
				print("hello world!")
			end,
		}, {
			__index = function(self)
				return "does not exist!"
			end
		})
		dict.part = Instance.new("Part", dict.folder)
		dict.cyclic = dict
		getmetatable(dict.userdata).__index = function(self, k)
			return "indexed with " .. k 
		end
		
		local newDict = Copy(dict)
		
		assert(dict ~= newDict)
		
		assert(newDict.member == 8)
		assert(newDict.cyclic == newDict)
		assert(dict.part ~= newDict.part)
		assert(dict.greet == newDict.greet)
		
		assert(getmetatable(dict) ~= getmetatable(newDict))
		assert(newDict.fakeMember == "does not exist!")
		
		assert(dict.userdata ~= newDict.userdata)
		assert(newDict.userdata.key == "indexed with key")
		
		assert(newDict.folder.Part == newDict.part)
		assert(newDict.folder.Parent == nil)
	end,
	
	-- Copying Copy
	SelfCopy = function(Copy)
		local newCopy = Copy(Copy)
		
		local someArray = { 5, 6, 7 }
		local newArray = newCopy(someArray)
		
		for i, old_v in ipairs(someArray) do
			local new_v = newArray[i]
			assert(old_v == new_v)
		end
	end,
	
	-- These are copied
	CheckCopied = function(Copy)
		local copiedValues = {
			table = {},
			userdata = newproxy(),
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
	
	-- for Copy:Across
	TransformSafeguardAcross = function(Copy)
		Copy.Transform["value"] = "other value"
		local newTransform = {
			["different value"] = "separate value"
		}
		
		Copy:Across(newTransform, Copy.Transform)
		
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