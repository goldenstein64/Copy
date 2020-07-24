local codeFormat = [[```lua
%s
```]]

local fileFormat = [[`%s`]]

local sourceHeader = [[[details="Source code"]
Module hierarchy:
![image|127x62](upload://aHaL9S5FjAQ5PasNVgI5xCTZOZk.png)

]]

local sourceFooter = "[/details]\n"

local testHeader = [[[details="Test suite source code"]
Test suite hierarchy:
![image|169x222](upload://8KOyYB0iTqPS5Ba1kpsYei7hXff.png)

]]

local testFooter = "[/details]\n___"

local copyModule = script.Parent
local instancesModule = copyModule.Instances

local testLoader = copyModule.TestLoader
local testModule = testLoader.Test

local formatString = sourceHeader .. string.rep(fileFormat .. "\n" .. codeFormat .. "\n", 2) .. sourceFooter ..
	testHeader .. string.rep(fileFormat .. "\n" .. codeFormat .. "\n", 9) .. testFooter

local insertArray = {
	copyModule.Name, copyModule.Source,
	instancesModule.Name, instancesModule.Source,
	testLoader.Name, testLoader.Source,
	testModule.Name, testModule.Source
}

for _, runner in ipairs(testModule:GetChildren()) do
	table.insert(insertArray, runner.Name)
	table.insert(insertArray, runner.Source)
end

return string.format(formatString, table.unpack(insertArray))