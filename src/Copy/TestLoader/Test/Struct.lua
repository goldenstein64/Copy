return {
	Test = function(Copy)
		local class = {
			subKey = "sub value"
		}
		local obj = {
			key = "value",
			__index = class
		}

		Copy:Extend(obj, {
			[Copy.struct] = true,

			key = "newValue",
			__index = {
				[Copy.struct] = true,

				subKey = "other sub value"
			}
		})

		assert(obj.__index == class)
		assert(obj.__index.subKey == "other sub value")
	end
}