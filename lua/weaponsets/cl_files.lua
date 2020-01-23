
-- Net --

local WeaponSets = WeaponSets

WeaponSets.Net[WeaponSets.Net.SendSets] = function (len)
    local sets = WeaponSets:NetReadTable()
    WeaponSets.Sets = sets or {}
    PrintTable(WeaponSets.Sets)
end

WeaponSets.Net[WeaponSets.Net.SendSet] = function (len)
    print("SET", net.ReadString())
    local values = WeaponSets:NetReadTable()
    PrintTable(values or {})
end

WeaponSets.Net[WeaponSets.Net.Response] = function (len)
    print("RESPONSE", len)
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
