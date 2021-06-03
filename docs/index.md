# Copy

## Purpose

Copy is a Roblox module meant to specialize in providing any kind of copying behavior and attempt to do so with a setup-then-call interface. It tries very hard to stay within the scope of copying objects and not manipulating or distorting them, but this would limit the power of one of its most powerful functions.

The `Copy` module's first priority is giving the freedom of how the `table` type is copied. All remotely mutable datatypes use tables, which makes them very powerful, so there are a plethora of tools for forming tables within its namespace, among the most powerful being `Copy:Extend` and `Copy:BehaveAs()`.

## Motivation

There are many methods for creating copies of tables:

* shallow copying
* deep copying (for tables in tables)
* deep copying with a cache (to avoid infinite loops)

Not to mention all the potential data types you might or might not want to support copying for as well, mainly userdatas and other user-defined types like classes.

This module takes a deeper look at how all these algorithms are created and makes an all-encompassing system for the problem.

* [API Reference](./API)
* [Guide on Classes](./Classes)
* [When to use `Copy`](./When)
