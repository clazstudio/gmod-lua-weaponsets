local flags = FCVAR_CLIENTCMD_CAN_EXECUTE

local getPlayerByUserID = Player
if not isfunction(getPlayerByUserID) then
    getPlayerByUserID = function()
        return nil
    end
    ErrorNoHalt("[WeaponSets] Global Player() is not a function! Try to disable all other addons.")
end

--[[---------------------------------------------------------
    SERVER - commands.lua
-----------------------------------------------------------]]
-- "weaponsets" concommand
concommand.Add("weaponsets", function(ply, _, args, _)
    if not WEAPONSETS:Access(ply) then return false end

    if #args == 1 and IsValid(ply) then
        local name = tostring(args[1])
        local tbl = WEAPONSETS:LoadFromFile(name)
        net.Start("wepsetsToCl")
        net.WriteString("openEditMenu")

        net.WriteTable({
            name = WEAPONSETS:FormatFileName(name),
            tbl = tbl
        })

        net.Send(ply)
    else
        local str = table.concat(WEAPONSETS:GetList(), ", ")
        print("Weapon sets: " .. str)
    end
end, _, "Usage: weaponsets <weaponSetName>", flags)

-- "delete" concommand
concommand.Add("weaponsets_delete", function(ply, _, args, _)
    if not WEAPONSETS:Access(ply) then return false end

    if #args > 0 then
        for i = 1, #args do
            WEAPONSETS:DeleteFile(tostring(args[i]))
            WEAPONSETS:SendList()
        end
    else
        local str = table.concat(WEAPONSETS:GetList(), ", ")
        print("Weapon sets: " .. str)
    end
end, _, "Usage: weaponsets_delete <weaponSetName1> <weaponSetName2> ...", flags)

-- TODO: may be add NPC support?
-- "give" concommand
concommand.Add("weaponsets_give", function(ply, _, args, _)
    if not WEAPONSETS:Access(ply) then return false end

    if #args < 1 then
        if IsValid(ply) then
            WEAPONSETS:OpenGiveMenu(ply)
        else
            print("Usage: weaponsets_give <weaponSetName> [userId1] [userId2] ...")
        end
    else
        local name = tostring(args[1])

        if #args < 2 then
            for _, v in pairs(player.GetAll()) do
                v:GiveWeaponSet(name)
            end
        else
            for i = 2, #args do
                local id = tonumber(args[i])
                if not id then continue end
                local target = getPlayerByUserID(id)

                if IsValid(target) then
                    target:GiveWeaponSet(name)
                end
            end
        end
    end
end, _, "Usage: weaponsets_give <weaponSetName> [userId1] [userId2] ...", flags)

-- "setloadout" concommand
concommand.Add("weaponsets_setloadout", function(ply, _, args, _)
    if not WEAPONSETS:Access(ply) then return false end

    if #args < 1 then
        if IsValid(ply) then
            WEAPONSETS:OpenGiveMenu(ply)
        else
            print("Usage: weaponsets_setloadout <weaponSetName> [userId1] [userId2] ...")
        end
    else
        local name = tostring(args[1])

        if #args < 2 then
            for _, v in pairs(player.GetAll()) do
                v:SetWeaponSet(name)
            end
        else
            for i = 2, #args do
                local id = tonumber(args[i])

                if not id then
                    util.SetPData(args[i], "loadoutWeaponSet", name)
                else
                    local target = getPlayerByUserID(id)

                    if IsValid(target) then
                        target:SetWeaponSet(name)
                    end
                end
            end
        end
    end
end, _, "Usage: weaponsets_setloadout <weaponSetName> [userId1] [userId2] ...", flags)
