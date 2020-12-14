local Workspace = game:GetService("Workspace")

local copy = require(Workspace.Copy)

return function()
	local newCopy = setmetatable({
		Flags = setmetatable({
			Flush = copy.Flags.Flush,
			SetParent = copy.Flags.SetParent,
		}, {
			__newindex = getmetatable(copy.Flags).__newindex
		}),
		GlobalBehavior = setmetatable({
			[next(copy.GlobalBehavior)] = {
				Keys = copy.GlobalBehavior.Keys,
				Values = copy.GlobalBehavior.Values,
				Meta = copy.GlobalBehavior.Meta,
			}
		}, {
			__index = getmetatable(copy.GlobalBehavior).__index,
			__newindex = getmetatable(copy.GlobalBehavior).__newindex,
		}),
		Transform = {},
		BehaviorMap = setmetatable({}, {
			__mode = getmetatable(copy.BehaviorMap).__mode
		}),

		Extend = copy.Extend,
		BehaveAs = copy.BehaveAs,
		Flush = copy.Flush,
	}, {
		__call = getmetatable(copy).__call
	})
	return newCopy
end