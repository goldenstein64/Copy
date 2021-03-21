return function()
	local Workspace = game:GetService("Workspace")

	local CopyFactory = require(script.Parent.Parent.CopyFactory)

	local CopyModule = Workspace:WaitForChild("Copy")
	local class = require(CopyModule.Class)

	local Copy
	beforeEach(function()
		Copy = CopyFactory()
	end)

	describe("Inheritance", function()
		it("allows single inheritance", function()
			local base = class("Base")
			base.prototype = {
				Key = "base value",
				BaseKey = "inherited value",
			}

			local modifier = class("Modifier", base)
			modifier.prototype = {
				Key = "modified value",
				ModKey = "extended value",
			}

			local modifier2 = class("Modifier2", modifier)
			modifier2.prototype = {
				Key = "modified 2 value",
				Mod2Key = "extended 2 value",
			}

			local newClass = class("Object", modifier2)
			newClass.prototype = {
				objectKey = "object value",
			}

			local object = newClass.new()

			expect(object.objectKey).to.equal("object value")
			expect(object.Key).to.equal("modified 2 value")
			expect(object.BaseKey).to.equal("inherited value")
			expect(object.ModKey).to.equal("extended value")
			expect(object.Mod2Key).to.equal("extended 2 value")
		end)

		it("allows multiple inheritance", function()
			local base1 = class("Base1")
			base1.prototype = {
				Base1Key = "inherited 1 value",
			}

			local base2 = class("Base2")
			base2.prototype = {
				Base2Key = "inherited 2 value",
			}

			local newClass = class("Object", base1, base2)
			newClass.prototype = {
				objectKey = "object value",
			}

			local object = newClass.new()

			expect(object.objectKey).to.equal("object value")
			expect(object.Base1Key).to.equal("inherited 1 value")
			expect(object.Base2Key).to.equal("inherited 2 value")
		end)
	end)
end
