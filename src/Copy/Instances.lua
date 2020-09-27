-- Private Functions
local function getTransform(copy, value)
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
	if type_var == "Instance" and not getTransform(state.Copy, var) then
		state.Instances[var] = true
	elseif type_var == "table" and not state.Explored[var] then
		indexSubTable(state, var)
	elseif type_var == "userdata" then
		indexSubValue(state, getmetatable(var))
	end
end

function indexSubTable(state, tabl)
	state.Explored[tabl] = true
	if tabl == state.Copy.Transform then return end
	for k, v in pairs(tabl) do
		if state.Copy.GlobalBehavior.Keys == "copy" and not getTransform(state.Copy, k) then
			indexSubValue(state, k)
		end
		if state.Copy.GlobalBehavior.Values == "copy" and not getTransform(state.Copy, v) then
			indexSubValue(state, v)
		end
	end

	local meta = getmetatable(tabl)
	if type(meta) == "table"
		and state.Copy.GlobalBehavior.Meta == "copy" and not getTransform(state.Copy, meta)
	then
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