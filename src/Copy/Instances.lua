-- Private Functions
local function getTransform(copy, context, value)
	local result = copy.Transform[context][value]

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
local function indexSubValue(state, context, value)
	local type_value = typeof(value)
	if type_value == "Instance" and not getTransform(state.Copy, context, value) then
		state.Instances[context][value] = true
	elseif type_value == "table" and not state.Explored[value] then
		indexSubTable(state, value)
	end
end
function indexSubTable(state, tabl)
	state.Explored[tabl] = true
	for k, v in pairs(tabl) do
		indexSubValue(state, "Keys", k)
		indexSubValue(state, "Values", v)
	end
	local meta = getmetatable(tabl)
	if type(meta) == "table" then
		indexSubValue(state, "Meta", meta)
	end
end

local function indexValue(copy, value)
	local state = {
		Copy = copy,
		Instances = {
			Keys = {},
			Values = {},
			Meta = {},
		},
		Explored = {}
	}
	indexSubValue(state, "Values", value)
	return state.Instances
end

local function getInstanceRelations(instance, instances)
	local registeredDescendants = {
		Keys = {},
		Values = {},
		Meta = {},
	}
	for context, contextDict in pairs(instances) do
		for other in pairs(contextDict) do
			if instance == other then
				continue
			elseif instance:IsDescendantOf(other) then
				return false
			elseif instance:IsAncestorOf(other) then
				registeredDescendants[context][other] = true
			end
		end
	end
	return true, registeredDescendants
end

local function cloneRootAncestors(instances, transform, setParent)
	for context, contextDict in pairs(instances) do
		for instance in pairs(contextDict) do
			local isRootAncestor, registeredDescendants = getInstanceRelations(instance, instances)
			if isRootAncestor then
				local newInstance = safeClone(instance, setParent)
				transform[context][instance] = newInstance
				if next(registeredDescendants) ~= nil then
					local descendants = instance:GetDescendants()
					local newDescendants = newInstance:GetDescendants()
					for descContext, descContextDict in pairs(registeredDescendants) do
						for desc in pairs(descContextDict) do
							local descIndex = table.find(descendants, desc)
							transform[descContext][desc] = newDescendants[descIndex]
						end
					end
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