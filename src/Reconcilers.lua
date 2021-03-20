local main = script.Parent
local Behaviors = require(main.Behaviors)

local reconcilers = {}

function reconcilers.table(self, oldTable, newTable)
	if oldTable == self.Transform then
		return true, true, newTable
	end
	self.Transform[oldTable] = newTable

	local keyBehavior = self.GlobalContext.Keys
	local valueBehavior = self.GlobalContext.Values
	local metaBehavior = self.GlobalContext.Meta

	for k, v in pairs(oldTable) do
		local doSet_k, newKey
		local midKey = nil
		if self.SymbolMap[k] then
			doSet_k, newKey = k(midKey)
		else
			doSet_k, newKey = Behaviors.HandleValue(self, keyBehavior, k, midKey)
		end
		if not doSet_k or newKey == nil then
			newKey = k
		end

		local doSet_v, newValue
		local midValue = rawget(newTable, k)
		if self.SymbolMap[v] then
			doSet_v, newValue = v(midValue)
		else
			doSet_v, newValue = Behaviors.HandleValue(self, valueBehavior, v, midValue)
		end
		if doSet_v then
			rawset(newTable, newKey, newValue)
		end
	end

	local meta = getmetatable(oldTable)
	if type(meta) == "table" then
		local doSet_m, newMeta
		local midMeta = getmetatable(newTable)
		if self.SymbolMap[meta] then
			doSet_m, newMeta = meta(midMeta)
		else
			doSet_m, newMeta = Behaviors.HandleValue(self, metaBehavior, meta, midMeta)
		end
		if doSet_m then
			setmetatable(newTable, newMeta)
		end
	end

	return true, true, newTable
end

function reconcilers.userdata(self, userdata, newUserdata)
	local meta = getmetatable(userdata)
	local hasMeta = type(meta) == "table"
	local newMeta = getmetatable(userdata)
	local newHasMeta = type(newMeta) == "table"
	if hasMeta and newHasMeta then
		self.Transform[userdata] = newUserdata
		reconcilers.table(self, meta, newMeta)
		return true, true, newUserdata
	else
		return false
	end
end

return reconcilers
