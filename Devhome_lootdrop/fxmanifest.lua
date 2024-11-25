fx_version 'cerulean'
game 'gta5'

description 'ESX Lootdrop Script by DEVHOME'

shared_script 'config.lua'

server_scripts {
    '@es_extended/locale.lua',
    'server.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'client.lua'
}

shared_script '@es_extended/imports.lua'
