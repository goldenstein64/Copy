local R = Random.new()

local function isEmpty(t)
	return next(t) == nil
end

return {

	-- Flush
	FlushOn = function(Copy)
		local someValue = {}
		local dict = setmetatable({
			[someValue] = someValue
		}, someValue)
		
		Copy.Flags.Flush = true
		Copy(dict)
		
		for _, contextDict in pairs(Copy.Transform) do
			assert( isEmpty(contextDict) )
		end
	end,
	FlushOff = function(Copy)
		local someValue = {}
		local dict = setmetatable({
			[someValue] = someValue
		}, someValue)
		
		Copy.Flags.Flush = false
		Copy(dict)
		
		for _, contextDict in pairs(Copy.Transform) do
			assert( not isEmpty(contextDict) )
		end
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