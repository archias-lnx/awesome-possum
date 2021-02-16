local awful = require('awful')
local dpi = require('beautiful').xresources.apply_dpi

local function createTooltip(widget, tip)
  return awful.tooltip {
    objects = {widget},
    mode = 'outside',
    delay_show = 1,
    preferred_positions = {'right', 'left', 'top', 'bottom'},
    preferred_alignments = {'middle'},
    margin_leftright = dpi(8),
    margin_topbottom = dpi(8),
    timer_function = function() return tip end
  }
end

return createTooltip