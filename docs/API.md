# API

This is a list of all public properties and methods contained in the Copy module.

## Types and Enums

The `Copy` module uses a few concepts to make itself more coherent, so this section is devoted to that specifically.

### <a name="behaviors"></a> Behaviors

The `Copy` module uses `Behaviors` to describe how objects are copied from a base value to a new one. Behaviors are usually combined to create higher-level behaviors using arrays, like so: `{ "transform", "reconcile", "replace" }`. The `Copy` module sequentially makes a pass with each behavior and, upon the first successful conversion, returns that value.

All the presets are listed here:

* `"default" = { "transform", "reconcile", "replace" }` - the default behavior for copying generic values.
* `"set" = {}` - skips copying a value and simply return itself.

Presets can be used by simply supplying the name as a string, `Copy:BehaveAs("set", 'some value')`

And all the lowest level behaviors are listed here:

* `"transform"` - if the value is mapped to an already copied value in `Copy.Transform`, it will return that value.
* `"reconcile"` - if the value can be reconciled, like a table, `Copy` will attempt to overwrite fields from the old value to the new one, given it exists. This type of behavior is used in functions like `Copy:Extend`.
* `"replace"` - if the value can be replaced, like a `Random` datatype, `Copy` will attempt to create a new value from the old value, removing the new one entirely.
* `"skip"` - don't do anything with the value and skip setting it.

If the `Copy` module receives an empty array `{}`, copying that value will return itself.

### Symbols

The `Copy` module has the power to control how values are copied, but it needs `Symbols` to control which behaviors are used.

Traditionally, `Symbols` are created using [`Copy:BehaveAs`](#Copy_BehaveAs):

```lua
local sub = {}

local some = {
  owned = sub,
  shared = Copy:BehaveAs("set", sub)
}

local new = Copy(some)

print(new.owned == sub) --> false
print(new.shared == sub) --> true
```

But you can also create them using functions. Functions take the type `(T) -> (boolean, T)`.

* **Parameter:** the old value's field
* **Returns:** a boolean describing whether to set the value, and the value to set

```lua
--[[** Creates a duck **]]
local function makeDuck(oldValue)
  local duck = {}

  function duck.quack()
    print("QUACK")
  end

  return true, duck
end

Copy.BehaviorMap[makeDuck] = true

local some = {
  duck = makeDuck
}

local new = Copy(someTable)

new.duck.quack() --> QUACK
```

### Transform

The `Copy` module uses a table to keep track of what values have been copied so that it can return it again if it receives a reference to that same value:

```lua
Copy.Transform = {
  ["old value"] = "new value"
}

local some = {
  key = "old value"
}

local new = Copy(some)

print(new.key) --> "new value"
```

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

### `Copy:Extend(object: T, ...bases: Q): T & Q`

Creates a copy of `obj` and copies all fields from all tables given in `bases` from left to right. This is essentially a lower-level method for creating classes by giving explicit control over how the root value is structured and what base values are used.

### <a name="Copy_BehaveAs"></a> `Copy:BehaveAs(behavior: string|array, object: any): Symbol

Creates a Symbol for controlling how a specific sub-value is copied using [behaviors](#behaviors). It can be placed anywhere in the base value to signify making that value (but not its sub-values) behave in that way.

## Properties

There are a great number of properties `Copy` has, useful for creating versatile behavior.

### `Copy.GlobalBehavior`

This table stores the default behaviors `Copy()` should use to copy values when no behavior is provided, separated by context.

* `Copy.GlobalBehavior.Keys` - The default behavior to use for table keys
* `Copy.GlobalBehavior.Values` - The default behavior to use for generic values
* `Copy.GlobalBehavior.Meta` - The default behavior to use for metatables

These contexts accept the same [behaviors](#behaviors) as `Copy:BehaveAs`.
