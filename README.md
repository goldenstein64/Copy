# Copy

A module for copying any value with state.

Free Model: <https://www.roblox.com/library/5089132938>
Docs: <https://goldenstein64.github.io/Copy>

## Getting started

This is built using [Rojo](https://github.com/rojo-rbx/rojo) 6.2.0 and VS Code. Documentation for Rojo can be found [here](https://rojo.space/docs).

1. Build the testing place by opening the command pallette (`Ctrl+Shift+P`) and selecting "Rojo: Build with project file..." Use `test.project.json`.

2. Open the new place file in Roblox Studio and connect it to Rojo using "Start Rojo" at the bottom and activating the plugin.

Server-running the place will run all the tests in the workspace's `CopyTest` folder, and its results will appear in the output.

I decided against organizing TestEZ files

## Building

You can build the module by running this in PowerShell:

```powershell
rojo build default.project.json -o Copy.rbxmx
```

It will appear in the project directory.
