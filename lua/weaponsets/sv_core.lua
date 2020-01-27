--- Gives weaponset to the player
-- @param ply Given player
-- @param values table, weaponset to give
-- @param midGame boolean
function WeaponSets:Give(ply, values, midGame)
    for _, key in ipairs(self._optionsOrder) do
        local value = values[key]
        if value == nil then continue end

        local option = self.Options[key]
        if isfunction(option.equip) then
            option.equip(ply, value, midGame, values, option)
        end
    end
end

--- Strips weaponset from the player
-- @param ply Given player
-- @param values table, weaponset to strip
function WeaponSets:Strip(ply, set, midGame)
    for _, key in ipairs(self._optionsOrder) do
        local value = set[key]
        if value == nil then continue end

        local option = self.Options[key]
        if isfunction(option.strip) then
            option.strip(ply, value, midGame, set, option)
        end
    end
end

--- Generates weaponset values from the given player object
function WeaponSets:FromPlayer(ply)
    local set = {}

    for key, option in pairs(self.Options) do
        if isfunction(option.getFromPlayer) then
            set[key] = option.getFromPlayer(ply)
        end
    end

    return set
end

--- Generates PLAYER struct from a weaponset
function WeaponSets:PlayerClass(set, displayName)
    local PLAYER = {
        DisplayName = displayName,
        WeaponSet = set,
        --TeammateNoCollide = set.teamcollide,
        --AvoidPlayers = set.avoidplayers,
        WalkSpeed = set.normalspeed,
        RunSpeed = set.runspeed,
        CrouchedWalkSpeed = set.crouchspeed,
        DuckSpeed = set.duckspeed,
        UnDuckSpeed = set.unduckspeed,
        JumpPower = set.jump,
        CanUseFlashlight = set.allowflashlight,
        MaxHealth = set.maxhealth,
        StartHealth = set.health,
        StartArmor = set.armor,
        DropWeaponOnDie = set.dropweapons
    }

    function PLAYER:Loadout()
        WeaponSets:Give(self.Player, self.WeaponSet, false)
    end

    return PLAYER
end

-- Infinite ammo --

local function checkInfiniteAmmo(ply, wep)
    if not ply.wsInfiniteAmmo or not IsValid(wep) then
        return
    end

    local primaryAmmo = wep:GetPrimaryAmmoType()
    if primaryAmmo ~= -1 and ply.wsInfiniteAmmo ~= 2 then
        ply:SetAmmo(99, primaryAmmo)
    end

    local secondaryAmmo = wep:GetSecondaryAmmoType()
    if secondaryAmmo ~= -1 and isnumber(ply.wsInfiniteAmmo) and ply.wsInfiniteAmmo >= 2 then
        ply:SetAmmo(99, secondaryAmmo)
    end
end

timer.Create("wsInfiniteAmmo", 5, 0, function()
    for _, ply in pairs(player.GetHumans()) do
        checkInfiniteAmmo(ply, ply:GetActiveWeapon())
    end
end)

hook.Add("PlayerSwitchWeapon", "WeaponSets", function(ply, from, to)
    checkInfiniteAmmo(ply, to)
end)
