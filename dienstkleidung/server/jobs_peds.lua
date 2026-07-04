-- ============================================================
-- jobs_peds.lua – Jobs/Peds-Schreibzugriffe (DB)
-- ============================================================

local NS = JobOutfitServer

function NS.SanitizeAllowedJobs(v, fallback)
    if type(v) ~= 'table' then return fallback end
    local out = {}
    local any = false
    for k, val in pairs(v) do
        if NS.IsSafeJobKey(k) then
            out[k] = NS.SanitizeBool(val, false)
            any = true
        end
    end
    return any and out or fallback
end

function NS.SanitizeJobPeds(v, fallback)
    if type(v) ~= 'table' then return fallback end
    local out = {}

    for jobName, ped in pairs(v) do
        if NS.IsSafeJobKey(jobName) and type(ped) == 'table' then
            local model = NS.SanitizeString(ped.model, nil)
            local coords = NS.SanitizeCoords(ped.coords, nil)

            if model and coords then
                out[jobName] = {
                    enabled = NS.SanitizeBool(ped.enabled, true),
                    model = model,
                    coords = coords,
                    scenario = NS.SanitizeString(ped.scenario, ''),
                    label = NS.SanitizeString(ped.label, '[E] Outfit-Menü öffnen')
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

function NS.SaveJobsToDB(allowedJobs)
    for jobName, enabled in pairs(allowedJobs) do
        MySQL.query.await(
            'INSERT INTO `multijob_outfit_jobs` (job_name, enabled) VALUES (?, ?) ON DUPLICATE KEY UPDATE enabled = VALUES(enabled)',
            { jobName, enabled and 1 or 0 }
        )
    end
end

function NS.SavePedsToDB(jobPeds)
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
