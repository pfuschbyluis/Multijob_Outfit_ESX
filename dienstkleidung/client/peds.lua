-- ============================================================
-- peds.lua – Outfit-Peds spawnen/entfernen + Key-Interaktion
-- ============================================================

JobOutfit.Peds = {}

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

local function SpawnSinglePed(jobName, pedData)
    if type(pedData) ~= 'table' or pedData.enabled == false then return end
    if Config.AllowedJobs and Config.AllowedJobs[jobName] == false then return end

    local c = pedData.coords
    local x, y, z = tonumber(c and c.x), tonumber(c and c.y), tonumber(c and c.z)
    local heading = tonumber(c and c.w) or 0.0

    if not x or not y or not z then
        JobOutfit.Debug(('Ped-Koordinaten ungültig für Job %s'):format(tostring(jobName)), 'PED')
        return
    end

    local hash = LoadModel(pedData.model)
    if not hash then return end

    -- Wichtig (Crash-Fix): CreatePed niemals ungeschützt aufrufen. Ein
    -- ungültiges/beschädigtes Modell oder ein Streaming-Fehler kann sonst
    -- den Client hart abstürzen lassen statt nur diesen einen Ped zu
    -- überspringen.
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

            -- ox_target filtert Jobs nativ über `groups`. Dadurch muss beim
            -- Annähern nicht in jedem Target-Tick ESX.GetPlayerData() aus
            -- canInteract ausgeführt werden. JobOutfit.Menu.Open prüft den
            -- Job zusätzlich nochmal, falls ein Target-Bridge `groups` ignoriert.
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
        targetName = targetName
    })

    JobOutfit.Debug('Ped gespawnt für Job: ' .. tostring(jobName), 'PED')
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
        end
    end

    JobOutfit.State.spawnedPeds = {}
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
end

-- Key-Interaktion (Alternative zu ox_target): zeigt 3D-Text und öffnet das
-- Menü bei Tastendruck in Reichweite. Läuft nur, wenn Config.Interaction ~= 'key'
-- ist der Loop praktisch im Leerlauf (1x/Sekunde Wait).
CreateThread(function()
    while ESX == nil and JobOutfit.State.esx == nil do Wait(250) end

    for _ = 1, 40 do
        JobOutfit.RefreshPlayerData()
        if JobOutfit.State.playerData and JobOutfit.State.playerData.job then break end
        Wait(250)
    end

    JobOutfit.Clothing.SaveCurrent()
    JobOutfit.Peds.SpawnAll()

    while true do
        if Config.Interaction ~= 'key' then
            Wait(1000)
        else
            local sleep = 1000
            local playerPed = PlayerPedId()

            if not playerPed or playerPed == 0 or not DoesEntityExist(playerPed) then
                Wait(sleep)
            else
                local playerCoords = GetEntityCoords(playerPed)
                local keyCfg = Config.KeyInteract or {}
                local drawDistance = tonumber(keyCfg.drawDistance) or 12.0
                local interactDistance = tonumber(keyCfg.distance) or 2.5
                local interactKey = tonumber(keyCfg.key) or 38

                for _, pedInfo in ipairs(JobOutfit.State.spawnedPeds) do
                    local ped = pedInfo.entity

                    if ped and DoesEntityExist(ped) then
                        local pedCoords = GetEntityCoords(ped)
                        local distance = #(playerCoords - pedCoords)

                        if distance <= drawDistance then
                            local show = true

                            if keyCfg.onlyShowForAllowedJobs then
                                local okHasJob, hasJob = pcall(JobOutfit.HasJob, pedInfo.job)
                                show = okHasJob and hasJob == true
                            end

                            if show then
                                sleep = 0
                                DrawText3D(pedCoords, pedInfo.label or '[E] Outfit-Menü öffnen')

                                if distance <= interactDistance and IsControlJustReleased(0, interactKey) then
                                    JobOutfit.Menu.Open(pedInfo.job)
                                end
                            end
                        end
                    end
                end

                Wait(sleep)
            end
        end
    end
end)
