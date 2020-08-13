return {

	ValuesDisabled = function(Copy)
		local part = Instance.new("Part")
		local array = { part }

		Copy.GlobalBehavior.Values = false
		Copy.Flags.FlushTransform = false
		local _ = Copy(array)
		local newPart = Copy.Transform[part]

		assert( newPart == nil )
	end,

	KeysDisabled = function(Copy)
		local part = Instance.new("Part")
		local dict = {
			[part] = "value"
		}

		Copy.GlobalBehavior.Keys = false
		Copy.Flags.FlushTransform = false
		local _ = Copy(dict)
		local newPart = Copy.Transform[part]

		assert( newPart == nil )
	end,

	MetaDisabled = function(Copy)
		local part = Instance.new("Part")
		local meta = { part }
		local someTable = setmetatable({}, meta)

		Copy.GlobalBehavior.Meta = false
		Copy.Flags.FlushTransform = false
		local _ = Copy(someTable)
		local newPart = Copy.Transform[part]

		assert( newPart == nil )
	end,

	Hierarchy = function(Copy)
		local folder = Instance.new("Folder")
		local someTable = {
			folder = folder,
			part = Instance.new("Part")
		}
		someTable.part.Parent = folder

		local newTable = Copy(someTable)

		assert(newTable.folder.Part == newTable.part)
	end,
	
}