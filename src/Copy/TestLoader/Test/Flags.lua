local DEFAULT_ERROR = "assertion failed!"

local R = Random.new()

local function isEmpty(t)
	return next(t) == nil
end

return {

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

		assert(not isEmpty(Copy.Transform), DEFAULT_ERROR)
	end,

	-- relationship between tables and subtables
	FlushRelation = function(Copy)
		local someTable = {
			sub = {}
		}

		Copy.Flags.Flush = false
		local newSubTable = Copy(someTable.sub)
		local newTable = Copy(someTable)

		assert(newTable.sub == newSubTable, DEFAULT_ERROR)
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
			assert(newArray[i].Parent == array[i].Parent, DEFAULT_ERROR)
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
			assert(newArray[i].Parent == nil, DEFAULT_ERROR)
		end
	end,

	ErrorNonFlag = function(Copy)
		local ok = pcall(function()
			Copy.Flags.NonFlag = true
		end)
		assert(not ok, DEFAULT_ERROR)
	end,

}