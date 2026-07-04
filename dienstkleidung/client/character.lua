-- ============================================================
-- character.lua – Charakterwechsel & Logout
-- ============================================================

local function ResetSessionState()
    local s = JobOutfit.State
    s.savedCivilianSkin = nil
    s.isWearingJobOutfit = false
    s.currentAppliedOutfit = nil
    s.currentMenuOutfits = {}
    s.characterLoadToken = s.characterLoadToken + 1
end

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    local s = JobOutfit.State
    local esx = s.esx

    s.playerData = xPlayer or (esx and esx.GetPlayerData and esx.GetPlayerData() or {}) or {}
    ResetSessionState()

    if Config.CloseMenuOnCharacterLoad ~= false then
        JobOutfit.CloseAllNui()
    end
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    local s = JobOutfit.State
    s.playerData = {}
    ResetSessionState()

    if Config.CloseMenuOnCharacterLoad ~= false then
        JobOutfit.CloseAllNui()
    end

    if Config.DeletePedsOnLogout then
        JobOutfit.Peds.DeleteAll()
    end
end)
