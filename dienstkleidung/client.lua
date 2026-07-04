local ESX = nil
local PlayerData = {}
local spawnedPeds = {}
local savedCivilianSkin = nil
local isWearingJobOutfit = false
local currentAppliedOutfit = nil
local currentMenuOutfits = {}
local characterLoadToken = 0
local HandleCharacterLoaded = nil
local HandleCharacterLogout = nil
local SpawnAllPeds = nil
local DeleteSpawnedPeds = nil

local function Debug(msg)
    if Config.Debug then
        print(('[job_outfit] %s'):format(tostring(msg)))
    end
end

local nuiFocusActive = false
local outfitMenuOpen = false
local adminMenuOpen = false

local function SetNuiOpen(open)
    nuiFocusActive = open == true

    SetNuiFocus(nuiFocusActive, nuiFocusActive)

    if SetNuiFocusKeepInput then
        SetNuiFocusKeepInput(false)
    end
end

local function ReleaseNuiFocus()
    nuiFocusActive = false
    SetNuiFocus(false, false)

    if SetNuiFocusKeepInput then
        SetNuiFocusKeepInput(false)
    end
end

-- Watchdog: gleicht den TATSÄCHLICHEN NUI-Fokus (IsNuiFocused) mit dem
-- gewünschten Zustand (nuiFocusActive) ab. Läuft im normalen Thread-Kontext,
-- deshalb wirkt SetNuiFocus hier zuverlässig – auch wenn der Aufruf innerhalb
-- eines RegisterNUICallback (z. B. beim Schließen) von CEF ignoriert wurde.
CreateThread(function()
    while true do
        Wait(150)

        if not nuiFocusActive and IsNuiFocused() then
            SetNuiFocus(false, false)
            if SetNuiFocusKeepInput then
                SetNuiFocusKeepInput(false)
            end
            Debug('Watchdog: hängender NUI-Fokus zurückgesetzt')
        end
    end
end)

local function InitESX()
    while ESX == nil do
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)

        if ok and obj then
            ESX = obj
        else
            TriggerEvent('esx:getSharedObject', function(obj2)
                ESX = obj2
            end)
        end

        Wait(250)
    end

    while not ESX.GetPlayerData do
        Wait(250)
    end

    PlayerData = ESX.GetPlayerData() or {}
    Debug('ESX geladen')
end

CreateThread(InitESX)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    if HandleCharacterLoaded then
        HandleCharacterLoaded('esx:playerLoaded', xPlayer)
        return
    end

    PlayerData = xPlayer or (ESX and ESX.GetPlayerData() or {}) or {}
    savedCivilianSkin = nil
    isWearingJobOutfit = false
    currentAppliedOutfit = nil
    currentMenuOutfits = {}
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    if HandleCharacterLogout then
        HandleCharacterLogout('esx:onPlayerLogout')
        return
    end

    PlayerData = {}
    savedCivilianSkin = nil
    isWearingJobOutfit = false
    currentAppliedOutfit = nil
    currentMenuOutfits = {}
    characterLoadToken = characterLoadToken + 1
end)

RegisterNetEvent('esx:setJob', function(job)
    PlayerData.job = job
    Debug('Job geändert: ' .. tostring(job and job.name))
end)

local function RefreshPlayerData()
    if ESX and ESX.GetPlayerData then
        local data = ESX.GetPlayerData()
        if data and data.job then
            PlayerData = data
        end
    end

    return PlayerData
end

local function NormalizeNotifyType(typ)
    typ = tostring(typ or 'info'):lower()

    if typ == 'inform' then typ = 'info' end

    if typ ~= 'success' and typ ~= 'error' and typ ~= 'info' and typ ~= 'warning' then
        typ = 'info'
    end

    return typ
end

