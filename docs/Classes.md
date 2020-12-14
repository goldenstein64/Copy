# Classes

There is some boilerplate included with `Copy()` that allows for the creation of classes with inheritance and proper objects with separate namespaces. You can pair this with `Copy:Extend` to create instances of objects like in `javascript`.

```lua
local Copy = require(path.to.Copy)
local class = require(path.to.Copy.Class)

local vector = class("vectorClass")

local vectorMt = {}
vector.prototype = setmetatable

local vector2 = class("vector2Class", vector)

vector2.factors = { "x", "y" }

vector2.prototype = {
  type = "vector2",

  x = 0,
  y = 0,
}

local vector2Meta = {}

local vector2Methods = {}
function vector2Methods:Dot(other)
  return self.x * rawget(other, "x") + rawget(self, "y") * rawget(other, "y")
end

function vector2Meta:__index(k)
  local method = vector2Methods[k]
  if method then
    return method
  elseif k == "Magnitude" then
    return (rawget(self, "x")^2 + rawget(self, "y")^2)^0.5
  elseif k == "Unit" then
    return self / self.Magnitude
  end
end

function vector2Meta.__index:Dot(other)
  return rawget(self, "x") * rawget(other, "x") + rawget(self, "y") * rawget(other, "y")
end

function vector2Meta:__add(other)
  if typeof(other) == "table" and other.type == "vector2" then
    return vector2.new(
      rawget(self, "x") + rawget(other, "x"),
      rawget(self, "y") + rawget(other, "y")
    )
  else
    error(string.format("Attempt to add vector2 and %s", typeof(other)))
  end
end

function vector2Meta:__sub(other)
  if typeof(other) == "table" and other.type == "vector2" then
    return vector2.new(
      rawget(self, "x") - rawget(other, "x"),
      rawget(self, "y") - rawget(other, "y")
    )
  else
    error(string.format("Attempt to subtract vector2 and %s", typeof(other)))
  end
end

function vector2Meta:__mul(other)
  local typeof_other = typeof(other)
  if typeof_other == "table" and other.type == "vector2" then
    return vector2.new(
      rawget(self, "x") * rawget(other, "x"),
      rawget(self, "y") * rawget(other, "y")
    )
  elseif typeof_other == "number" then
    return vector2.new(
      rawget(self, "x") * other,
      rawget(self, "y") * other
    )
  else
    error(string.format("Attempt to multiply vector2 and %s", typeof_other))
  end
end

function vector2Meta:__div(other)
  local typeof_other = typeof(other)
  if typeof_other == "table" and other.type == "vector2" then
    return vector2.new(
      rawget(self, "x") / rawget(other, "x"),
      rawget(self, "y") / rawget(other, "y")
    )
  elseif typeof_other == "number" then
    return vector2.new(
      rawget(self, "x") / other,
      rawget(self, "y") / other
    )
  else
    error(string.format("Attempt to divide vector2 and %s", typeof_other))
  end
end

setmetatable(vector2.prototype, vector2Meta)

function vector2:init(x, y)
  if x ~= nil then
    self.x = x
  end
  if y ~= nil then
    self.y = y
  end

  return self
end

local newVector2 = vector2.new(5, 8)
```
