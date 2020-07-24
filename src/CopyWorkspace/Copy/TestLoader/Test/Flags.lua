--[[

(a child of) The Copy Module
A module that copies any value with state. No more, no less.

Author: goldenstein64
Free Model: https://www.roblox.com/library/5089132938
Docs: TBD

ver 1

--]]

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

		Copy.Flags.copyKeys = true
		local newDict = Copy(dict)
		local newKey = next(newDict)

		assert(key ~= newKey)
	end,
	CopyKeysOff = function(Copy)
		local key = newproxy(false)
		local dict = {
			[key] = "value"
		}
		
		Copy.Flags.copyKeys = false
		local newDict = Copy(dict)
		local newKey = next(newDict)
		
		assert(key == newKey)
	end,

	-- CopyKeys as parameter
	CopyKeysParamOn = function(Copy)
		local key = newproxy(false)
		local dict = {
			[key] = "value"
		}
		
		local newDict = Copy(dict, {copyKeys = true})
		local newKey = next(newDict)
		
		assert(key ~= newKey)
	end,
	CopyKeysParamOff = function(Copy)
		local key = newproxy(false)
		local dict = {
			[key] = "value"
		}
		
		local newDict = Copy(dict, {copyKeys = false})
		local newKey = next(newDict)
		
		assert(key == newKey)
	end,
	
	CopyMetaOn = function(Copy)
		local meta = {}
		local dict = setmetatable({}, meta)
		
		Copy.Flags.copyMeta = true
		local newDict = Copy(dict)
		local newMeta = getmetatable(newDict)
		
		assert(meta ~= newMeta)
	end,
	CopyMetaOff = function(Copy)
		local meta = {}
		local dict = setmetatable({}, meta)
		
		Copy.Flags.copyMeta = false
		local newDict = Copy(dict)
		local newMeta = getmetatable(newDict)
		
		assert(meta == newMeta)
	end,

	-- CopyMeta as parameter
	CopyMetaParamOn = function(Copy)
		local meta = {}
		local dict = setmetatable({}, meta)
		
		local newDict = Copy(dict, {copyMeta = true})
		local newMeta = getmetatable(newDict)
		
		assert(meta ~= newMeta)
	end,
	CopyMetaParamOff = function(Copy)
		local meta = {}
		local dict = setmetatable({}, meta)
		
		local newDict = Copy(dict, {copyMeta = false})
		local newMeta = getmetatable(newDict)
		
		assert(meta == newMeta)
	end,
	
	-- Flush
	FlushOn = function(Copy)
		local dict = {
			sub = {}
		}
		
		Copy.Flags.flush = true
		local _ = Copy(dict)
		
		assert( isEmpty(Copy.Transform) )
	end,
	FlushOff = function(Copy)
		local dict = {
			sub = {}
		}
		
		Copy.Flags.flush = false
		local _ = Copy(dict)
		
		assert( not isEmpty(Copy.Transform) )
	end,

	-- Flush as param
	FlushParamOn = function(Copy)
		local dict = {
			sub = {}
		}
		
		local _ = Copy(dict, {flush = true})
		
		assert( isEmpty(Copy.Transform) )
	end,
	FlushParamOff = function(Copy)
		local dict = {
			sub = {}
		}
		
		local _ = Copy(dict, {flush = false})
		
		assert( not isEmpty(Copy.Transform) )
	end,
	
	-- relationship between tables and subtables
	FlushRelation = function(Copy)
		local params = { flush = false }
		
		local someTable = { 
			sub = {}
		}
		
		local newSubTable = Copy(someTable.sub, params)
		local newTable = Copy(someTable, params)
		
		assert(newTable.sub == newSubTable)
	end,
	
	-- ParentAncestors
	SetParentOn = function(Copy)
		local array = {}
		local parent = Instance.new("Folder")
		for i = 1, 5 do
			local newPart = Instance.new("Part")
			newPart.Transparency = R:NextNumber()
			newPart.Parent = parent
			array[i] = newPart
			
		end
		
		Copy.Flags.setParent = true
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
		
		Copy.Flags.setParent = false
		local newArray = Copy(array)
		
		for i = 1, 5 do
			assert(newArray[i].Parent == nil)
		end
	end,

	-- ParentAncestors as param
	SetParentParamOn = function(Copy)
		local array = {}
		local parent = Instance.new("Folder")
		for i = 1, 5 do
			local newPart = Instance.new("Part")
			newPart.Transparency = R:NextNumber()
			newPart.Parent = parent
			array[i] = newPart
			
		end
		
		local newArray = Copy(array, {setParent = true})
		
		for i = 1, 5 do
			assert(newArray[i].Parent == array[i].Parent)
		end
	end,
	SetParentParamOff = function(Copy)
		local array = {}
		local parent = Instance.new("Folder")
		for i = 1, 5 do
			local newPart = Instance.new("Part")
			newPart.Transparency = R:NextNumber()
			newPart.Parent = parent
			array[i] = newPart
		end
		
		local newArray = Copy(array, {setParent = false})
		
		for i = 1, 5 do
			assert(newArray[i].Parent == nil)
		end
	end,
	
	ErrorNonFlag = function(Copy)
		local s = pcall(function()
			Copy.Flags.NonFlag = true
		end)
		assert(s == false)
	end,

	GetBackupFlag = function(Copy)
		Copy.Flags.copyKeys = true
		local params = { copyKeys = nil }

		local key = newproxy(false)
		local newDict = Copy({ [key] = "value"}, params)

		local newKey = next(newDict)

		assert(key ~= newKey)
	end,
}