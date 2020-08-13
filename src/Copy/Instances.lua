-- Private Functions
local function getContext(copy, context, returnType)
	if context.allowed and rawget(context.current, copy.Tag) then
		local result = context.current[returnType]

		if result == copy.NIL then
			return true, nil
		else
			return result ~= nil, result
		end
	else
		return false, nil
	end
end

local function getTransform(copy, value)
	local result = copy.Transform[value]

	if result == copy.NIL then
		return true, nil
	else
		return result ~= nil, result
	end
end

local function searchForValue(copy, context, returnType, value)
	local contextSuccess = getContext(copy, context, returnType)
	local transformSuccess = getTransform(copy, value)

	return contextSuccess or transformSuccess
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
	if type_var == "Instance" and state.Copy.Transform[var] == nil then
		state.Instances[var] = true
	elseif type_var == "table" and not state.Explored[var] then
		indexSubTable(state, var)
	end
end
function indexSubTable(state, tabl)
	state.Explored[tabl] = true
	if tabl == state.Copy.Transform then return end
	local lastAllowed = state.Context.allowed
	local lastCurrent = state.Context.current
	for k, v in pairs(tabl) do
		state.Context.allowed = lastAllowed and lastCurrent[k] ~= nil
		if state.Context.allowed then
			state.Context.current = lastCurrent[k]
		end

		local success_k = searchForValue(state.Copy, state.Context, "key", k)
		if not success_k and state.Copy.GlobalBehavior.Keys then
			indexSubValue(state, k)
		end
		local success_v = searchForValue(state.Copy, state.Context, "value", v)
		if not success_v and state.Copy.GlobalBehavior.Values then
			indexSubValue(state, v)
		end
	end
	
	local metaCurrent = getmetatable(lastCurrent)
	state.Context.allowed = lastAllowed and metaCurrent ~= nil
	if state.Context.allowed then
		state.Context.current = metaCurrent
	end
	local meta = getmetatable(tabl)
	local success_meta = searchForValue(state.Copy, state.Context, "value", meta)
	if type(meta) == "table" and not success_meta and state.Copy.GlobalBehavior.Meta then
		indexSubValue(state, meta)
	end

	state.Context.allowed = lastAllowed
	state.Context.current = lastCurrent
end

local function indexValue(copy, value)
	local state = {
		Copy = copy,
		Context = {
			allowed = type(copy.Context) == "table",
			current = copy.Context
		},
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