return {
	
	ErrorNonTable = function(Copy)
		local userdata = newproxy(true)
		local otherUserdata = newproxy(true)
		local otherMt = getmetatable(otherUserdata)
		otherMt.__index = {}
		
		local ok = pcall(function()
			Copy:Across(userdata, otherUserdata)
		end)
		
		assert(not ok)
	end,
	
	Arrays = function(Copy)
		local completeArray = { "a", "b", "c" }
		local array = { nil, "b", nil }
		
		Copy:Across(array, completeArray)
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
		
		Copy:Across(namespace, otherNamespace)
		assert(namespace.OtherMethod ~= nil)
		assert(namespace.OtherMethod() == "other method")
	end,
	
	Metatables = function(Copy)
		local someTable = setmetatable({}, { key = "value" })
		local otherTable = setmetatable({}, { otherKey = "other value" })
		
		Copy.Flags.CopyMeta = true
		Copy:Across(otherTable, someTable)

		assert(getmetatable(otherTable).key == "value")
		assert(getmetatable(otherTable).otherKey == nil)
	end,

	CheckMetaFlagOn = function(Copy)
		local mt = {}
		local someTable = setmetatable({}, mt)
		local otherTable = setmetatable({}, {})

		Copy.Flags.CopyMeta = true
		Copy:Across(otherTable, someTable)

		local otherMt = getmetatable(otherTable)

		assert(otherMt ~= mt)
	end,
	CheckMetaFlagOff = function(Copy)
		local mt = {}
		local someTable = setmetatable({}, mt)
		local otherTable = setmetatable({}, {})

		Copy.Flags.CopyMeta = false
		Copy:Across(otherTable, someTable)

		local otherMt = getmetatable(otherTable)

		assert(otherMt == mt)
	end,

	ExtensionSample = function(Copy)
		local Base = {
			Method = function()
				return "base method!"
			end,
			FromBase = function()
				return "FromBase!"
			end
		}
		local Child = {
			Method = function()
				return "child method!"
			end,
			FromChild = function()
				return "FromChild!"
			end
		}

		local newObject = Copy(Base)
		Copy:Across(newObject, Child)

		assert(newObject.Method() == "child method!")
		assert(newObject.FromBase() == "FromBase!")
		assert(newObject.FromChild() == "FromChild!")
	end,


}