local base = {
	Key = "base value",
	BaseKey = "inherited value"
}

local modifier = {
	Key = "modified value",
	ModKey = "extended value"
}

local modifier2 = {
	Key = "modified 2 value",
	Mod2Key = "extended 2 value",
}

return {
	
	ErrorNonTable = function(Copy)
		local userdata = newproxy(true)
		local otherUserdata = newproxy(true)
		local otherMt = getmetatable(otherUserdata)
		otherMt.__index = {}
		
		local ok = pcall(function()
			Copy:Extend(userdata, otherUserdata)
		end)
		
		assert(not ok)
	end,
	
	Arrays = function(Copy)
		local completeArray = { "a", "b", "c" }
		local array = { nil, "b", nil }
		
		Copy:Extend(array, completeArray)
		assert(array[1] == "a" and array[2] == "b" and array[3] == "c")
	end,
	
	Dictionaries = function(Copy)
		local namespace = {}
		function namespace.Method()
			return "method"
		end
		
		local otherNamespace = {}
		function otherNamespace.OtherMethod()
			return "other method"
		end
		
		Copy:Extend(namespace, otherNamespace)
		assert(namespace.OtherMethod ~= nil)
		assert(namespace.OtherMethod() == "other method")
	end,
	
	Metatables = function(Copy)
		local someTable = setmetatable({}, { key = "value" })
		local otherTable = setmetatable({}, { otherKey = "other value" })
		
		Copy.Flags.CopyMeta = true
		Copy:Extend(otherTable, someTable)

		assert(getmetatable(otherTable).key == "value")
		assert(getmetatable(otherTable).otherKey == nil)
	end,

	CheckMetaFlagOn = function(Copy)
		local mt = {}
		local someTable = setmetatable({}, mt)
		local otherTable = setmetatable({}, {})

		Copy.Flags.CopyMeta = true
		Copy:Extend(otherTable, someTable)

		local otherMt = getmetatable(otherTable)

		assert(otherMt ~= mt)
	end,
	CheckMetaFlagOff = function(Copy)
		local mt = {}
		local someTable = setmetatable({}, mt)
		local otherTable = setmetatable({}, {})

		Copy.Flags.CopyMeta = false
		Copy:Extend(otherTable, someTable)

		local otherMt = getmetatable(otherTable)

		assert(otherMt == mt)
	end,

	ExtendTwice = function(Copy)
		local object = Copy:Extend({}, base, modifier, modifier2)

		assert(object.Key == "modified 2 value")
		assert(object.BaseKey == "inherited value")
		assert(object.ModKey == "extended value")
		assert(object.Mod2Key == "extended 2 value")
	end,

}