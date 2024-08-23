fx_version 'cerulean'

game 'gta5'

author 'leocroatian'
description "God's Eye"
version '1.0.0'

lua54 'yes'

shared_script '@ox_lib/init.lua'
client_scripts {
    'config.lua',
    'client.lua',
}
server_script 'server.lua'