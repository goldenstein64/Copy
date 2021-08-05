# Contributing

```{toctree}
---
titlesonly: true
---
new-types.md
```

This project is developed using [VS Code](https://code.visualstudio.com/)/[Rojo](https://rojo.space), and the documentation is developed using [VS Code](https://code.visualstudio.com/).

VS Code's Extensions side bar will recommend the extensions used in this project.

## Contributing to Source

This project uses [run-in-roblox](https://github.com/rojo-rbx/run-in-roblox), [Rojo](https://rojo.space), and [TestEZ](https://github.com/Roblox/testez) for testing. TestEZ is included as a submodule.

* [Adding New Type Support](contributing/new-types)

### Dev Environment

Included with the project is a collection of tasks used for building and testing `Copy`.

* `Build` - Rebuilds `CopyTest.rbxlx` from scratch.
* `Test` - Runs the `test/TestLoader` script in `CopyTest` using `run-in-roblox`. It also automatically rebuilds the place before running it to account for changes.

A `rojo` and `run-in-roblox` executable needs to be added to your PATH to use the tasks in this project.

A place is already included in the repository, `CopyTest.rbxlx`, but you can use the `Build` task to rebuild it, and the `Test` task will do it automatically.

Even though you can use the `Test` task to test the module from inside VSCode, you can still use `rojo serve` and sync with Roblox Studio for faster testing. Simply running the game will apply test results.

Both new tests and new features can be accepted as long as they don't overlap with existing features. Refactors are generally not accepted unless required for a feature with a lot of impact.

## Contributing to Documentation

The documentation *as a whole* has no obvious structure other than being linked from `index.md`. New documents can be accepted as pull requests as long as they are reviewed by the owner, @goldenstein64.
