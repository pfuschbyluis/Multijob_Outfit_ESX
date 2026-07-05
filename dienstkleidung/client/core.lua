-- ============================================================
-- core.lua – Namespace, State, Debug, NUI-Fokus, ESX, Notify
-- ============================================================
-- Alle Client-Dateien hängen ihre Funktionen an den globalen Namespace
-- `JobOutfit` an. So bleibt jede Datei fokussiert auf EIN Thema, kann aber
-- trotzdem Funktionen aus anderen Dateien aufrufen (Ladereihenfolge steht
-- in fxmanifest.lua und ist wichtig: core.lua zuerst, bootstrap.lua zuletzt).

JobOutfit = JobOutfit or {}

-- ------------------------------------------------------------
-- Zentraler State (statt verstreuter file-lokaler Variablen)
-- ------------------------------------------------------------
JobOutfit.State = {
    esx = nil,
    playerData = {},

    spawnedPeds = {},
    pedsSpawned = false,
    settingsSynced = false, -- erst true nach erstem Server-Sync (Jobs/Peds aus DB)

    savedCivilianSkin = nil,
    isWearingJobOutfit = false,
    currentAppliedOutfit = nil,
    currentMenuOutfits = {},

    characterLoadToken = 0,

    -- Fokus/Menü-Status
    nuiFocusActive = false,
    desiredFocus = false,
    outfitMenuOpen = false,
    adminMenuOpen = false,
    lastFocusReason = 'init',

    -- Laufzeit-Debug-Override (unabhängig von Config.Debug, per /outfitdebug togglebar)
    debugEnabled = nil, -- nil = Config.Debug verwenden
    debugHud = false,
}

-- ------------------------------------------------------------
-- Debug-System
-- ------------------------------------------------------------
function JobOutfit.IsDebug()
    local s = JobOutfit.State
    if s.debugEnabled ~= nil then return s.debugEnabled end
    return Config.Debug == true
end

function JobOutfit.Debug(msg, cat)
    if not JobOutfit.IsDebug() then return end
    cat = cat or 'INFO'
    print(('^3[job_outfit]^7 [%.3f] [%s] %s'):format(GetGameTimer() / 1000, cat, tostring(msg)))
end

-- ------------------------------------------------------------
-- Zentraler NUI-Fokus-Manager
-- ------------------------------------------------------------
-- desiredFocus = was wir WOLLEN. Ein dauerhafter Thread gleicht den
-- TATSÄCHLICHEN Fokus (IsNuiFocused) frame-genau mit desiredFocus ab.
-- Grund: SetNuiFocus(false) innerhalb eines RegisterNUICallback wird von
-- FiveM-CEF gelegentlich ignoriert (deshalb ging /outfitunstuck, aber ein
-- Klick auf Schließen nicht). Die Reconciliation läuft im normalen
-- Thread-Kontext und wirkt daher immer.
function JobOutfit.SetDesiredFocus(state, reason)
    local s = JobOutfit.State
    s.desiredFocus = state == true
    s.nuiFocusActive = s.desiredFocus
    s.lastFocusReason = reason or (s.desiredFocus and 'open' or 'close')

    -- Sofortversuch (funktioniert außerhalb von NUI-Callbacks)
    SetNuiFocus(s.desiredFocus, s.desiredFocus)
    if SetNuiFocusKeepInput then
        SetNuiFocusKeepInput(false)
    end
end

function JobOutfit.SetNuiOpen(open, reason)
    JobOutfit.SetDesiredFocus(open, reason or 'SetNuiOpen')
end

function JobOutfit.ReleaseNuiFocus()
    JobOutfit.SetDesiredFocus(false, 'ReleaseNuiFocus')
end

function JobOutfit.CloseOutfitMenu()
    JobOutfit.Debug('CloseOutfitMenu()', 'MENU')
    JobOutfit.State.outfitMenuOpen = false
    JobOutfit.ReleaseNuiFocus()
    SendNUIMessage({ action = 'close' })
end

function JobOutfit.CloseAdminPanel()
    JobOutfit.Debug('CloseAdminPanel()', 'ADMIN')
    JobOutfit.State.adminMenuOpen = false
    JobOutfit.ReleaseNuiFocus()
    SendNUIMessage({ action = 'closeAdmin' })
end

function JobOutfit.CloseAllNui()
    JobOutfit.Debug('CloseAllNui()', 'MENU')
    JobOutfit.State.outfitMenuOpen = false
    JobOutfit.State.adminMenuOpen = false
    JobOutfit.ReleaseNuiFocus()
    SendNUIMessage({ action = 'close' })
    SendNUIMessage({ action = 'closeAdmin' })
end

