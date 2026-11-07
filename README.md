# MoveToMouse.spoon

A simple [Hammerspoon](https://www.hammerspoon.org/) [Spoon](https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md) to bring an app's window to the screen under your mouse with a hotkey.

Features:
  - Bind a hotkey per app, by bundle ID
  - Moves the chosen window, or all of the app's windows, to the screen under the mouse
  - Optional maximize to the screen frame (not native fullscreen)
  - Optional launch if the app is not running
  - Pressing the hotkey while the app is focused hides it (optional)

## MoveToMouse:configure

Sets the defaults used by every binding. Options given to `bind` override them.

Parameters:
 * opts - A table of options:
   * `target` (string) - Which windows to move: `"front"` (most recently used), `"main"`, or `"all"` (default: `"all"`)
   * `maximize` (boolean) - Maximize to the screen frame (default: `true`)
   * `launch` (boolean) - Launch the app if it isn't running (default: `true`)
   * `hideWhenFocused` (boolean) - Hide the app if its window is already focused (default: `true`)

Example:

```lua
hs.loadSpoon("MoveToMouse")
spoon.MoveToMouse:configure{
  maximize = false,
}
```

## MoveToMouse:bind

Binds a hotkey that brings a window of an app to the screen under the mouse.

Parameters:
 * opts - A table of options:
   * `bundleID` (string) - App bundle ID, such as `"com.mitchellh.ghostty"` (required)
   * `hotkey` (table) - Hotkey as `{mods, key}`, such as `{{"ctrl"}, "`"}` (required)
   * `target`, `maximize`, `launch`, `hideWhenFocused` - Override the `configure` defaults for this binding

Returns:
 * The MoveToMouse object

Example:

```lua
spoon.MoveToMouse:bind{
  bundleID = "com.mitchellh.ghostty",
  hotkey = {{"ctrl"}, "`"},
  maximize = true,
}
```

## MoveToMouse:stop

Disables all hotkeys bound by this Spoon.

## License

MIT. See [LICENSE.md](LICENSE.md).
