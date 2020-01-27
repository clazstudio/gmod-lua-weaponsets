local flags = FCVAR_CLIENTCMD_CAN_EXECUTE

-- TODO: add better help
-- TODO: add NPC give?

local function autoComplete(cmd, args)
    if #args == 1 then
        return table.GetKeys(WeaponSets.Sets)
    end
end

local function printPlayersTable()
    print("[UserID]    [Loadout set]         [Last given] [Nickname]")
    for _, ply in pairs(player.GetHumans()) do
        print(string.format("%4d %20s %20s %s", ply:UserID(), WeaponSets:GetLoadout(ply), ply.wsLastGiven or "N/A", ply:Nick()))
    end
end

local function sendPlayersTable(ply)
    local tbl = {}
    for _, v in pairs(player.GetHumans()) do
        table.insert(tbl, {
            userId = v:UserID(),
            steamId = v:SteamID(),
            loadout = WeaponSets:GetLoadout(ply),
            lastGiven = ply.wsLastGiven or "N/A",
            nick = ply:Nick()
        })
    end
    WeaponSets:StartNet(WeaponSets.Net.SendPlayers)
    WeaponSets:NetWriteTable(tbl)
    net.Send(ply)
end

concommand.Add("weaponsets", function(ply, _, args, _)
    if not WeaponSets:Access(ply, "edit") then return false end

    if not IsValid(ply) then
        if #args == 0 then
            WeaponSets.Print("Weapon sets:")
            PrintTable(WeaponSets.Sets or {})
        else
            WeaponSets.Print("Weapon set '" .. args[1] .. "':")
            PrintTable(WeaponSets:LoadSet(args[1]) or {})
        end
        return
    end

    -- TODO: override on client?
    if #args == 1 then
        WeaponSets:SendSet(ply, args[1])
    else
        WeaponSets:SendSets(ply)
    end
end, autoComplete, "Usage: weaponsets [<weaponSetId>]", flags)

concommand.Add("weaponsets_delete", function(ply, _, args, _)
    if not WeaponSets:Access(ply, "edit") then return false end
    if #args == 0 then return end

    for i = 1, #args do
        WeaponSets:DeleteSet(args[i])
    end

    WeaponSets:WriteSets(WeaponSets.Sets)
    WeaponSets:SendSets()
end, autoComplete, "Usage: weaponsets_delete <weaponSetId1> <weaponSetId2> ...", flags)

concommand.Add("weaponsets_rename", function(ply, _, args, _)
    if not WeaponSets:Access(ply, "edit") then return false end
    if #args ~= 2 then return end
    local id = WeaponSets:RenameSet(args[1], args[2])
    if id ~= args[1] then
        WeaponSets:WriteSets(WeaponSets.Sets)
    end
    WeaponSets:SendSets()
end, autoComplete, "Usage: weaponsets_rename <id> <newName>", flags)

concommand.Add("weaponsets_duplicate", function(ply, _, args, _)
    if not WeaponSets:Access(ply, "edit") then return false end
    if #args ~= 2 then return end
    WeaponSets:DuplicateSet(args[1], args[2])
    WeaponSets:WriteSets(WeaponSets.Sets)
    WeaponSets:SendSets()
end, autoComplete, "Usage: weaponsets_duplicate <id> <copyName>", flags)

concommand.Add("weaponsets_give", function(ply, _, args, _)
    if not WeaponSets:Access(ply, "give") then return false end

    if #args < 1 then
        if IsValid(ply) then
            sendPlayersTable(ply)
        else
            printPlayersTable()
        end

        return
    end

    local id = tostring(args[1])

    if #args < 2 then
        for _, target in pairs(player.GetAll()) do
            WeaponSets:GiveSet(target, id, true)
        end

        return
    end

    for i = 2, #args do
        local userId = tonumber(args[i])
        if not userId then continue end
        local target = Player(userId)

        if IsValid(target) then
            WeaponSets:GiveSet(target, id, true)
        end
    end
end, autoComplete, "Usage: weaponsets_give <weaponSetId> [userId1] [userId2] ...", flags)

concommand.Add("weaponsets_setloadout", function(ply, _, args, _)
    if not WeaponSets:Access(ply, "loadout") then return false end

    if #args < 1 then
        if IsValid(ply) then
            sendPlayersTable(ply)
        else
            printPlayersTable()
        end

        return
    end

    local id = tostring(args[1])

    if #args < 2 then
        for _, target in pairs(player.GetAll()) do
            WeaponSets:SetLoadoutSet(target, id)
        end

        return
    end

    for i = 2, #args do
        local userId = tonumber(args[i])

        if userId == nil then
            WeaponSets:SetLoadoutSet(args[i], id)
        else
            local target = Player(id)

            if IsValid(target) then
                WeaponSets:SetLoadoutSet(target, id)
            end
        end
    end
end, autoComplete, "Usage: weaponsets_setloadout <weaponSetId> [userId1/SteamId1] [userId2/SteamId2] ...", flags)

concommand.Add("weaponsets_select", function(ply, _, args, _)
    if not WeaponSets:Access(ply, "select") then return false end
    if #args < 1 then
        -- TODO: Open select window?
        return
    end
    -- TODO: Check usergroup
    WeaponSets:SetLoadoutSet(ply, args[1])
end, autoComplete, "Usage: weaponsets_select <weaponSetId>", flags)

concommand.Add("weaponsets_reload", function(ply, cmd, args)
    if not WeaponSets:Access(ply, "edit") then return end
    WeaponSets.Sets = WeaponSets:ReadSets()
    WeaponSets:ClearCache()
    collectgarbage("collect")
    WeaponSets:SendSets()
end, nil, nil, flags)

concommand.Add("weaponsets_save", function(ply, cmd, args)
    if not WeaponSets:Access(ply, "edit") then return end
    WeaponSets:WriteSets(WeaponSets.Sets)
end, nil, nil, flags)
