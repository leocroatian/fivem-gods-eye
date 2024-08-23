fx_version 'cerulean'

game 'gta5'

author 'leocroatian'
description "God's Eye"
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client.lua'
server_script 'server.lua'