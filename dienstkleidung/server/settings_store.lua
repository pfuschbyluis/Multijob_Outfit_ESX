-- ============================================================
-- settings_store.lua – Namespace, settings.json, Sanitizer
-- ============================================================
-- Zwei getrennte Speicherorte:
--
--   1) settings.json (im Ressourcen-Ordner): NUR für allgemeine/statische
--      Einstellungen (Debug, Notify*, Interaction, MenuType,
--      ClothingSystem, EnableRestoreClothes/Label, PedSettings,
--      KeyInteract, Target). Overrides werden gegen die config.lua-Werte
--      sanitisiert.
--
--   2) MySQL-Datenbank (über oxmysql, siehe database.lua): Jobs
--      (AllowedJobs), Outfit-Peds (JobPeds) und Outfits (Kleidung) sind
--      vollständig datenbankgestützt.
--
-- Alle Server-Dateien hängen ihre Funktionen an den globalen Namespace
-- `JobOutfitServer` an (Ladereihenfolge steht in fxmanifest.lua).

JobOutfitServer = JobOutfitServer or {}
JobOutfitServer.Cache = { Jobs = {}, Peds = {}, Outfits = {}, ValidJobs = {} }

local NS = JobOutfitServer

NS.SETTINGS_FILE = 'settings.json'
NS.ADMIN_ACE = 'job_outfit.admin'

-- Nur die allgemeinen/statischen Felder laufen über settings.json.
-- AllowedJobs, JobPeds und Outfits laufen über die Datenbank.
NS.ADMIN_FIELDS = {
    'Debug', 'Notify', 'NotifyTitle', 'NotifyDuration', 'NotifyPosition',
    'Interaction', 'MenuType', 'ClothingSystem',
    'EnableRestoreClothes', 'RestoreClothesLabel', 'EnableUiAnimations',
    'AdminColor', 'JobColors',
    'PedSettings', 'KeyInteract', 'Target'
}

NS.ENUMS = {
    Notify = { standard = true, esx = true, ox_lib = true, okok = true, mythic = true, codem = true, qs = true },
    NotifyPosition = {
        ['top-right'] = true, ['top-left'] = true, ['top-center'] = true,
        ['bottom-right'] = true, ['bottom-left'] = true, ['bottom-center'] = true
    },
    Interaction = { key = true, ox_target = true },
    MenuType = { custom = true, ox_lib = true },
    ClothingSystem = { skinchanger = true, native = true }
}

-- ------------------------------------------------------------
-- Generische Sanitizer-Bausteine
-- ------------------------------------------------------------

function NS.DeepCopy(value)
    if type(value) ~= 'table' then return value end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = NS.DeepCopy(v)
    end
    return copy
end

function NS.IsSafeJobKey(key)
    return type(key) == 'string' and key:match('^[%w_%-]+$') ~= nil
end

function NS.SanitizeBool(v, fallback)
    if type(v) == 'boolean' then return v end
    if v == 1 or v == '1' or v == 'true' then return true end
    if v == 0 or v == '0' or v == 'false' then return false end
    return fallback
end

-- oxmysql liefert TINYINT(1) je nach Treiber/Build als Zahl oder Boolean.
function NS.FromDBBool(v)
    if v == true or v == 1 or v == '1' then return true end
    return false
end

function NS.SanitizeString(v, fallback)
    if type(v) == 'string' and v ~= '' then return v end
    return fallback
end

function NS.SanitizeNumber(v, fallback)
    local n = tonumber(v)
    if n ~= nil then return n end
    return fallback
end

function NS.SanitizeEnum(field, v, fallback)
    if type(v) == 'string' and NS.ENUMS[field] and NS.ENUMS[field][v] then return v end
    return fallback
end

