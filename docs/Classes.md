# Classes

There is some boilerplate included with `Copy()` that allows for the creation of classes with inheritance and proper objects with separate namespaces. You can pair this with `Copy:Extend` to create instances of objects like in `javascript`.

```lua
local Copy = require(path.to.Copy)
local class = require(path.to.Copy.Class)

local vector = class("vectorClass")

local vector2 = class("vector2Class", vector)

vector2.prototype = {
  type = "vector2",

  x = 0,
  y = 0,
}

local vector2Mt = {}
local vector2Methods = {}

setmetatable(vector2.prototype, vector2Mt)

vector2Mt.__index = vector2Methods

function vector2Mt:__add(other)
  if typeof(other) == "table" and other.type == "vector2" then
    return vector2.new(self.x + other.x, self.y + other.y)
  end
end

function vector2Mt:__sub(other)
  if typeof(other) == "table" and other.type == "vector2" then
    return vector2.new(self.x - other.x, self.y - other.y)
  end
end

function vector2Mt:__mul(other)
  local typeof_other = typeof(other)
  if typeof_other == "table" and other.type == "vector2" then
    return vector2.new(self.x * other.x, self.y * other.y)
  elseif typeof_other == "number" then
    return vector2.new(self.x * other, self.y * other)
  end
end

function vector2Mt:__div(other)
  local typeof_other = typeof(other)
  if typeof_other == "table" and other.type == "vector2" then
    return vector2.new(self.x / other.x, self.y / other.y)
  elseif typeof_other == "number" then
    return vector2.new(self.x / other, self.y / other)
  end
end

function vector2Methods:Dot(other)
  return self.x * other.x + self.y * other.y
end

function vector2.new(x, y)
  local self = Copy(vector2.prototype)
  if x ~= nil then
    self.x = x
  end
  if y ~= nil then
    self.y = y
  end
end
```
