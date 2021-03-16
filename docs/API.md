# API

This is a list of all intentionally public properties and methods of the Copy module.

## `Copy(obj: T): T`

Starting with the simplest method, calling the module will make it attempt to copy the argument given, which is guaranteed to return a value of the same type. Only tables and userdatas will be copied.

## `Copy:Extend(obj: T, ...: Q): T & Q`

This method will create a copy of `obj` and copy all fields over from `...`, essentially creating 
a table that "inherits" from `...`.
