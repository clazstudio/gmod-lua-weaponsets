CreateConVar("weaponsets_loadoutset", "<default>", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Loadout weapon set for all players")
CreateConVar("weaponsets_deathmatch", "0", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

-- Net --

WeaponSets.Net[WeaponSets.Net.SendSets] = function (len)
    local sets = WeaponSets:NetReadTable()
    WeaponSets.Sets = sets or {}

    WeaponSets.D("Recieved sets: ")
    PrintTable(WeaponSets.Sets)
end

WeaponSets.Net[WeaponSets.Net.SendSet] = function (len)
    local values = WeaponSets:NetReadTable()

    WeaponSets.D("SET", net.ReadString())
    PrintTable(values or {})
end

WeaponSets.Net[WeaponSets.Net.Response] = function (len)
    WeaponSets.D("RESPONSE", len)
end

concommand.Add("weaponsets_retrieve", function (_, _, args)
    if #args == 0 then
        WeaponSets:StartNet(WeaponSets.Net.RetrieveSets)
        net.SendToServer()
    else
        WeaponSets:StartNet(WeaponSets.Net.RetrieveSet)
        net.WriteString(args[1])
        net.SendToServer()
    end
end)

local function autoComplete(cmd, args)
    if #args == 1 then
        local tbl = {}
        for id, _ in pairs(WeaponSets.Sets) do
            table.insert(tbl, cmd .. " " .. id .. " ")
        end
        return tbl
    end
end

concommand.Add("weaponsets", function(ply, _, args)
    if not IsValid(ply) or not WeaponSets:Access(ply, "edit") then
        WeaponSets.Print("Access denied")
        return false
    end

    if #args == 1 then
        WeaponSets:StartNet(WeaponSets.Net.RetrieveSet)
        net.WriteString(args[1])
        net.SendToServer()
    else
        -- TODO: open main GUI
    end
end, autoComplete, "Usage: weaponsets [<weaponSetId>]", flags)
