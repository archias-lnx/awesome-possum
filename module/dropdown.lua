-------------------------------------------------------------------
-- Drop-down applications manager for the awesome window manager
-------------------------------------------------------------------
-- Coded  by: * Lucas de Vries <lucas@glacicle.com>
-- Hacked by: * Adrian C. (anrxc) <anrxc@sysphere.org>
-- Licensed under the WTFPL version 2
--   * http://sam.zoy.org/wtfpl/COPYING
-------------------------------------------------------------------
-- Parameters:
--   prog   - Program to run; "urxvt", "gmrun", "thunderbird"
--   vert   - Vertical; "bottom", "center" or "top" (default)
--   horiz  - Horizontal; "left", "right" or "center" (default)
--   width  - Width in absolute pixels, or width percentage
--            when <= 1 (1 (100% of the screen) by default)
--   height - Height in absolute pixels, or height percentage
--            when <= 1 (0.25 (25% of the screen) by default)
--   sticky - Visible on all tags, false by default
--   screen - Screen (optional), mouse.screen by default
-------------------------------------------------------------------
-- Grab environment
local pairs = pairs
local awful = require('awful')
local setmetatable = setmetatable
local capi = {mouse = _G.mouse, client = _G.client, screen = _G.screen}

-- Scratchdrop: drop-down applications manager for the awesome window manager
local drop = {} -- module scratch.drop

local dropdown = {}

-- Create a new window for the drop-down application when it doesn't
-- exist, or toggle between hidden and visible states when it does
local function toggle(prog, properties, screen)

  local vert = properties and properties.vert or 'top'
  local horiz = properties and properties.horiz or 'center'
  local width = properties.width or 0.5
  local minwidth = properties.minwidth or 0
  local height = properties and properties.height or 0.25
  local minheight = properties and properties.minheight or 0
  local sticky = properties and properties.sticky or false
  screen = screen or capi.mouse.screen

  -- Determine signal usage in this version of awesome
  local attach_signal = capi.client.connect_signal or capi.client.add_signal
  local detach_signal = capi.client.disconnect_signal or
                          capi.client.remove_signal

  if not dropdown[prog] then
    dropdown[prog] = {}

    -- Add unmanage signal for scratchdrop programs
    attach_signal(
      'unmanage', function(c)
        for scr, cl in pairs(dropdown[prog]) do
          if cl == c then
            dropdown[prog][scr] = nil
          end
        end
      end)
  end

  if not dropdown[prog][screen] then
    local spawnw
    spawnw = function(c)
      dropdown[prog][screen] = c

      -- Scratchdrop clients are floaters
      -- awful.client.floating.set(c, true)
      c.floating = true

      -- Client geometry and placement
      local screengeom = capi.screen[screen].workarea
      local x, y

      if width <= 1 then
        width = screengeom.width * width - 3
      end
      if height <= 1 then
        height = screengeom.height * height
      end

      if width < minwidth then
        width = minwidth
      end
      if height < minheight then
        width = minwidth
      end

      if horiz == 'left' then
        x = screengeom.x
      elseif horiz == 'right' then
        x = screengeom.width - width
      else
        x = screengeom.x + (screengeom.width - width) / 2 - 1
      end

      if vert == 'bottom' then
        y = screengeom.height + screengeom.y - height
      elseif vert == 'center' then
        y = screengeom.y + (screengeom.height - height) / 2 - 1
      else
        y = screengeom.y
      end

      -- Client properties
      c:geometry({x = x, y = y, width = width, height = height})
      c.ontop = true
      c.above = true
      c.skip_taskbar = true
      if sticky then
        c.sticky = true
      end
      if c.titlebar then
        awful.titlebar.remove(c)
      end

      c:raise()
      capi.client.focus = c
      detach_signal('manage', spawnw)
    end

    -- Add manage signal and spawn the program
    attach_signal('manage', spawnw)
    awful.spawn.with_shell(prog, false)
  else
    -- Get a running client
    local c = dropdown[prog][screen]

    -- Switch the client to the current workspace
    if c:isvisible() == false then
      c.hidden = true
      awful.client.movetotag(awful.tag.selected(screen), c)
    end

    -- Focus and raise if hidden
    if c.hidden then
      -- Make sure it is centered
      -- if vert  == "center" then awful.placement.center_vertical(c)   end
      -- if horiz == "center" then awful.placement.center_horizontal(c) end
      c.hidden = false
      c:raise()
      capi.client.focus = c
    else -- Hide and detach tags if not
      c.hidden = true
      local ctags = c:tags()
      for i, t in pairs(ctags) do
        ctags[i] = nil
      end
      c:tags(ctags)
    end
  end
end

return setmetatable(drop, {__call = function(_, ...) return toggle(...) end})