local function Notify(msg, typ, duration)
    typ = NormalizeNotifyType(typ)
    duration = tonumber(duration) or Config.NotifyDuration or 8000

    local notifyType = tostring(Config.Notify or 'standard'):lower()

    if notifyType == 'standard' or notifyType == 'custom' or notifyType == 'standalone' then
        SendNUIMessage({
            action = 'notify',
            type = typ,
            message = msg,
            length = duration,
            position = Config.NotifyPosition or 'top-right'
        })
        return
    end

    if notifyType == 'ox_lib' and lib and lib.notify then
        lib.notify({
            title = Config.NotifyTitle or 'Outfit-Menü',
            description = msg,
            type = typ == 'info' and 'inform' or typ,
            duration = duration
        })
        return
    end

    if notifyType == 'okok' and GetResourceState('okokNotify') == 'started' then
        exports['okokNotify']:Alert(Config.NotifyTitle or 'Outfit-Menü', msg, duration, typ, true)
        return
    end

    if notifyType == 'mythic' and GetResourceState('mythic_notify') == 'started' then
        exports['mythic_notify']:DoHudText(typ, msg)
        return
    end

    if notifyType == 'codem' and GetResourceState('codem-notification') == 'started' then
        TriggerEvent('codem-notification:Create', msg, typ, Config.NotifyTitle or 'Outfit-Menü', duration)
        return
    end

    if notifyType == 'qs' and GetResourceState('qs-notify') == 'started' then
        exports['qs-notify']:Alert(msg, duration, typ)
        return
    end

    if notifyType == 'esx' and ESX and ESX.ShowNotification then
        ESX.ShowNotification(msg)
        return
    end

    if ESX and ESX.ShowNotification then
        ESX.ShowNotification(msg)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(msg)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

local function CloseOutfitMenu()
    outfitMenuOpen = false
    ReleaseNuiFocus()
    SendNUIMessage({ action = 'close' })
end

local function CloseAdminPanel()
    Debug('CloseAdminPanel aufgerufen')
    adminMenuOpen = false
    ReleaseNuiFocus()
    SendNUIMessage({ action = 'closeAdmin' })
end

local function CloseAllNui()
    outfitMenuOpen = false
    adminMenuOpen = false
    ReleaseNuiFocus()
    SendNUIMessage({ action = 'close' })
    SendNUIMessage({ action = 'closeAdmin' })
end

-- Not-Aus: setzt NUI-Fokus bedingungslos zurück und schließt beide Menüs,
-- falls die Maus aus irgendeinem Grund in der UI hängen bleiben sollte.
RegisterCommand('outfitunstuck', function()
    CloseAllNui()
end, false)

local function GetJob()
    local data = RefreshPlayerData()
    return data and data.job or nil
end

local function HasJob(jobName)
    local job = GetJob()
    return job and job.name == jobName
end

local function DrawText3D(coords, text)
    SetDrawOrigin(coords.x, coords.y, coords.z + 1.0, 0)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 220)
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local function LoadModel(model)
    local hash = type(model) == 'string' and joaat(model) or model

    if not IsModelInCdimage(hash) then
        Debug('Ungültiges Ped-Model: ' .. tostring(model))
        return nil
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 10000

    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() > timeout then
            Debug('Ped-Model Timeout: ' .. tostring(model))
            return nil
        end
    end

    return hash
end

local componentSlots = {
    mask = 1,
    pants = 4,
    bags = 5,
    shoes = 6,
    chain = 7,
    tshirt = 8,
    bproof = 9,
    decals = 10,
    torso = 11,
    arms = 3
}

local propSlots = {
    helmet = 0,
    glasses = 1,
    ears = 2,
    watches = 6,
    bracelets = 7
}

local function GetClothingSystem()
    local system = tostring(Config.ClothingSystem or 'skinchanger'):lower()

    if system == 'esx_skin' then
        system = 'skinchanger'
    end

    return system
end

local function UsesNativeClothing()
    return GetClothingSystem() == 'native'
end

local function CaptureNativeClothes()
    local ped = PlayerPedId()
    local snapshot = {
        model = GetEntityModel(ped),
        components = {},
        props = {}
    }

    for _, componentId in pairs(componentSlots) do
        snapshot.components[componentId] = {
            drawable = GetPedDrawableVariation(ped, componentId),
            texture = GetPedTextureVariation(ped, componentId),
            palette = GetPedPaletteVariation(ped, componentId)
        }
    end

    for _, propId in pairs(propSlots) do
        snapshot.props[propId] = {
            drawable = GetPedPropIndex(ped, propId),
            texture = GetPedPropTextureIndex(ped, propId)
        }
    end

    return snapshot
end

