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
	Extend = {
		"ErrorNonTable",
		"Arrays",
		"Dictionaries",
		"Metatables",
		"CheckMetaFlagOn",
		"CheckMetaFlagOff",
		"ExtendTwice",
	},
	ExtendFlags = {
		"CopyKeysOn",
		"CopyKeysOff",
		"CopyMetaOn",
		"CopyMetaOff",
	},
	Flags = {
		"CopyKeysOn",
		"CopyKeysOff",
		"CopyMetaOn",
		"CopyMetaOff",
		"FlushOn",
		"FlushOff",
		"FlushRelation",
		"SetParentOn",
		"SetParentOff",
		"ErrorNonFlag",
	},
	Transform = {
		"Values",
		"Keys",
		"Metatables",
		"SubValues",
		"AltPreserve",
	},
	QueueDelete = {
		"DeleteValues",
		"DeleteMetatables",
		"DeleteKeySafeguard",
	},
	QueueForce = {
		"ForceKeys",
		"ForceMeta",
		"ForceMultipleKeys",
	},
	QueuePreserve = {
		"Values",
		"Keys",
		"Metatables",
		"MultipleValues",
		"AvoidNil",
	},
	OperationSelect = {
		"KeySelect",
		"MetaSelect",
	},
	Flush = {
		"CheckFunctionality",
	},
	InstanceArtifacts = {
		"CopyKeysOn",
		"CopyKeysOff",
		"CopyMetaOn",
		"CopyMetaOff",
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