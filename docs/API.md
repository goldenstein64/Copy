# API

This is a list of all public properties and methods contained in the Copy module.

## Functions

There are only two functions that do the job of copying:

### `Copy(object: T): T`

`Copy()` makes an attempt to create a copy of the argument given and return it. This is guaranteed to return a result of the same type and sub-type.

All the values that are copied by this function are:

* `table`
* `userdata`
* `Random`

Any other datatype passed in will simply return itself.

You can also use `Copy()` to copy itself, like so:

```lua
local newCopy = Copy(Copy)
```

### `Copy:Extend(object: T, ...: Q): T & Q`

Creates a copy of `obj` and copies all fields from all tables given in `...` from left to right. This is essentially a lower-level method for creating classes by giving explicit control over how the root object is structured and what template objects are used in the process.

### `Copy:BehaveAs(behavior: string|array, object: any): Symbol

Creates a Symbol for controlling how a specific sub-value is copied. It can be placed anywhere in a template object to signify making that value (but not its sub-values) behave in that way.

There are some presets already made:

* `"default"` - the default behavior for copying values.
* `"set"` - skip copying a value and simply return itself.

Some lower level Behaviors can be used as well:

* `"transform"` - if the value is mapped to an already copied value in `Copy.Transform`, it will return that value.
* `"reconcile"` - if the value can be reconciled, like a table, `Copy` will attempt to overwrite fields from the old value to the new one, given it exists. This type of behavior is used in functions like `Copy:Extend`.
* `"replace"` - if the value can be replaced, like a `Random` datatype, `Copy` will attempt to create a new value from the old value, removing the new one entirely.
* `"skip"` - don't do anything with the value and skip setting it.

These Behaviors can be organized as an array, with each behavior being applied from left to right, or just the string itself, equivalent to `{ behavior }`:

```lua
local subTable = {
  key = "some value"
}

local someTable = {
  [1] = subTable,
  [2] = subTable
}

local templateTable = Copy(someTable)

print(templateTable[1].key) --> "some value" - this looks like subTable
print(templateTable[1] == someTable[1]) --> false - a copy was created
print(templateTable[1] == templateTable[2]) --> true - references are retained

templateTable[1] = Copy:BehaveAs("replace", subTable) -- replace this table with a new one
templateTable[2] = Copy:BehaveAs("set", subTable) -- take the table from the old one

local newTable = Copy(templateTable)

print(newTable[1].key) --> "some value" --> this looks like subTable
print(newTable[1] == someTable[1]) --> false --> a copy was created
print(newTable[2] == subTable) --> true --> no copy was created
```

Finally, you can create custom functions, which `Copy` can treat as symbols:

```lua
local function makeDuck()
  local duck = {}

  function duck.quack()
    print("QUACK")
  end

  return true, duck
end

Copy.BehaviorMap[makeDuck] = true

local someTable = {
  duck = makeDuck
}

local newTable = Copy(someTable)

newTable.duck.quack() --> QUACK
```

## Properties

There are a great number of properties `Copy` has, useful for creating versatile behavior.
