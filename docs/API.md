# API

This is a list of all public properties and methods contained in the Copy module.

## Functions

There are only two functions that do the job of copying, the rest are just helper functions.

### `Copy(object: T): T`

Creates a copy of `object`. This is guaranteed to return a result of the same type and sub-type.

All the datatypes copied by this function are:

* `table`
* `userdata`
* `Random`
* `Instance`

Any other datatype passed in will simply return itself.

You can also use `Copy()` to copy itself, like so:

```lua
local newCopy = Copy(Copy)
```

This is useful for creating a `Copy` module with a different configuration, since it holds flags and contexts.

### `Copy:Extend(object: T, ...bases: Q): T & Q`

Copies all fields in `bases` to `object` from left to right. `Copy(some)` is the same as `Copy:Extend({}, some)`.

### <a name="Copy_BehaveAs"></a> `Copy:BehaveAs(behavior: string|array, object: any): Symbol`

Creates a [Symbol](#symbols). It can be placed anywhere in the base value to signify that this field should follow the specified [Behavior](#behaviors).


### `Copy:Flush()`

Clears any data lingering from the last time something was copied. This is only useful when paired with [`Copy.Flags.Flush`](#Flush_Flag) set to `false`.

## Properties

There are a great number of properties `Copy` has, useful for creating versatile behavior.

### `Copy.GlobalContext`

This table stores the default behaviors `Copy()` should use to copy values when no behavior is provided, separated by context.

* `Copy.GlobalBehavior.Keys` - The default behavior to use for table keys
* `Copy.GlobalBehavior.Values` - The default behavior to use for generic values
* `Copy.GlobalBehavior.Meta` - The default behavior to use for metatables

These contexts accept the same [behaviors](#behaviors) as [`Copy:BehaveAs`](#Copy_BehaveAs).

### `Copy.Flags`

A set of miscellaneous flags. Setting an unknown flag throws an error.

#### <a name="Flush_Flag"></a> `Copy.Flags.Flush = true`

Stops `Copy()` and `Copy:Extend()` from removing internal data (namely `Copy.Transform` and `Copy.InstanceTransform`). This is useful for inspecting the module in case something was copied weirdly. If you plan to use the module again after inspection, make sure to call `Copy:Flush()` beforehand.

#### `Copy.Flags.SetInstanceParent = false`

Decides whether instances cloned by the module are parented to the original instance's parent, otherwise `nil`.

### `Copy.SymbolMap`

A weak table that lists every [Symbol](#symbols) in existence as keys. Symbols delete themselves once they are not used anymore, and they can be used multiple times. Any values intended to be used as symbols should be registered in the symbol map, like so:

```lua
Copy.SymbolMap[customSymbol] = true
```

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

### <a name="symbols"></a> Symbols

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

**`T.BehaveAs.CustomSymbols`**

```lua
it("can make ducks", function()
  local function makeDuck(oldValue)
    local duck = {}

    function duck.quack()
      return "QUACK"
    end

    return true, duck
  end

  Copy.SymbolMap[makeDuck] = true

  local some = {
    duck = makeDuck
  }

  local new = Copy(some)

  expect(new.duck.quack()).to.equal("QUACK")
end)
```

### <a name="transform"></a> Transform

The `Copy` module uses a table to keep track of what values have been copied so that it can return it again if it receives a reference to that same value:

**`T.Transform.BaseTraits`**

```lua
it("transforms values", function()
  local array = { "value", "normal value" }

  Copy.Transform["value"] = "some other value"
  local newArray = Copy(array)

  expect(newArray[1]).to.equal("some other value")
  expect(newArray[2]).to.equal("normal value")
end)
```

`Copy.Transform` accepts any value, including [Symbols](#symbols).
