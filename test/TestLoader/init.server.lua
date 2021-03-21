-- Dependencies
local TestEZModule = script.Parent.TestEZ
local TextReporter = require(TestEZModule.Reporters.TextReporter)

local TestEZ: TestEZ = require(TestEZModule)

TestEZ.TestBootstrap:run({ script }, TextReporter)
