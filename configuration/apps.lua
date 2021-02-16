local filesystem = require('gears.filesystem')
local config_dir = filesystem.get_configuration_dir()
local bin_dir = config_dir .. 'binaries/'
local screen = _G.screen


return {

	-- The default applications in keybindings and widgets
	default = {
    terminal                                        = os.getenv("TERMINAL"),           -- Terminal Emulator
    text_editor                                     = os.getenv("VISUAL"),             -- GUI Text Editor
    web_browser                                     = os.getenv("BROWSER"),            -- Web browser
    alt_web_browser                                 = os.getenv("ALT_BROWSER"),        -- Web browser
    mail_client                                     = os.getenv("EMAIL"),              -- Mail client
    gui_file_manager                                = os.getenv("GUIFM"),              -- GUI File manager
    file_manager                                    = os.getenv("FM"),                 -- File manager
    password_manager                                = os.getenv("PASSWD"),             -- Password manager
    gui_ide                                         = os.getenv("VISUAL"),
    default_player                                  = os.getenv("PLAYER"),
    network_manager                                 = 'nm-connection-editor',          -- Network manager
    bluetooth_manager                               = 'blueman-manager',						   -- Bluetooth manager
    power_manager                                   = 'xfce4-power-manager-settings',  -- Power manager
    package_manager                                 = 'yay',							             -- Package manager
    lock                                            = 'screenlock',                    --'awesome-client "_G.show_lockscreen()"',  -- Lockscreen
    rofiglobal                                      = 'rofi -dpi ' .. screen.primary.dpi ..
				                            ' -show "Global Search" -modi "Global Search":' .. config_dir ..
				                            '/configuration/rofi/sidebar/rofi-spotlight.sh' ..
				                            ' -theme ' .. config_dir ..
				                            '/configuration/rofi/sidebar/rofi.rasi', 	-- Rofi Global Search


    rofiappmenu 									= os.getenv("LAUNCHER"),
    -- for network applety thing
    wifi_interface                = "wlp0s20f3",
    eth_interface                 = "enp0s31f6",
    vpn                           = "LRZ-VPN"
    -- You can add more default applications here
    },

    -- List of apps to start once on start-up
    run_on_start_up = {os.getenv('HOME') .. '/.config/awesome/autostart.sh'}
}
