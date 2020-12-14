## Copy

Copy is a Roblox module meant to specialize in providing any kind of copying behavior and attempt to do so with a simplistic interface. However, it also tries very hard to stay within the scope of *copying* objects and not manipulating or distorting them.

The `Copy` module's first priority is to allow for a ton of customization around how the `table` type is copied. Tables are extremely powerful, so there are a plethora of tools for forming tables within its namespace, among the most powerful being `Copy:Extend` and `Copy:BehaveAs`

### Usage

To use the `Copy` module, you can simply call it, `Copy(x)`, and it will return a copy of `x`, if possible.
