# API

This is a list of all public properties and methods contained in the Copy module.

As a precursor, you may see references to `it()` functions in code blocks. These will be cited using this format:

**`T.FileName.DescribeBlock`**

These functions can be found in the `test` directory found [here](https://github.com/goldenstein64/Copy/test/TestLoader).

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

Creates a [Symbol](#symbols). It can be placed anywhere in the base value to signify that it should follow the specified [Behavior](#behaviors).

**`T.BehaveAs.Exclusivity`**

```lua
it("allows different behavior in values", function()
  local someTable = {
    key = "value",
  }

  local baseTable = {
    key = Copy:BehaveAs("set", nil),
  }

  Copy:Extend(someTable, baseTable)
  local newValue = someTable.key

  expect(newValue).to.equal(nil)
end)
```

### `Copy:Flush()`

Clears any data lingering from the last time something was copied. This is only useful when paired with [Copy.Flags.Flush](#Flush_Flag) set to `false`.

## Properties

There are a great number of properties `Copy` has, useful for creating versatile behavior.

### `Copy.GlobalContext`

This table stores the default behaviors `Copy()` should use to copy values when no behavior is provided, categorized by context.

* `Copy.GlobalBehavior.Keys` - The default behavior to use for table keys
* `Copy.GlobalBehavior.Values` - The default behavior to use for generic values
* `Copy.GlobalBehavior.Meta` - The default behavior to use for metatables

These contexts accept the same [behaviors](#behaviors) as [Copy:BehaveAs()](#Copy_BehaveAs).

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

The `Copy` module uses `Behaviors` to describe how objects are copied from a base value to a new one. This is encapsulated in the `Behaviors` module, found under the `Copy` module.

All the lowest level behaviors are listed here:

* `"transform"` - if the value is mapped to an already copied value in `Copy.Transform`, it will return that value.
* `"reconcile"` - if the value can be reconciled, like a table, `Copy` will overwrite fields from the old value to the new one. This type of behavior is used in functions like `Copy:Extend`.
* `"replace"` - if the value can be replaced, like a `Random` object, `Copy` will create a new value from the old one.
* `"skip"` - This will do nothing with the value and skip its setting.

The above can be used by supplying them as strings where expected:

```lua
Copy:BehaveAs('transform', "some value")
Copy.GlobalBehavior.Values = 'transform'
```

Behaviors are usually combined to create higher-level behaviors using arrays, like so:

```lua
Copy:BehaveAs({'transform', 'reconcile', 'replace'}, "some value")
Copy.GlobalBehavior.Values = {'transform', 'reconcile', 'replace'}
```

The `Copy` module sequentially makes a pass with each behavior and, upon the first successful conversion, returns that value.

The most commonly used behaviors can be substituted with a string just like the lower level behaviors. These are known as (behavior) presets.

All the presets are listed here:

* `"default" = { "transform", "reconcile", "replace" }` - the default behavior for copying generic values.
* `"set" = {}` - skips copying a value and simply return itself.

These can be used by simply supplying the name as a string:

```lua
Copy:BehaveAs('default', "some value")
Copy.GlobalBehavior.Keys = 'default'
```

If the `Copy` module receives an empty array `{}` in place of a behavior, copying the value with that behavior will return itself.

Indexing `Copy.GlobalBehavior` will return the array representing the behavior:

```lua
Copy.GlobalBehavior.Keys = 'default'

local keysBehavior = Copy.GlobalBehavior.Keys

expect(keysBehavior).to.be.a("table")
expect(keysBehavior[1]).to.equal('transform')
expect(keysBehavior[2]).to.equal('reconcile')
expect(keyBehavior[3]).to.equal('replace')
```

### <a name="symbols"></a> Symbols

The `Copy` module has the power to control how values behave when copied, but it needs `Symbols` to control the behavior of particular sub-values.

Symbols are very good for representing different copying behavior for identical sub-values in different locations, but they are not very good for being treated as actual values.

Traditionally, `Symbols` are created using [Copy:BehaveAs()](#Copy_BehaveAs):

**`T.BehaveAs.Behaviors`**

```lua
it("can move shared values using 'set'", function()
  local sub = {}

  local some = {
    owned = sub,
    shared = Copy:BehaveAs("set", sub),
  }

  local new = Copy(some)

  expect(new.owned).to.never.equal(sub)
  expect(new.shared).to.equal(sub)
end)
```

Symbols created using `Copy:BehaveAs()` have a small API of their own.

* `Symbol.Owner` - describes which `Copy` module created the symbol
* `Symbol.Value` - the value that the symbol should copy
* `Symbol.Behavior` - how the value will behave when copied. **There are no type assertions made for this field, so be careful if you decide to assign to this!**
* `Symbol()` - Copies the value using the owner, behavior, and value provided by its fields.

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

The `Copy` module solves recursive tables by using a mapping of original values to new ones. Any values that were already copied in a `Copy()` call will be used again in subsequent assignments to that value.

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
