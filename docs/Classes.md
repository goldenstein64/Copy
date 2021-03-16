# Classes

There is some boilerplate included with `Copy()` that allows for the creation of classes with inheritance and proper objects with separate namespaces. You can pair this with `Copy:Extend` to create instances of objects like in `javascript`.

List:

```lua
local HttpService = game:GetService("HttpService")

local Copy = require(path.to.Copy)
local class = require(path.to.Copy.Class)

local List = class("List")

function List.init(self)
  return self
end

function List.fromJSON(value)
  local data = HttpService:DecodeJSON(value)
  local self = Copy:Extend(data, List:gatherSupers())
  return self
end

local prototype = {}

setmetatable(prototype, { __index = table })

List.prototype = prototype

return List
```

Sorted List:

```lua
local Copy = require(path.to.Copy)
local class = require(path.to.Copy.Class)

local list = require(script.Parent.list)

local SortedList = class("SortedList", list)

local prototype = {}

for name, func in pairs(table) do
  prototype[k] = function(self, ...)
    local result = table.pack(func(self, ...))
    self:sort()

    return table.unpack(result, 1, result.n)
  end
end

SortedList.prototype = prototype

return SortedList
```
