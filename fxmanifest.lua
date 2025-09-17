fx_version 'cerulean'
game 'gta5'

author 'Swusku Development Team'
description 'Advanced Vehicle Management System with Multi-Language Support'
version '1.0.0'
repository 'https://github.com/SwuskuRP/swusku_vehiclemanager'

shared_scripts {
    'config.lua',
    'shared/*.lua',
    'locales/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'locales/*.json'
}

-- Optional dependencies (one of these should be present)
-- dependencies {
--     'es_extended'  -- For ESX
--     'qb-core'      -- For QB-Core
-- }

lua54 'yes'
