--[[
	TestEZ and Tests are referenced from Workspace because it's also used by 
	run-in-roblox to run the tests. `run-in-roblox` will run the script from in 
	the plugin, meaning `script` will be located somewhere else in the tree.
--]]

local Workspace = game:GetService("Workspace")

local CopyTest = Workspace.CopyTest
	local TestEZ = require(CopyTest.TestEZ)
	local testFolder = CopyTest.Tests

TestEZ.TestBootstrap:run({ testFolder }, TestEZ.Reporters.TextReporter)