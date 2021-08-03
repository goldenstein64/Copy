local root = script.Parent
local Behaviors = require(root.Behaviors)

local function getReal(self)
	return select(2, next(self))
end

local Contexts = {
	Global = {
		[newproxy()] = {
			Keys = {},
			Values = { "transform", "reconcile", "replace" },
			Meta = {},
		},
	},
}

Contexts.Enum = {}
local enumString = {}
for context in pairs(getReal(Contexts.Global)) do
	Contexts.Enum[context] = true
	table.insert(enumString, context)
end

enumString = table.concat(enumString, ", ")
local function errorUnknownContext(context)
	error(
		string.format("Unknown context (%s) found. The only allowed contexts are %s.", tostring(context), enumString),
		2
	)
end

function Contexts.Assert(context)
	if Contexts.Enum[context] then
		return context
	else
		errorUnknownContext(context)
	end
end

local globalMt = {}

function globalMt:__index(context)
	Contexts.Assert(context)
	return getReal(self)[context]
end

function globalMt:__newindex(context, behaviors)
	Contexts.Assert(context)
	behaviors = Behaviors.Convert(behaviors)
	getReal(self)[context] = behaviors
end

setmetatable(Contexts.Global, globalMt)

return Contexts
