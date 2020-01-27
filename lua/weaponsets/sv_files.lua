local LOADOUT_SET_PDATA_KEY = "loadoutWeaponSet"
-- local LAST_GIVEN_SET_NW_KEY = "lastWeaponSet"

local globalLoadout = CreateConVar("weaponsets_loadoutset", "<default>", {FCVAR_REPLICATED, FCVAR_ARCHIVE},
    "Loadout weapon set for all players")

function WeaponSets:GiveSet(ply, id, midgame)
    if id == "<inherit>" then
        id = globalLoadout:GetString()
    end

    if ply.wsLastGiven then
        -- TODO: strip prev weaponset only if it configured
        self:Strip(ply, self:LoadSet(ply.wsLastGiven), midGame)
    end

    if id == "<default>" then
        ply.wsLastGiven = nil
        return false
    end

    self:Give(ply, self:LoadSet(id), midGame)
    -- ply:SetNWString(LAST_GIVEN_SET_NW_KEY, id)
    ply.wsLastGiven = id
    return true
end

function WeaponSets:SetLoadout(ply, id)
    if isstring(ply) then
        return util.SetPData(ply, LOADOUT_SET_PDATA_KEY)
    end
    return ply:SetPData(LOADOUT_SET_PDATA_KEY, name)
end

function WeaponSets:GetLoadout(ply)
    if isstring(ply) then
        return util.GetPData(ply, LOADOUT_SET_PDATA_KEY, "<inherit>")
    end
    return ply:GetPData(LOADOUT_SET_PDATA_KEY, "<inherit>")
end

