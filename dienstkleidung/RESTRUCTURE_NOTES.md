# Restrukturierung – was sich geändert hat

Funktional ist alles 1:1 identisch zur vorherigen Version (inkl. Ped-Crash-Fix
per `pcall` um `CreatePed`). Es wurde nur die Code-Organisation überarbeitet:

## client.lua (1383 Zeilen, eine Datei) → 7 fokussierte Module

- `client/core.lua` – Namespace (`JobOutfit`), zentraler `State`, Debug-System, NUI-Fokus-Manager, ESX-Bootstrap, Notify
- `client/clothing.lua` – Kleidungs-Slots, Capture/Apply/Restore (native + skinchanger)
- `client/peds.lua` – Ped-Spawning, Modell-Laden, ox_target/Key-Interaktion
- `client/menu.lua` – Outfit-Menü (custom NUI + ox_lib) + zugehörige NUI-Callbacks
- `client/character.lua` – Charakterwechsel/Logout (Reset Kleidungs-State, Menü schließen)
- `client/admin.lua` – Admin-Panel (Client-Seite): Sync, Speichern, Outfits-CRUD-Brücke
- `client/bootstrap.lua` – Debug-Befehle, Resource-Stop-Cleanup, Start-Diagnose

Statt verstreuter file-lokaler Variablen (`spawnedPeds`, `savedCivilianSkin`, …)
gibt es jetzt EINEN zentralen `JobOutfit.State`-Table. Alle Module hängen ihre
Funktionen an den globalen Namespace `JobOutfit` (z.B. `JobOutfit.Notify(...)`,
`JobOutfit.Clothing.ApplyOutfit(...)`), statt vorwärts-deklarierte lokale
Funktionsvariablen zu verwenden. Die Ladereihenfolge in `fxmanifest.lua` ist
wichtig (core.lua zuerst, bootstrap.lua zuletzt) und mit Kommentaren dokumentiert.

## server.lua (815 Zeilen, eine Datei) → 5 fokussierte Module

- `server/settings_store.lua` – Namespace (`JobOutfitServer`), `settings.json`-Persistenz, generische Sanitizer
- `server/database.lua` – Tabellen anlegen, Erstmigration aus `db_seed.lua`, Caches (Jobs/Peds/Outfits)
- `server/jobs_peds.lua` – Schreibzugriffe für Jobs/Peds (Sanitizing + DB)
- `server/outfits.lua` – Outfits-Auslieferung an Clients + Admin-CRUD
- `server/admin.lua` – Admin-Auth, Validierung, Settings-Sync/Speichern/Reset

Gleiches Prinzip: globaler Namespace `JobOutfitServer` mit `JobOutfitServer.Cache`
(`Jobs`/`Peds`/`Outfits`) statt einzelner Modul-Level-Variablen.

## Unverändert

- `config.lua` (bis auf entfernten VMS-Block, siehe unten), `db_seed.lua`, `install.sql`
- `html/` (index.html, script.js, admin.js, style.css, admin.css, Main.ttf) –
  alle NUI-Callback-Namen sind identisch geblieben, daher war hier keine
  Anpassung nötig.

## Entfernt: VMS-Multichars-Support

Auf Wunsch komplett rausgeworfen (`Config.VMSMultichars`, `VMS_COMPATIBILITY.txt`,
die zugehörigen Re-Capture-/Respawn-Threads). `character.lua` macht jetzt nur
noch das Nötigste: Kleidungs-State zurücksetzen und Menü schließen bei
`esx:playerLoaded`/`esx:onPlayerLogout`. Übrig geblieben sind zwei einfache
Flags in `config.lua`: `Config.CloseMenuOnCharacterLoad` und `Config.DeletePedsOnLogout`.

## Warum das besser ist

- Jede Datei behandelt genau ein Thema (Kleidung, Peds, Menü, Admin, …) –
  einfacher zu finden, zu testen und zu erweitern.
- Kein Vorwärts-Deklarations-Hack mehr (`local HandleCharacterLoaded = nil`),
  da zusammengehörige Logik jetzt in derselben Datei steht.
- Zentraler `State`/`Cache`-Table statt verstreuter lokaler Variablen macht
  den Datenfluss zwischen den Modulen nachvollziehbar.
- Alle Dateien wurden mit `luac5.4 -p` auf Syntaxfehler geprüft.
