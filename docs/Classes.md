# Classes

There is some boilerplate included with `Copy()` that allows for the creation of classes with inheritance and proper objects with separate namespaces. You can pair this with `Copy:Extend` to create instances of objects like in `javascript`.

List:

```lua
local class = require(path.to.Copy.Class)

local List = class("List")

function List.init(self, ...)
  local values = table.pack(...)
  table.move(values, 1, values.n, self.length, self.data)
end

local prototype = {
  data = {},
  length = 0
}

function prototype:append(value)
  table.insert(self.data, value)
  self.length += 1
end

function prototype:insert(index, value)
  table.insert(self.data, index, value)
  self.length += 1
end

function prototype:pop(index)
  table.remove(self.data, index)
  self.length -= 1
end

List.prototype = prototype

return List
```

Sorted List:

```lua
local Copy = require(path.to.Copy)
local class = require(path.to.Copy.Class)

local list = require(script.Parent.list)

local SortedList = class("SortedList", list)

local prototype = {
  data = {},
  length = 0
}

function prototype:append(value)
  SortedList.extends[1].prototype.append(self, value)
end

SortedList.prototype = prototype

return SortedList
```
