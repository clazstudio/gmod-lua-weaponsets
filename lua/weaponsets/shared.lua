--[[---------------------------------------------------------
    SHARED
-----------------------------------------------------------]]

-- Blood enums with description
WEAPONSETS.BloodEnums = {
    -- [-10] = "Don't change",
    [DONT_BLEED] = "No blood",
    [BLOOD_COLOR_RED] = "Normal red blood",
    [BLOOD_COLOR_YELLOW] = "Yellow blood",
    [BLOOD_COLOR_GREEN] = "Green blood",
    [BLOOD_COLOR_MECH] = "Sparks",
    [BLOOD_COLOR_ANTLION] = "Yellow (Antlion) blood",
    [BLOOD_COLOR_ZOMBIE] = "Zombie blood",
    [BLOOD_COLOR_ANTLION_WORKER] = "Bright green blood"
}

--[[---------------------------------------------------------
    Empty weapon set structure
----------------------------------------------------------]]
local emptySet = {
    stripweapons = false,
    stripammo = false,
    dropweapons = false,
    allowflashlight = true,
    health = -1,
    armor = -1,
    maxhealth = -1,
    jump = -1,
    gravity = 1,
    speed = 1,
    opacity = 255,
    blood = -10,
    friction = -1.0,
    scale = 1,
    set = {
        -- weapon_class = -1 or ammo_name = count
    }
}

-- TODO:
local _sets = {
    file_name = {
        name = "Pretty name",
        usergroup = "user",
    }
}

function WEAPONSETS:GetEmptySet()
    return table.Copy(emptySet)
end

-- Weapon set structure validation
local validateKeyFuncs = {
    stripweapons = tobool,
    stripammo = tobool,
    allowflashlight = tobool,
    dropweapons = tobool,
    health = tonumber,
    armor = tonumber,
    maxhealth = tonumber,
    jump = tonumber,
    gravity = tonumber,
    speed = tonumber,
    opacity = tonumber,
    blood = tonumber,
    friction = tonumber,
    scale = tonumber
}

function WEAPONSETS:ValidateWeaponSet(name, tbl)
    name = self:FormatFileName(name or "unnamed")
    local empty = self:GetEmptySet()
    if not tbl or not istable(tbl) then return name, empty end

    for k, v in pairs(empty) do
        if tbl[k] == nil then
            tbl[k] = v
        elseif validateKeyFuncs[k] then
            local valid = validateKeyFuncs[k](tbl[k])

            if valid == nil then
                tbl[k] = v
            else
                tbl[k] = valid
            end
        end
    end

    if not tbl.set or not istable(tbl.set) then
        tbl.set = {}
    end

    local set = {}

    for k, v in pairs(tbl.set) do
        local key = tostring(k)
        local val = tonumber(v) or -1
        if val <= 0 and game.GetAmmoID(key) ~= -1 then continue end
        set[key] = val
    end

    return name, tbl
end

-- Filename formatter
function WEAPONSETS:FormatFileName(text)
    text = string.Replace(string.lower(text), " ", "_")
    text = string.Replace(text, ".", "_")
    text = string.gsub(text, [[\\/:%*%?"<>,;'|]], "")

    if text == "" then
        text = "unnamed"
    end

    return text
end

--[[---------------------------------------------------------
    Resizes a player
-----------------------------------------------------------]]
function WEAPONSETS:SetPlayerSize(ply, scale)
    ply:SetViewOffset(Vector(0, 0, 64) * scale)
    ply:SetViewOffsetDucked(Vector(0, 0, 28) * scale)
    --ply:SetModelScale(scale, 0) -- Broken
    ply:ResetHull()

    if scale ~= 1 then
        local h_b, h_t = ply:GetHull()
        local d_b, d_t = ply:GetHullDuck()
        ply:SetHull(h_b * scale, h_t * scale)
        ply:SetHullDuck(d_b * scale, d_t * scale)
    end

    if SERVER then
        ply:SetStepSize(ply:GetStepSize() * scale)
        net.Start("wepsetsToCl")
        net.WriteString("applyNewScale")

        net.WriteTable({
            scale = scale,
            ply = ply:UserID()
        })

        net.Broadcast()
    end
end
