-- ============================================================
-- admin.lua (server) – Admin-Panel: Auth + allgemeine Settings
-- ============================================================

local NS = JobOutfitServer

function NS.IsAdminAllowed(src)
    if src == 0 then return true end -- Konsole
    return IsPlayerAceAllowed(src, NS.ADMIN_ACE)
end

-- Strengere Prüfung für den interaktiven Speichern-Klick im Panel: hier soll
-- der Admin eine klare Fehlermeldung sehen statt einer stillen Korrektur.
local function ValidateSettings(data)
    if type(data) ~= 'table' then return false, 'Ungültiges Format' end

    if data.JobPeds ~= nil then
        if type(data.JobPeds) ~= 'table' then
            return false, 'JobPeds muss ein Objekt sein'
        end
        local markerMode = type(data.PedSettings) == 'table' and data.PedSettings.displayMode == 'markers'
        for jobName, ped in pairs(data.JobPeds) do
            if type(ped) ~= 'table' then
                return false, ('Ped-Eintrag für "%s" ist ungültig'):format(tostring(jobName))
            end
            if not NS.IsRealJob(jobName) then
                return false, ('Job "%s" existiert nicht in der Datenbank'):format(tostring(jobName))
            end
            if not markerMode and (type(ped.model) ~= 'string' or ped.model == '') then
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
    for _, field in ipairs(NS.ADMIN_FIELDS) do
        out[field] = NS.DeepCopy(Config[field])
    end
    out.AllowedJobs = NS.DeepCopy(Config.AllowedJobs or {})
    out.JobPeds = NS.DeepCopy(Config.JobPeds or {})
    return out
end

RegisterNetEvent('job_outfit:admin:requestSync', function()
    local src = source
    TriggerClientEvent('job_outfit:admin:sync', src, BuildClientSettings())
end)

RegisterNetEvent('job_outfit:admin:openRequest', function()
    local src = source

    if not NS.IsAdminAllowed(src) then
        TriggerClientEvent('job_outfit:admin:denied', src)
        return
    end

    -- Frische Jobliste ziehen, damit neu angelegte ESX-Jobs sofort auftauchen.
    NS.ReloadValidJobs()

    -- jobKeys = auswählbare Jobs. Gibt es eine echte Jobliste (ESX-`jobs`-
    -- Tabelle), sind nur diese Jobs auswählbar – so kann man keine Job-Namen
    -- frei erfinden. Bereits konfigurierte Jobs bleiben sichtbar (damit man sie
    -- weiter verwalten/entfernen kann), auch wenn sie nicht mehr existieren.
    local jobKeySet = {}
    if NS.HasValidJobList() then
        for key in pairs(NS.Cache.ValidJobs) do jobKeySet[key] = true end
    end
    for key in pairs(NS.Cache.Jobs) do jobKeySet[key] = true end
    for key in pairs(NS.Cache.Peds) do jobKeySet[key] = true end
    for key in pairs(NS.Cache.Outfits) do jobKeySet[key] = true end

    local jobKeys = {}
    local configuredJobs = {}
    local jobLabels = {}
    for key in pairs(jobKeySet) do
        jobKeys[#jobKeys + 1] = key
        configuredJobs[key] = NS.JobHasUsableOutfits(key)
        jobLabels[key] = NS.Cache.ValidJobs[key]
    end
    table.sort(jobKeys)

    TriggerClientEvent('job_outfit:admin:openPanel', src, BuildClientSettings(), jobKeys, configuredJobs, jobLabels)
end)

RegisterNetEvent('job_outfit:admin:save', function(newSettings)
    local src = source

    if not NS.IsAdminAllowed(src) then
        TriggerClientEvent('job_outfit:admin:denied', src)
        return
    end

    local ok, err = ValidateSettings(newSettings)
    if not ok then
        TriggerClientEvent('job_outfit:admin:saveError', src, err)
        return
    end

    -- Allgemeine/statische Felder weiterhin über settings.json.
    local sanitized = NS.SanitizeOverrides(newSettings, NS.Defaults)

    if not NS.SaveRawFile(sanitized) then
        TriggerClientEvent('job_outfit:admin:saveError', src, ('%s konnte nicht gespeichert werden'):format(NS.SETTINGS_FILE))
        return
    end

    NS.Overrides = sanitized
    NS.ApplyOverridesToConfig()

    -- Jobs/Peds liegen in der Datenbank statt in settings.json.
    local markerMode = type(newSettings.PedSettings) == 'table' and newSettings.PedSettings.displayMode == 'markers'
    local sanitizedJobs = NS.SanitizeAllowedJobs(newSettings.AllowedJobs, NS.Cache.Jobs)
    local sanitizedPeds = NS.SanitizeJobPeds(newSettings.JobPeds, NS.Cache.Peds, markerMode)

    local dbOk, dbErr = pcall(function()
        NS.SaveJobsToDB(sanitizedJobs)
        NS.SavePedsToDB(sanitizedPeds)
    end)

    if not dbOk then
        print('[job_outfit] DB-Fehler beim Speichern von Jobs/Peds: ' .. tostring(dbErr))
        TriggerClientEvent('job_outfit:admin:saveError', src, 'Jobs/Peds konnten nicht in der Datenbank gespeichert werden')
        return
    end

    NS.ReloadJobsCache()
    NS.ReloadPedsCache()
    Config.AllowedJobs = NS.Cache.Jobs
    Config.JobPeds = NS.Cache.Peds

    local synced = BuildClientSettings()
    TriggerClientEvent('job_outfit:admin:sync', -1, synced)
    TriggerClientEvent('job_outfit:admin:saved', src)
end)

-- Reset betrifft nur die allgemeinen/statischen Felder (settings.json).
-- Jobs/Peds/Outfits liegen in der Datenbank und werden hierdurch NICHT
-- zurückgesetzt oder gelöscht - das wäre bei echten Spielerdaten zu riskant.
local function ResetToDefaults(src)
    NS.Overrides = {}
    NS.SaveRawFile(NS.Overrides)
    NS.ApplyOverridesToConfig()

    local synced = BuildClientSettings()
    TriggerClientEvent('job_outfit:admin:sync', -1, synced)

    if src and src ~= 0 then
        TriggerClientEvent('job_outfit:admin:saved', src)
    end

    print('[job_outfit] Allgemeine Einstellungen wurden auf die config.lua-Standardwerte zurückgesetzt (Jobs/Peds/Outfits in der DB bleiben unverändert).')
end

RegisterNetEvent('job_outfit:admin:resetRequest', function()
    local src = source

    if not NS.IsAdminAllowed(src) then
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

-- Erlaubt anderen Server-Scripts/der Konsole, die aktuellen Einstellungen zu lesen.
exports('GetSettings', BuildClientSettings)
exports('GetOutfitsForJob', function(jobName, grade)
    local jobOutfits = NS.Cache.Outfits[jobName]
    if not jobOutfits then return {} end
    return jobOutfits[tonumber(grade) or 0] or {}
end)
