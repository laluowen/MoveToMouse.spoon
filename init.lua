local obj = {
  name = "MoveToMouse",
  version = "1.0.0", -- x-release-please-version
  author = "laluowen",
  license = "MIT - https://opensource.org/licenses/MIT",
  homepage = "https://github.com/laluowen/MoveToMouse.spoon",
}

obj.bindings = {}

obj.defaults = {
  target = "all",
  maximize = true,
  launch = true,
  hideWhenFocused = true,
}

local function pick(value, default)
  if value == nil then
    return default
  end
  return value
end

local function windowsFor(bundleID, target)
  local app = hs.application.get(bundleID)
  if not app then
    return {}
  end

  local wins = {}
  for _, w in ipairs(hs.window.orderedWindows()) do
    local wApp = w:application()
    if wApp and wApp:bundleID() == bundleID and w:isStandard() then
      table.insert(wins, w)
    end
  end
  if #wins == 0 then
    for _, w in ipairs(app:allWindows()) do
      if w:isStandard() then
        table.insert(wins, w)
      end
    end
  end

  if target == "all" then
    return wins
  end
  if target == "main" then
    local main = app:mainWindow()
    if main then
      return { main }
    end
  end
  if #wins == 0 then
    return {}
  end
  return { wins[1] }
end

local function place(win, screen, maximize)
  if win:screen() ~= screen then
    win:moveToScreen(screen, false, true, 0)
  end
  if maximize then
    win:maximize(0)
  end
end

--- MoveToMouse:configure(opts)
--- Method
--- Sets the defaults used by every binding. Options given to bind() override them.
---
--- Parameters:
---  * opts - table with any of:
---    * target - "front" (most recently used window), "main", or "all" (default: "all")
---    * maximize - boolean, maximize to screen frame (not native fullscreen) (default: true)
---    * launch - boolean, launch the app if it is not running (default: true)
---    * hideWhenFocused - boolean, hide the app if its window is already focused (default: true)
---
--- Returns:
---  * The MoveToMouse object
function obj:configure(opts)
  for k, v in pairs(opts or {}) do
    self.defaults[k] = v
  end
  return self
end

--- MoveToMouse:bind(opts)
--- Method
--- Binds a hotkey that brings a window of an app to the screen under the mouse.
---
--- Parameters:
---  * opts - table with:
---    * bundleID - string, app bundle ID, e.g. "com.mitchellh.ghostty" (required)
---    * hotkey - table {mods, key}, e.g. {{"ctrl"}, "`"} (required)
---    * target, maximize, launch, hideWhenFocused - override the defaults from configure() for this binding
---
--- Returns:
---  * The MoveToMouse object
function obj:bind(opts)
  assert(opts and opts.bundleID, "MoveToMouse: bundleID required")
  assert(opts.hotkey, "MoveToMouse: hotkey required")

  local bundleID = opts.bundleID
  local defaults = self.defaults
  local target = pick(opts.target, defaults.target)
  local maximize = pick(opts.maximize, defaults.maximize)
  local launch = pick(opts.launch, defaults.launch)
  local hideWhenFocused = pick(opts.hideWhenFocused, defaults.hideWhenFocused)
  local mods, key = opts.hotkey[1], opts.hotkey[2]

  local hk = hs.hotkey.bind(mods, key, function()
    local focused = hs.window.focusedWindow()
    if hideWhenFocused and focused and focused:application() and focused:application():bundleID() == bundleID then
      focused:application():hide()
      return
    end

    local wins = windowsFor(bundleID, target)

    if #wins == 0 then
      if not launch then
        hs.alert.show(bundleID .. " has no window")
        return
      end
      hs.application.launchOrFocusByBundleID(bundleID)
      hs.timer.doAfter(1, function()
        local launched = windowsFor(bundleID, target)
        if #launched > 0 then
          place(launched[#launched], hs.mouse.getCurrentScreen(), maximize)
          launched[#launched]:focus()
        end
      end)
      return
    end

    local screen = hs.mouse.getCurrentScreen()
    for _, w in ipairs(wins) do
      place(w, screen, maximize)
    end
    wins[#wins]:focus()
  end)

  table.insert(self.bindings, hk)
  return self
end

--- MoveToMouse:stop()
--- Method
--- Disables all hotkeys bound by this spoon.
function obj:stop()
  for _, hk in ipairs(self.bindings) do
    hk:delete()
  end
  self.bindings = {}
  return self
end

return obj
