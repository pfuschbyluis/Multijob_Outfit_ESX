-- ============================================================
-- admin.lua (client) – Admin-Panel (Client-Seite)
-- ============================================================

local ADMIN_SYNC_FIELDS = {
    'Debug', 'Notify', 'NotifyTitle', 'NotifyDuration', 'NotifyPosition',
    'Interaction', 'MenuType', 'ClothingSystem',
    'EnableRestoreClothes', 'RestoreClothesLabel', 'EnableUiAnimations',
    'AdminColor', 'JobColors',
    'AllowedJobs', 'JobPeds', 'PedSettings', 'KeyInteract', 'Target'
}

local ADMIN_FIELD_TYPES = {
    Debug = 'boolean',
    Notify = 'string',
    NotifyTitle = 'string',
    NotifyDuration = 'number',
    NotifyPosition = 'string',
    Interaction = 'string',
    MenuType = 'string',
    ClothingSystem = 'string',
    EnableRestoreClothes = 'boolean',
    RestoreClothesLabel = 'string',
    EnableUiAnimations = 'boolean',
    AdminColor = 'string',
    JobColors = 'table',
    AllowedJobs = 'table',
    JobPeds = 'table',
    PedSettings = 'table',
    KeyInteract = 'table',
    Target = 'table'
}

local function ApplyClientSettings(settings)
    if type(settings) ~= 'table' then return end

    local hadSync = JobOutfit.State.settingsSynced == true
    local pedsChanged = settings.JobPeds ~= nil or settings.PedSettings ~= nil
        or settings.AllowedJobs ~= nil
        or (settings.Interaction ~= nil and settings.Interaction ~= Config.Interaction)

    for _, field in ipairs(ADMIN_SYNC_FIELDS) do
        local value = settings[field]
        local expectedType = ADMIN_FIELD_TYPES[field]

        -- Defense in depth: der Server sanitisiert bereits vor dem Senden,
        -- aber falscher Typ hier wird trotzdem nie übernommen.
        if value ~= nil and (not expectedType or type(value) == expectedType) then
            Config[field] = value
        end
    end

    if settings.Debug ~= nil then
        JobOutfit.State.debugEnabled = nil
    end

    -- Erster Sync nach Resource-Start: nur Config setzen, Spawn macht peds.lua.
    if pedsChanged and hadSync then
        JobOutfit.Peds.DeleteAll()
        JobOutfit.Peds.SpawnAll()
    end
end

RegisterNetEvent('job_outfit:admin:sync', function(settings)
    ApplyClientSettings(settings)
    JobOutfit.State.settingsSynced = true
end)

RegisterNetEvent('job_outfit:admin:denied', function()
    JobOutfit.Notify('Keine Berechtigung für das Admin-Panel.', 'error')
end)

RegisterNetEvent('job_outfit:admin:saved', function()
    JobOutfit.CloseAdminPanel()
    SendNUIMessage({ action = 'adminSaved' })
    JobOutfit.Notify('Einstellungen gespeichert.', 'success')
end)

RegisterNetEvent('job_outfit:admin:saveError', function(reason)
    SendNUIMessage({ action = 'adminSaveError', reason = reason or 'unbekannter Fehler' })
    JobOutfit.Notify('Speichern fehlgeschlagen: ' .. tostring(reason or 'unbekannter Fehler'), 'error')
end)

RegisterNetEvent('job_outfit:admin:openPanel', function(settings, jobKeys, configuredJobs, jobLabels, restrictJobs)
    JobOutfit.Debug('Server-Event: openPanel', 'ADMIN')
    JobOutfit.State.adminMenuOpen = true
    JobOutfit.SetNuiOpen(true, 'openPanel')

    SendNUIMessage({
        action = 'openAdmin',
        debug = JobOutfit.IsDebug(),
        settings = settings,
        jobKeys = jobKeys or {},
        configuredJobs = configuredJobs or {},
        jobLabels = jobLabels or {},
        restrictJobs = restrictJobs == true
    })
end)

RegisterNetEvent('job_outfit:admin:jobDeleted', function(jobName)
    SendNUIMessage({ action = 'adminJobDeleted', job = jobName })
    JobOutfit.Notify(('Job „%s" wurde entfernt.'):format(tostring(jobName)), 'success')
end)

CreateThread(function()
    TriggerServerEvent('job_outfit:admin:requestSync')
end)

