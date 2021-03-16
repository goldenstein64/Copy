local main = script.Parent
local reconcilers = require(main.Reconcilers)

local replacers = {}

function replacers.table(self, oldTable)
	return reconcilers.table(self, oldTable, {})
end

function replacers.userdata(self, userdata)
	local meta = getmetatable(userdata)
	local hasMeta = type(meta) == "table"
	local newUserdata = newproxy(hasMeta)
	self.Transform[userdata] = newUserdata
	reconcilers.userdata(self, userdata, newUserdata)

	return true, true, newUserdata
end

function replacers.Random(self, random)
	local newRandom = random:Clone()
	self.Transform[random] = newRandom
	return true, true, newRandom
end

function replacers.Instance(self, instance)
	local newInstance = self.InstanceTransform[instance]
	return true, true, newInstance
end

return replacers
