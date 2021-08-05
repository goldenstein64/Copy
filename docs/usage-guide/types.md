---
layout: default
---
# How Types are Supported by Copy

The utmost requirement for being able to copy a value is whether the state of that value can be inspected and accessed.

These are all the Lua datatypes and whether they have state:

| Datatypes | Has state? | Can copy? |
|-----------|------------|-----------|
| nil       | no         | yes       |
| boolean   | no         | yes       |
| number    | no         | yes       |
| string    | no         | yes       |
| userdata  | no         | yes       |
| function  | yes        | no        |
| thread    | yes        | no        |
| table     | yes        | yes       |

Those first four values (nil, boolean, number, string) are primitives. That is, their internal state is stored *directly* inside the variable. Therefore, the thing that determines the state of these values is whatever value the variable is. And therefore, it is not the state of the value that changes, but the state of the variable, and variables are trivial to copy (`x = y`). Since the `Copy` module returns these values back to the caller, copying primitives is technically supported, but that's not what `Copy` is used for.

For functions, the only state you can change is their environment through `setfenv` and `getfenv`. However in Luau, these environments are not inspectable for optimization reasons, so functions cannot be inspected, and therefore cannot be copied.

For userdatas in Luau, the only state you can change is their metamethods through `setmetatable` and `getmetatable`. However, their metamethods are implemented as tables, so we can say the state of a userdata depends on the state of their metamethods, which is a table. Also, due to Luau implementation, a userdata's metatable cannot be changed, so userdatas don't have state, just the table containing their metamethods.

For threads, the only state you can change is their status, visible through `coroutine.status`. This status can be changed through:

- calls to `coroutine.resume` and `coroutine.yield`
- whether the underlying function has started or ended or both.

The most useful portion of the thread would be how far it has progressed in the underlying function implementing it, which is not exactly accessible. Since we cannot access the entirety of the thread's state, it would be impossible to create a complete copy of the thread, so it's just not supported.

This leaves tables. All other values that require an accessible state have an underlying table implementing it. A table's state is *completely* accessible (given `__metatable` is not set on its metatable), so the `Copy` module supports copying tables.
