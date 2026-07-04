-- ============================================================
-- Dienstkleidung – Server: Datenbank-Layer + Admin-Panel
-- ============================================================
-- Zwei getrennte Speicherorte:
--
--   1) settings.json (im Ressourcen-Ordner): NUR noch für allgemeine/
--      statische Einstellungen (Debug, Notify*, Interaction, MenuType,
--      ClothingSystem, EnableRestoreClothes/Label, PedSettings,
--      KeyInteract, Target). Funktioniert wie bisher: Overrides werden
--      gegen die config.lua-Werte sanitisiert.
--
--   2) MySQL-Datenbank (über oxmysql): Jobs (AllowedJobs), Outfit-Peds
--      (JobPeds) und Outfits (Kleidung) sind jetzt vollständig
--      datenbankgestützt. Beim allerersten Start werden die alten,
--      hart im Script hinterlegten Daten aus `db_seed.lua` einmalig in
--      die Datenbank importiert (siehe RunFirstTimeMigration()).
--
-- Outfits werden NICHT mehr komplett an alle Clients verteilt (das wäre
-- bei vielen Jobs/Outfits sehr viel Traffic), sondern pro Job+Rang auf
-- Anfrage ausgeliefert (job_outfit:getOutfits Callback).

local SETTINGS_FILE = 'settings.json'
local ADMIN_ACE = 'job_outfit.admin'

-- Nur noch die allgemeinen/statischen Felder laufen über settings.json.
-- AllowedJobs, JobPeds und Outfits laufen über die Datenbank (siehe unten).
local ADMIN_FIELDS = {
    'Debug', 'Notify', 'NotifyTitle', 'NotifyDuration', 'NotifyPosition',
    'Interaction', 'MenuType', 'ClothingSystem',
    'EnableRestoreClothes', 'RestoreClothesLabel',
    'PedSettings', 'KeyInteract', 'Target'
}

local ENUMS = {
    Notify = { standard = true, esx = true, ox_lib = true, okok = true, mythic = true, codem = true, qs = true },
    NotifyPosition = {
        ['top-right'] = true, ['top-left'] = true, ['top-center'] = true,
        ['bottom-right'] = true, ['bottom-left'] = true, ['bottom-center'] = true
    },
    Interaction = { key = true, ox_target = true },
    MenuType = { custom = true, ox_lib = true },
    ClothingSystem = { skinchanger = true, native = true }
}

local function DeepCopy(value)
    if type(value) ~= 'table' then return value end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = DeepCopy(v)
    end
    return copy
end

local function SanitizeBool(v, fallback)
    if type(v) == 'boolean' then return v end
    return fallback
end

local function SanitizeString(v, fallback)
    if type(v) == 'string' and v ~= '' then return v end
    return fallback
end

local function SanitizeNumber(v, fallback)
    local n = tonumber(v)
    if n ~= nil then return n end
    return fallback
end

local function SanitizeEnum(field, v, fallback)
    if type(v) == 'string' and ENUMS[field] and ENUMS[field][v] then return v end
    return fallback
end

local function IsSafeJobKey(key)
    return type(key) == 'string' and key:match('^[%w_%-]+$') ~= nil
end

local function SanitizeCoords(v, fallbackCoords)
    if type(v) ~= 'table' then return fallbackCoords end
    local x, y, z = tonumber(v.x), tonumber(v.y), tonumber(v.z)
    if not x or not y or not z then return fallbackCoords end
    return { x = x, y = y, z = z, w = tonumber(v.w) or 0.0 }
end

local function SanitizePedSettings(v, fallback)
    if type(v) ~= 'table' then return fallback end
    return {
        freeze = SanitizeBool(v.freeze, fallback and fallback.freeze),
        invincible = SanitizeBool(v.invincible, fallback and fallback.invincible),
        blockEvents = SanitizeBool(v.blockEvents, fallback and fallback.blockEvents)
    }
end

