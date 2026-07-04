fx_version 'cerulean'
game 'gta5'
lua '54'

name 'dienstkleidung'
author 'luka004'
description 'Dienstkleidung – Multi-Job Outfit-Menü mit Admin-Panel'
version '1.3.0'

ui_page 'html/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

-- Reihenfolge unten ist wichtig (spätere Dateien nutzen Funktionen aus
-- früheren): core -> clothing -> peds -> menu -> character -> admin -> bootstrap
client_scripts {
    'client/core.lua',       -- Namespace, State, Debug, NUI-Fokus, ESX, Notify
    'client/clothing.lua',   -- Kleidungs-Snapshots + An-/Ausziehen
    'client/peds.lua',       -- Ped-Spawning + Interaktion
    'client/menu.lua',       -- Outfit-Menü (ox_lib/custom) + NUI-Callbacks
    'client/character.lua',  -- Charakterwechsel/Logout
    'client/admin.lua',      -- Admin-Panel (Client-Seite)
    'client/bootstrap.lua'   -- Debug-Befehle, Cleanup, Start-Diagnose (braucht alle anderen Module)
}

-- Reihenfolge unten ist wichtig: settings_store -> database -> jobs_peds -> outfits -> admin
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/settings_store.lua', -- Namespace, settings.json, Sanitizer
    'server/database.lua',       -- Tabellen, Erstmigration, Caches
    'server/jobs_peds.lua',      -- Jobs/Peds-Schreibzugriffe (DB)
    'server/outfits.lua',        -- Outfits (Kleidung): Auslieferung + Admin-CRUD
    'server/admin.lua'           -- Admin-Panel: Auth + allgemeine Settings
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/admin.css',
    'html/admin.js',
    'html/Main.ttf'
}

escrow_ignore {
    'config.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'oxmysql'
}

-- ox_target ist Standard-Interaktion (Config.Interaction = 'ox_target') und wird deshalb hart als Dependency geführt.
-- Wer die Ressource ohne ox_target betreiben will, muss Config.Interaction = 'key' setzen und kann die Dependency entfernen.
-- Admin-Panel (/outfitadmin) benötigt die ACE-Permission 'job_outfit.admin' in der server.cfg, z.B.:
--   add_ace group.admin job_outfit.admin allow
--   add_principal identifier.xxx group.admin