function WeaponSets:SendSets(ply)
    self.D("SendSets", ply)
    self:StartNet(self.Net.SendSets)
    self:NetWriteTable(self.Sets)
    if IsValid(ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

function WeaponSets:SendSet(ply, id)
    self.D("SendSet", id, ply)
    local values
    if #id == 0 then
        values = self:FromPlayer(ply)
        self.D("FromPlayer")
    else
        values = self:LoadSet(id)
    end
    self:StartNet(self.Net.SendSet)
    net.WriteString(id)
    self:NetWriteTable(values or {})
    net.Send(ply)
end

function WeaponSets:UpdateSet(id, set, values)
    if set ~= nil and not isstring(set.name) or #set.name == 0 or not isstring(set.usergroup) then
        return nil, nil, "invalid_set_struct"
    end

    if values ~= nil then
        local ok, key, err = self:Validate(values)

        if not ok then
            return nil, key, err
        end
    end

    if not id or #id == 0 or not self.Sets[id] then
        if not set then
            return nil, nil, "invalid_set_struct"
        end
        id = self:AddSet(set, values or {})
        self:WriteSets(self.Sets)
        self:SendSets()
        return id
    end

    if set ~= nil then
        id = self:RenameSet(id, set.name)
        self.Sets[id] = set
        self:WriteSets(self.Sets)
        self:SendSets()
    end

    return self:SaveSet(id, values)
end

-- Files operations --

local function filePath(id)
    return "weaponsets/" .. id .. ".txt"
end

local cachedSets = setmetatable({}, {__mode = 'v'})
function WeaponSets:ClearCache()
    self.D("ClearCache")
    cachedSets = setmetatable({}, {__mode = 'v'})
end

function WeaponSets:ReadSets()
    local json = file.Read("weaponsets_sets.txt", "DATA") or ""
    local sets = util.JSONToTable(json)
    self.D("ReadSets", json)
    return sets or {}
end

function WeaponSets:WriteSets(sets)
    self.D("WriteSets")
    file.Write("weaponsets_sets.txt", util.TableToJSON(sets, false))
end

function WeaponSets:LoadSet(id)
    if cachedSets[id] ~= nil then
        return cachedSets[id]
    end

    local json = file.Read(filePath(id), "DATA") or ""
    local values = util.JSONToTable(json)

    if values == nil and self.Sets[id] ~= nil then
        self.Print("Unregister invalid set file: " .. id)
        self.Sets[id] = nil
        self:SendSets()
    end
    if values ~= nil and self.Sets[id] == nil then
        id = self:IdFromName(id)
        self.Print("Found unregistered file: " .. id)
        self.Sets[id] = {
            name = id,
            usergroup = "superadmin"
        }
        self:SendSets()
    end

    if value ~= nil then
        values = self:Sanitize(values)
    end

    self.D("Load: " .. id, json)
    cachedSets[id] = values
    return values
end

function WeaponSets:SaveSet(id, values)
    id = self:IdFromName(id)
    file.Write(filePath(id), util.TableToJSON(values, false))
    cachedSets[id] = values
    self.D("Save: " .. id)
    return id
end

function WeaponSets:AddSet(set, values)
    if not isstring(set.name) or #set.name == 0 or not isstring(set.usergroup) then
        return nil
    end
    local id = self:IdFromName(set.name)
    self:SaveSet(id, values)
    self.Sets[id] = set
    return id
end

function WeaponSets:RemoveSet(id)
    file.Delete(filePath(id))
    cachedSets[id] = nil
    self.Sets[id] = nil
    self.Print("Remove: " .. id)
end

function WeaponSets:RenameSet(id, newName)
    if self.Sets[id] and self.Sets[id].name == newName then
        return id
    end
    local newId = self:IdFromName(newName)
    local ok = file.Rename(filePath(id), filePath(newId))
    self.D("Rename: " .. id .. " -> " .. newId, ok)
    if not ok then
        self.Print("Can't rename: " .. id .. " -> " .. newId)
        return
    end
    self.Sets[newId] = self.Sets[id]
    self.Sets[id] = nil
    cachedSets[newId] = cachedSets[id]
    cachedSets[id] = nil
    return newId
end

function WeaponSets:DuplicateSet(id, copyName)
    local values = self.LoadSet(id)
    local newId = self:IdFromName(copyName)
    self.SaveSet(newId, values)
    self.D("Duplicate: " .. id .. " -> " .. newId)
    self.Sets[newId] = self.Sets[newId]
    self.Sets[newId].name = copyName
    return newId
end

-- Net --

WeaponSets.Net[WeaponSets.Net.RetrieveSets] = function (len, ply)
    if not IsValid(ply) or not WeaponSets:Access(ply, "retrieve_sets") then
        return
    end
    WeaponSets:SendSets(ply)
end

WeaponSets.Net[WeaponSets.Net.RetrieveSet] = function (len, ply)
    if not IsValid(ply) or not WeaponSets:Access(ply, "retrieve_set") then
        return
    end
    local id = net.ReadString()
    WeaponSets:SendSet(ply, id)
end

WeaponSets.Net[WeaponSets.Net.UpdateSet] = function (len, ply)
    if not IsValid(ply) or not WeaponSets:Access(ply, "edit") then
        return
    end

    local id = net.ReadString()
    local set = WeaponSets:NetReadTable()
    local values = WeaponSets:NetReadTable()
    WeaponSets:UpdateSet(id, set, values)
    -- TODO: response
end

WeaponSets.Net[WeaponSets.Net.GiveSetTable] = function (len, ply)
    if not IsValid(ply) or not WeaponSets:Access(ply, "give") then
        return
    end
    local values = WeaponSets:NetReadTable()
    -- TODO: validate
    WeaponSets:Give(ply, values, true)
end

-- Version --

--[[ function WeaponSets:Download()
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
end ]]

-- Hooks --

hook.Add("PlayerLoadout", "WeaponSets", function(ply)
    local setId = WeaponSets:GetLoadout(ply)
    if WeaponSets:GiveSet(ply, setId) then
        return true
    end
end)

hook.Add("PlayerLoadout", "WeaponSets", function(ply)
    local setId = WeaponSets:GetLoadout(ply)
    WeaponSets:GiveSet(ply, setId)
end)

local initialized = false
hook.Add("Initialize", "WeaponSets", function()
    if not file.Exists("weaponsets", "DATA") then
        file.CreateDir("weaponsets")
    end

    WeaponSets:ClearCache()
    WeaponSets.Sets = WeaponSets:ReadSets() or {}
    initialized = true
end)

hook.Add("ShutDown", "WeaponSets", function()
    if initialized then
        WeaponSets:WriteSets(WeaponSets.Sets)
    end
end)

hook.Add("PlayerInitialSpawn", "WeaponSets", function(ply)
    timer.Simple(5, function()
        WeaponSets:SendSets(ply)
    end)
end)

hook.Add("ShowTeam", "WeaponSets", function(ply)
    -- TODO:
end)
