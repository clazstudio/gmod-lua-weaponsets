if WeaponSets.Debug then
    function WeaponSets.D(...)
        print( "[WeaponSets] D", ...)
    end
else
    function WeaponSets.D() end
end
function WeaponSets.Print(...)
    print("[WeaponSets]", ...)
end

WeaponSets.Options = {}
WeaponSets._optionsOrder = {}

function WeaponSets:AddOption(key, tbl)
    if (self.Options[key] ~= nil) then
        table.RemoveByValue(WeaponSets._optionsOrder, key)
    end
    self.Options[key] = tbl

    return table.insert(self._optionsOrder, key)
end

--[[--
    Validates given weaponset values
]]
-- TODO: think about validation messages localization and with parameters?
function WeaponSets:Validate(set)
    if not istable(set) then
        return false
    end
    -- FIXME: ??? add order property to SetOption and use SortedPairsByMemberValue instead this?
    for _, key in ipairs(self._optionsOrder) do
        local value = set[key]
        if value == nil then
            continue
        end
        local option = self.Options[key]
        if isfunction(option.validate) then
            local valid, err = option.validate(value, option, set)
            if not valid then
                self.D("Validate FAIL at key: ", key, value, err)
                return false, key, err
            end
        end
    end
    return true
end

-- TODO: complete sanitize and make validation more strict
-- TODO: remove strip functions wqith hard-coded values???
-- TODO: use function for default value?
-- TODO: add options to control prev set undoing before giving new set. Also undo all sets in death hook
-- TODO: weapon, model, material... entries types
-- TODO: use slider or something else for "number" entryType

--[[ WeaponSets:AddOption("example", {
    default = "Default value",
    category = "other", -- "weapons", "player", "movement"... nil for "other" category
    entryType = "string", -- string, bool, number, combobox, color...
    -- Entry options: alpha, min, max, precision, values...
    validate = function(value, option, set) end,
    sanitize = function(value, option, set) end,
    equip = function(ply, value, midGame, set, option) end,
    strip = function(ply, value, set, option) end,
    getFromPlayer = function(ply) end
}) ]]

-- Weapons category --

WeaponSets:AddOption("stripweapons", {
    default = false,
    entryType = "bool",
    category = "weapons",
    validate = isbool,
    sanitize = tobool,
    equip = function(ply, value)
        if (value) then
            ply:StripWeapons()
        end
    end
})
WeaponSets:AddOption("stripammo", {
    default = false,
    entryType = "bool",
    category = "weapons",
    validate = isbool,
    sanitize = tobool,
    equip = function(ply, value)
        if (value) then
            ply:StripAmmo()
        end
    end
})
WeaponSets:AddOption("infiniteammo", {
    default = false,
    entryType = "bool",
    category = "weapons",
    validate = isbool,
    sanitize = tobool,
    equip = function(ply, value)
        ply.wsInfiniteAmmo = value
        -- TODO: implement infinite ammo
    end,
    strip = function(ply)
        ply.wsInfiniteAmmo = nil
    end,
    getFromPlayer = function(ply)
        return ply.wsInfiniteAmmo
    end
})
WeaponSets:AddOption("givewithoutammo", {
    default = false,
    entryType = "bool",
    category = "weapons",
    validate = isbool,
    sanitize = tobool,
    equip = function() end
})
WeaponSets:AddOption("dropweapons", {
    default = false,
    entryType = "bool",
    category = "weapons",
    validate = isbool,
    sanitize = tobool,
    equip = function(ply, value)
        ply:ShouldDropWeapon(value)
    end,
    getFromPlayer = function(ply)
        return ply.DropWeaponOnDie
    end
})
WeaponSets:AddOption("set", {
    default = {},
    validate = function(value)
        if not istable(value) then
            return false, "not table"
        end
        for name, count in pairs(value) do
            if not isstring(name) or not isnumber(count) then
                return false, "wrong keyvalues"
            end
            -- check ammo?
        end
        return true
    end,
    sanitize = function(value)
        if not istable(value) then
            return {}
        end
        local tbl = {}
        for k, v in pairs(value) do
            local name = tostring(k)
            local count = tonumber(v)
            if name == nil or count == nil then
                continue
            end
            if count < -1 then
                count = -1
            end
            tbl[name] = math.floor(count)
        end
        return tbl
    end,
    equip = function(ply, value, midGame, set)
        local weps = 0
        for name, count in pairs(value) do
            if count > 0 then
                ply:GiveAmmo(count, name, not midGame)
            elseif count == -1 then
                ply:Give(name, set.givewithoutammo)
                weps = weps + 1
            end
        end
        if weps ~= 0 and set.defaultweapon == nil then
            ply:SwitchToDefaultWeapon()
        end
    end,
    strip = function(ply, value)
        for name, count in pairs(value) do
            if count > 0 then
                ply:RemoveAmmo(math.min(ply:GetAmmoCount(name), count), name)
            elseif count == -1 then
                ply:StripWeapon(name)
            end
        end
    end,
    getFromPlayer = function(ply)
        local set = {}
        for _, wep in ipairs(ply:GetWeapons()) do
            if IsValid(wep) then
                set[wep:GetClass()] = -1
            end
        end
        for id, count in pairs(ply:GetAmmo()) do
            set[game.GetAmmoName(id)] = count
        end
        return set
    end
})
WeaponSets:AddOption("defaultweapon", {
    default = "weapon_physgun",
    entryType = "string",
    category = "weapons",
    validate = function(x, _, set)
        return isstring(x) and set.set[x] == -1
    end,
    sanitize = tostring,
    equip = function(ply, value)
        if ply:HasWeapon(value) then
            ply:SelectWeapon(value)
        else
            ply:SwitchToDefaultWeapon()
        end
    end,
    strip = function(ply)
        ply:SwitchToDefaultWeapon()
    end,
    getFromPlayer = function(ply)
        local wep = ply:GetActiveWeapon()
        return IsValid(wep) and wep:GetClass() or nil
    end
})

