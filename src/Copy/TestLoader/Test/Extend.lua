local base = {
	Key = "base value",
	BaseKey = "inherited value"
}

local modifier = {
	Key = "modified value",
	ModKey = "extended value"
}

local modifier2 = {
	Key = "modified 2 value",
	Mod2Key = "extended 2 value",
}

return {

	ExtendOnce = function(Copy)
		local object = Copy:Extend(base, modifier)

		assert(object.Key == "modified value")
		assert(object.BaseKey == "inherited value")
		assert(object.ModKey == "extended value")
	end,

	ExtendTwice = function(Copy)
		local object = Copy:Extend(base, modifier, modifier2)

		assert(object.Key == "modified 2 value")
		assert(object.BaseKey == "inherited value")
		assert(object.ModKey == "extended value")
		assert(object.Mod2Key == "extended 2 value")
	end,

}