function WeaponSets:Give(ply, set, midGame)
    for _, key in ipairs(self._optionsOrder) do
        local value = set[key]
        if value == nil then continue end

        local option = self.Options[key]
        if isfunction(option.equip) then
            option.equip(ply, value, midGame, set, option)
        end
    end
end

function WeaponSets:Strip(ply, set)
    for _, key in ipairs(self._optionsOrder) do
        local value = set[key]
        if value == nil then continue end

        local option = self.Options[key]
        if isfunction(option.strip) then
            option.strip(ply, value, set, option)
        end
    end
end

function WeaponSets:FromPlayer(ply)
    local set = {}

    for key, option in pairs(self.Options) do
        if isfunction(option.getFromPlayer) then
            set[key] = option.getFromPlayer(ply)
        end
    end

    return set
end

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

-- Version --
function WeaponSets:Download()
    http.Fetch("http://pastebin.com/raw/" .. self.PasteBinSets, function(body, _, _, _)
        local tbl = util.JSONToTable(body)
        if tbl == nil then return false end

        for name, id in pairs(tbl) do
            http.Fetch("http://pastebin.com/raw/" .. id, function(json, _, _, _)
                local set = util.JSONToTable(json)
                if set == nil then return false end
                self:SaveToFile(name, set)
                print("[WeaponSets] Downloaded: " .. name)
            end)
        end
    end)
end

function WeaponSets:Upgrade()
    if file.Exists("weaponsets_version.txt", "DATA") then
        if file.Read("weaponsets_version.txt", "DATA") == tostring(self.Version) then
            return
        else
            -- Options -> Convars
            if file.Exists("weaponsets_options.txt", "DATA") then
                local options = util.JSONToTable(file.Read("weaponsets_options.txt", "DATA"))

                if options then
                    if options.loadoutset then
                        self.Convars["loadoutSet"]:SetString(options.loadoutset)
                    end

                    if options.onlyAdmin then
                        self.Convars["adminOnly"]:SetBool(tobool(options.onlyAdmin))
                    end
                end

                file.Delete("weaponsets_options.txt")
                print("[WeaponSets] Migration: Options -> Convars")
            end

            -- Validate all weapon sets
            local sets = self:GetList()

            for _, name in pairs(sets) do
                local tbl = self:LoadFromFile(name)
                self:SaveToFile(self:ValidateWeaponSet(name, tbl))
                print("[WeaponSets] Migration: " .. name)
            end
        end
    end

    timer.Simple(5, function()
        WEAPONSETS:Download()
    end)

    file.Write("weaponsets_version.txt", tostring(self.Version))
end

-- Hooks --

hook.Add("PlayerLoadout", "WeaponSets", function(ply)
    local result = ply:GiveWeaponSet()
    if result then return false end
end)

hook.Add("Initialize", "WeaponSets", function()
    WeaponSets.Sets = WeaponSets:ReadSets() or {}
    WeaponSets:ClearCache()
end)

hook.Add("Shutdown", "WeaponSets", function()
    if WeaponSets.Sets ~= nil then
        WeaponSets:WriteSets(WeaponSets.Sets)
    end
end)

hook.Add("PlayerInitialSpawn", "WeaponSets", function(ply)
    timer.Simple(5, function()
        WeaponSets:SendSets(ply)
    end)
end)

hook.Add("ShowTeam", "WeaponSets", function(ply)
    -- TODO
end)