-- Player model category --

WeaponSets:AddOption("model", {
    default = "", -- nil or "" to use convar
    entryType = "string",
    category = "player",
    validate = function(value)
        return isstring(value) and util.IsValidModel(value)
    end,
    sanitize = function(x)
        return tostring(x) or ""
    end,
    equip = function(ply, value)
        ply:SetModel(value)
        ply:PhysicsInit(SOLID_VPHYSICS)
    end,
    getFromPlayer = function(ply)
        return ply:GetModel()
    end
})
WeaponSets:AddOption("material", {
    default = "", -- "" to reset
    entryType = "string",
    category = "player",
    validate = function(value)
        return isstring(value)
    end,
    sanitize = function(x)
        return tostring(x) or ""
    end,
    equip = function(ply, value)
        ply:SetMaterial(value, true) -- force
    end,
    strip = function(ply)
        ply:SetMaterial("")
    end,
    getFromPlayer = function(ply)
        return ply:GetMaterial()
    end
})
local function isColPart(col)
    return isnumber(col) and col >= 0 and col <= 255
end
local function isColor(x)
    return IsColor(x) or (isColPart(x.r) and isColPart(x.g) and isColPart(x.b) and isColPart(x.a))
end
local function toColor(x)
    return istable(x) and Color(x.r, x.red, x.g or x.green, x.b or x.blue, x.a or x.aplha or 255) or nil
