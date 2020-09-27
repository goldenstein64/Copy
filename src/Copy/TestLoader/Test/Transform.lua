return {

	Values = function(Copy)
		local array = { "value" }

		Copy.GlobalBehavior.Values = "copy"
		Copy.Transform["value"] = "some other value"
		local newArray = Copy(array)

		assert(newArray[1] == "some other value")
	end,

	Keys = function(Copy)
		local dict = { key = "value" }

		Copy.GlobalBehavior.Keys = "copy"
		Copy.Transform["key"] = "someOtherKey"
		local newDict = Copy(dict)

		assert(newDict.key == nil)
		assert(newDict.someOtherKey == "value")
	end,

	Metatables = function(Copy)
		local addMeta = {
			__add = function(self, b)
				return self.Value + b.Value
			end
		}
		local otherMeta = {
			__add = function(self, b)
				return 2 * (self.Value + b.Value)
			end
		}
		local someTable = setmetatable({ Value = 3 }, addMeta)
		local otherTable = { Value = 8 }

		Copy.GlobalBehavior.Meta = "copy"
		Copy.Transform[addMeta] = otherMeta
		local newTable = Copy(someTable)

		assert(someTable + otherTable == 11)
		-- 2 * (   3     +     8    ) == 22
		assert(newTable + otherTable == 22)
	end,

	-- transforming values in subsequent tables
	SubValues = function(Copy)
		local obj = {
			sub = {
				key = "value"
			},
			key = "value"
		}

		Copy.Transform["value"] = "some other value"
		local newSubObj = Copy(obj.sub) -- this flushes the last line
		Copy.Transform[obj.sub] = newSubObj
		local newObj = Copy(obj)

		assert(newObj.key == "value")
		assert(newObj.sub.key == "some other value")
	end,

	DeleteValues = function(Copy)
		local dict = {
			key = "value"
		}

		Copy.Transform["value"] = Copy:BehaveAs("set", nil)
		local newDict = Copy(dict)

		assert(newDict.key == nil)
	end,

	SkipValues = function(Copy)
		local dict = {
			key = "value"
		}

		Copy.Transform["value"] = Copy:BehaveAs("pass")
		local newDict = Copy(dict)

		assert(newDict.key == nil)
	end,

	-- preserving a value using Copy.Transform
	AltPreserve = function(Copy)
		local dict = {
			shared = {}
		}
		
		Copy.Transform[dict.shared] = dict.shared
		local newDict = Copy(dict)

		assert(newDict.shared == dict.shared)
	end,

	Safeguard = function(Copy)
		Copy.Transform["value"] = "other value"

		local newTransform = Copy(Copy.Transform)

		assert(next(newTransform) == nil)
	end,

	-- for Copy:Extend
	SafeguardExtend = function(Copy)
		Copy.Transform["value"] = "other value"
		local newTransform = {
			["different value"] = "separate value"
		}

		Copy:Extend(newTransform, Copy.Transform)

		assert(newTransform["value"] == nil)
	end,

	-- proper Transform duplication
	SafeguardBypass = function(Copy)
		Copy.Transform["value"] = "other value"

		local oldTransform
		Copy.Transform, oldTransform = {}, Copy.Transform
		local newTransform = Copy(oldTransform)

		assert(newTransform["value"] == "other value")
	end,

}