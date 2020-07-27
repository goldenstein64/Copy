return {

	CopyKeysOn = function(Copy)
		local folder = Instance.new("Folder")
		local someTable = {
			[folder] = "value"
		}

		Copy.Flags.Flush = false
		Copy.Flags.CopyKeys = true
		Copy(someTable)
		local newFolder = Copy.Transform[folder]

		assert(newFolder ~= nil)
	end,
	CopyKeysOff = function(Copy)
		local folder = Instance.new("Folder")
		local someTable = {
			[folder] = "value"
		}

		Copy.Flags.Flush = false
		Copy.Flags.CopyKeys = false
		Copy(someTable)
		local newFolder = Copy.Transform[folder]
		
		assert(newFolder == nil)
	end,

	CopyMetaOn = function(Copy)
		local folder = Instance.new("Folder")
		local someTable = setmetatable({}, {
			key = folder
		})

		Copy.Flags.Flush = false
		Copy.Flags.CopyMeta = true
		Copy(someTable)
		local newFolder = Copy.Transform[folder]

		assert(newFolder ~= nil)
	end,
	CopyMetaOff = function(Copy)
		local folder = Instance.new("Folder")
		local someTable = setmetatable({}, {
			key = folder
		})

		Copy.Flags.Flush = false
		Copy.Flags.CopyMeta = false
		Copy(someTable)
		local newFolder = Copy.Transform[folder]

		assert(newFolder == nil)
	end,
	
}