-- Akzeptiert nur echte Hex-Farben (#rgb oder #rrggbb).
function NS.SanitizeHexColor(v, fallback)
    if type(v) == 'string' and (v:match('^#%x%x%x$') or v:match('^#%x%x%x%x%x%x$')) then
        return v
    end
    return fallback
end

-- Map jobKey -> Hex-Farbe. Ungültige Einträge fallen weg.
function NS.SanitizeJobColors(v, fallback)
    if type(v) ~= 'table' then return fallback end
    local out = {}
    for jobName, color in pairs(v) do
        if NS.IsSafeJobKey(jobName) then
            local hex = NS.SanitizeHexColor(color, nil)
            if hex then out[jobName] = hex end
        end
    end
    return out
end

function NS.SanitizeCoords(v, fallbackCoords)
    if type(v) ~= 'table' then return fallbackCoords end
    local x, y, z = tonumber(v.x), tonumber(v.y), tonumber(v.z)
    if not x or not y or not z then return fallbackCoords end
    return { x = x, y = y, z = z, w = tonumber(v.w) or 0.0 }
end

function NS.SanitizePedSettings(v, fallback)
    if type(v) ~= 'table' then return fallback end

    local displayMode = 'peds'
    if v.displayMode == 'markers' or v.displayMode == 'peds' then
        displayMode = v.displayMode
    elseif v.showMarker == true then
        displayMode = 'markers'
    end

    return {
        freeze = NS.SanitizeBool(v.freeze, fallback and fallback.freeze),
        invincible = NS.SanitizeBool(v.invincible, fallback and fallback.invincible),
        blockEvents = NS.SanitizeBool(v.blockEvents, fallback and fallback.blockEvents),
        displayMode = displayMode,
        showBlip = NS.SanitizeBool(v.showBlip, fallback and fallback.showBlip),
        markerDrawDistance = NS.SanitizeNumber(v.markerDrawDistance, fallback and fallback.markerDrawDistance)
    }
end

function NS.SanitizeKeyInteract(v, fallback)
    if type(v) ~= 'table' then return fallback end
    return {
        distance = NS.SanitizeNumber(v.distance, fallback and fallback.distance),
        drawDistance = NS.SanitizeNumber(v.drawDistance, fallback and fallback.drawDistance),
        key = NS.SanitizeNumber(v.key, fallback and fallback.key),
        onlyShowForAllowedJobs = NS.SanitizeBool(v.onlyShowForAllowedJobs, fallback and fallback.onlyShowForAllowedJobs)
    }
end

function NS.SanitizeTarget(v, fallback)
    if type(v) ~= 'table' then return fallback end
    return {
        distance = NS.SanitizeNumber(v.distance, fallback and fallback.distance),
        icon = NS.SanitizeString(v.icon, fallback and fallback.icon),
        label = NS.SanitizeString(v.label, fallback and fallback.label)
    }
end

-- Prüft jedes Feld einzeln gegen den mitgegebenen Fallback (die echten
-- config.lua-Werte). Ein kaputtes/fremdes Feld fällt auf den Fallback
-- zurück statt das ganze System zu beeinflussen.
function NS.SanitizeOverrides(raw, base)
    local out = {}
    if type(raw) ~= 'table' then return out end

    if raw.Debug ~= nil then out.Debug = NS.SanitizeBool(raw.Debug, base.Debug) end
    if raw.Notify ~= nil then out.Notify = NS.SanitizeEnum('Notify', raw.Notify, base.Notify) end
    if raw.NotifyTitle ~= nil then out.NotifyTitle = NS.SanitizeString(raw.NotifyTitle, base.NotifyTitle) end
    if raw.NotifyDuration ~= nil then out.NotifyDuration = NS.SanitizeNumber(raw.NotifyDuration, base.NotifyDuration) end
    if raw.NotifyPosition ~= nil then out.NotifyPosition = NS.SanitizeEnum('NotifyPosition', raw.NotifyPosition, base.NotifyPosition) end
    if raw.Interaction ~= nil then out.Interaction = NS.SanitizeEnum('Interaction', raw.Interaction, base.Interaction) end
    if raw.MenuType ~= nil then out.MenuType = NS.SanitizeEnum('MenuType', raw.MenuType, base.MenuType) end
    if raw.ClothingSystem ~= nil then out.ClothingSystem = NS.SanitizeEnum('ClothingSystem', raw.ClothingSystem, base.ClothingSystem) end
    if raw.EnableRestoreClothes ~= nil then out.EnableRestoreClothes = NS.SanitizeBool(raw.EnableRestoreClothes, base.EnableRestoreClothes) end
    if raw.RestoreClothesLabel ~= nil then out.RestoreClothesLabel = NS.SanitizeString(raw.RestoreClothesLabel, base.RestoreClothesLabel) end
    if raw.EnableUiAnimations ~= nil then out.EnableUiAnimations = NS.SanitizeBool(raw.EnableUiAnimations, base.EnableUiAnimations) end
    if raw.AdminColor ~= nil then out.AdminColor = NS.SanitizeHexColor(raw.AdminColor, base.AdminColor) end
    if raw.JobColors ~= nil then out.JobColors = NS.SanitizeJobColors(raw.JobColors, base.JobColors) end
    if raw.PedSettings ~= nil then out.PedSettings = NS.SanitizePedSettings(raw.PedSettings, base.PedSettings) end
    if raw.KeyInteract ~= nil then out.KeyInteract = NS.SanitizeKeyInteract(raw.KeyInteract, base.KeyInteract) end
    if raw.Target ~= nil then out.Target = NS.SanitizeTarget(raw.Target, base.Target) end

    return out
end

-- ------------------------------------------------------------
-- settings.json Persistenz
-- ------------------------------------------------------------

function NS.LoadRawFile()
    local raw = LoadResourceFile(GetCurrentResourceName(), NS.SETTINGS_FILE)
    if not raw or raw == '' then return {} end

    local ok, data = pcall(json.decode, raw)
    if ok and type(data) == 'table' then
        return data
    end

    print(('[job_outfit] Konnte %s nicht lesen (ungültiges JSON), benutze Standardwerte aus config.lua'):format(NS.SETTINGS_FILE))
    return {}
end

function NS.SaveRawFile(data)
    local ok, encoded = pcall(json.encode, data, { indent = true })
    if not ok then
        print('[job_outfit] Einstellungen konnten nicht kodiert werden.')
        return false
    end

    local saved = SaveResourceFile(GetCurrentResourceName(), NS.SETTINGS_FILE, encoded, -1)
    if not saved then
        print(('[job_outfit] %s konnte nicht gespeichert werden.'):format(NS.SETTINGS_FILE))
        return false
    end

    return true
end

-- Echte config.lua-Werte, bevor irgendein Override angewendet wird. Dient
-- als sicherer Fallback für die Sanitisierung und für /outfitadmin_reset.
NS.Defaults = {}
for _, field in ipairs(NS.ADMIN_FIELDS) do
    NS.Defaults[field] = NS.DeepCopy(Config[field])
end

NS.Overrides = NS.SanitizeOverrides(NS.LoadRawFile(), NS.Defaults)

function NS.ApplyOverridesToConfig()
    for _, field in ipairs(NS.ADMIN_FIELDS) do
        if NS.Overrides[field] ~= nil then
            Config[field] = NS.DeepCopy(NS.Overrides[field])
        else
            Config[field] = NS.DeepCopy(NS.Defaults[field])
        end
    end
end

NS.ApplyOverridesToConfig()
