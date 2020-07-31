local R = Random.new()

local function isEmpty(t)
	return next(t) == nil
end

return {
	
	-- CopyKeys
	CopyKeysOn = function(Copy)
		local key = newproxy(false)
		local dict = {
			[key] = "value"
		}

		Copy.Flags.CopyKeys = true
		local newDict = Copy(dict)
		local newKey = next(newDict)

		assert(key ~= newKey)
	end,
	CopyKeysOff = function(Copy)
		local key = newproxy(false)
		local dict = {
			[key] = "value"
		}
		
		Copy.Flags.CopyKeys = false
		local newDict = Copy(dict)
		local newKey = next(newDict)
		
		assert(key == newKey)
	end,

	-- CopyMeta
	CopyMetaOn = function(Copy)
		local meta = {}
		local dict = setmetatable({}, meta)
		
		Copy.Flags.CopyMeta = true
		local newDict = Copy(dict)
		local newMeta = getmetatable(newDict)
		
		assert(meta ~= newMeta)
	end,
	CopyMetaOff = function(Copy)
		local meta = {}
		local dict = setmetatable({}, meta)
		
		Copy.Flags.CopyMeta = false
		local newDict = Copy(dict)
		local newMeta = getmetatable(newDict)
		
		assert(meta == newMeta)
	end,

	-- Flush
	FlushOn = function(Copy)
		local dict = {
			sub = {}
		}
		
		Copy.Flags.Flush = true
		local _ = Copy(dict)
		
		assert( isEmpty(Copy.Transform) )
	end,
	FlushOff = function(Copy)
		local dict = {
			sub = {}
		}
		
		Copy.Flags.Flush = false
		local _ = Copy(dict)
		
		assert( not isEmpty(Copy.Transform) )
	end,

	-- relationship between tables and subtables
	FlushRelation = function(Copy)
		local someTable = { 
			sub = {}
		}
		
		Copy.Flags.Flush = false
		local newSubTable = Copy(someTable.sub)
		local newTable = Copy(someTable)
		
		assert(newTable.sub == newSubTable)
	end,
	
	-- SetParent
	SetParentOn = function(Copy)
		local array = {}
		local parent = Instance.new("Folder")
		for i = 1, 5 do
			local newPart = Instance.new("Part")
			newPart.Transparency = R:NextNumber()
			newPart.Parent = parent
			array[i] = newPart
		end
		
		Copy.Flags.SetParent = true
		local newArray = Copy(array)
		
		for i = 1, 5 do
			assert(newArray[i].Parent == array[i].Parent)
		end
	end,
	SetParentOff = function(Copy)
		local array = {}
		local parent = Instance.new("Folder")
		for i = 1, 5 do
			local newPart = Instance.new("Part")
			newPart.Transparency = R:NextNumber()
			newPart.Parent = parent
			array[i] = newPart
		end
		
		Copy.Flags.SetParent = false
		local newArray = Copy(array)
		
		for i = 1, 5 do
			assert(newArray[i].Parent == nil)
		end
	end,

	ErrorNonFlag = function(Copy)
		local ok = pcall(function()
			Copy.Flags.NonFlag = true
		end)
		assert(not ok)
	end,

}