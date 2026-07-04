fx_version 'cerulean'
game 'gta5'
lua '54'

author 'luka004'
description 'Multi-Job Outfit-Menü'
version '1.1.0'

ui_page 'html/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/admin.css',
    'html/admin.js',
    'html/Main.ttf',
    'VMS_COMPATIBILITY.txt'
}

escrow_ignore {
    'config.lua',
    'VMS_COMPATIBILITY.txt'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'oxmysql'
}

-- ox_target ist Standard-Interaktion (Config.Interaction = 'ox_target') und wird deshalb hart als Dependency geführt.
-- Wer die Ressource ohne ox_target betreiben will, muss Config.Interaction = 'key' setzen und kann die Dependency entfernen.
-- vms_multichars wird unterstützt, bleibt aber optional, damit die Ressource auch ohne Multichars startet
-- Admin-Panel (/outfitadmin) benötigt die ACE-Permission 'job_outfit.admin', siehe server.cfg-Hinweis in VMS_COMPATIBILITY.txt