end
WeaponSets:AddOption("color", {
    default = Color(255, 255, 255, 255),
    entryType = "color",
    category = "player",
    alpha = true,
    validate = isColor,
    sanitize = toColor,
    equip = function(ply, col)
        if col.a ~= 255 then
            ply:SetRenderMode(RENDERMODE_TRANSALPHA)
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) then
                wep:SetRenderMode(RENDERMODE_TRANSALPHA)
            end
        end
        ply:SetColor(col)
    end,
    strip = function(ply)
        ply:SetColor(Color(255, 255, 255, 255))
    end,
    getFromPlayer = function(ply)
        local col = ply:GetColor()
        return Color(col.r, col.g, col.b, col.a)
    end
})
WeaponSets:AddOption("teamcolor", {
    default = Color(255, 255, 255),
    entryType = "color",
    category = "player",
    alpha = false,
    validate = isColor,
    sanitize = toColor,
    equip = function(ply, col)
        ply:SetPlayerColor(Vector(col.r / 255, col.g / 255, col.b / 255))
    end,
    strip = function(ply)
        local arr = string.Explode(" ", ply:GetInfo("cl_playercolor") or "")
        if (#arr == 3) then
            ply:SetPlayerColor(Vector(tonumber(arr[1]) or 0, tonumber(arr[2]) or 0, tonumber(arr[3]) or 0))
        end
    end,
    getFromPlayer = function(ply)
        local col = ply:GetPlayerColor()
        return Color(math.Round(col.r * 255), math.Round(col.g * 255), math.Round(col.b * 255))
    end
})
WeaponSets:AddOption("weaponcolor", {
    default = Color(255, 255, 255),
    entryType = "color",
    category = "player",
    alpha = false,
    validate = isColor,
    sanitize = toColor,
    equip = function(ply, col)
        ply:SetWeaponColor(Vector(col.r / 255, col.g / 255, col.b / 255))
    end,
    strip = function(ply)
        local arr = string.Explode(" ", ply:GetInfo("cl_weaponcolor") or "")
        if (#arr == 3) then
            ply:SetWeaponColor(Vector(tonumber(arr[1]) or 0, tonumber(arr[2]) or 0, tonumber(arr[3]) or 0))
        end
    end,
    getFromPlayer = function(ply)
        local col = ply:GetWeaponColor()
        return Color(math.Round(col.r * 255), math.Round(col.g * 255), math.Round(col.b * 255))
    end
})
WeaponSets:AddOption("blood", {
    default = BLOOD_COLOR_RED,
    entryType = "combobox",
    category = "player",
    values = { -1, 0, 1, 2, 3, 4, 5, 6 },
    validate = function(x)
        return isnumber(x) and math.floor(x) == x and x >= -1 and x <= 6
    end,
    sanitize = function(x)
        return math.Clamp(math.Round(tonumber(x) or 0), -1, 6)
    end,
    equip = function(ply, value)
        ply:SetBloodColor(value)
    end,
    strip = function(ply)
        ply:SetBloodColor(BLOOD_COLOR_RED)
    end,
    getFromPlayer = function(ply)
        return ply:GetBloodColor()
    end
})

-- Movement category --

-- TODO: somehow control new gmod_suit convar for each player?
WeaponSets:AddOption("removesuit", {
    default = false,
    entryType = "bool",
    -- category = "movement",
    validate = isbool,
    sanitize = tobool,
    equip = function(ply, value)
        if value then
            ply:RemoveSuit()
        else
            ply:EquipSuit()
        end
    end,
    strip = function(ply, value)
        if value then
            ply:EquipSuit()
        else
            ply:RemoveSuit()
        end
    end
})
WeaponSets:AddOption("jump", {
    default = 200,
    entryType = "number",
    category = "movement",
    min = 0,
    max = 1000,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetJumpPower(value)
    end,
    strip = function(ply, value)
        ply:SetJumpPower(200)
    end,
    getFromPlayer = function(ply)
        return ply:GetJumpPower()
    end
})
WeaponSets:AddOption("stepsize", {
    default = 18,
    entryType = "number",
    category = "movement",
    min = 0,
    max = 1000,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetStepSize(value)
    end,
    strip = function(ply, value)
        ply:SetStepSize(18)
    end,
    getFromPlayer = function(ply)
        return ply:GetStepSize()
    end
})
WeaponSets:AddOption("gravity", {
    default = 1.0,
    entryType = "number",
    category = "movement",
    min = -1.0,
    max = 10.0,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetGravity(value)
    end,
    strip = function(ply, value)
        ply:SetGravity(1.0)
    end,
    getFromPlayer = function(ply)
        return ply:GetGravity()
    end
})
WeaponSets:AddOption("mass", {
    default = 85,
    entryType = "number",
    category = "movement",
    min = 0.01,
    max = 1000,
    validate = isnumber,
    equip = function(ply, value)
        local phys = ply:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(value)
        end
    end,
    strip = function(ply, value)
        local phys = ply:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMass(85)
        end
    end,
    getFromPlayer = function(ply)
        local phys = ply:GetPhysicsObject()
        return IsValid(phys) and phys:GetMass() or nil
    end
})
WeaponSets:AddOption("friction", {
    default = 1.0,
    entryType = "number",
    category = "movement",
    min = -1.0,
    max = 10.0,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetFriction(value)
        -- TODO: try MOVETYPE_STEP
    end,
    strip = function(ply, value)
        ply:SetFriction(1.0)
    end,
    getFromPlayer = function(ply)
        return ply:GetFriction()
    end
})
WeaponSets:AddOption("timescale", {
    default = 1.0,
    entryType = "number",
    category = "movement",
    min = 0.01,
    max = 1000,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetLaggedMovementValue(value)
    end,
    strip = function(ply, value)
        ply:SetLaggedMovementValue(1)
    end,
    getFromPlayer = function(ply)
        return ply:GetLaggedMovementValue()
    end
})
WeaponSets:AddOption("enablewalk", {
    default = true,
    entryType = "bool",
    category = "movement",
    validate = isbool,
    sanitize = tobool,
    equip = function(ply, value)
        ply:SetCanWalk(value)
    end,
    getFromPlayer = function(ply)
        return ply:GetCanWalk()
    end
})
WeaponSets:AddOption("normalspeed", {
    default = 1.0,
    entryType = "number",
    category = "movement",
    min = 1,
    max = 1000000,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetWalkSpeed(value)
    end,
    getFromPlayer = function(ply)
        return ply:GetWalkSpeed()
    end
})
WeaponSets:AddOption("runspeed", {
    default = 1.0,
    entryType = "number",
    category = "movement",
    min = 1,
    max = 1000000,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetRunSpeed(value)
    end,
    getFromPlayer = function(ply)
        return ply:GetRunSpeed()
    end
})
WeaponSets:AddOption("crouchspeed", {
    default = 0.3,
    entryType = "number",
    category = "movement",
    min = 0,
    max = 1,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetCrouchedWalkSpeed(value)
    end,
    getFromPlayer = function(ply)
        return ply:GetCrouchedWalkSpeed()
    end
})
WeaponSets:AddOption("duckspeed", {
    default = 0.3,
    entryType = "number",
    category = "movement",
    min = 0,
    max = 1,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetDuckSpeed(value)
    end,
    getFromPlayer = function(ply)
        return ply:GetDuckSpeed()
    end
})
WeaponSets:AddOption("unduckspeed", {
    default = 0.3,
    entryType = "number",
    category = "movement",
    min = 0,
    max = 1,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetUnDuckSpeed(value)
    end,
    getFromPlayer = function(ply)
        -- TODO: try: getFromPlayer = Player.GetUnDuckSpeed ?
        return ply:GetUnDuckSpeed()
    end
})
-- TODO: allowDuck???

-- Other category --

WeaponSets:AddOption("allowflashlight", {
    default = true,
    entryType = "bool",
    validate = isbool,
    sanitize = tobool,
    equip = function(ply, value)
        ply:AllowFlashlight(ply)
        if (not value and ply:FlashlightIsOn()) then
            ply:Flashlight(false)
        end
    end,
    strip = function(ply, value)
        ply:AllowFlashlight(true)
    end,
    getFromPlayer = function(ply)
        return ply:CanUseFlashlight()
    end
})
WeaponSets:AddOption("allowzoom", {
    default = true,
    entryType = "bool",
    validate = isbool,
    sanitize = tobool,
    equip = function(ply, value)
        ply:SetCanZoom(ply)
        if (not value and ply:GetCanZoom()) then
            ply:StopZooming()
        end
    end,
    strip = function(ply, value)
        ply:SetCanZoom(true)
    end,
    getFromPlayer = function(ply)
        return ply:GetCanZoom()
    end
})
WeaponSets:AddOption("fov", {
    default = 0, -- 0 to use default
    entryType = "number",
    min = 0,
    max = 360,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetFOV(value, 1.0)
    end,
    strip = function(ply, value)
        ply:SetFOV(0, 1.0)
    end,
    getFromPlayer = function(ply)
        return ply:GetFOV()
    end
})
WeaponSets:AddOption("godmode", {
    default = false,
    entryType = "bool",
    validate = isbool,
    sanitize = tobool,
    equip = function(ply, value)
        if value then
            ply:GodEnable()
        else
            ply:GodDisable()
        end
    end,
    strip = function(ply, value)
        if value then
            ply:GodDisable()
        else
            ply:GodEnable()
        end
    end,
    getFromPlayer = function(ply)
        return ply:HasGodMode()
    end
})
WeaponSets:AddOption("health", {
    default = 100,
    entryType = "number",
    min = 0,
    max = 1000000,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetHealth(value)
    end,
    strip = function(ply, value)
        ply:SetHealth(100)
    end,
    getFromPlayer = function(ply)
        return ply:Health()
    end
})
WeaponSets:AddOption("maxhealth", {
    default = 100,
    entryType = "number",
    min = 0,
    max = 1000000,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetHealth(value)
    end,
    strip = function(ply, value)
        ply:SetHealth(100)
    end,
    getFromPlayer = function(ply)
        return ply:Health()
    end
})
WeaponSets:AddOption("armor", {
    default = 25,
    entryType = "number",
    min = 0,
    max = 255,
    validate = isnumber,
    sanitize = tonumber,
    equip = function(ply, value)
        ply:SetArmor(value)
    end,
    strip = function(ply, value)
        ply:SetArmor(0)
    end,
    getFromPlayer = function(ply)
        return ply:Armor()
    end
})
-- TODO: allow pickup: props, ammo, weapons