local function RestoreNativeClothes(snapshot)
    if not snapshot then return false end

    local ped = PlayerPedId()

    if snapshot.model and snapshot.model ~= GetEntityModel(ped) then
        return false
    end

    for componentId, data in pairs(snapshot.components or {}) do
        SetPedComponentVariation(
            ped,
            tonumber(componentId),
            tonumber(data.drawable) or 0,
            tonumber(data.texture) or 0,
            tonumber(data.palette) or 0
        )
    end

    for propId, data in pairs(snapshot.props or {}) do
        local id = tonumber(propId)
        local drawable = tonumber(data.drawable) or -1
        local texture = tonumber(data.texture) or 0

        if drawable < 0 then
            ClearPedProp(ped, id)
        else
            SetPedPropIndex(ped, id, drawable, texture, true)
        end
    end

    return true
end

local function ApplyNativeClothes(clothes)
    if type(clothes) ~= 'table' then return false end

    local ped = PlayerPedId()

    for prefix, componentId in pairs(componentSlots) do
        local drawable = clothes[prefix .. '_1']
        local texture = clothes[prefix .. '_2']

        if prefix == 'arms' and drawable == nil then
            drawable = clothes.arms
        end

        if drawable ~= nil then
            SetPedComponentVariation(
                ped,
                componentId,
                tonumber(drawable) or 0,
                tonumber(texture) or 0,
                2
            )
        end
    end

    for prefix, propId in pairs(propSlots) do
        local drawable = clothes[prefix .. '_1']
        local texture = clothes[prefix .. '_2']

        if drawable ~= nil then
            drawable = tonumber(drawable) or -1
            texture = tonumber(texture) or 0

            if drawable < 0 then
                ClearPedProp(ped, propId)
            else
                SetPedPropIndex(ped, propId, drawable, texture, true)
            end
        end
    end

    return true
end

local function SaveCurrentClothes()
    savedCivilianSkin = {
        native = CaptureNativeClothes(),
        skinchanger = nil
    }

    if UsesNativeClothing() then
        return
    end

    TriggerEvent('skinchanger:getSkin', function(skin)
        if type(savedCivilianSkin) ~= 'table' then savedCivilianSkin = {} end
        savedCivilianSkin.skinchanger = skin
    end)
end

local function RestoreCivilianClothes()
    if not savedCivilianSkin then
        Notify('Es wurde noch keine vorherige Kleidung gespeichert.', 'error')
        return
    end

    if UsesNativeClothing() then
        if RestoreNativeClothes(savedCivilianSkin.native) then
            isWearingJobOutfit = false
            currentAppliedOutfit = nil
            Notify('Normale Kleidung wurde wieder angezogen.', 'success')
        else
            Notify('Normale Kleidung konnte nicht wiederhergestellt werden.', 'error')
        end
        return
    end

    if savedCivilianSkin.skinchanger then
        TriggerEvent('skinchanger:loadSkin', savedCivilianSkin.skinchanger)
        isWearingJobOutfit = false
        currentAppliedOutfit = nil
        Notify('Normale Kleidung wurde wieder angezogen.', 'success')
        return
    end

    if RestoreNativeClothes(savedCivilianSkin.native) then
        isWearingJobOutfit = false
        currentAppliedOutfit = nil
        Notify('Normale Kleidung wurde wieder angezogen.', 'success')
    else
        Notify('Normale Kleidung konnte nicht wiederhergestellt werden.', 'error')
    end
end

local function IsVMSMulticharsEnabled()
    local cfg = Config.VMSMultichars or {}

    if cfg.Enabled ~= true then
        return false
    end

    local resource = cfg.Resource or 'vms_multichars'

    if resource == '' then
        return true
    end

    local state = GetResourceState(resource)
    return state == 'started' or state == 'starting'
end

local function WaitForPlayablePed(timeout)
    local timeoutAt = GetGameTimer() + (tonumber(timeout) or 10000)

    while GetGameTimer() < timeoutAt do
        local ped = PlayerPedId()

        if ped and ped ~= 0 and DoesEntityExist(ped) and not IsEntityDead(ped) then
            local model = GetEntityModel(ped)

            if model == joaat('mp_m_freemode_01') or model == joaat('mp_f_freemode_01') then
                return true
            end
        end

        Wait(250)
    end

    return false
end

