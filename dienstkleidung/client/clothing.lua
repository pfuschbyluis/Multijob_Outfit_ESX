-- ============================================================
-- clothing.lua – Kleidungs-Snapshots & Anziehen (native/skinchanger)
-- ============================================================

JobOutfit.Clothing = {}

local COMPONENT_SLOTS = {
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

local PROP_SLOTS = {
    helmet = 0,
    glasses = 1,
    ears = 2,
    watches = 6,
    bracelets = 7
}

local function GetClothingSystem()
    local system = tostring(Config.ClothingSystem or 'skinchanger'):lower()
    if system == 'esx_skin' then system = 'skinchanger' end
    return system
end

function JobOutfit.Clothing.UsesNative()
    return GetClothingSystem() == 'native'
end

function JobOutfit.Clothing.CaptureNative()
    local ped = PlayerPedId()
    local snapshot = { model = GetEntityModel(ped), components = {}, props = {} }

    for _, componentId in pairs(COMPONENT_SLOTS) do
        snapshot.components[componentId] = {
            drawable = GetPedDrawableVariation(ped, componentId),
            texture = GetPedTextureVariation(ped, componentId),
            palette = GetPedPaletteVariation(ped, componentId)
        }
    end

    for _, propId in pairs(PROP_SLOTS) do
        snapshot.props[propId] = {
            drawable = GetPedPropIndex(ped, propId),
            texture = GetPedPropTextureIndex(ped, propId)
        }
    end

    return snapshot
end

function JobOutfit.Clothing.RestoreNative(snapshot)
    if not snapshot then return false end
    local ped = PlayerPedId()

    if snapshot.model and snapshot.model ~= GetEntityModel(ped) then
        return false
    end

    for componentId, data in pairs(snapshot.components or {}) do
        SetPedComponentVariation(
            ped, tonumber(componentId),
            tonumber(data.drawable) or 0, tonumber(data.texture) or 0, tonumber(data.palette) or 0
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

function JobOutfit.Clothing.ApplyNative(clothes)
    if type(clothes) ~= 'table' then return false end
    local ped = PlayerPedId()

    for prefix, componentId in pairs(COMPONENT_SLOTS) do
        local drawable = clothes[prefix .. '_1']
        local texture = clothes[prefix .. '_2']

        if prefix == 'arms' and drawable == nil then
            drawable = clothes.arms
        end

        if drawable ~= nil then
            SetPedComponentVariation(ped, componentId, tonumber(drawable) or 0, tonumber(texture) or 0, 2)
        end
    end

    for prefix, propId in pairs(PROP_SLOTS) do
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

function JobOutfit.Clothing.SaveCurrent()
    local s = JobOutfit.State
    s.savedCivilianSkin = { native = JobOutfit.Clothing.CaptureNative(), skinchanger = nil }

    if JobOutfit.Clothing.UsesNative() then return end

    TriggerEvent('skinchanger:getSkin', function(skin)
        if type(s.savedCivilianSkin) ~= 'table' then s.savedCivilianSkin = {} end
        s.savedCivilianSkin.skinchanger = skin
    end)
end

function JobOutfit.Clothing.RestoreCivilian()
    local s = JobOutfit.State

    if not s.savedCivilianSkin then
        JobOutfit.Notify('Es wurde noch keine vorherige Kleidung gespeichert.', 'error')
        return
    end

    if JobOutfit.Clothing.UsesNative() then
        if JobOutfit.Clothing.RestoreNative(s.savedCivilianSkin.native) then
            s.isWearingJobOutfit = false
            s.currentAppliedOutfit = nil
            JobOutfit.Notify('Normale Kleidung wurde wieder angezogen.', 'success')
        else
            JobOutfit.Notify('Normale Kleidung konnte nicht wiederhergestellt werden.', 'error')
        end
        return
    end

    if s.savedCivilianSkin.skinchanger then
        TriggerEvent('skinchanger:loadSkin', s.savedCivilianSkin.skinchanger)
        s.isWearingJobOutfit = false
        s.currentAppliedOutfit = nil
        JobOutfit.Notify('Normale Kleidung wurde wieder angezogen.', 'success')
        return
    end

    if JobOutfit.Clothing.RestoreNative(s.savedCivilianSkin.native) then
        s.isWearingJobOutfit = false
        s.currentAppliedOutfit = nil
        JobOutfit.Notify('Normale Kleidung wurde wieder angezogen.', 'success')
    else
        JobOutfit.Notify('Normale Kleidung konnte nicht wiederhergestellt werden.', 'error')
    end
end

function JobOutfit.Clothing.ApplyOutfit(outfit)
    local s = JobOutfit.State

    if s.currentAppliedOutfit == outfit then
        JobOutfit.Notify('Dieses Kleidungsstück tragen Sie bereits.', 'info')
        return
    end

    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    local clothes

    if model == joaat('mp_m_freemode_01') then
        clothes = outfit.male
    elseif model == joaat('mp_f_freemode_01') then
        clothes = outfit.female
    else
        JobOutfit.Notify('Dieses Ped-Modell wird nicht unterstützt.', 'error')
        return
    end

    if type(clothes) ~= 'table' then
        JobOutfit.Notify('Für dieses Geschlecht ist kein Outfit hinterlegt.', 'error')
        return
    end

    if not next(clothes) then
        JobOutfit.Notify('Für dieses Outfit sind noch keine Kleidungsdaten hinterlegt (Konfiguration unvollständig).', 'error')
        return
    end

    if not s.isWearingJobOutfit then
        JobOutfit.Clothing.SaveCurrent()
    end

    if JobOutfit.Clothing.UsesNative() then
        if JobOutfit.Clothing.ApplyNative(clothes) then
            s.isWearingJobOutfit = true
            s.currentAppliedOutfit = outfit
            JobOutfit.Notify('Outfit angezogen: ' .. outfit.label, 'success')
        else
            JobOutfit.Notify('Outfit konnte nicht angezogen werden.', 'error')
        end
        return
    end

    TriggerEvent('skinchanger:getSkin', function(skin)
        if not s.savedCivilianSkin then
            s.savedCivilianSkin = { native = JobOutfit.Clothing.CaptureNative(), skinchanger = skin }
        elseif not s.savedCivilianSkin.skinchanger then
            s.savedCivilianSkin.skinchanger = skin
        end

        TriggerEvent('skinchanger:loadClothes', skin, clothes)
        s.isWearingJobOutfit = true
        s.currentAppliedOutfit = outfit
        JobOutfit.Notify('Outfit angezogen: ' .. outfit.label, 'success')
    end)
end
