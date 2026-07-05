Config = {}

Config.Debug = false

-- Notify-Auswahl:
-- 'standard' = eigene integrierte Notify aus diesem Script (Standard)
-- 'esx' = ESX.ShowNotification
-- 'ox_lib' = lib.notify
-- 'okok' = okokNotify
-- 'mythic' = mythic_notify
-- 'codem' = codem-notification
-- 'qs' = qs-notify
Config.Notify = 'standard'
Config.NotifyTitle = 'Outfit-Menü'
Config.NotifyDuration = 8000

-- Position der Benachrichtigungen (nur bei Config.Notify = 'standard'):
-- 'top-right', 'top-left', 'top-center', 'bottom-right', 'bottom-left', 'bottom-center'
Config.NotifyPosition = 'top-right'

-- 'key' = 3D-Text + Taste | 'ox_lib' = ox_lib Text-UI + Taste | 'ox_target' = Target-System
Config.Interaction = 'ox_target'

-- 'custom' = eigenes HTML/NUI-Menü
-- 'ox_lib' = ox_lib Context-Menü
Config.MenuType = 'custom'

-- Kleidungssystem:
-- 'skinchanger' = klassisches ESX/esx_skin/skinchanger Verhalten
-- 'native'      = direktes Native-Anziehen ohne Skinmanager
Config.ClothingSystem = 'skinchanger'

-- Schließt das Outfit-Menü automatisch, falls ein Charakterwechsel (esx:playerLoaded)
-- während offenem Menü passiert.
Config.CloseMenuOnCharacterLoad = true

-- Normalerweise false, weil die lokalen Peds nach Logout weiter benutzt werden können.
Config.DeletePedsOnLogout = false

Config.EnableRestoreClothes = true
Config.RestoreClothesLabel = 'Normale Kleidung anziehen'

-- Öffnungs-Animationen für Outfit-Menü und Admin-Panel (kann im Admin deaktiviert werden)
Config.EnableUiAnimations = true

-- Feste Akzentfarbe des Admin-Panels (unabhängig vom Job-Menü).
-- Hex-Wert, z.B. '#ff5a3c'. Im Admin-Panel unter „Allgemein“ wählbar.
Config.AdminColor = '#ff5a3c'

-- Optionale UI-Farbe pro Job für das Outfit-Menü.
-- Leer lassen = eingebaute Standardfarbe des Jobs. Beispiel:
--   Config.JobColors = { police = '#3b82f6', ambulance = '#22b06d' }
-- Im Admin-Panel unter „Jobs“ pro Job wählbar.
Config.JobColors = {}

Config.PedSettings = {
    freeze = true,
    invincible = true,
    blockEvents = true,
    displayMode = 'peds', -- 'peds' = NPCs spawnen | 'markers' = nur Marker an den Positionen
    showBlip = false,
    markerDrawDistance = 30.0
}

Config.KeyInteract = {
    distance = 2.5,
    drawDistance = 12.0,
    key = 38,
    onlyShowForAllowedJobs = true
}

Config.Target = {
    distance = 2.5,
    icon = 'fa-solid fa-shirt',
    label = 'Outfit-Menü öffnen'
}

-- Platzhalter, bis der Server die echten Werte aus der Datenbank sendet
-- (siehe server.lua). Bleiben absichtlich leer, damit der Client nie mit
-- einem nil-Wert arbeitet, falls er vor dem ersten Sync etwas prüft.
Config.AllowedJobs = {}
Config.JobPeds = {}

-- ============================================================
-- Datenbank-gestützte Daten (NICHT mehr hier konfigurieren!)
-- ============================================================
-- Folgende Daten kommen jetzt zur Laufzeit aus der Datenbank und werden
-- NICHT mehr in dieser Datei gepflegt:
--
--   - Config.AllowedJobs  -> Tabelle `multijob_outfit_jobs`
--   - Config.JobPeds      -> Tabelle `multijob_outfit_peds`
--   - Config.Outfits      -> Tabelle `multijob_outfit_outfits`
--
-- Server lädt AllowedJobs/JobPeds beim Start aus der DB nach Config.* (werden
-- weiterhin per Admin-Sync an Clients verteilt). Outfits bleiben serverseitig
-- in der DB und werden pro Job/Rang auf Anfrage an den anfragenden Client
-- ausgeliefert (nicht mehr komplett an alle Clients gesendet).
--
-- Alle drei Tabellen kannst du komplett über das Admin-Panel (/outfitadmin)
-- verwalten: Jobs an/ausschalten, Outfit-Peds platzieren, Outfits (Kleidung)
-- pro Job und Rang anlegen/bearbeiten/löschen.
--
-- Beim allerersten Start nach der Umstellung werden die alten, hart im
-- Script hinterlegten Daten aus `db_seed.lua` automatisch einmalig in die
-- Datenbank importiert (siehe server.lua). Diese Datei ist danach nicht
-- mehr relevant für den laufenden Betrieb und kann gelöscht werden.