-- Reconciliation-Thread: korrigiert Ist- vs. Soll-Fokus, sobald eine Abweichung
-- besteht. Im Ruhezustand nur alle 250 ms, um CPU zu sparen.
CreateThread(function()
    local s = JobOutfit.State
    while true do
        -- IsNuiFocused() liefert je nach FiveM-Build einen Boolean ODER die
        -- Zahl 1/0. In Lua ist 1 ~= true immer wahr, deshalb hart auf Boolean
        -- normalisieren, sonst dreht die Reconciliation-Schleife endlos durch.
        local raw = IsNuiFocused()
        local actual = (raw == true) or (raw == 1)

        if actual ~= s.desiredFocus then
            SetNuiFocus(s.desiredFocus, s.desiredFocus)
            if SetNuiFocusKeepInput then
                SetNuiFocusKeepInput(false)
            end
            -- Nicht jeden Frame erzwingen: verhindert Log-/CPU-Spam, falls ein
            -- anderes UI den Fokus hält oder CEF kurzzeitig nicht reagiert.
            Wait(100)
        else
            Wait(250)
        end
    end
end)

-- Lua-seitiger ESC-Handler (unabhängig vom NUI-fetch): IsRawKeyReleased
-- liest die physische Tastatur direkt aus – auch dann, wenn NUI den Fokus
-- hat und der JS->Lua fetch aus irgendeinem Grund nicht ankommt. Damit
-- lässt sich das Menü IMMER schließen. VK-Code 27 = ESC. (Backspace bewusst
-- NICHT, sonst schließt Löschen in Textfeldern das Panel.)
CreateThread(function()
    while true do
        if JobOutfit.State.nuiFocusActive then
            Wait(0)
            if IsRawKeyReleased and IsRawKeyReleased(27) then
                JobOutfit.Debug('Raw ESC erkannt -> schließe Menü', 'INPUT')
                JobOutfit.CloseAllNui()
            end
        else
            Wait(200)
        end
    end
end)

-- Not-Aus: setzt NUI-Fokus bedingungslos zurück und schließt beide Menüs,
-- falls die Maus aus irgendeinem Grund in der UI hängen bleiben sollte.
RegisterCommand('outfitunstuck', function()
    JobOutfit.CloseAllNui()
end, false)

-- ------------------------------------------------------------
-- ESX-Bootstrap
-- ------------------------------------------------------------
local function InitESX()
    local s = JobOutfit.State

    while s.esx == nil do
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)

        if ok and obj then
            s.esx = obj
        else
            TriggerEvent('esx:getSharedObject', function(obj2)
                s.esx = obj2
            end)
        end

        Wait(250)
    end

    while not s.esx.GetPlayerData do
        Wait(250)
    end

    s.playerData = s.esx.GetPlayerData() or {}
    JobOutfit.Debug('ESX geladen')
end

CreateThread(InitESX)

function JobOutfit.RefreshPlayerData()
    local s = JobOutfit.State
    if s.esx and s.esx.GetPlayerData then
        local data = s.esx.GetPlayerData()
        if data and data.job then
            s.playerData = data
        end
    end
    return s.playerData
end

function JobOutfit.GetJob()
    local data = JobOutfit.RefreshPlayerData()
    return data and data.job or nil
end

function JobOutfit.HasJob(jobName)
    local job = JobOutfit.GetJob()
    return job and job.name == jobName
end

RegisterNetEvent('esx:setJob', function(job)
    JobOutfit.State.playerData.job = job
    JobOutfit.Debug('Job geändert: ' .. tostring(job and job.name))
end)

-- esx:playerLoaded / esx:onPlayerLogout werden zentral in
-- character.lua behandelt.

-- ------------------------------------------------------------
-- Notify
-- ------------------------------------------------------------
local function NormalizeNotifyType(typ)
    typ = tostring(typ or 'info'):lower()
    if typ == 'inform' then typ = 'info' end

    if typ ~= 'success' and typ ~= 'error' and typ ~= 'info' and typ ~= 'warning' then
        typ = 'info'
    end

    return typ
end

function JobOutfit.Notify(msg, typ, duration)
    typ = NormalizeNotifyType(typ)
    duration = tonumber(duration) or Config.NotifyDuration or 8000

    local notifyType = tostring(Config.Notify or 'standard'):lower()
    local esx = JobOutfit.State.esx

    if notifyType == 'standard' or notifyType == 'custom' or notifyType == 'standalone' then
        SendNUIMessage({
            action = 'notify',
            type = typ,
            title = Config.NotifyTitle or 'Outfit-Menü',
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

    if notifyType == 'esx' and esx and esx.ShowNotification then
        esx.ShowNotification(msg)
        return
    end

    if esx and esx.ShowNotification then
        esx.ShowNotification(msg)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(msg)
        EndTextCommandThefeedPostTicker(false, true)
    end
end
