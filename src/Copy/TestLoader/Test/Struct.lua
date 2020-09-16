return {
	Default = function(Copy)
		local class = {
			subKey = "sub value"
		}
		local obj = {
			key = "value",
			__index = class
		}

		Copy:Extend(obj, {
			key = "newValue",

			__index = Copy:Struct {
				subKey = "other sub value"
			}
		})

		assert(obj.__index == class)
		assert(obj.__index.subKey == "other sub value")
	end,
}