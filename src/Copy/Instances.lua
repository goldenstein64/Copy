-- Private Functions
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
	if type_var == "Instance" and state.Copy.Transform[var] == nil then
		state.Instances[var] = true
	elseif type_var == "table" and not state.Explored[var] then
		indexSubTable(state, var)
	end
end
function indexSubTable(state, tabl)
	state.Explored[tabl] = true
	for k, v in pairs(tabl) do
		if state.Copy.Flags.CopyKeys or state.Copy.Operations.Force[k] then
			indexSubValue(state, k)
		end
		indexSubValue(state, v)
	end
	local meta = getmetatable(tabl)
	if (state.Copy.Flags.CopyMeta or state.Copy.Operations.Force[meta]) and type(meta) == "table" then
		indexSubValue(state, meta)
	end
end

local function indexValue(copy, value)
	local state = {
		Copy = copy,
		Instances = {},
		Explored = {}
	}
	indexSubValue(state, value)
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

local function cloneRootAncestors(instances, transform, setParent)
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
end

-- Module
local Instances = {}

-- Public Functions
function Instances.SafeClone(copy, instance)
	return safeClone(instance, copy.Flags.SetParent)
end

function Instances.ApplyTransform(copy, value)
	local instances = indexValue(copy, value)
	cloneRootAncestors(instances, copy.Transform, copy.Flags.SetParent)
end

return Instances