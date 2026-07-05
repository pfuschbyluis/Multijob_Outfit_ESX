-- ============================================================
-- peds.lua – Outfit-Peds spawnen/entfernen + Interaktion (Key 3D-Text / ox_lib TextUI)
-- ============================================================

JobOutfit.Peds = {}

local pedBlips = {}

local function UsesMarkerMode()
    local pedSettings = Config.PedSettings or {}
    return pedSettings.displayMode == 'markers'
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
        JobOutfit.Debug('Ungültiges Ped-Model: ' .. tostring(model))
        return nil
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 10000

    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() > timeout then
            JobOutfit.Debug('Ped-Model Timeout: ' .. tostring(model))
            return nil
        end
    end

    return hash
end

local function ShouldRegisterPoint(jobName, pedData)
    if type(pedData) ~= 'table' or pedData.enabled == false then return false end
    if Config.AllowedJobs and Config.AllowedJobs[jobName] == false then return false end
    local c = pedData.coords
    return tonumber(c and c.x) and tonumber(c and c.y) and tonumber(c and c.z)
end

local function RegisterMarkerPoint(jobName, pedData)
    if not ShouldRegisterPoint(jobName, pedData) then return end

    local c = pedData.coords
    local x, y, z = tonumber(c.x), tonumber(c.y), tonumber(c.z)
    local zoneId = nil

    if Config.Interaction == 'ox_target' then
        if GetResourceState('ox_target') == 'started' then
            local targetCfg = Config.Target or {}
            local optionName = 'job_outfit_marker_' .. tostring(jobName)
            local okTarget, result = pcall(function()
                return exports.ox_target:addSphereZone({
                    coords = vector3(x, y, z),
                    radius = tonumber(targetCfg.distance) or 2.5,
                    debug = false,
                    options = {
                        {
                            name = optionName,
                            icon = targetCfg.icon or 'fa-solid fa-shirt',
                            label = targetCfg.label or 'Outfit-Menü öffnen',
                            groups = jobName,
                            onSelect = function()
                                JobOutfit.Menu.Open(jobName)
                            end
                        }
                    }
                })
            end)

            if okTarget then
                zoneId = result
            else
                JobOutfit.Debug(('ox_target addSphereZone Fehler für Job %s: %s'):format(tostring(jobName), tostring(result)), 'PED')
            end
        else
            JobOutfit.Debug('ox_target nicht gestartet', 'PED')
        end
    end

    table.insert(JobOutfit.State.spawnedPeds, {
        entity = nil,
        job = jobName,
        label = pedData.label or '[E] Outfit-Menü öffnen',
        zoneId = zoneId,
        isMarker = true,
        coords = { x = x, y = y, z = z }
    })

    JobOutfit.Debug('Marker-Position registriert für Job: ' .. tostring(jobName), 'PED')
end

local function SpawnSinglePed(jobName, pedData)
    if not ShouldRegisterPoint(jobName, pedData) then return end

    if UsesMarkerMode() then
        RegisterMarkerPoint(jobName, pedData)
        return
    end

    if type(pedData.model) ~= 'string' or pedData.model == '' then
        JobOutfit.Debug(('Ped-Modell fehlt für Job %s'):format(tostring(jobName)), 'PED')
        return
    end

    local c = pedData.coords
    local x, y, z = tonumber(c.x), tonumber(c.y), tonumber(c.z)
    local heading = tonumber(c.w) or 0.0

    local hash = LoadModel(pedData.model)
    if not hash then return end

    local okCreate, pedOrErr = pcall(function()
        return CreatePed(4, hash, x, y, z - 1.0, heading, false, true)
    end)

    SetModelAsNoLongerNeeded(hash)

    if not okCreate or not pedOrErr or pedOrErr == 0 or not DoesEntityExist(pedOrErr) then
        JobOutfit.Debug(('Ped konnte nicht erstellt werden für Job %s: %s'):format(tostring(jobName), tostring(pedOrErr)), 'PED')
        return
    end

    local ped = pedOrErr
    SetEntityAsMissionEntity(ped, true, true)

    local pedSettings = Config.PedSettings or {}
    if pedSettings.freeze then FreezeEntityPosition(ped, true) end
    if pedSettings.invincible then SetEntityInvincible(ped, true) end
    if pedSettings.blockEvents then SetBlockingOfNonTemporaryEvents(ped, true) end

    if type(pedData.scenario) == 'string' and pedData.scenario ~= '' then
        local okScenario, scenarioErr = pcall(function()
            TaskStartScenarioInPlace(ped, pedData.scenario, 0, true)
        end)
        if not okScenario then
            JobOutfit.Debug(('Scenario konnte nicht gestartet werden für Job %s: %s'):format(tostring(jobName), tostring(scenarioErr)), 'PED')
        end
    end

    local targetName = nil

    if Config.Interaction == 'ox_target' then
        if GetResourceState('ox_target') ~= 'started' then
            JobOutfit.Debug('ox_target nicht gestartet', 'PED')
        else
            local optionName = 'job_outfit_menu_' .. tostring(jobName)
            local targetCfg = Config.Target or {}

            local okTarget, targetErr = pcall(function()
                exports.ox_target:addLocalEntity(ped, {
                    {
                        name = optionName,
                        icon = targetCfg.icon or 'fa-solid fa-shirt',
                        label = targetCfg.label or 'Outfit-Menü öffnen',
                        distance = tonumber(targetCfg.distance) or 2.5,
                        groups = jobName,
                        onSelect = function()
                            JobOutfit.Menu.Open(jobName)
                        end
                    }
                })
            end)

            if okTarget then
                targetName = optionName
            else
                JobOutfit.Debug(('ox_target addLocalEntity Fehler für Job %s: %s'):format(tostring(jobName), tostring(targetErr)), 'PED')
            end
        end
    end

    table.insert(JobOutfit.State.spawnedPeds, {
        entity = ped,
        job = jobName,
        label = pedData.label or '[E] Outfit-Menü öffnen',
        targetName = targetName,
        coords = { x = x, y = y, z = z }
    })

    JobOutfit.Debug('Ped gespawnt für Job: ' .. tostring(jobName), 'PED')
