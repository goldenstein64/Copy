local CopyMt = {}

function CopyMt:__tostring()
	return "Copy: " .. tostring(self._id):sub(11)
end

function CopyMt:__index(key)
	error(string.format("Unknown key (%s) indexed!", tostring(key)), 2)
end

function CopyMt:__newindex(key, value)
	error(string.format("Unknown key ([%s] = %s) indexed!", tostring(key), tostring(value)), 2)
end

return CopyMt
