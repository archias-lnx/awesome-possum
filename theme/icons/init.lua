-- Icons directory
local _, package_path = ...
if not package_path then
  package_path = string.sub(debug.getinfo(1,'S').source, 2)
end
local dir = package_path:match('(.*/)')

return {
  -- Action Bar
  face         = dir .. 'face.svg',

  mail         = dir .. 'tag-list/' .. 'thunderbird.svg',
  web_browser  = dir .. 'tag-list/' .. 'web-browser.svg',
  code         = dir .. 'tag-list/' .. 'code.svg',
  file_manager = dir .. 'tag-list/' .. 'file-manager.svg',
  terminal     = dir .. 'tag-list/' .. 'terminal.svg',
  vim          = dir .. 'tag-list/' .. 'vim.svg',
  text_editor  = dir .. 'tag-list/' .. 'text-editor.svg',
  development  = dir .. 'tag-list/' .. 'development.svg',
  spotify      = dir .. 'tag-list/' .. 'spotify.svg',
  social       = dir .. 'tag-list/' .. 'social.svg',
  multimedia   = dir .. 'tag-list/' .. 'multimedia.svg',
  games        = dir .. 'tag-list/' .. 'games.svg',
  sandbox      = dir .. 'tag-list/' .. 'sandbox.svg',
  graphics     = dir .. 'tag-list/' .. 'graphics.svg',
  menu         = dir .. 'tag-list/' .. 'menu.svg',
  close_small  = dir .. 'tag-list/' .. 'close-small.svg',

  -- tag1 = dir .. 'tag-list/' .. 'thunderbird.svg',
  -- tag2 = dir .. 'tag-list/' .. 'web-browser.svg',
  -- tag3 = dir .. 'tag-list/' .. 'code.svg',
  -- tag4 = dir .. 'tag-list/' .. 'file-manager.svg',
  -- tag5 = dir .. 'tag-list/' .. 'terminal.svg',
  -- tag6 = dir .. 'tag-list/' .. 'vim.svg',
  -- tag7 = dir .. 'tag-list/' .. 'text-editor.svg',
  -- tag8 = dir .. 'tag-list/' .. 'development.svg',
  -- tag9 = dir .. 'tag-list/' .. 'spotify.svg',

  tag1  = dir .. 'tag-list-numbers/1.svg',
  tag2  = dir .. 'tag-list-numbers/2.svg',
  tag3  = dir .. 'tag-list-numbers/3.svg',
  tag4  = dir .. 'tag-list-numbers/4.svg',
  tag5  = dir .. 'tag-list-numbers/5.svg',
  tag6  = dir .. 'tag-list-numbers/6.svg',
  tag7  = dir .. 'tag-list-numbers/7.svg',
  tag8  = dir .. 'tag-list-numbers/8.svg',
  tag9  = dir .. 'tag-list-numbers/9.svg',
  tag_number10 = dir ..'tag-list-numbers/10.svg',

  tag_focused  = dir .. 'tag-list-symbols/' .. 'dash.svg',
  tag_empty    = dir .. 'tag-list-symbols/' .. 'empty.svg',
  tag_occupied = dir .. 'tag-list-symbols/' .. 'dot.svg',
  tag_urgent   = dir .. 'tag-list-symbols/' .. 'dots.svg',

	-- Others/System UI
	close           = dir .. 'close.svg',
	logout          = dir .. 'logout.svg',
	sleep           = dir .. 'power-sleep.svg',
	power           = dir .. 'power.svg',
	lock            = dir .. 'lock.svg',
	restart         = dir .. 'restart.svg',
	search          = dir .. 'magnify.svg',
	effects         = dir .. 'effects.svg',
	plus            = dir .. 'plus.svg',
	batt_chargin    = dir .. 'battery-charge.svg',
	batt_discharging= dir .. 'battery-discharge.svg',
	toggled_on      = dir .. 'toggled-on.svg',
  toggled_off     = dir .. 'toggled-off.svg',
  right_arrow     = dir .. 'right-arrow.svg',
  left_arrow      = dir .. 'left-arrow.svg',
  -- widgets
  widget = {
    toggled_on   = dir .. 'toggled-on.svg',
    toggled_off  = dir .. 'toggled-off.svg',
    plus         = dir .. 'widgets/' .. 'plus.svg',
    notification_button = dir .. 'widgets/' .. 'notification.svg',
    settings     = dir .. 'widgets/' .. 'settings.svg',
    endsession   = dir .. 'widgets/' .. 'endsession.svg',
    clock        = dir .. 'widgets/' .. 'clock.svg',
    search       = dir .. 'widgets/' .. 'search.svg',
    no_updates   = dir .. 'widgets/' .. 'package-normal.svg',
    updates      = dir .. 'widgets/' .. 'package-up.svg',
	  brightness   = dir .. 'widgets/' .. 'brightness.svg',
    volume       = dir .. 'widgets/' .. 'volume-high.svg',
    volume_mute  = dir .. 'widgets/' .. 'volume-mute.svg',
  	effects      = dir .. 'widgets/' .. 'effects.svg',

    network = {
      eth_off        = dir .. 'widgets/network/' .. 'eth-off.svg',
      eth_on_alert   = dir .. 'widgets/network/' .. 'eth-on-alert.svg',
      eth_on_lock    = dir .. 'widgets/network/' .. 'eth-on-lock.svg',
      eth_on         = dir .. 'widgets/network/' .. 'eth-on.svg',
      no_network     = dir .. 'widgets/network/' .. 'no-network.svg',
      notify_off     = dir .. 'widgets/network/' .. 'notification-no-network.svg',
      notify_eth     = dir .. 'widgets/network/' .. 'notification-eth.svg',
      notify_vpn_off = dir .. 'widgets/network/' .. 'notification-vpn-off.svg',
      notify_vpn_on  = dir .. 'widgets/network/' .. 'notification-vpn-on.svg',
      notify_wifi    = dir .. 'widgets/network/' .. 'notification-wifi.svg',
      wifi_off       = dir .. 'widgets/network/' .. 'wifi-default-strength-off.svg',
      wifi_1_alert   = dir .. 'widgets/network/' .. 'wifi-strength-1-alert.svg',
      wifi_1_lock    = dir .. 'widgets/network/' .. 'wifi-strength-1-lock.svg',
      wifi_1         = dir .. 'widgets/network/' .. 'wifi-strength-1.svg',
      wifi_2_alert   = dir .. 'widgets/network/' .. 'wifi-strength-2-alert.svg',
      wifi_2_lock    = dir .. 'widgets/network/' .. 'wifi-strength-2-lock.svg',
      wifi_2         = dir .. 'widgets/network/' .. 'wifi-strength-2.svg',
      wifi_3_alert   = dir .. 'widgets/network/' .. 'wifi-strength-3-alert.svg',
      wifi_3_lock    = dir .. 'widgets/network/' .. 'wifi-strength-3-lock.svg',
      wifi_3         = dir .. 'widgets/network/' .. 'wifi-strength-3.svg',
      wifi_4_alert   = dir .. 'widgets/network/' .. 'wifi-strength-4-alert.svg',
      wifi_4_lock    = dir .. 'widgets/network/' .. 'wifi-strength-4-lock.svg',
      wifi_4         = dir .. 'widgets/network/' .. 'wifi-strength-4.svg',
      wifi_emp_alert = dir .. 'widgets/network/' .. 'wifi-strength-empty-alert.svg',
      wifi_emp       = dir .. 'widgets/network/' .. 'wifi-strength-empty.svg',
      vpn_off        = dir .. 'widgets/network/' .. 'lock-off.svg',
      vpn_on         = dir .. 'widgets/network/' .. 'lock-on.svg'
    },

    notification = {
      clear_all          = dir .. 'widgets/notification/' .. 'clear-all.svg',
      delete             = dir .. 'widgets/notification/' .. 'delete.svg',
      dont_disturb_mode  = dir .. 'widgets/notification/' .. 'dont-disturb-mode.svg',
      empty_notification = dir .. 'widgets/notification/' .. 'empty-notification.svg',
      new_notification   = dir .. 'widgets/notification/' .. 'new-notification.svg',
      notify_mode        = dir .. 'widgets/notification/' .. 'notify-mode.svg',
    },

    bluetooth = {
      loading   = dir .. 'widgets/bluetooth/' .. 'loading.svg',
      on        = dir .. 'widgets/bluetooth/' .. 'bluetooth.svg',
      off       = dir .. 'widgets/bluetooth/' .. 'bluetooth-off.svg',
      scanning  = dir .. 'widgets/bluetooth/' .. 'bluetooth-scanning.svg',
      connected = dir .. 'widgets/bluetooth/' .. 'bluetooth-connected.svg'
    },

    music = {
      toggle_icon = dir .. 'widgets/music/' .. 'music.svg',
      play        = dir .. 'widgets/music/' .. 'play.svg',
      pause       = dir .. 'widgets/music/' .. 'pause.svg',
      prev_song   = dir .. 'widgets/music/' .. 'prev.svg',
      next_song   = dir .. 'widgets/music/' .. 'next.svg',
      repeat_on   = dir .. 'widgets/music/' .. 'repeat-on.svg',
      repeat_off  = dir .. 'widgets/music/' .. 'repeat-off.svg',
      random_on   = dir .. 'widgets/music/' .. 'random-on.svg',
      random_off  = dir .. 'widgets/music/' .. 'random-off.svg',
      vinyl_cover = dir .. 'widgets/music/' .. 'vinyl.svg'
    },

    battery = {
      n10           = dir .. 'widgets/battery/' .. 'battery-10.svg',
      n20           = dir .. 'widgets/battery/' .. 'battery-20.svg',
      n30           = dir .. 'widgets/battery/' .. 'battery-30.svg',
      n50           = dir .. 'widgets/battery/' .. 'battery-50.svg',
      n60           = dir .. 'widgets/battery/' .. 'battery-60.svg',
      n80           = dir .. 'widgets/battery/' .. 'battery-80.svg',
      n90           = dir .. 'widgets/battery/' .. 'battery-90.svg',
      n100          = dir .. 'widgets/battery/' .. 'battery-100.svg',
      alert_red     = dir .. 'widgets/battery/' .. 'battery-alert-red.svg',
      alert         = dir .. 'widgets/battery/' .. 'battery-alert.svg',
      c10           = dir .. 'widgets/battery/' .. 'battery-charging-10.svg',
      c20           = dir .. 'widgets/battery/' .. 'battery-charging-20.svg',
      c30           = dir .. 'widgets/battery/' .. 'battery-charging-30.svg',
      c50           = dir .. 'widgets/battery/' .. 'battery-charging-50.svg',
      c60           = dir .. 'widgets/battery/' .. 'battery-charging-60.svg',
      c80           = dir .. 'widgets/battery/' .. 'battery-charging-80.svg',
      c90           = dir .. 'widgets/battery/' .. 'battery-charging-90.svg',
      c100          = dir .. 'widgets/battery/' .. 'battery-charging-100.svg',
      std           = dir .. 'widgets/battery/' .. 'battery-standard.svg',
      unknown       = dir .. 'widgets/battery/' .. 'battery-unknown.svg'
    },

    hwmonitor = {
      cpu_slider    = dir .. 'widgets/hw_monitor/' .. 'chart-areaspline.svg',
      ram_slider    = dir .. 'widgets/hw_monitor/' .. 'memory.svg',
      temp_slider   = dir .. 'widgets/hw_monitor/' .. 'thermometer.svg',
      disk_slider   = dir .. 'widgets/hw_monitor/' .. 'harddisk.svg'
    }
  }
}
