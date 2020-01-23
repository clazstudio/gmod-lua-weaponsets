local globalLoadout = CreateConVar("weaponsets_loadoutset", "<default>", {FCVAR_REPLICATED, FCVAR_ARCHIVE},
    "Loadout weapon set for all players")

function WeaponSets:GiveSet(ply, id, midgame)
    local values = self:LoadSet(id)
    if id == "<inherit>" then
        id = globalLoadout:GetString()
    end
    if id ~= "<default>" then
        self:Give(ply, values, midGame)
    end
end

local LOADOUT_SET_PDATA_KEY = "loadoutWeaponSet"
function WeaponSets:SetLoadout(ply, id)
    if isstring(ply) then
        return util.SetPData(ply, LOADOUT_SET_PDATA_KEY)
    end
    return ply:SetPData(LOADOUT_SET_PDATA_KEY, name)
end

function WeaponSets:GetLoadout(ply, setId)
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
        self.D("FromPlayer", values)
    else
        values = self:LoadSet(id)
    end
    self:StartNet(self.Net.SendSet)
    net.WriteString(id)
    self:NetWriteTable(values or {})
    net.Send(ply)
end

-- Files operations --

if not file.Exists("weaponsets", "DATA") then
    file.CreateDir("weaponsets")
end

local function filePath(id)
    return "weaponsets/" .. id .. ".txt"
end

local cachedSets = nil
function WeaponSets:ClearCache()
    self.D("ClearCache")
    cachedSets = setmetatable({}, {__mode = 'v'})
end
WeaponSets:ClearCache()

function WeaponSets:ReadSets()
    local json = file.Read("weaponsets_sets.txt", "DATA") or ""
    local sets = util.JSONToTable(json)
    self.D("ReadSets", json)
    return sets or {}
end
WeaponSets.Sets = WeaponSets:ReadSets()

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
    local ok, key, err = self:Validate(values)
    if not ok then
        values = nil
    end
    if not ok and self.Sets[id] ~= nil then
        self.Print("Unregister invalid set file: " .. id, key, err)
        self.Sets[id] = nil
        self:SendSets()
    end
    if ok and self.Sets[id] == nil then
        self.Print("Found unregistered file: " .. id)
        self.Sets[id] = {
            name = id
        }
        self:SendSets()
    end
    self.D("Load: " .. id, json)
    cachedSets[id] = values
    return values
end

function WeaponSets:SaveSet(id, values)
    cachedSets[id] = values
    file.Write(filePath(id), util.TableToJSON(values, false))
    self.D("Save: " .. id)
end

function WeaponSets:AddSet(set, values)
    local id = self:IdFromName(set.name or "")
    self:SaveSet(id, values)
    self.Sets[id] = set
    return id
end

function WeaponSets:RemoveSet(id)
    cachedSets[id] = nil
    self.Sets[id] = nil
    file.Delete(filePath(id))
    self.Print("Remove: " .. id)
end

function WeaponSets:RenameSet(id, newName)
    if self.Sets[id] and self.Sets[id].name == newName then
        return id
    end
    local newId = self:IdFromName(newName)
    local ok = file.Rename(filePath(id), filePath(newId))
    if not ok then
        self.Print("Can't rename: " .. id .. " -> " .. newId)
        return
    end
    self.D("Rename: " .. id .. " -> " .. newId)
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

    -- TODO: move into function WeaponSets:UpdateSet(id, set, values)
    if #id == 0 then
        id = WeaponSets:AddSet(set, values)
        WeaponSets:SendSets()
    else
        -- TODO: validate set
        if set ~= nil and isstring(set.name) then
            id = WeaponSets:RenameSet(id, set.name)
            WeaponSets.Sets[id] = set
            WeaponSets:SendSets()
        end
        if values ~= nil then
            -- TODO: validate
            WeaponSets:Save(id, values)
        end
    end

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
