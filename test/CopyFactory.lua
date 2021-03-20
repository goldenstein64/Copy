local Workspace = game:GetService("Workspace")

local copy = require(Workspace.Copy)

return function()
	local newCopy = setmetatable({
		Flags = setmetatable({
			Flush = copy.Flags.Flush,
			SetParent = copy.Flags.SetParent,
		}, {
			__newindex = getmetatable(copy.Flags).__newindex,
		}),
		GlobalContext = setmetatable(
			{
				[newproxy(false)] = {
					Keys = {},
					Values = { "transform", "reconcile", "replace" },
					Meta = {},
				},

			},
			getmetatable(copy.GlobalContext)
		),
		Transform = {},
		BehaviorMap = setmetatable({}, {
			__mode = getmetatable(copy.BehaviorMap).__mode,
		}),

		Extend = copy.Extend,
		BehaveAs = copy.BehaveAs,
		Flush = copy.Flush,
	}, {
		__call = getmetatable(copy).__call,
	})
	return newCopy
end
