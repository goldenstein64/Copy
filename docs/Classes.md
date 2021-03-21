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

List.prototype = {}
setmetatable(List.prototype, { __index = table })

return List
```

Sorted List:

```lua
local Copy = require(path.to.Copy)
local class = require(path.to.Copy.Class)

local list = require(script.Parent.list)

local SortedList = class("SortedList", list)

function SortedList.fromJSON(value)
  local self = list.fromJSON(value)
  self:sort()
  return self
end

SortedList.prototype = {}

function SortedList.prototype:insert(value)
  table.insert(self, value)
  self:sort()
end

return SortedList
```

Usage:

```lua
local SortedList = require(path.to.SortedList)

local someList = SortedList.new()

someList:insert(1)
someList:insert(3)
someList:insert(2)

for i, v in ipairs(someList) do
  print(i, v)
  --> { [1] = 1, [2] = 2, [3] = 3 }
end
```
