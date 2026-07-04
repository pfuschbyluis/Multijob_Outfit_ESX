# Dienstkleidung

FiveM-Ressource für ein Multi-Job Outfit-Menü mit Admin-Panel (ESX, ox_lib, ox_target, oxmysql).

## Installation

1. Ordner `dienstkleidung` in deinen `resources`-Ordner legen.
2. SQL aus `dienstkleidung/install.sql` in der Datenbank ausführen.
3. In der `server.cfg` eintragen:

```
ensure oxmysql
ensure es_extended
ensure ox_lib
ensure ox_target
ensure dienstkleidung
```

> **Hinweis:** Früher hieß der Ordner `multijob_outfit`. Nach dem Umbenennen `ensure dienstkleidung` verwenden.

## Befehle

| Befehl | Beschreibung |
|--------|--------------|
| `/outfitadmin` | Admin-Panel öffnen |
| `/outfitunstuck` | NUI-Fokus zurücksetzen (Notfall) |
| `/outfitdebug [on\|off\|hud\|status]` | Debug-Modus steuern |
| `/outfitstatus` | Aktuellen Status in die Konsole ausgeben |

### Debug-Modus

- `/outfitdebug on` – ausführliche Logs in der **F8-Konsole** (Fokus, Menü, NUI-Callbacks)
- `/outfitdebug hud` – blendet ein Live-Overlay ein (zeigt `desiredFocus`, `IsNuiFocused`, Menü-Status)
- `/outfitdebug status` bzw. `/outfitstatus` – einmaliger Status-Dump
- `/outfitdebug off` – alles aus

Der Debug-Modus loggt auch in der Browser-Konsole der NUI (über die F8-Devtools erreichbar), sodass sich Klick → `POST` → Lua-Callback lückenlos nachverfolgen lässt.

Dauerhaft aktivierbar über `Config.Debug = true` in `config.lua`.

## Admin-Berechtigung

ACE-Permission in der `server.cfg`:

```
add_ace group.admin job_outfit.admin allow
```

## Konfiguration

- `dienstkleidung/config.lua` – Grundeinstellungen
- `/outfitadmin` – Jobs, Outfits, Peds und Notify live bearbeiten
