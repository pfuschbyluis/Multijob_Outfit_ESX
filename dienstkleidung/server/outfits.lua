-- ============================================================
-- outfits.lua – Outfits (Kleidung): Auslieferung + Admin-CRUD
-- ============================================================

local NS = JobOutfitServer

function NS.SanitizeClothesTable(v)
    if type(v) ~= 'table' then return {} end
    local out = {}
    for key, val in pairs(v) do
        -- Muss zu den tatsächlichen Slot-Keys passen (z.B. "mask_1", "torso_2",
        -- "arms"): Buchstaben, Ziffern und Unterstriche, beginnend mit einem
        -- Buchstaben.
        if type(key) == 'string' and key:match('^%a[%a%d_]*$') then
            local n = tonumber(val)
            if n ~= nil then
                out[key] = n
            end
        end
    end
    return out
end

-- Outfits werden NICHT komplett an alle Clients verteilt (das wäre bei
-- vielen Jobs/Outfits sehr viel Traffic), sondern pro Job+Rang auf Anfrage
-- ausgeliefert.
lib.callback.register('job_outfit:getOutfits', function(_source, jobName, grade)
    if type(jobName) ~= 'string' then return {} end
    grade = tonumber(grade) or 0

    local jobOutfits = NS.Cache.Outfits[jobName]
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

-- ------------------------------------------------------------
-- Admin-Panel: Outfits CRUD
-- ------------------------------------------------------------

lib.callback.register('job_outfit:admin:outfits:list', function(source, jobName)
    if not NS.IsAdminAllowed(source) then return nil end
    if type(jobName) ~= 'string' then return {} end

    local grades = NS.Cache.Outfits[jobName] or {}
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

    if not NS.IsAdminAllowed(src) then
        TriggerClientEvent('job_outfit:admin:denied', src)
        return
    end

    if type(data) ~= 'table' or not NS.IsSafeJobKey(data.jobName) then
        TriggerClientEvent('job_outfit:admin:outfits:saveError', src, 'Ungültiger Job')
        return
    end

    if not NS.IsRealJob(data.jobName) then
        TriggerClientEvent('job_outfit:admin:outfits:saveError', src, ('Job "%s" existiert nicht in der Datenbank'):format(tostring(data.jobName)))
        return
    end

    local grade = tonumber(data.grade)
    local label = NS.SanitizeString(data.label, nil)

    if not grade or not label then
        TriggerClientEvent('job_outfit:admin:outfits:saveError', src, 'Rang und Bezeichnung sind erforderlich')
        return
    end

    local male = NS.SanitizeClothesTable(data.male)
    local female = NS.SanitizeClothesTable(data.female)
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

    NS.ReloadOutfitsCache()
    TriggerClientEvent('job_outfit:admin:outfits:saved', src, data.jobName)
end)

RegisterNetEvent('job_outfit:admin:outfits:delete', function(data)
    local src = source

    if not NS.IsAdminAllowed(src) then
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

    NS.ReloadOutfitsCache()
    TriggerClientEvent('job_outfit:admin:outfits:saved', src, type(data) == 'table' and data.jobName or nil)
end)
