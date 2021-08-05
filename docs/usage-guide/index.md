---
layout: default
---
# How to Use Copy

- [Classes](classes)
- [Datatypes](types)

## What can Copy Do?

On the surface, the `Copy` module is very simple: any value you give it, it will do its best to clone that value and return it.

**`T.CallCopy`**

```lua
it("can run the basic sample", function()
  -- this is a table
  local array = { 1, 2, 3 }

  -- this is a copy of that table
  local newArray = Copy(array)

  -- these tables are not the same!
  expect(newArray).to.never.equal(array)
end)
```

In most cases, this is all you will ever need.

However, this module includes some extra infrastructure for more niche use cases, like

* classes or prototypes
  * classes are used to create copies of an object

* copying grained by sub-value
  * copying or sharing only part of a large structure may be useful.

* copying to a pre-existing value
  * this could be necessary for tables that require modifications from many sources, such as reseting a table's data, multiple inheritance, .
  * this is one of the ways of forming inheritance - giving an empty table all the values of `A` and then all the values of `B` is the same as creating an instance of `B` that inherits from `A`

```lua
-- classes and prototypes

local Copy = require(path.to.Copy)

local Vector4 = {}

local prototype = {
  W = 0,
  X = 0,
  Y = 0,
  Z = 0,
}

local prototypeMt = {}

setmetatable(prototype, prototypeMt)

function prototype:GetMagnitude()
  return math.sqrt(self.W^2 + self.X^2 + self.Y^2 + self.Z^2)
end

function prototype:GetUnit()
  local magnitude = self:GetMagnitude()
  return Vector4.new(
    self.W / magnitude,
    self.X / magnitude,
    self.Y / magnitude,
    self.Z / magnitude
  )
end

function prototypeMt:__add(other)
  return Vector4.new(
    self.W + other.W,
    self.X + other.X,
    self.Y + other.Y,
    self.Z + other.Z
  )
end

function Vector4.new(w, x, y, z)
  return Copy:Extend(prototype, {
    W = w,
    X = x,
    Y = y,
    Z = z,
  })
end

return Vector4
```

```lua
-- copying grained by sub-value

local hugeTable = {
  subTable = {},
  skipped = {},
  shared = {},
  -- ...
}

-- makes sure not to copy any values in the table, just the root table
Copy.GlobalContext.Values = "set"
local protoTable = Copy(hugeTable)

-- returns back to default
Copy.GlobalContext.Values = "default"
protoTable.shared = Copy:BehaveAs(protoTable.shared, "set")
protoTable.skipped = nil

local function createHugeTable()
  return Copy(protoTable)
end
```

```lua
-- copying to a pre-existing value

local human = {}

local canFly = {}

function canFly:fly()
  -- ...
end

local canRun = {}

function canRun:run()
  -- ...
end

-- other component tables

Copy:Extend(human, canFly, canRun, ...)
-- now human can :fly(), :run(), etc.
```

## What heuristics should I use to know when to use Copy?

Generally, if you need to copy of a table, you use `Copy()`. Everything else is there purely for completing the definition of copying something in virtually any respect.

(WIP)