local function SanitizeKeyInteract(v, fallback)
    if type(v) ~= 'table' then return fallback end
    return {
        distance = SanitizeNumber(v.distance, fallback and fallback.distance),
        drawDistance = SanitizeNumber(v.drawDistance, fallback and fallback.drawDistance),
        key = SanitizeNumber(v.key, fallback and fallback.key),
        onlyShowForAllowedJobs = SanitizeBool(v.onlyShowForAllowedJobs, fallback and fallback.onlyShowForAllowedJobs)
    }
end

local function SanitizeTarget(v, fallback)
    if type(v) ~= 'table' then return fallback end
    return {
        distance = SanitizeNumber(v.distance, fallback and fallback.distance),
        icon = SanitizeString(v.icon, fallback and fallback.icon),
        label = SanitizeString(v.label, fallback and fallback.label)
    }
end

-- Prüft jedes Feld einzeln gegen den mitgegebenen Fallback (die echten
-- config.lua-Werte). Ein kaputtes/fremdes Feld fällt auf den Fallback
-- zurück statt das ganze System zu beeinflussen.
local function SanitizeOverrides(raw, base)
    local out = {}
    if type(raw) ~= 'table' then return out end

    if raw.Debug ~= nil then out.Debug = SanitizeBool(raw.Debug, base.Debug) end
    if raw.Notify ~= nil then out.Notify = SanitizeEnum('Notify', raw.Notify, base.Notify) end
    if raw.NotifyTitle ~= nil then out.NotifyTitle = SanitizeString(raw.NotifyTitle, base.NotifyTitle) end
    if raw.NotifyDuration ~= nil then out.NotifyDuration = SanitizeNumber(raw.NotifyDuration, base.NotifyDuration) end
    if raw.NotifyPosition ~= nil then out.NotifyPosition = SanitizeEnum('NotifyPosition', raw.NotifyPosition, base.NotifyPosition) end
    if raw.Interaction ~= nil then out.Interaction = SanitizeEnum('Interaction', raw.Interaction, base.Interaction) end
    if raw.MenuType ~= nil then out.MenuType = SanitizeEnum('MenuType', raw.MenuType, base.MenuType) end
    if raw.ClothingSystem ~= nil then out.ClothingSystem = SanitizeEnum('ClothingSystem', raw.ClothingSystem, base.ClothingSystem) end
    if raw.EnableRestoreClothes ~= nil then out.EnableRestoreClothes = SanitizeBool(raw.EnableRestoreClothes, base.EnableRestoreClothes) end
    if raw.RestoreClothesLabel ~= nil then out.RestoreClothesLabel = SanitizeString(raw.RestoreClothesLabel, base.RestoreClothesLabel) end
    if raw.PedSettings ~= nil then out.PedSettings = SanitizePedSettings(raw.PedSettings, base.PedSettings) end
    if raw.KeyInteract ~= nil then out.KeyInteract = SanitizeKeyInteract(raw.KeyInteract, base.KeyInteract) end
    if raw.Target ~= nil then out.Target = SanitizeTarget(raw.Target, base.Target) end

    return out
end

local function LoadRawFile()
    local raw = LoadResourceFile(GetCurrentResourceName(), SETTINGS_FILE)
    if not raw or raw == '' then return {} end

    local ok, data = pcall(json.decode, raw)
    if ok and type(data) == 'table' then
        return data
    end

    print(('[job_outfit] Konnte %s nicht lesen (ungültiges JSON), benutze Standardwerte aus config.lua'):format(SETTINGS_FILE))
    return {}
end

local function SaveRawFile(data)
    local ok, encoded = pcall(json.encode, data, { indent = true })
    if not ok then
        print('[job_outfit] Einstellungen konnten nicht kodiert werden.')
        return false
    end

    local saved = SaveResourceFile(GetCurrentResourceName(), SETTINGS_FILE, encoded, -1)
    if not saved then
        print(('[job_outfit] %s konnte nicht gespeichert werden.'):format(SETTINGS_FILE))
        return false
    end

    return true
end

-- Echte config.lua-Werte, bevor irgendein Override angewendet wird.
-- Dient als sicherer Fallback für die Sanitisierung und für /outfitadmin_reset.
local DEFAULTS = {}
for _, field in ipairs(ADMIN_FIELDS) do
    DEFAULTS[field] = DeepCopy(Config[field])
