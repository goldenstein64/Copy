--[[

(a child of) The Copy Module
A module that copies any value with state. No more, no less.

Author: goldenstein64
Free Model: https://www.roblox.com/library/5089132938
Docs: TBD

ver 1

--]]

return {
	
	ErrorNonTable = function(Copy)
		local userdata = newproxy(true)
		local otherUserdata = newproxy(true)
		local otherMt = getmetatable(otherUserdata)
		otherMt.__index = {}
		
		local s = pcall(function()
			Copy:Across(userdata, otherUserdata)
		end)
		
		assert(not s)
	end,
	
	Arrays = function(Copy)
		local completeArray = { "a", "b", "c" }
		local array = { nil, "b", nil }
		
		Copy:Across(array, completeArray)
		assert(array == array)
		assert(array[1] == "a", array[2] == "b", array[3] == "c")
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
		
		Copy:Across(otherTable, someTable)
		assert(getmetatable(otherTable).otherKey == "other value")
	end
}