local function SchedulePostCharacterCapture(reason)
    local cfg = Config.VMSMultichars or {}

    if cfg.CaptureAfterCharacterLoad == false then
        return
    end

    local token = characterLoadToken
    local delay = tonumber(cfg.CaptureDelay) or 3500
    local timeout = tonumber(cfg.CaptureTimeout) or 12000

    CreateThread(function()
        Wait(delay)

        if token ~= characterLoadToken then return end

        WaitForPlayablePed(timeout)

        if token ~= characterLoadToken then return end

        SaveCurrentClothes()
        Debug(('Zivilkleidung nach Charakter-Ladevorgang neu gespeichert: %s'):format(tostring(reason)))

        if cfg.RespawnPedsAfterCharacterLoad and DeleteSpawnedPeds and SpawnAllPeds then
            DeleteSpawnedPeds()
            SpawnAllPeds()
        end
    end)
end

HandleCharacterLoaded = function(reason, xPlayer)
    PlayerData = xPlayer or (ESX and ESX.GetPlayerData and ESX.GetPlayerData() or {}) or {}
    savedCivilianSkin = nil
    isWearingJobOutfit = false
    currentAppliedOutfit = nil
    currentMenuOutfits = {}
    characterLoadToken = characterLoadToken + 1

    local cfg = Config.VMSMultichars or {}

    if cfg.CloseMenuOnCharacterLoad ~= false then
        CloseAllNui()
    end

    if IsVMSMulticharsEnabled() then
        SchedulePostCharacterCapture(reason)
    end
end

HandleCharacterLogout = function(reason)
    PlayerData = {}
    savedCivilianSkin = nil
    isWearingJobOutfit = false
    currentAppliedOutfit = nil
    currentMenuOutfits = {}
    characterLoadToken = characterLoadToken + 1

    local cfg = Config.VMSMultichars or {}

    if cfg.CloseMenuOnCharacterLoad ~= false then
        CloseAllNui()
    end

    if cfg.DeletePedsOnLogout and DeleteSpawnedPeds then
        DeleteSpawnedPeds()
    end
end

CreateThread(function()
    Wait(0)

    local cfg = Config.VMSMultichars or {}

    for _, eventName in ipairs(cfg.ExtraLoadedEvents or {}) do
        if type(eventName) == 'string' and eventName ~= '' then
            RegisterNetEvent(eventName, function(...)
                if HandleCharacterLoaded then
                    HandleCharacterLoaded(eventName)
                end
            end)
        end
    end
end)

local function ApplyOutfit(outfit)
    if currentAppliedOutfit == outfit then
        Notify('Dieses Kleidungsstück tragen Sie bereits.', 'info')
        return
    end

    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    local clothes = nil

    if model == joaat('mp_m_freemode_01') then
        clothes = outfit.male
    elseif model == joaat('mp_f_freemode_01') then
        clothes = outfit.female
    else
        Notify('Dieses Ped-Modell wird nicht unterstützt.', 'error')
        return
    end

    if type(clothes) ~= 'table' then
        Notify('Für dieses Geschlecht ist kein Outfit hinterlegt.', 'error')
        return
    end

    local hasClothesData = false
    for _ in pairs(clothes) do
        hasClothesData = true
        break
    end

    if not hasClothesData then
        Notify('Für dieses Outfit sind noch keine Kleidungsdaten hinterlegt (Konfiguration unvollständig).', 'error')
        return
    end

    if not isWearingJobOutfit then
        SaveCurrentClothes()
    end

    if UsesNativeClothing() then
        if ApplyNativeClothes(clothes) then
            isWearingJobOutfit = true
            currentAppliedOutfit = outfit
            Notify('Outfit angezogen: ' .. outfit.label, 'success')
        else
            Notify('Outfit konnte nicht angezogen werden.', 'error')
        end
        return
    end

    TriggerEvent('skinchanger:getSkin', function(skin)
        if not savedCivilianSkin then
            savedCivilianSkin = { native = CaptureNativeClothes(), skinchanger = skin }
        elseif not savedCivilianSkin.skinchanger then
            savedCivilianSkin.skinchanger = skin
        end

        TriggerEvent('skinchanger:loadClothes', skin, clothes)
        isWearingJobOutfit = true
        currentAppliedOutfit = outfit
        Notify('Outfit angezogen: ' .. outfit.label, 'success')
    end)
end


