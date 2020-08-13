local R = Random.new()

local function isEmpty(t)
	return next(t) == nil
end

return {

	-- Flush
	FlushTransformOn = function(Copy)
		local dict = {
			sub = {}
		}

		Copy.Flags.FlushTransform = true
		local _ = Copy(dict)

		assert( isEmpty(Copy.Transform) )
	end,
	FlushTransformOff = function(Copy)
		local dict = {
			sub = {}
		}

		Copy.Flags.FlushTransform = false
		local _ = Copy(dict)

		assert(not isEmpty(Copy.Transform))
	end,

	-- relationship between tables and subtables
	FlushTransformRelation = function(Copy)
		local someTable = {
			sub = {}
		}

		Copy.Flags.FlushTransform = false
		local newSubTable = Copy(someTable.sub)
		local newTable = Copy(someTable)

		assert(newTable.sub == newSubTable)
	end,

	FlushContextOn = function(Copy)
		local someTable = {}

		Copy.Flags.FlushContext = true
		Copy.Context = Copy:repl{ value = 2 }
		local _2 = Copy(someTable)

		assert(Copy.Context == nil)
	end,

	FlushContextOff = function(Copy)
		local someTable = {}

		Copy.Flags.FlushContext = false
		Copy.Context = Copy:repl{ value = 2 }
		local _2 = Copy(someTable)

		assert(Copy.Context ~= nil)
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