end

local function ClearPedBlips()
    for _, blip in ipairs(pedBlips) do
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    pedBlips = {}
end

local function capitalize(str)
    str = tostring(str or '')
    if str == '' then return '' end
    return str:sub(1, 1):upper() .. str:sub(2)
end

local function RefreshPedBlips()
    ClearPedBlips()

    if not UsesMarkerMode() then return end

    local pedSettings = Config.PedSettings or {}
    if not pedSettings.showBlip or type(Config.JobPeds) ~= 'table' then return end

    for jobName, pedData in pairs(Config.JobPeds) do
        if ShouldRegisterPoint(jobName, pedData) then
            local c = pedData.coords
            local x, y, z = tonumber(c.x), tonumber(c.y), tonumber(c.z)
            local blip = AddBlipForCoord(x, y, z)
            SetBlipSprite(blip, 73)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.75)
            SetBlipColour(blip, 47)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(pedData.label or (capitalize(jobName) .. ' Outfit'))
            EndTextCommandSetBlipName(blip)
            pedBlips[#pedBlips + 1] = blip
        end
    end
end

local function DrawPedMarker(coords)
    DrawMarker(
        2,
        coords.x, coords.y, coords.z + 0.25,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        0.32, 0.32, 0.32,
        255, 90, 60, 185,
        false, false, 2, true, nil, nil, false
    )
end

function JobOutfit.Peds.DeleteAll()
    for _, pedInfo in ipairs(JobOutfit.State.spawnedPeds) do
        if pedInfo.entity and DoesEntityExist(pedInfo.entity) then
            if pedInfo.targetName and GetResourceState('ox_target') == 'started' then
                local okRemove, removeErr = pcall(function()
                    exports.ox_target:removeLocalEntity(pedInfo.entity, pedInfo.targetName)
                end)
                if not okRemove then
                    JobOutfit.Debug(('ox_target removeLocalEntity Fehler: %s'):format(tostring(removeErr)), 'PED')
                end
            end

            DeleteEntity(pedInfo.entity)
        elseif pedInfo.zoneId and GetResourceState('ox_target') == 'started' then
            local okRemove, removeErr = pcall(function()
                exports.ox_target:removeZone(pedInfo.zoneId)
            end)
            if not okRemove then
                JobOutfit.Debug(('ox_target removeZone Fehler: %s'):format(tostring(removeErr)), 'PED')
            end
        end
    end

    JobOutfit.State.spawnedPeds = {}
    ClearPedBlips()
end

function JobOutfit.Peds.SpawnAll()
    local s = JobOutfit.State

    if s.pedsSpawned then
        JobOutfit.Peds.DeleteAll()
    end

    if type(Config.JobPeds) ~= 'table' then
        JobOutfit.Debug('Config.JobPeds ist keine Tabelle - Peds werden nicht gespawnt.', 'PED')
        s.pedsSpawned = false
        return
    end

    for jobName, pedData in pairs(Config.JobPeds) do
        SpawnSinglePed(jobName, pedData)
        Wait(100)
    end

    s.pedsSpawned = true
    RefreshPedBlips()
end

-- ox_lib-Text-UI: wird nur angezeigt, während man wirklich in Reichweite eines
-- Punktes steht. Status merken, damit nicht in jedem Frame neu ge-/versteckt wird.
local activeTextUI = nil

local function ShowInteractTextUI(label)
    if activeTextUI == label then return end
    activeTextUI = label
    if lib and lib.showTextUI then
        lib.showTextUI(label, { position = 'right-center', icon = 'shirt' })
    end
end

local function HideInteractTextUI()
    if activeTextUI == nil then return end
    activeTextUI = nil
    if lib and lib.hideTextUI then
        lib.hideTextUI()
    end
end

CreateThread(function()
    while ESX == nil and JobOutfit.State.esx == nil do Wait(250) end

    for _ = 1, 40 do
        JobOutfit.RefreshPlayerData()
        if JobOutfit.State.playerData and JobOutfit.State.playerData.job then break end
        Wait(250)
    end

    JobOutfit.Clothing.SaveCurrent()

    -- Erst spawnen, wenn der Server Jobs/Peds aus der DB geschickt hat.
    while not JobOutfit.State.settingsSynced do
        Wait(100)
    end

    JobOutfit.Peds.SpawnAll()

    while true do
        local mode = Config.Interaction
        if mode ~= 'key' and mode ~= 'ox_lib' then
            HideInteractTextUI()
            Wait(1000)
        else
            local sleep = 1000
            local playerPed = PlayerPedId()

            if not playerPed or playerPed == 0 or not DoesEntityExist(playerPed) then
                HideInteractTextUI()
                Wait(sleep)
            else
                local playerCoords = GetEntityCoords(playerPed)
                local keyCfg = Config.KeyInteract or {}
                local drawDistance = tonumber(keyCfg.drawDistance) or 12.0
                local interactDistance = tonumber(keyCfg.distance) or 2.5
                local interactKey = tonumber(keyCfg.key) or 38

                -- Nächstliegenden Punkt in Sichtweite finden; Taste nur in Interaktions-Distanz.
                local nearestInfo, nearestDist, canInteract = nil, math.huge, false

                for _, pedInfo in ipairs(JobOutfit.State.spawnedPeds) do
                    local pedCoords

                    if pedInfo.entity and DoesEntityExist(pedInfo.entity) then
                        pedCoords = GetEntityCoords(pedInfo.entity)
                    elseif pedInfo.coords then
                        pedCoords = vector3(pedInfo.coords.x, pedInfo.coords.y, pedInfo.coords.z)
                    end

                    if pedCoords then
                        local distance = #(playerCoords - pedCoords)

                        if distance <= drawDistance then
                            local show = true

                            if keyCfg.onlyShowForAllowedJobs then
                                local okHasJob, hasJob = pcall(JobOutfit.HasJob, pedInfo.job)
                                show = okHasJob and hasJob == true
                            end

                            if show and distance < nearestDist then
                                nearestDist = distance
                                nearestInfo = pedInfo
                                canInteract = distance <= interactDistance
                            end
                        end
                    end
                end

                if nearestInfo then
                    sleep = 0
                    local promptLabel = nearestInfo.label or 'Outfit-Menü öffnen'

                    if mode == 'ox_lib' then
                        ShowInteractTextUI(promptLabel)
                    else
                        HideInteractTextUI()
                        local drawCoords
                        if nearestInfo.entity and DoesEntityExist(nearestInfo.entity) then
                            drawCoords = GetEntityCoords(nearestInfo.entity)
                        elseif nearestInfo.coords then
                            drawCoords = vector3(nearestInfo.coords.x, nearestInfo.coords.y, nearestInfo.coords.z)
                        end
                        if drawCoords then
                            DrawText3D(drawCoords, promptLabel)
                        end
                    end

                    if canInteract and IsControlJustReleased(0, interactKey) then
                        JobOutfit.Menu.Open(nearestInfo.job)
                    end
                else
                    HideInteractTextUI()
                end

                Wait(sleep)
            end
        end
    end
end)

CreateThread(function()
    while true do
        if not UsesMarkerMode() or type(Config.JobPeds) ~= 'table' then
            Wait(1000)
        else
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local pedSettings = Config.PedSettings or {}
            local drawDistance = tonumber(pedSettings.markerDrawDistance) or 30.0

            for jobName, pedData in pairs(Config.JobPeds) do
                if ShouldRegisterPoint(jobName, pedData) then
                    local c = pedData.coords
                    local coords = vector3(tonumber(c.x), tonumber(c.y), tonumber(c.z))
                    local distance = #(playerCoords - coords)

                    if distance <= drawDistance then
                        sleep = 0
                        DrawPedMarker(coords)
                    end
                end
            end

            Wait(sleep)
        end
    end
end)
