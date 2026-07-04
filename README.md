# multijob_outfit

FiveM-Ressource für ein Multi-Job Outfit-Menü (ESX, ox_lib, ox_target, oxmysql).

## Installation

1. Ordner `multijob_outfit` in deinen `resources`-Ordner kopieren.
2. SQL aus `multijob_outfit/install.sql` in der Datenbank ausführen.
3. In der `server.cfg` eintragen:

```
ensure oxmysql
ensure es_extended
ensure ox_lib
ensure ox_target
ensure multijob_outfit
```

## Admin-Panel

- Befehl: `/outfitadmin`
- ACE-Permission: `job_outfit.admin` (siehe `multijob_outfit/ADMIN_PANEL.txt`)

## Weitere Infos

- Konfiguration: `multijob_outfit/config.lua`
- VMS Multichars: `multijob_outfit/VMS_COMPATIBILITY.txt`
