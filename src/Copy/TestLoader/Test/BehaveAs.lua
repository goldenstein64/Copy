return {

	setNil = function(Copy)
		local someTable = {
			key = "value"
		}

		local baseTable = {
			key = Copy:BehaveAs("set", nil)
		}

		Copy:Extend(someTable, baseTable)

		assert(someTable.key == nil)
	end,

	force = function(Copy)
		local someTable = {
			sub = {
				key = "value"
			}
		}

		local baseTable = {
			sub = Copy:BehaveAs("copy", {
				baseKey = "copied value"
			})
		}

		Copy:Extend(someTable, baseTable)

		assert(someTable.sub ~= nil)
		assert(someTable.sub ~= baseTable.sub.Value)
		assert(someTable.sub.key == nil)
		assert(someTable.sub.baseKey == "copied value")
	end,

	altForce = function(Copy)
		local someTable = {
			sub = {
				key = "value"
			}
		}

		local subBaseTable = {
			baseKey = "copied value"
		}
		local baseTable = {
			sub = Copy:BehaveAs("set", Copy(subBaseTable))
		}

		Copy:Extend(someTable, baseTable)

		assert(someTable.sub ~= nil)
		assert(someTable.sub ~= subBaseTable)
		assert(someTable.sub.key == nil)
		assert(someTable.sub.baseKey == "copied value")
	end,

	set = function(Copy)
		local someTable = {
			shared = {
				key = "value"
			}
		}

		local baseTable = {
			shared = Copy:BehaveAs("set", {
				baseKey = "replaced value"
			})
		}

		Copy:Extend(someTable, baseTable)

		assert(someTable.shared == baseTable.shared.Value)
	end,

	setMeta = function(Copy)
		local someTable = setmetatable({}, {
			key = "value"
		})

		local baseTable = setmetatable({}, {
			key = "base value"
		})

		Copy.GlobalBehavior.Meta = "copy"
		Copy:Extend(someTable, baseTable)

		assert(getmetatable(someTable).key == "base value")
	end,

	pass = function(Copy)
		local someTable = {
			key = "value"
		}

		local baseTable = {
			key = Copy:BehaveAs("pass")
		}

		Copy:Extend(someTable, baseTable)

		assert(someTable.key == "value")
	end,

	CustomSymbol = function(Copy)
		local function symbol()
			return true, "some other value"
		end
		local someTable = {
			key = "value"
		}
		local baseTable = {
			key = symbol
		}

		Copy.BehaviorMap[symbol] = true
		Copy:Extend(someTable, baseTable)

		assert(someTable.key == "some other value")
	end,

	ErrorInvalid = function(Copy)
		local ok = pcall(function()
			Copy:BehaveAs("not a real symbol!")
		end)

		assert(not ok)
	end,

}