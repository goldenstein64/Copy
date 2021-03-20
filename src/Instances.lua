-- Private Functions
local function isTransformed(copy, value)
	local result = copy.Transform[value]

	return result ~= nil
end

local function safeClone(instance, setParent)
	local oldArchivable = instance.Archivable
	instance.Archivable = true
	local newInstance = instance:Clone()
	if newInstance then
		newInstance.Archivable = oldArchivable
		if setParent then
			newInstance.Parent = instance.Parent
		end
	else
		newInstance = instance
	end
	instance.Archivable = oldArchivable
	return newInstance
end

local indexSubTable
local function indexSubValue(state, var)
	local type_var = typeof(var)
	if type_var == "Instance" and not isTransformed(state.Copy, var) then
		state.Instances[var] = true
	elseif type_var == "table" and not state.Explored[var] and not state.Copy.BehaviorMap[var] then
		indexSubTable(state, var)
	elseif type_var == "userdata" then
		indexSubValue(state, getmetatable(var))
	end
end

function indexSubTable(state, tabl)
	state.Explored[tabl] = true
	if tabl == state.Copy.Transform then
		return
	end
	for k, v in pairs(tabl) do
		if table.find(state.Copy.GlobalContext.Keys, "replace") then
			indexSubValue(state, k)
		end
		if table.find(state.Copy.GlobalContext.Values, "replace") then
			indexSubValue(state, v)
		end
	end

	local meta = getmetatable(tabl)
	if type(meta) == "table" and table.find(state.Copy.GlobalContext.Meta, "replace") then
		indexSubValue(state, meta)
	end
end

local function indexValue(copy, value)
	local state = {
		Copy = copy,
		Instances = {},
		Explored = {},
	}
	if table.find(state.Copy.GlobalContext.Values, "replace") then
		indexSubValue(state, value)
	end

	return state.Instances
end

local function getInstanceRelations(instance, instances)
	local result = {}
	for other in pairs(instances) do
		if instance == other then
			continue
		elseif instance:IsDescendantOf(other) then
			return false
		elseif instance:IsAncestorOf(other) then
			result[other] = true
		end
	end
	return true, result
end

local function cloneRootAncestors(instances, setParent)
	local transform = {}

	for instance in pairs(instances) do
		local isRootAncestor, registeredDescendants = getInstanceRelations(instance, instances)
		if isRootAncestor then
			local newInstance = safeClone(instance, setParent)
			transform[instance] = newInstance
			if next(registeredDescendants) ~= nil then
				local descendants = instance:GetDescendants()
				local newDescendants = newInstance:GetDescendants()
				for desc in pairs(registeredDescendants) do
					local descIndex = table.find(descendants, desc)
					transform[desc] = newDescendants[descIndex]
				end
			end
		end
	end

	return transform
end

-- Module
local Instances = {}

-- Public Functions
function Instances.SafeClone(copy, instance)
	return safeClone(instance, copy.Flags.SetParent)
end

function Instances.ApplyTransform(copy, value)
	local instances = indexValue(copy, value)
	local transform = cloneRootAncestors(instances, copy.Flags.SetParent)
	return transform
end

return Instances
