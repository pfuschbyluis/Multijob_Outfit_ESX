-- ============================================================
-- bootstrap.lua – Debug-Befehle, Cleanup, Start-Diagnose
-- ============================================================
-- Diese Datei läuft absichtlich zuletzt: sie fasst nur Befehle/Handler
-- zusammen, die auf ALLE anderen Module zugreifen dürfen.

local function DumpStatus()
    local s = JobOutfit.State
    local job = s.playerData and s.playerData.job

    print('^2======== [job_outfit] STATUS ========^7')
    print(('Debug aktiv:       %s (Config.Debug=%s, override=%s)'):format(tostring(JobOutfit.IsDebug()), tostring(Config.Debug), tostring(s.debugEnabled)))
    print(('desiredFocus:      %s'):format(tostring(s.desiredFocus)))
    print(('nuiFocusActive:    %s'):format(tostring(s.nuiFocusActive)))
    print(('IsNuiFocused():    %s'):format(tostring(IsNuiFocused())))
    print(('outfitMenuOpen:    %s'):format(tostring(s.outfitMenuOpen)))
    print(('adminMenuOpen:     %s'):format(tostring(s.adminMenuOpen)))
    print(('letzter Fokusgrund: %s'):format(tostring(s.lastFocusReason)))
    print(('Job:               %s (grade %s)'):format(tostring(job and job.name), tostring(job and job.grade)))
    print(('MenuType:          %s'):format(tostring(Config.MenuType)))
    print(('Interaction:       %s'):format(tostring(Config.Interaction)))
    print(('ClothingSystem:    %s'):format(tostring(Config.ClothingSystem)))
    print(('Notify:            %s'):format(tostring(Config.Notify)))
    print(('ESX geladen:       %s'):format(tostring(s.esx ~= nil)))
    print(('ox_lib:            %s'):format(tostring(lib ~= nil)))
    print('^2=====================================^7')
end

-- Debug an/aus schalten: /outfitdebug [on|off|hud|status]
RegisterCommand('outfitdebug', function(_, args)
    local s = JobOutfit.State
    local mode = (args[1] or 'toggle'):lower()

    if mode == 'on' then
        s.debugEnabled = true
        print('^2[job_outfit] Debug EIN^7')
    elseif mode == 'off' then
        s.debugEnabled = false
        s.debugHud = false
        print('^1[job_outfit] Debug AUS^7')
    elseif mode == 'hud' then
        s.debugEnabled = true
        s.debugHud = not s.debugHud
        print(('^3[job_outfit] Debug-HUD: %s^7'):format(s.debugHud and 'EIN' or 'AUS'))
    elseif mode == 'status' then
        DumpStatus()
    else
        s.debugEnabled = not JobOutfit.IsDebug()
        print(('^3[job_outfit] Debug: %s^7'):format(JobOutfit.IsDebug() and 'EIN' or 'AUS'))
    end
end, false)

-- Schnell-Status: /outfitstatus
RegisterCommand('outfitstatus', function()
    DumpStatus()
end, false)

-- On-Screen-HUD: zeigt Live-Fokusstatus, damit man Stuck-Zustände sofort sieht.
CreateThread(function()
    local s = JobOutfit.State
    while true do
        if s.debugHud then
            Wait(0)
            local raw = IsNuiFocused()
            local actual = (raw == true) or (raw == 1)
            local mismatch = (actual ~= s.desiredFocus)
            local lines = {
                '~y~[job_outfit DEBUG]~s~',
                ('desiredFocus: %s'):format(s.desiredFocus and '~g~true~s~' or '~r~false~s~'),
                ('IsNuiFocused: %s'):format(actual and '~g~true~s~' or '~r~false~s~'),
                ('mismatch: %s'):format(mismatch and '~r~JA~s~' or '~g~nein~s~'),
                ('outfitMenuOpen: %s'):format(tostring(s.outfitMenuOpen)),
                ('adminMenuOpen: %s'):format(tostring(s.adminMenuOpen)),
                ('letzter Grund: %s'):format(tostring(s.lastFocusReason)),
            }

            for i, text in ipairs(lines) do
                SetTextFont(4)
                SetTextScale(0.34, 0.34)
                SetTextColour(255, 255, 255, 220)
                SetTextOutline()
                SetTextEntry('STRING')
                AddTextComponentString(text)
                DrawText(0.015, 0.30 + (i - 1) * 0.022)
            end
        else
            Wait(500)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    JobOutfit.CloseAllNui()

    local s = JobOutfit.State
    if s.isWearingJobOutfit and s.savedCivilianSkin then
        JobOutfit.Clothing.RestoreCivilian()
    end

    JobOutfit.Peds.DeleteAll()
end)

-- Diagnose: Ressourcenname beim Start ausgeben. Muss EXAKT mit dem
-- 'resourceName' aus der NUI-Konsole übereinstimmen, sonst erreichen die
-- fetch()-Aufrufe (RegisterNUICallback) den Client nie.
CreateThread(function()
    print(('^2[job_outfit] Client geladen. GetCurrentResourceName() = "%s"^7'):format(GetCurrentResourceName()))
    print('^2[job_outfit] NUI-Callbacks registriert: close, selectOutfit, restoreClothes, admin:save, admin:close, admin:getPosition, admin:outfits:*^7')
end)

-- Test-Callback zum Prüfen der JS->Lua-Brücke (per NUI aufrufbar).
RegisterNUICallback('debug:ping', function(_, cb)
    print('^2[job_outfit] debug:ping empfangen! JS->Lua fetch FUNKTIONIERT.^7')
    cb('pong')
end)
