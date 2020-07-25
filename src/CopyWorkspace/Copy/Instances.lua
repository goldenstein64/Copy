-- Private Functions
local function getTransform(copy, var)
	local result = copy.Transform[var]
	
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
local function indexValue(state, var)
	local type_var = typeof(var)
	if type_var == "Instance" and not getTransform(state.Copy, var) then
		state.Instances[var] = true
	elseif type_var == "table" and not state.Explored[var] then
		indexSubTable(state, var)
	end
end
function indexSubTable(state, tabl)
	state.Explored[tabl] = true
	for k, v in pairs(tabl) do
		if state.Copy.Parameters.copyKeys then
			indexValue(state, k)
		end
		indexValue(state, v)
	end
	local mt = getmetatable(tabl)
	if type(mt) == "table" then
		indexValue(state, mt)
	end
end
local function indexTable(var, copy)
	local state = {
		Copy = copy,
		Instances = {},
		Explored = {}
	}
	indexValue(state, var)
	return state.Instances
end

local function isRootAncestor(instance, instances)
	local result = true
	for other in pairs(instances) do
		if instance:IsDescendantOf(other) then
			result = false
			break
		end
	end
	return result
end

local function getRegisteredDescendants(instance, instances)
	local result = {}
	for other in pairs(instances) do
		if instance:IsAncestorOf(other) then
			result[other] = true
		end
	end
	return result
end

local function cloneRootAncestors(instances, transform, parentAncestors)
	for instance in pairs(instances) do
		if not isRootAncestor(instance, instances) then continue end
		local newInstance = safeClone(instance, parentAncestors)
		transform[instance] = newInstance
		local descendants = instance:GetDescendants()
		local newDescendants = newInstance:GetDescendants()
		for desc in pairs(getRegisteredDescendants(instance, instances)) do
			local descIndex = table.find(descendants, desc)
			transform[desc] = newDescendants[descIndex]
		end
	end
end

-- Module
local Instances = {
	SafeClone = safeClone
}

-- Public Functions
function Instances.ApplyTransform(copy, tabl)
	local instances = indexTable(tabl, copy)
	cloneRootAncestors(instances, copy.Transform, copy.Parameters.SetParent)
end

return Instances