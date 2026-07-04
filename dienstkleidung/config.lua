Config = {}

Config.Debug = true

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

-- 'key' oder 'ox_target'
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

Config.PedSettings = {
    freeze = true,
    invincible = true,
    blockEvents = true
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