-- Outfits liegen jetzt in der Datenbank (siehe server.lua) statt in
-- Config.Outfits. Der Client fragt pro Job+Rang gezielt beim Server nach,
-- statt den kompletten Datensatz aller Jobs/Grade lokal vorzuhalten.
local function GetAllowedOutfits(jobName)
    local job = GetJob()

    if not job then
        Notify('Jobdaten werden noch geladen. Versuch es gleich nochmal.', 'error')
        return nil
    end

    if job.name ~= jobName then
        Notify('Du kannst diesen Outfit-Ped nicht benutzen.', 'error')
        return nil
    end

    if Config.AllowedJobs and Config.AllowedJobs[jobName] == false then
        Notify('Für diesen Job ist die Dienstkleidung deaktiviert.', 'error')
        return nil
    end

    local grade = tonumber(job.grade) or job.grade

    local ok, outfits = pcall(function()
        return lib.callback.await('job_outfit:getOutfits', false, jobName, grade)
    end)

    if not ok then
        Debug('Fehler beim Abrufen der Outfits vom Server: ' .. tostring(outfits))
        Notify('Outfits konnten nicht geladen werden (Server nicht erreichbar).', 'error')
        return nil
    end

    if not outfits or #outfits <= 0 then
        Notify('Für deinen Dienstgrad sind keine Outfits hinterlegt.', 'error')
        return nil
    end

    return outfits, job.label or jobName, job.grade_label or tostring(grade)
end

