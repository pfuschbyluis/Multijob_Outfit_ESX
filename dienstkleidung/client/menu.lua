-- ============================================================
-- menu.lua – Outfit-Menü (custom NUI + ox_lib)
-- ============================================================

JobOutfit.Menu = {}

-- Outfits liegen in der Datenbank (siehe server.lua). Der Client fragt pro
-- Job+Rang gezielt beim Server nach, statt den kompletten Datensatz aller
-- Jobs/Grade lokal vorzuhalten.
local function GetAllowedOutfits(jobName)
    local job = JobOutfit.GetJob()

    if not job then
        JobOutfit.Notify('Jobdaten werden noch geladen. Versuch es gleich nochmal.', 'error')
        return nil
    end

    if job.name ~= jobName then
        JobOutfit.Notify('Du kannst diesen Outfit-Ped nicht benutzen.', 'error')
        return nil
    end

    if Config.AllowedJobs and Config.AllowedJobs[jobName] == false then
        JobOutfit.Notify('Für diesen Job ist die Dienstkleidung deaktiviert.', 'error')
        return nil
    end

    local grade = tonumber(job.grade) or job.grade

    local ok, outfits = pcall(function()
        return lib.callback.await('job_outfit:getOutfits', false, jobName, grade)
    end)

    if not ok then
        JobOutfit.Debug('Fehler beim Abrufen der Outfits vom Server: ' .. tostring(outfits))
        JobOutfit.Notify('Outfits konnten nicht geladen werden (Server nicht erreichbar).', 'error')
        return nil
    end

    if not outfits or #outfits <= 0 then
        JobOutfit.Notify('Für deinen Dienstgrad sind keine Outfits hinterlegt.', 'error')
        return nil
    end

    return outfits, job.label or jobName, job.grade_label or tostring(grade)
end

local function OpenOxLibMenu(jobName)
    if not lib or not lib.registerContext then
        JobOutfit.Notify('ox_lib ist nicht gestartet. Stelle Config.MenuType auf custom.', 'error')
        return
    end

    local outfits, realJobName, grade = GetAllowedOutfits(jobName)
    if not outfits then return end

    local s = JobOutfit.State
    local options = {}

    if Config.EnableRestoreClothes then
        options[#options + 1] = {
            title = Config.RestoreClothesLabel,
            description = 'Vorherige Kleidung wiederherstellen',
            icon = 'user',
            disabled = s.savedCivilianSkin == nil,
            onSelect = JobOutfit.Clothing.RestoreCivilian
        }
    end

    for _, outfit in ipairs(outfits) do
        local isActive = outfit == s.currentAppliedOutfit
        options[#options + 1] = {
            title = outfit.label,
            description = isActive and 'Bereits angezogen' or nil,
            icon = isActive and 'circle-check' or 'shirt',
            disabled = isActive,
            onSelect = isActive and nil or function()
                JobOutfit.Clothing.ApplyOutfit(outfit)
            end
        }
    end

    lib.registerContext({
        id = 'job_outfit_grade_menu_' .. realJobName,
        title = grade,
        options = options
    })

    lib.showContext('job_outfit_grade_menu_' .. realJobName)
end

local function OpenCustomMenu(jobName)
    local outfits, realJobName, grade = GetAllowedOutfits(jobName)
    if not outfits then return end

    local s = JobOutfit.State
    s.currentMenuOutfits = {}
    local nuiOutfits = {}

    for _, outfit in ipairs(outfits) do
        table.insert(s.currentMenuOutfits, outfit)
        local isActive = outfit == s.currentAppliedOutfit
        nuiOutfits[#nuiOutfits + 1] = {
            id = #s.currentMenuOutfits,
            label = outfit.label,
            sub = isActive and 'Bereits angezogen' or 'Outfit anlegen',
            active = isActive
        }
    end

    JobOutfit.Debug(('Outfit-Menü öffnen (job=%s, outfits=%d)'):format(tostring(jobName), #nuiOutfits), 'MENU')
    s.outfitMenuOpen = true
    JobOutfit.SetNuiOpen(true, 'OpenCustomMenu')
    SendNUIMessage({
        action = 'open',
        debug = JobOutfit.IsDebug(),
        title = 'Dienstkleidung',
        job = jobName,
        jobLabel = realJobName,
        grade = grade,
        restoreEnabled = Config.EnableRestoreClothes,
        restoreAvailable = s.savedCivilianSkin ~= nil,
        restoreLabel = Config.RestoreClothesLabel,
        outfits = nuiOutfits
    })
end

function JobOutfit.Menu.Open(jobName)
    if Config.MenuType == 'ox_lib' then
        OpenOxLibMenu(jobName)
    else
        OpenCustomMenu(jobName)
    end
end

-- ------------------------------------------------------------
-- NUI-Callbacks: Outfit-Menü
-- ------------------------------------------------------------

RegisterNUICallback('close', function(_, cb)
    JobOutfit.Debug('NUI-Callback: close', 'NUI')
    JobOutfit.CloseOutfitMenu()
    cb('ok')
end)

RegisterNUICallback('selectOutfit', function(data, cb)
    local id = tonumber(data.id)
    local selected = id and JobOutfit.State.currentMenuOutfits[id]

    -- Fokus wird zuerst freigegeben: selbst wenn ApplyOutfit() aus
    -- irgendeinem Grund einen Fehler wirft, bleibt der Spieler nie mit
    -- sichtbarer Maus/eingefrorenem Charakter hängen.
    JobOutfit.CloseOutfitMenu()

    if selected then
        local ok, err = pcall(JobOutfit.Clothing.ApplyOutfit, selected)
        if not ok then
            JobOutfit.Debug('Fehler in ApplyOutfit: ' .. tostring(err))
            JobOutfit.Notify('Outfit konnte nicht angezogen werden.', 'error')
        end
    end

    cb('ok')
end)

RegisterNUICallback('restoreClothes', function(_, cb)
    -- Reihenfolge bewusst getauscht: Fokus IMMER zuerst freigeben, damit ein
    -- Fehler in RestoreCivilian() nie dazu führt, dass CloseOutfitMenu()
    -- übersprungen wird und der Spieler mit hängendem NUI-Fokus feststeckt.
    JobOutfit.CloseOutfitMenu()

    local ok, err = pcall(JobOutfit.Clothing.RestoreCivilian)
    if not ok then
        JobOutfit.Debug('Fehler in RestoreCivilian: ' .. tostring(err))
        JobOutfit.Notify('Kleidung konnte nicht wiederhergestellt werden.', 'error')
    end

    cb('ok')
end)