end

local overrides = SanitizeOverrides(LoadRawFile(), DEFAULTS)

local function ApplyOverridesToConfig()
    for _, field in ipairs(ADMIN_FIELDS) do
        Config[field] = overrides[field] ~= nil and overrides[field] or DeepCopy(DEFAULTS[field])
    end
end

ApplyOverridesToConfig()

-- ============================================================
-- Datenbank-Layer
-- ============================================================

local JobsCache = {}    -- job_name -> boolean
local PedsCache = {}    -- job_name -> { enabled, model, coords = {x,y,z,w}, scenario, label }
local OutfitsCache = {} -- job_name -> grade(number) -> { { id, label, male, female }, ... } (sort_order)

local function EnsureTables()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `multijob_outfit_jobs` (
            `job_name` VARCHAR(50) NOT NULL,
            `enabled` TINYINT(1) NOT NULL DEFAULT 1,
            PRIMARY KEY (`job_name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `multijob_outfit_peds` (
            `job_name` VARCHAR(50) NOT NULL,
            `enabled` TINYINT(1) NOT NULL DEFAULT 1,
            `model` VARCHAR(100) NOT NULL DEFAULT '',
            `coord_x` FLOAT NOT NULL DEFAULT 0,
            `coord_y` FLOAT NOT NULL DEFAULT 0,
            `coord_z` FLOAT NOT NULL DEFAULT 0,
            `heading` FLOAT NOT NULL DEFAULT 0,
            `scenario` VARCHAR(100) NOT NULL DEFAULT '',
            `label` VARCHAR(150) NOT NULL DEFAULT '[E] Outfit-Menü öffnen',
            PRIMARY KEY (`job_name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `multijob_outfit_outfits` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `job_name` VARCHAR(50) NOT NULL,
            `grade` INT NOT NULL DEFAULT 0,
            `label` VARCHAR(150) NOT NULL DEFAULT '',
            `sort_order` INT NOT NULL DEFAULT 0,
            `male_clothes` LONGTEXT NULL,
            `female_clothes` LONGTEXT NULL,
            PRIMARY KEY (`id`),
            KEY `idx_job_grade` (`job_name`, `grade`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
end

-- Gleiche Normalisierung wie clientseitig: eine Rang-Konfiguration kann als
-- Liste mehrerer Outfits, als einzelnes Outfit oder als { outfits = {...} }
-- vorliegen. Wird nur für den einmaligen Import aus db_seed.lua gebraucht.
local function NormalizeOutfitList(entry)
    if not entry then return nil end
    if type(entry) == 'table' and entry[1] ~= nil then return entry end
    if type(entry) == 'table' and (entry.male or entry.female or entry.label) then return { entry } end
    if type(entry) == 'table' and type(entry.outfits) == 'table' then return entry.outfits end
    return nil
end

local function LoadSeedData()
    local raw = LoadResourceFile(GetCurrentResourceName(), 'db_seed.lua')
    if not raw or raw == '' then return nil end

    local chunk, loadErr = load(raw, '@db_seed.lua')
    if not chunk then
        print('[job_outfit] db_seed.lua konnte nicht geladen werden: ' .. tostring(loadErr))
        return nil
    end

    local ok, seed = pcall(chunk)
    if not ok or type(seed) ~= 'table' then
        print('[job_outfit] db_seed.lua lieferte keine gültigen Daten: ' .. tostring(seed))
        return nil
    end

    return seed
end

-- Läuft nur, solange die Jobs-Tabelle komplett leer ist (= frischer Umstieg
-- von config.lua auf die Datenbank). Importiert die alten Legacy-Daten aus
-- db_seed.lua einmalig. Danach ist die Datenbank die alleinige Quelle der
-- Wahrheit; diese Funktion tut ab dann nichts mehr.
local function RunFirstTimeMigration()
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM `multijob_outfit_jobs`')
    if tonumber(count) and tonumber(count) > 0 then
        return
    end

    local seed = LoadSeedData()
    if not seed then
        print('[job_outfit] Keine db_seed.lua gefunden oder leer - Datenbank bleibt leer. Bitte Jobs/Peds/Outfits über /outfitadmin anlegen.')
        return
    end

    print('[job_outfit] Erststart erkannt: importiere Legacy-Daten aus db_seed.lua in die Datenbank ...')

    local jobCount = 0
    for jobName, enabled in pairs(seed.AllowedJobs or {}) do
        if IsSafeJobKey(jobName) then
            MySQL.insert.await('INSERT INTO `multijob_outfit_jobs` (job_name, enabled) VALUES (?, ?)', { jobName, enabled and 1 or 0 })
            jobCount = jobCount + 1
        end
    end

    local pedCount = 0
    for jobName, ped in pairs(seed.JobPeds or {}) do
        if IsSafeJobKey(jobName) and type(ped) == 'table' then
            local c = ped.coords or {}
            MySQL.insert.await(
                'INSERT INTO `multijob_outfit_peds` (job_name, enabled, model, coord_x, coord_y, coord_z, heading, scenario, label) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                {
                    jobName, ped.enabled and 1 or 0, ped.model or '',
                    tonumber(c.x) or 0.0, tonumber(c.y) or 0.0, tonumber(c.z) or 0.0, tonumber(c.w) or 0.0,
                    ped.scenario or '', ped.label or '[E] Outfit-Menü öffnen'
                }
            )
            pedCount = pedCount + 1
        end
    end

    local outfitCount = 0
    for jobName, grades in pairs(seed.Outfits or {}) do
        if IsSafeJobKey(jobName) and type(grades) == 'table' then
            for gradeKey, gradeEntry in pairs(grades) do
                local grade = tonumber(gradeKey) or 0
                local outfits = NormalizeOutfitList(gradeEntry)

                if outfits then
                    for sortOrder, outfit in ipairs(outfits) do
                        if type(outfit) == 'table' then
                            local maleJson = (type(outfit.male) == 'table' and next(outfit.male)) and json.encode(outfit.male) or nil
                            local femaleJson = (type(outfit.female) == 'table' and next(outfit.female)) and json.encode(outfit.female) or nil

                            MySQL.insert.await(
                                'INSERT INTO `multijob_outfit_outfits` (job_name, grade, label, sort_order, male_clothes, female_clothes) VALUES (?, ?, ?, ?, ?, ?)',
                                { jobName, grade, outfit.label or ('Outfit ' .. sortOrder), sortOrder, maleJson, femaleJson }
                            )
                            outfitCount = outfitCount + 1
                        end
                    end
                end
            end
        end
    end

    print(('[job_outfit] Migration abgeschlossen: %d Jobs, %d Peds, %d Outfits importiert.'):format(jobCount, pedCount, outfitCount))
end

local function ReloadJobsCache()
    local rows = MySQL.query.await('SELECT job_name, enabled FROM `multijob_outfit_jobs`') or {}
    local out = {}
    for _, row in ipairs(rows) do
        out[row.job_name] = row.enabled == 1
    end
    JobsCache = out
end

local function ReloadPedsCache()
    local rows = MySQL.query.await('SELECT * FROM `multijob_outfit_peds`') or {}
    local out = {}
    for _, row in ipairs(rows) do
        out[row.job_name] = {
            enabled = row.enabled == 1,
            model = row.model,
            coords = { x = row.coord_x, y = row.coord_y, z = row.coord_z, w = row.heading },
            scenario = row.scenario or '',
            label = row.label or '[E] Outfit-Menü öffnen'
        }
    end
    PedsCache = out
end

local function ReloadOutfitsCache()
    local rows = MySQL.query.await('SELECT * FROM `multijob_outfit_outfits` ORDER BY job_name, grade, sort_order, id') or {}
    local out = {}

    for _, row in ipairs(rows) do
        out[row.job_name] = out[row.job_name] or {}
        out[row.job_name][row.grade] = out[row.job_name][row.grade] or {}

        local okMale, male = pcall(json.decode, row.male_clothes or '{}')
        local okFemale, female = pcall(json.decode, row.female_clothes or '{}')

        table.insert(out[row.job_name][row.grade], {
            id = row.id,
            label = row.label,
            male = (okMale and type(male) == 'table') and male or {},
            female = (okFemale and type(female) == 'table') and female or {}
        })
    end

    OutfitsCache = out
end

local function ReloadAllCaches()
    ReloadJobsCache()
    ReloadPedsCache()
    ReloadOutfitsCache()
end

local function JobHasUsableOutfits(jobName)
    local grades = OutfitsCache[jobName]
    if type(grades) ~= 'table' then return false end

    for _, outfits in pairs(grades) do
        for _, outfit in ipairs(outfits) do
            if (outfit.male and next(outfit.male)) or (outfit.female and next(outfit.female)) then
                return true
            end
        end
    end

    return false
end

CreateThread(function()
    EnsureTables()
    RunFirstTimeMigration()
    ReloadAllCaches()

    Config.AllowedJobs = JobsCache
    Config.JobPeds = PedsCache

    print('[job_outfit] Datenbank geladen: Jobs/Peds/Outfits sind bereit.')

    -- Falls schon Spieler verbunden waren, bevor die DB fertig geladen war,
    -- bekommen sie hier noch einen aktuellen Sync nachgeliefert.
    TriggerClientEvent('job_outfit:admin:sync', -1, {
        AllowedJobs = DeepCopy(Config.AllowedJobs),
        JobPeds = DeepCopy(Config.JobPeds)
    })
end)

-- ============================================================
-- Jobs/Peds-Schreibzugriffe (DB)
-- ============================================================

local function SanitizeAllowedJobs(v, fallback)
    if type(v) ~= 'table' then return fallback end
    local out = {}
    local any = false
    for k, val in pairs(v) do
        if IsSafeJobKey(k) and type(val) == 'boolean' then
            out[k] = val
            any = true
        end
    end
    return any and out or fallback
end

local function SanitizeJobPeds(v, fallback)
    if type(v) ~= 'table' then return fallback end
    local out = {}

    for jobName, ped in pairs(v) do
        if IsSafeJobKey(jobName) and type(ped) == 'table' then
            local model = SanitizeString(ped.model, nil)
            local coords = SanitizeCoords(ped.coords, nil)

            if model and coords then
                out[jobName] = {
                    enabled = SanitizeBool(ped.enabled, true),
                    model = model,
                    coords = coords,
                    scenario = SanitizeString(ped.scenario, ''),
                    label = SanitizeString(ped.label, '[E] Outfit-Menü öffnen')
                }
            end
            -- Ungültige einzelne Ped-Einträge werden stillschweigend übersprungen,
            -- statt die komplette JobPeds-Liste zu verwerfen.
        end
    end

    -- Eine leere Tabelle ist eine gültige, bewusste Konfiguration (Admin hat
    -- alle Peds entfernt) und darf nicht mehr auf den Fallback zurückfallen.
    return out
end

local function SaveJobsToDB(allowedJobs)
    for jobName, enabled in pairs(allowedJobs) do
        MySQL.query.await(
            'INSERT INTO `multijob_outfit_jobs` (job_name, enabled) VALUES (?, ?) ON DUPLICATE KEY UPDATE enabled = VALUES(enabled)',
            { jobName, enabled and 1 or 0 }
        )
    end
end

local function SavePedsToDB(jobPeds)
    -- Volles Replace: passt zur Semantik "leere Tabelle = alle Peds entfernt".
    MySQL.query.await('DELETE FROM `multijob_outfit_peds`')

    for jobName, ped in pairs(jobPeds) do
        local c = ped.coords
        MySQL.insert.await(
            'INSERT INTO `multijob_outfit_peds` (job_name, enabled, model, coord_x, coord_y, coord_z, heading, scenario, label) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            { jobName, ped.enabled and 1 or 0, ped.model, c.x, c.y, c.z, c.w or 0.0, ped.scenario or '', ped.label or '[E] Outfit-Menü öffnen' }
        )
    end
end

-- ============================================================
-- Outfits (Kleidung) – Datenbank-Zugriff
-- ============================================================

local function SanitizeClothesTable(v)
    if type(v) ~= 'table' then return {} end
    local out = {}
    for key, val in pairs(v) do
        -- Muss zu den tatsächlichen Slot-Keys passen (z.B. "mask_1", "torso_2",
        -- "arms"): Buchstaben, Ziffern und Unterstriche, beginnend mit einem
        -- Buchstaben. Frühere Version erlaubte fälschlich keine Ziffern und
        -- hätte damit praktisch jeden Kleidungs-Key verworfen.
        if type(key) == 'string' and key:match('^%a[%a%d_]*$') then
            local n = tonumber(val)
            if n ~= nil then
                out[key] = n
            end
        end
    end
    return out
end

lib.callback.register('job_outfit:getOutfits', function(source, jobName, grade)
    if type(jobName) ~= 'string' then return {} end
    grade = tonumber(grade) or 0

    local jobOutfits = OutfitsCache[jobName]
    if not jobOutfits then return {} end

    local list = jobOutfits[grade] or {}
    local filtered = {}

    for _, outfit in ipairs(list) do
        local hasMale = outfit.male and next(outfit.male) ~= nil
        local hasFemale = outfit.female and next(outfit.female) ~= nil

        -- Outfits ohne echte Kleidungsdaten (Platzhalter) werden erst gar
        -- nicht an den Client geschickt.
        if hasMale or hasFemale then
            filtered[#filtered + 1] = {
                id = outfit.id,
                label = outfit.label,
                male = outfit.male,
                female = outfit.female
            }
        end
    end

    return filtered
end)

-- ============================================================
-- Admin-Panel: Auth + allgemeine Settings
-- ============================================================

local function IsAdminAllowed(src)
    if src == 0 then return true end -- Konsole
    return IsPlayerAceAllowed(src, ADMIN_ACE)
end

-- Strengere Prüfung für den interaktiven Speichern-Klick im Panel: hier soll
-- der Admin eine klare Fehlermeldung sehen statt einer stillen Korrektur.
local function ValidateSettings(data)
    if type(data) ~= 'table' then return false, 'Ungültiges Format' end

    if data.JobPeds ~= nil then
        if type(data.JobPeds) ~= 'table' then
            return false, 'JobPeds muss ein Objekt sein'
        end
        for jobName, ped in pairs(data.JobPeds) do
            if type(ped) ~= 'table' or type(ped.model) ~= 'string' or ped.model == '' then
                return false, ('Ped-Eintrag für "%s" ist unvollständig (Model fehlt)'):format(tostring(jobName))
            end
            if type(ped.coords) ~= 'table' or type(tonumber(ped.coords.x)) ~= 'number'
                or type(tonumber(ped.coords.y)) ~= 'number' or type(tonumber(ped.coords.z)) ~= 'number' then
                return false, ('Ped-Eintrag für "%s" hat ungültige Koordinaten'):format(tostring(jobName))
            end
        end
    end

    if data.AllowedJobs ~= nil and type(data.AllowedJobs) ~= 'table' then
        return false, 'AllowedJobs muss ein Objekt sein'
    end

    return true
end

local function BuildClientSettings()
    local out = {}
    for _, field in ipairs(ADMIN_FIELDS) do
        out[field] = DeepCopy(Config[field])
    end
    out.AllowedJobs = DeepCopy(Config.AllowedJobs or {})
    out.JobPeds = DeepCopy(Config.JobPeds or {})
    return out
end

RegisterNetEvent('job_outfit:admin:requestSync', function()
    local src = source
    TriggerClientEvent('job_outfit:admin:sync', src, BuildClientSettings())
end)

RegisterNetEvent('job_outfit:admin:openRequest', function()
    local src = source

    if not IsAdminAllowed(src) then
        TriggerClientEvent('job_outfit:admin:denied', src)
        return
    end

    -- jobKeys = alle Jobs, die irgendwo bekannt sind (Jobs-Tabelle, Peds oder
    -- Outfits) - so tauchen auch Jobs auf, die z.B. nur Outfits aber noch
    -- keinen Ped haben.
    local jobKeySet = {}
    for key in pairs(JobsCache) do jobKeySet[key] = true end
    for key in pairs(PedsCache) do jobKeySet[key] = true end
    for key in pairs(OutfitsCache) do jobKeySet[key] = true end

    local jobKeys = {}
    local configuredJobs = {}
    for key in pairs(jobKeySet) do
        jobKeys[#jobKeys + 1] = key
        configuredJobs[key] = JobHasUsableOutfits(key)
    end
    table.sort(jobKeys)

    TriggerClientEvent('job_outfit:admin:openPanel', src, BuildClientSettings(), jobKeys, configuredJobs)
end)

RegisterNetEvent('job_outfit:admin:save', function(newSettings)
    local src = source

    if not IsAdminAllowed(src) then
        TriggerClientEvent('job_outfit:admin:denied', src)
        return
    end

    local ok, err = ValidateSettings(newSettings)
    if not ok then
        TriggerClientEvent('job_outfit:admin:saveError', src, err)
        return
    end

    -- Allgemeine/statische Felder weiterhin über settings.json.
    local sanitized = SanitizeOverrides(newSettings, DEFAULTS)

    if not SaveRawFile(sanitized) then
        TriggerClientEvent('job_outfit:admin:saveError', src, ('%s konnte nicht gespeichert werden'):format(SETTINGS_FILE))
        return
    end

    overrides = sanitized
    ApplyOverridesToConfig()

    -- Jobs/Peds jetzt in der Datenbank statt in settings.json.
    local sanitizedJobs = SanitizeAllowedJobs(newSettings.AllowedJobs, JobsCache)
    local sanitizedPeds = SanitizeJobPeds(newSettings.JobPeds, PedsCache)

    local dbOk, dbErr = pcall(function()
        SaveJobsToDB(sanitizedJobs)
        SavePedsToDB(sanitizedPeds)
    end)

    if not dbOk then
        print('[job_outfit] DB-Fehler beim Speichern von Jobs/Peds: ' .. tostring(dbErr))
        TriggerClientEvent('job_outfit:admin:saveError', src, 'Jobs/Peds konnten nicht in der Datenbank gespeichert werden')
        return
    end

    ReloadJobsCache()
    ReloadPedsCache()
    Config.AllowedJobs = JobsCache
    Config.JobPeds = PedsCache

    local synced = BuildClientSettings()
    TriggerClientEvent('job_outfit:admin:sync', -1, synced)
    TriggerClientEvent('job_outfit:admin:saved', src)
end)

-- Reset betrifft nur noch die allgemeinen/statischen Felder (settings.json).
-- Jobs/Peds/Outfits liegen in der Datenbank und werden hierdurch NICHT
-- zurückgesetzt oder gelöscht - das wäre bei echten Spielerdaten zu riskant.
local function ResetToDefaults(src)
    overrides = {}
    SaveRawFile(overrides)
    ApplyOverridesToConfig()

    local synced = BuildClientSettings()
    TriggerClientEvent('job_outfit:admin:sync', -1, synced)

    if src and src ~= 0 then
        TriggerClientEvent('job_outfit:admin:saved', src)
    end

    print('[job_outfit] Allgemeine Einstellungen wurden auf die config.lua-Standardwerte zurückgesetzt (Jobs/Peds/Outfits in der DB bleiben unverändert).')
end

RegisterNetEvent('job_outfit:admin:resetRequest', function()
    local src = source

    if not IsAdminAllowed(src) then
        TriggerClientEvent('job_outfit:admin:denied', src)
        return
    end

    ResetToDefaults(src)
end)

-- Server-Konsolenbefehl: settings.json leeren und auf config.lua-Standard zurücksetzen.
RegisterCommand('outfitadmin_reset', function(source)
    if source ~= 0 then return end -- nur Server-Konsole
    ResetToDefaults(nil)
end, true)

-- ============================================================
-- Admin-Panel: Outfits (Kleidung) CRUD
-- ============================================================

lib.callback.register('job_outfit:admin:outfits:list', function(source, jobName)
    if not IsAdminAllowed(source) then return nil end
    if type(jobName) ~= 'string' then return {} end

    local grades = OutfitsCache[jobName] or {}
    local list = {}

    for grade, outfits in pairs(grades) do
        for _, outfit in ipairs(outfits) do
            list[#list + 1] = {
                id = outfit.id,
                grade = grade,
                label = outfit.label,
                male = outfit.male,
                female = outfit.female
            }
        end
    end

    table.sort(list, function(a, b)
        if a.grade ~= b.grade then return a.grade < b.grade end
        return (a.id or 0) < (b.id or 0)
    end)

    return list
end)

RegisterNetEvent('job_outfit:admin:outfits:save', function(data)
    local src = source

    if not IsAdminAllowed(src) then
        TriggerClientEvent('job_outfit:admin:denied', src)
        return
    end

    if type(data) ~= 'table' or not IsSafeJobKey(data.jobName) then
        TriggerClientEvent('job_outfit:admin:outfits:saveError', src, 'Ungültiger Job')
        return
    end

    local grade = tonumber(data.grade)
    local label = SanitizeString(data.label, nil)

    if not grade or not label then
        TriggerClientEvent('job_outfit:admin:outfits:saveError', src, 'Rang und Bezeichnung sind erforderlich')
        return
    end

    local male = SanitizeClothesTable(data.male)
    local female = SanitizeClothesTable(data.female)
    local maleJson = next(male) and json.encode(male) or nil
    local femaleJson = next(female) and json.encode(female) or nil
    local id = tonumber(data.id)

    local ok, err = pcall(function()
        if id then
            MySQL.update.await(
                'UPDATE `multijob_outfit_outfits` SET job_name = ?, grade = ?, label = ?, male_clothes = ?, female_clothes = ? WHERE id = ?',
                { data.jobName, grade, label, maleJson, femaleJson, id }
            )
        else
            local nextSort = tonumber(MySQL.scalar.await(
                'SELECT COALESCE(MAX(sort_order), 0) + 1 FROM `multijob_outfit_outfits` WHERE job_name = ? AND grade = ?',
                { data.jobName, grade }
            )) or 1

            MySQL.insert.await(
                'INSERT INTO `multijob_outfit_outfits` (job_name, grade, label, sort_order, male_clothes, female_clothes) VALUES (?, ?, ?, ?, ?, ?)',
                { data.jobName, grade, label, nextSort, maleJson, femaleJson }
            )
        end
    end)

    if not ok then
        print('[job_outfit] DB-Fehler beim Speichern eines Outfits: ' .. tostring(err))
        TriggerClientEvent('job_outfit:admin:outfits:saveError', src, 'Outfit konnte nicht gespeichert werden (DB-Fehler)')
        return
    end

    ReloadOutfitsCache()
    TriggerClientEvent('job_outfit:admin:outfits:saved', src, data.jobName)
end)

RegisterNetEvent('job_outfit:admin:outfits:delete', function(data)
    local src = source

    if not IsAdminAllowed(src) then
        TriggerClientEvent('job_outfit:admin:denied', src)
        return
    end

    local id = type(data) == 'table' and tonumber(data.id) or tonumber(data)
    if not id then return end

    local ok, err = pcall(function()
        MySQL.query.await('DELETE FROM `multijob_outfit_outfits` WHERE id = ?', { id })
    end)

    if not ok then
        print('[job_outfit] DB-Fehler beim Löschen eines Outfits: ' .. tostring(err))
        TriggerClientEvent('job_outfit:admin:outfits:saveError', src, 'Outfit konnte nicht gelöscht werden (DB-Fehler)')
        return
    end

    ReloadOutfitsCache()
    TriggerClientEvent('job_outfit:admin:outfits:saved', src, type(data) == 'table' and data.jobName or nil)
end)

-- Erlaubt anderen Server-Scripts/der Konsole, die aktuellen Einstellungen zu lesen.
exports('GetSettings', BuildClientSettings)
exports('GetOutfitsForJob', function(jobName, grade)
    local jobOutfits = OutfitsCache[jobName]
    if not jobOutfits then return {} end
    return jobOutfits[tonumber(grade) or 0] or {}
end)
