# Creating classes With Copy

This page lists some examples of some alternative organizations you can create using `Copy`.

Since functions are copied by reference, this method uses about the same memory as metatable classes without the re-index overhead. This also creates a proper separation between class functions and object methods, meaning `Class.new().new()...` is no longer possible.

List:

```lua
-- dependencies
local HttpService = game:GetService("HttpService")

local Copy = require(path.to.Copy)

-- content
local prototype = {}

local List = {
  prototype = prototype
}

-- object methods
Copy:Extend(prototype, table)

-- class methods
function List.new()
  return Copy(prototype)
end

function List.fromJSON(value)
  local data = HttpService:DecodeJSON(value)
  local self = Copy:Extend(data, prototype)
  return self
end

return List
```

Sorted List:

```lua
-- dependencies
local Copy = require(path.to.Copy)

-- base classes
local List = require(script.Parent.List)

-- content - inherits from List
local SortedList = Copy(List)

local prototype = SortedList.prototype

-- object methods
function prototype:insert(value)
  local index = 1
  while value > self[index] do
    index += 1
  end
  table.insert(self, index, value)
end

-- class methods
function SortedList.fromJSON(value)
  local self = List.fromJSON(value)
  Copy:Extend(self, prototype)
  self:sort()
  return self
end

return SortedList
```

Usage:

```lua
local SortedList = require(path.to.SortedList)

local someList = SortedList.new()

someList:insert(3)
someList:insert(2)
someList:insert(1)

print(someList) --> { 1, 2, 3 }
```
