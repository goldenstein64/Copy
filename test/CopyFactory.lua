local Workspace = game:GetService("Workspace")

local copy = require(Workspace.Copy)

return function()
	local newCopy = setmetatable({
		Flags = setmetatable({
			Flush = copy.Flags.Flush,
			SetInstanceParent = copy.Flags.SetInstanceParent,
		}, {
			__newindex = getmetatable(copy.Flags).__newindex,
		}),
		GlobalContext = setmetatable({
			[newproxy()] = {
				Keys = {},
				Values = { "transform", "reconcile", "replace" },
				Meta = {},
			},
		}, getmetatable(copy.GlobalContext)),
		Transform = {},
		SymbolMap = setmetatable({}, {
			__mode = getmetatable(copy.SymbolMap).__mode,
		}),

		Extend = copy.Extend,
		BehaveAs = copy.BehaveAs,
		Flush = copy.Flush,
	}, {
		__call = getmetatable(copy).__call,
		__index = getmetatable(copy).__index,
		__newindex = getmetatable(copy).__newindex,
	})
	return newCopy
end