local function OpenOxLibMenu(jobName)
    if not lib or not lib.registerContext then
        Notify('ox_lib ist nicht gestartet. Stelle Config.MenuType auf custom.', 'error')
        return
    end

    local outfits, realJobName, grade = GetAllowedOutfits(jobName)
    if not outfits then return end

    local options = {}

    if Config.EnableRestoreClothes then
        options[#options + 1] = {
            title = Config.RestoreClothesLabel,
            description = 'Vorherige Kleidung wiederherstellen',
            icon = 'user',
            disabled = savedCivilianSkin == nil,
            onSelect = RestoreCivilianClothes
        }
    end

    for _, outfit in ipairs(outfits) do
        local isActive = outfit == currentAppliedOutfit
        options[#options + 1] = {
            title = outfit.label,
            description = isActive and 'Bereits angezogen' or nil,
            icon = isActive and 'circle-check' or 'shirt',
            disabled = isActive,
            onSelect = isActive and nil or function()
                ApplyOutfit(outfit)
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

    currentMenuOutfits = {}

    local nuiOutfits = {}

    for _, outfit in ipairs(outfits) do
        currentMenuOutfits[#currentMenuOutfits + 1] = outfit
        local isActive = outfit == currentAppliedOutfit
        nuiOutfits[#nuiOutfits + 1] = {
            id = #currentMenuOutfits,
            label = outfit.label,
            sub = isActive and 'Bereits angezogen' or 'Outfit anlegen',
            active = isActive
        }
    end

    outfitMenuOpen = true
    SetNuiOpen(true)
    SendNUIMessage({
        action = 'open',
        title = 'Dienstkleidung',
        job = jobName,
        jobLabel = realJobName,
        grade = grade,
        restoreEnabled = Config.EnableRestoreClothes,
        restoreAvailable = savedCivilianSkin ~= nil,
        restoreLabel = Config.RestoreClothesLabel,
        outfits = nuiOutfits
    })
end

local function OpenJobOutfitMenu(jobName)
    if Config.MenuType == 'ox_lib' then
        OpenOxLibMenu(jobName)
    else
        OpenCustomMenu(jobName)
    end
end

RegisterNUICallback('close', function(_, cb)
    CloseOutfitMenu()
    cb('ok')
end)

RegisterNUICallback('selectOutfit', function(data, cb)
    local id = tonumber(data.id)
    local selected = id and currentMenuOutfits[id]

    -- Fokus wird zuerst freigegeben: selbst wenn ApplyOutfit() aus
    -- irgendeinem Grund einen Fehler wirft, bleibt der Spieler nie mit
    -- sichtbarer Maus/eingefrorenem Charakter hängen.
    CloseOutfitMenu()

    if selected then
        local ok, err = pcall(ApplyOutfit, selected)
        if not ok then
            Debug('Fehler in ApplyOutfit: ' .. tostring(err))
            Notify('Outfit konnte nicht angezogen werden.', 'error')
        end
    end

    cb('ok')
end)

RegisterNUICallback('restoreClothes', function(_, cb)
    -- Reihenfolge bewusst getauscht: Fokus IMMER zuerst freigeben, damit ein
    -- Fehler in RestoreCivilianClothes() nie dazu führt, dass CloseOutfitMenu()
    -- übersprungen wird und der Spieler mit hängendem NUI-Fokus feststeckt.
    CloseOutfitMenu()

    local ok, err = pcall(RestoreCivilianClothes)
    if not ok then
        Debug('Fehler in RestoreCivilianClothes: ' .. tostring(err))
        Notify('Kleidung konnte nicht wiederhergestellt werden.', 'error')
    end

    cb('ok')
end)

local function SpawnSinglePed(jobName, pedData)
    if not pedData.enabled then return end
    if Config.AllowedJobs and Config.AllowedJobs[jobName] == false then return end

    local hash = LoadModel(pedData.model)
    if not hash then return end

    local c = pedData.coords

    local ped = CreatePed(4, hash, c.x, c.y, c.z - 1.0, c.w or 0.0, false, true)
    SetEntityAsMissionEntity(ped, true, true)

    if Config.PedSettings.freeze then FreezeEntityPosition(ped, true) end
    if Config.PedSettings.invincible then SetEntityInvincible(ped, true) end
    if Config.PedSettings.blockEvents then SetBlockingOfNonTemporaryEvents(ped, true) end

    if pedData.scenario and pedData.scenario ~= '' then
        TaskStartScenarioInPlace(ped, pedData.scenario, 0, true)
    end

    SetModelAsNoLongerNeeded(hash)

    local targetName = nil

    if Config.Interaction == 'ox_target' then
        if GetResourceState('ox_target') ~= 'started' then
            Debug('ox_target nicht gestartet')
        else
            targetName = 'job_outfit_menu_' .. jobName

            exports.ox_target:addLocalEntity(ped, {
                {
                    name = targetName,
                    icon = Config.Target.icon,
                    label = Config.Target.label,
                    distance = Config.Target.distance,
                    onSelect = function()
                        OpenJobOutfitMenu(jobName)
                    end,
                    canInteract = function()
                        return HasJob(jobName)
                    end
                }
            })
        end
    end

    spawnedPeds[#spawnedPeds + 1] = {
        entity = ped,
        job = jobName,
        label = pedData.label or '[E] Outfit-Menü öffnen',
        targetName = targetName
    }

    Debug('Ped gespawnt für Job: ' .. jobName)
end

DeleteSpawnedPeds = function()
    for _, pedInfo in ipairs(spawnedPeds) do
        if pedInfo.entity and DoesEntityExist(pedInfo.entity) then
            if pedInfo.targetName and GetResourceState('ox_target') == 'started' then
                exports.ox_target:removeLocalEntity(pedInfo.entity, pedInfo.targetName)
            end

            DeleteEntity(pedInfo.entity)
        end
    end

    spawnedPeds = {}
end

local pedsSpawned = false

SpawnAllPeds = function()
    if pedsSpawned then
        DeleteSpawnedPeds()
    end

    for jobName, pedData in pairs(Config.JobPeds) do
        SpawnSinglePed(jobName, pedData)
        Wait(100)
    end

    pedsSpawned = true
end

CreateThread(function()
    while ESX == nil do Wait(250) end

    for _ = 1, 40 do
        RefreshPlayerData()
        if PlayerData and PlayerData.job then break end
        Wait(250)
    end

    SaveCurrentClothes()
    SpawnAllPeds()

    while true do
        if Config.Interaction ~= 'key' then
            Wait(1000)
        else
            local sleep = 1000
            local playerCoords = GetEntityCoords(PlayerPedId())

            for _, pedInfo in ipairs(spawnedPeds) do
                local ped = pedInfo.entity

                if ped and DoesEntityExist(ped) then
                    local pedCoords = GetEntityCoords(ped)
                    local distance = #(playerCoords - pedCoords)

                    if distance <= Config.KeyInteract.drawDistance then
                        local show = true

                        if Config.KeyInteract.onlyShowForAllowedJobs then
                            show = HasJob(pedInfo.job)
                        end

                        if show then
                            sleep = 0
                            DrawText3D(pedCoords, pedInfo.label)

                            if distance <= Config.KeyInteract.distance and IsControlJustReleased(0, Config.KeyInteract.key) then
                                OpenJobOutfitMenu(pedInfo.job)
                            end
                        end
                    end
                end
            end

            Wait(sleep)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    CloseAllNui()

    if isWearingJobOutfit and savedCivilianSkin then
        RestoreCivilianClothes()
    end

    if DeleteSpawnedPeds then
        DeleteSpawnedPeds()
    end
end)

-- ============================================================
-- Admin-Panel: Einstellungen im Spiel bearbeiten
-- ============================================================

local ADMIN_SYNC_FIELDS = {
    'Debug', 'Notify', 'NotifyTitle', 'NotifyDuration', 'NotifyPosition',
    'Interaction', 'MenuType', 'ClothingSystem',
    'EnableRestoreClothes', 'RestoreClothesLabel',
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
    AllowedJobs = 'table',
    JobPeds = 'table',
    PedSettings = 'table',
    KeyInteract = 'table',
    Target = 'table'
}

local function ApplyClientSettings(settings)
    if type(settings) ~= 'table' then return end

    local pedsChanged = settings.JobPeds ~= nil or settings.PedSettings ~= nil
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

    if pedsChanged and DeleteSpawnedPeds and SpawnAllPeds then
        DeleteSpawnedPeds()
        SpawnAllPeds()
    end
end

RegisterNetEvent('job_outfit:admin:sync', function(settings)
    ApplyClientSettings(settings)
end)

RegisterNetEvent('job_outfit:admin:denied', function()
    Notify('Keine Berechtigung für das Admin-Panel.', 'error')
end)

RegisterNetEvent('job_outfit:admin:saved', function()
    Notify('Einstellungen gespeichert.', 'success')
end)

RegisterNetEvent('job_outfit:admin:saveError', function(reason)
    Notify('Speichern fehlgeschlagen: ' .. tostring(reason or 'unbekannter Fehler'), 'error')
end)

RegisterNetEvent('job_outfit:admin:openPanel', function(settings, jobKeys, configuredJobs)
    adminMenuOpen = true
    SetNuiOpen(true)

    SendNUIMessage({
        action = 'openAdmin',
        settings = settings,
        jobKeys = jobKeys or {},
        configuredJobs = configuredJobs or {}
    })
end)

CreateThread(function()
    Wait(1000)
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
    CloseAdminPanel()
    TriggerServerEvent('job_outfit:admin:save', data)
    cb('ok')
end)

RegisterNUICallback('admin:close', function(_, cb)
    CloseAdminPanel()
    cb('ok')
end)

-- ============================================================
-- Admin-Panel: Outfits (Kleidung) – NUI-Brücke zur DB (server.lua)
-- ============================================================

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
        Debug('Fehler beim Laden der Outfit-Liste: ' .. tostring(list))
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
        local ped = PlayerPedId()
        local model = GetEntityModel(ped)
        local clothes = nil

        if model == joaat('mp_m_freemode_01') then
            clothes = data and data.male
        elseif model == joaat('mp_f_freemode_01') then
            clothes = data and data.female
        end

        if type(clothes) ~= 'table' or not next(clothes) then
            Notify('Für dein aktuelles Geschlecht sind in dieser Vorschau keine Kleidungsdaten gesetzt.', 'error')
            return
        end

        if not isWearingJobOutfit then
            SaveCurrentClothes()
        end

        if UsesNativeClothing() then
            ApplyNativeClothes(clothes)
            isWearingJobOutfit = true
            currentAppliedOutfit = nil
            Notify('Vorschau angezogen.', 'success')
        else
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerEvent('skinchanger:loadClothes', skin, clothes)
                isWearingJobOutfit = true
                currentAppliedOutfit = nil
                Notify('Vorschau angezogen.', 'success')
            end)
        end
    end)

    if not ok then
        Debug('Fehler bei Outfit-Vorschau: ' .. tostring(err))
        Notify('Vorschau konnte nicht angezogen werden.', 'error')
    end

    cb('ok')
end)

RegisterNetEvent('job_outfit:admin:outfits:saved', function(jobName)
    SendNUIMessage({ action = 'outfitsSaved', job = jobName })
end)

RegisterNetEvent('job_outfit:admin:outfits:saveError', function(reason)
    SendNUIMessage({ action = 'outfitsSaveError', reason = reason })
    Notify('Outfit-Fehler: ' .. tostring(reason or 'unbekannter Fehler'), 'error')
end)
