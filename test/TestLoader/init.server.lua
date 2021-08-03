local Workspace = game:GetService("Workspace")

local TestEZ = require(Workspace.CopyTest.TestEZ)

TestEZ.TestBootstrap:run({ script }, TestEZ.Reporters.TextReporter)
