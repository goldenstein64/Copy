# Adding Type Support to Copy

Just like how Copy is meant to be flexible, it's also meant to be extensible. If a new copyable datatype comes out (like `Random`), it might be useful to specify a method for copying it. This page will be covering how to do just that.

There are two ways to copy a value, replacing and reconciling.

* Replacing - creating a new value from an old value
* Reconciling - mapping an old value's state to a pre-existing value

Both of these methods expect the same return values:

* `success: boolean` - whether the value was successfully copied; if `false`, no further arguments are needed
* `doSet: boolean` - whether the value should be assigned on its super-value; if `false`, no further arguments are needed
* `newValue: T` - the new value to set

## Replacing

`(self: Copy, oldValue: T) -> (success: boolean, doSet: boolean, newValue: T)`

Parameters:

* `self: Copy` - the module doing the copying
* `oldValue: T` - the old value being used as a blueprint

There are two required tasks the function has to complete when replacing a value.

1. Creating the new value
2. Mapping the old value to the new one in `self.Transform`

## Reconciling

`(self: Copy, oldValue: T, newValue: T) -> (success: boolean, doSet: boolean, newValue: T)`

Parameters:

* `self: Copy` - the module doing the copying
* `oldValue: T` - the value to copy from
* `newValue: T` - the value to copy to
