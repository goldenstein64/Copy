-- Module
local Test = {
	Aspects = {},
	AllTests = {}
}
local testMt = {}
local allTestsMt = {}
setmetatable(Test, testMt)
setmetatable(Test.AllTests, allTestsMt)

-- Setup
for _, mod in ipairs(script:GetChildren()) do
	local aspect = require(mod)
	Test.Aspects[mod.Name] = aspect
	local aspectArray = {}
	for testName in pairs(aspect) do
		table.insert(aspectArray, testName)
	end
	Test.AllTests[mod.Name] = aspectArray
end

-- Public Functions
function allTestsMt:__tostring()
	local result = "{\n"
	for name, array in pairs(self) do
		local formatString = "\t%s = {\n" .. string.rep("\t\t%q,\n", #array) .. "\t},\n"
		result ..= string.format(formatString, name, table.unpack(array))
	end
	result ..= "}"
	return result
end

function Test.MakeFactory(copy)
	return function()
		local newCopy = setmetatable({
			Flags = setmetatable({
				FlushTransform = copy.Flags.FlushTransform,
				SetParent = copy.Flags.SetParent,
			}, {
				__newindex = getmetatable(copy.Flags).__newindex
			}),
			GlobalBehavior = {
				Keys = copy.GlobalBehavior.Keys,
				Values = copy.GlobalBehavior.Values,
				Meta = copy.GlobalBehavior.Meta,
			},
			Transform = {},
			SymbolMap = {},

			Extend = copy.Extend,
			Symbol = copy.Symbol,
			Flush = copy.Flush,
		}, {
			__call = getmetatable(copy).__call
		})
		return newCopy
	end
end

function testMt:__call(testDict, copy)
	local factory = Test.MakeFactory(copy)
	for aspectKey, array in pairs(testDict) do
		local aspectArray = self.Aspects[aspectKey]
		if not aspectArray then
			error(string.format(
				"This aspect (%s) does not exist!", tostring(aspectKey)
			))
		end
		for _, index in ipairs(array) do
			local test = aspectArray[index]
			if not test then
				error(string.format("This test (%s) does not exist!", tostring(index)))
			end

			local result = table.pack(xpcall(test, function(msg)
				warn(debug.traceback("false " .. msg))
			end, factory()))
			local ok = result[1]
			if ok then
				print(ok, table.unpack(result, 2, result.n))
			end
		end
	end
end

function Test.CheckMissingTests(testDict)
	for aspectKey, aspectArray in pairs(Test.AllTests) do
		local testArray = testDict[aspectKey]
		if testArray then
			for _, name in ipairs(aspectArray) do
				local hasTest = table.find(testArray, name)
				if not hasTest then
					warn(aspectKey, ".", name)
				end
			end
		else
			warn(aspectKey)
		end
	end
end

return Test