local DEFAULT_ERROR = "assertion failed!"

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

		assert(not ok, DEFAULT_ERROR)
	end,

	Arrays = function(Copy)
		local completeArray = { "a", "b", "c" }
		local array = { nil, "b", nil }

		Copy:Extend(array, completeArray)

		assert(array[1] == "a", DEFAULT_ERROR)
		assert(array[2] == "b", DEFAULT_ERROR)
		assert(array[3] == "c", DEFAULT_ERROR)
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

		assert(namespace.OtherMethod ~= nil, DEFAULT_ERROR)
		assert(namespace.OtherMethod() == "other method", DEFAULT_ERROR)
	end,

	Metatables = function(Copy)
		local someTable = setmetatable({}, { key = "value" })
		local otherTable = setmetatable({}, { otherKey = "other value" })

		Copy:Extend(otherTable, someTable)

		local otherMt = getmetatable(otherTable)
		assert(otherMt.key == "value", DEFAULT_ERROR)
		assert(otherMt.otherKey == nil, DEFAULT_ERROR)
	end,

	ExtendTwice = function(Copy)
		local object = {
			objectKey = "object value"
		}

		Copy:Extend(object, base, modifier, modifier2)

		assert(object.objectKey == "object value", DEFAULT_ERROR)
		assert(object.Key == "modified 2 value", DEFAULT_ERROR)
		assert(object.BaseKey == "inherited value", DEFAULT_ERROR)
		assert(object.ModKey == "extended value", DEFAULT_ERROR)
		assert(object.Mod2Key == "extended 2 value", DEFAULT_ERROR)
	end,

}