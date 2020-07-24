--[[

(a child of) The Copy Module
A module that copies any value with state. No more, no less.

Author: goldenstein64
Free Model: https://www.roblox.com/library/5089132938
Docs: TBD

ver 1

--]]

local ITER = 10_000

-- removing 1 iteration because TestLoader implementation
local NESTED_ITER = 8_186

return {
	
	-- Primitive stress test
	Primitives = function(Copy)
		local R = Random.new()
		local someTable = {} do
			for i = 1, ITER do
				someTable[i] = R:NextNumber()
			end
		end
		local t = os.clock()
		
		local newTable = Copy(someTable)
		
		local finish = os.clock() - t
		assert(#newTable == ITER)
		return "Primitives", finish
	end,
	
	-- Table stress test
	Tables = function(Copy)
		local someTable = {} do
			for i = 1, ITER do
				someTable[i] = {}
			end
		end
		local t = os.clock()
		
		local newTable = Copy(someTable)
		
		local finish = os.clock() - t
		assert(#newTable == ITER)
		return "Tables", finish
	end,
	
	-- Symbol stress test
	Symbols = function(Copy)
		local someTable = {} do
			for i = 1, ITER do
				someTable[i] = newproxy(false)
			end
		end
		local t = os.clock()
		
		local newTable = Copy(someTable)
		
		local finish = os.clock() - t
		assert(#newTable == ITER)
		return "Symbols", finish
	end,
	
	-- Full userdata stress test
	Userdatas = function(Copy)
		local someTable = {} do
			for i = 1, ITER do
				someTable[i] = newproxy(true)
			end
		end
		local t = os.clock()
		
		local newTable = Copy(someTable)
		
		local finish = os.clock() - t
		assert(#newTable == ITER)
		return "Userdatas", finish
	end,
	
	-- Nested stress test
	NestedTables = function(Copy)
		local someTable = {} do
			local current = someTable
			for _ = 1, NESTED_ITER do
				local new = {}
				current[1] = new
				current = new
			end
		end
		local t = os.clock()
		
		local newTable = Copy(someTable)
		
		local finish = os.clock() - t
		do
			local current = newTable
			for _ = 1, NESTED_ITER do
				current = current[1]
			end
			
			assert(current ~= nil)
		end
		
		return "NestedTables", finish
	end,
	
	-- Identical subtables
	IdenticalTables = function(Copy)
		local subTable = {}
		local someTable = table.create(10_000, subTable)
		local t = os.clock()
		
		local newTable = Copy(someTable)
		
		local finish = os.clock() - t
		do
			local newSubTable = newTable[1]
			for i = 2, ITER do
				assert(newTable[i] == newSubTable)
			end
		end
		
		return "IdenticalTables", finish
	end
}