-- Private Functions
local function getTransform(copy, value)
	local result = copy.Transform[value]

	if result == copy.NIL then
		return true, nil
	else
		return result ~= nil, result
	end
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
local function indexSubValue(state, value)
	local type_var = typeof(value)
	if type_var == "Instance" and not getTransform(state.Copy, value) then
		state.Instances[value] = true
	elseif type_var == "table" and not state.Explored[value] then
		indexSubTable(state, value)
	end
end
function indexSubTable(state, tabl)
	state.Explored[tabl] = true
	for k, v in pairs(tabl) do
		if state.Copy.Flags.CopyKeys or getTransform(state.Copy, k) then
			indexSubValue(state, k)
		end
		indexSubValue(state, v)
	end
	local meta = getmetatable(tabl)
	if (state.Copy.Flags.CopyMeta or getTransform(state.Copy, meta)) and type(meta) == "table" then
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

function Instances.ApplyCache(copy, value)
	local instances = indexValue(copy, value)
	cloneRootAncestors(instances, copy.Cache, copy.Flags.SetParent)
end

return Instances