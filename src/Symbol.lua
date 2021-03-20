local main = script.Parent
local Behaviors = require(main.Behaviors)

local Symbol = {}

function Symbol:__tostring()
	return string.format("Symbol(%s)", self.Name)
end

function Symbol:__call(newValue)
	return Behaviors.HandleValue(self.Owner, self.Behaviors, self.Value, newValue)
end

return Symbol
