local CopyMt = {}

function CopyMt.__tostring(self)
	return "Copy: " .. tostring(self._id):sub(11)
end

return CopyMt
