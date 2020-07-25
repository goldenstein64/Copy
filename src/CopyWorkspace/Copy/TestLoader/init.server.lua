-- Dependencies
local Test = require(script.Test)
local Copy = require(script.Parent)

-- All the tests to be run by Test
local RUNNING_TESTS = {
	CallCopy = { 
		"PremiseSample", 
		"TechnicalSample",
		"SelfCopy", 
		"CheckCopied", 
		"CheckReturned", 
		"InstanceHierarchy", 
		"TransformSafeguard", 
		"TransformSafeguardAcross", 
		"TransformSafeguardBypass", 
		"Cyclic",
		"DuplicateValues",
		"DuplicateKeys",
		"DuplicateMetatables",
	},
	Across = { 
		"ErrorNonTable", 
		"Arrays", 
		"Dictionaries", 
		"Metatables",
		"CheckMetaFlagOn",
		"CheckMetaFlagOff",
	},
	Flags = {
		"CopyKeysOn",
		"CopyKeysOff",
		"CopyKeysParamOn",
		"CopyKeysParamOff",
		"CopyMetaOn",
		"CopyMetaOff",
		"CopyMetaParamOn",
		"CopyMetaParamOff",
		"FlushOn", 
		"FlushOff", 
		"FlushParamOn",
		"FlushParamOff",
		"FlushRelation", 
		"SetParentOn", 
		"SetParentOff", 
		"SetParentParamOn",
		"SetParentParamOff",   
		"ErrorNonFlag",
		"GetBackupFlag",
	},
	AcrossFlags = {
		"CopyKeysOn",
		"CopyKeysOff",
		"CopyMetaOn",
		"CopyMetaOff",
	},
	Transform = { 
		"Values",
		"Keys", 
		"Metatables",
		"SubValues", 
		"AltPreserve", 
		"DeleteValues", 
		"DeleteMetatables",
		"DeleteKeySafeguard", 
		"CheckNIL",
	},
	Preserve = { 
		"Values", 
		"Keys",
		"Metatables", 
		"MultipleValues",
		"AvoidNil",
	},
	Flush = { 
		"CheckFunctionality",
	},
	Stress = { 
		"Primitives", 
		"Tables", 
		"Symbols", 
		"Userdatas", 
		"NestedTables",
		"IdenticalTables",
	},
}

Test.CheckMissingTests(RUNNING_TESTS)

Test(RUNNING_TESTS, Copy)