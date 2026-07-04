-- ============================================================
-- database.lua – Tabellen, Erstmigration, Caches
-- ============================================================

local NS = JobOutfitServer

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
-- von config.lua auf die Datenbank). Importiert die alten, hart im Script
-- hinterlegten Daten aus db_seed.lua einmalig. Danach ist die Datenbank die
-- alleinige Quelle der Wahrheit; diese Funktion tut ab dann nichts mehr.
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
        if NS.IsSafeJobKey(jobName) then
            MySQL.insert.await('INSERT INTO `multijob_outfit_jobs` (job_name, enabled) VALUES (?, ?)', { jobName, enabled and 1 or 0 })
            jobCount = jobCount + 1
        end
    end

    local pedCount = 0
    for jobName, ped in pairs(seed.JobPeds or {}) do
        if NS.IsSafeJobKey(jobName) and type(ped) == 'table' then
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
        if NS.IsSafeJobKey(jobName) and type(grades) == 'table' then
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

function NS.ReloadJobsCache()
    local rows = MySQL.query.await('SELECT job_name, enabled FROM `multijob_outfit_jobs`') or {}
    local out = {}
    for _, row in ipairs(rows) do
        out[row.job_name] = row.enabled == 1
    end
    NS.Cache.Jobs = out
end

function NS.ReloadPedsCache()
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
    NS.Cache.Peds = out
end

function NS.ReloadOutfitsCache()
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

    NS.Cache.Outfits = out
end

function NS.ReloadAllCaches()
    NS.ReloadJobsCache()
    NS.ReloadPedsCache()
    NS.ReloadOutfitsCache()
end

function NS.JobHasUsableOutfits(jobName)
    local grades = NS.Cache.Outfits[jobName]
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
    NS.ReloadAllCaches()

    Config.AllowedJobs = NS.Cache.Jobs
    Config.JobPeds = NS.Cache.Peds

    print('[job_outfit] Datenbank geladen: Jobs/Peds/Outfits sind bereit.')

    -- Falls schon Spieler verbunden waren, bevor die DB fertig geladen war,
    -- bekommen sie hier noch einen aktuellen Sync nachgeliefert.
    TriggerClientEvent('job_outfit:admin:sync', -1, {
        AllowedJobs = NS.DeepCopy(Config.AllowedJobs),
        JobPeds = NS.DeepCopy(Config.JobPeds)
    })
end)