RegisterCommand('outfitadmin', function()
    TriggerServerEvent('job_outfit:admin:openRequest')
end, false)

RegisterCommand('outfitadmin_reset', function()
    TriggerServerEvent('job_outfit:admin:resetRequest')
end, false)

RegisterNUICallback('admin:getPosition', function(_, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    cb({ x = coords.x, y = coords.y, z = coords.z, w = heading })
end)

RegisterNUICallback('admin:save', function(data, cb)
    JobOutfit.Debug('NUI-Callback: admin:save', 'NUI')
    TriggerServerEvent('job_outfit:admin:save', data)
    cb('ok')
end)

RegisterNUICallback('admin:close', function(_, cb)
    JobOutfit.Debug('NUI-Callback: admin:close', 'NUI')
    JobOutfit.CloseAdminPanel()
    cb('ok')
end)

RegisterNUICallback('admin:deleteJob', function(data, cb)
    if type(data) == 'table' and type(data.job) == 'string' then
        TriggerServerEvent('job_outfit:admin:deleteJob', data.job)
    end
    cb('ok')
end)

-- ------------------------------------------------------------
-- Admin-Panel: Outfits (Kleidung) – NUI-Brücke zur DB (server.lua)
-- ------------------------------------------------------------

RegisterNUICallback('admin:outfits:list', function(data, cb)
    local jobName = data and data.jobName

    if type(jobName) ~= 'string' or jobName == '' then
        cb({})
        return
    end

    local ok, list = pcall(function()
        return lib.callback.await('job_outfit:admin:outfits:list', false, jobName)
    end)

    if not ok then
        JobOutfit.Debug('Fehler beim Laden der Outfit-Liste: ' .. tostring(list))
        cb({})
        return
    end

    cb(list or {})
end)

RegisterNUICallback('admin:outfits:save', function(data, cb)
    TriggerServerEvent('job_outfit:admin:outfits:save', data)
    cb('ok')
end)

RegisterNUICallback('admin:outfits:delete', function(data, cb)
    TriggerServerEvent('job_outfit:admin:outfits:delete', data)
    cb('ok')
end)

-- Zieht ein Outfit testweise auf dem eigenen Charakter an, OHNE es zu
-- speichern. Rein clientseitig, damit Admins beim Bearbeiten sofort sehen,
-- wie die Werte tatsächlich aussehen.
RegisterNUICallback('admin:outfits:preview', function(data, cb)
    local ok, err = pcall(function()
        local s = JobOutfit.State
        local ped = PlayerPedId()
        local model = GetEntityModel(ped)
        local clothes = nil

        if model == joaat('mp_m_freemode_01') then
            clothes = data and data.male
        elseif model == joaat('mp_f_freemode_01') then
            clothes = data and data.female
        end

        if type(clothes) ~= 'table' or not next(clothes) then
            JobOutfit.Notify('Für dein aktuelles Geschlecht sind in dieser Vorschau keine Kleidungsdaten gesetzt.', 'error')
            return
        end

        if not s.isWearingJobOutfit then
            JobOutfit.Clothing.SaveCurrent()
        end

        if JobOutfit.Clothing.UsesNative() then
            JobOutfit.Clothing.ApplyNative(clothes)
            s.isWearingJobOutfit = true
            s.currentAppliedOutfit = nil
            JobOutfit.Notify('Vorschau angezogen.', 'success')
        else
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerEvent('skinchanger:loadClothes', skin, clothes)
                s.isWearingJobOutfit = true
                s.currentAppliedOutfit = nil
                JobOutfit.Notify('Vorschau angezogen.', 'success')
            end)
        end
    end)

    if not ok then
        JobOutfit.Debug('Fehler bei Outfit-Vorschau: ' .. tostring(err))
        JobOutfit.Notify('Vorschau konnte nicht angezogen werden.', 'error')
    end

    cb('ok')
end)

RegisterNetEvent('job_outfit:admin:outfits:saved', function(jobName)
    SendNUIMessage({ action = 'outfitsSaved', job = jobName })
end)

RegisterNetEvent('job_outfit:admin:outfits:saveError', function(reason)
    SendNUIMessage({ action = 'outfitsSaveError', reason = reason })
    JobOutfit.Notify('Outfit-Fehler: ' .. tostring(reason or 'unbekannter Fehler'), 'error')
end)
