--[[---------------------------------------------------------
    SERVER - init.lua
---------------------------------------------------------]]--
include("weaponsets/shared.lua")

WEAPONSETS.PasteBinSets = "Q72iy08U"
WEAPONSETS.Version = "18.11.16"
WEAPONSETS.Options = WEAPONSETS.Options or {
    loadoutset = "<default>",
    onlyAdmin = 1
}

util.AddNetworkString("wepsetsToSv")
util.AddNetworkString("wepsetsToCl")


--[[---------------------------------------------------------
    Player access
---------------------------------------------------------]]--
function WEAPONSETS:Access(ply)
    if !IsValid(ply) then return true end
    if self.Options["onlyAdmin"] == 1 then
        return ply:IsSuperAdmin()
    else
        return true
    end
end


--[[---------------------------------------------------------
    File functions
---------------------------------------------------------]]--

-- File exists and addon folder creation
function WEAPONSETS:FileExists(path)
    if !file.Exists("weaponsets", "DATA") then
        file.CreateDir("weaponsets")
        return false
    end
    return file.Exists(path, "DATA")
end

-- Load wepset from file
function WEAPONSETS:LoadFromFile(name)
    name = self:FormatFileName(name)
    local path = "weaponsets/" .. name .. ".txt"
    local tbl = {}

    if self:FileExists(path) then
        tbl = util.JSONToTable(file.Read(path, "DATA"))
        local empty = self:GetEmptySet()
        if tbl ~= nil then
            for k, v in pairs(empty) do
                if tbl[k] == nil then tbl[k] = v end
            end
            tbl.name = name
            return tbl
        end
    end

    tbl = self:GetEmptySet()
    tbl.name = name
    return tbl
end

-- Save wepset to file
function WEAPONSETS:SaveToFile(name, tbl)
    name = self:FormatFileName(name)
    local path = "weaponsets/" .. name .. ".txt"

    self:FileExists(path)
    return file.Write(path, util.TableToJSON(tbl, true))
end

-- Delete wepset file
function WEAPONSETS:DeleteFile(name)
    name = self:FormatFileName(name)
    local path = "weaponsets/" .. name .. ".txt"
    if !self:FileExists(path) then return false end

    file.Delete(path)
    return true
end

-- Load options
function WEAPONSETS:LoadOptions()
    local path = "weaponsets_options.txt"

    if file.Exists(path, "DATA") then
        local tbl = util.JSONToTable(file.Read(path, "DATA"))
        if tbl ~= nil then
            self.Options = tbl
        end
    end
end

-- Save options
function WEAPONSETS:SaveOptions()
    if !self.Options then return false end
    file.Write("weaponsets_options.txt", util.TableToJSON(self.Options, true))
end

-- gets list of weaponsets
function WEAPONSETS:GetList()
    self:FileExists("weaponsets")

    local tbl, _ = file.Find("weaponsets/*.txt", "DATA")
    for k, v in pairs(tbl) do
        tbl[k] = string.Left(v, #v - 4)
    end

    return tbl
end


--[[---------------------------------------------------------
    Downloading sets from pastebin
---------------------------------------------------------]]--
function WEAPONSETS:Download()
    if file.Exists("weaponsets_version.txt", "DATA") then
        if file.Read("weaponsets_version.txt", "DATA") == self.Version then
            return false 
        end 
    end
    http.Fetch("http://pastebin.com/raw.php?i=" .. self.PasteBinSets, function(body, _, _, _)
        local tbl = util.JSONToTable(body)
        if tbl == nil then return false end
        for k, v in pairs(tbl) do
            http.Fetch( "http://pastebin.com/raw.php?i=" .. v, function(json, _, _, _)
                local set = util.JSONToTable(json)
                if set == nil then return false end
                self:SaveToFile(set.name, set)
                print("[WeaponSets] Downloaded: " .. set.name)
            end)
        end

        file.Write("weaponsets_version.txt", self:Version)
    end)
end


--[[---------------------------------------------------------
    Weapon set giving
---------------------------------------------------------]]--
function WEAPONSETS:Give(ply, name)
    if !IsValid(ply) then return false end
    
    local tbl = self:LoadFromFile(name)
    if tbl == nil then return false end

    if tbl.health > 0 then
        ply:SetHealth(tbl.health) end
    if tbl.armor > -1 then
        ply:SetArmor(tbl.armor) end
    if tbl.maxhealth > -1 then
        ply:SetMaxHealth(tbl.maxhealth) end
    if tbl.jump > -1 then
        ply:SetJumpPower(tbl.jump) end
    if tbl.gravity ~= 1 then
        ply:SetGravity(tbl.gravity) end
    
    if tbl.speed ~= 1 then
        ply:SetCrouchedWalkSpeed(ply:GetCrouchedWalkSpeed() * tbl.speed)
        ply:SetWalkSpeed(ply:GetWalkSpeed() * tbl.speed)
        ply:SetRunSpeed(ply:GetRunSpeed() * tbl.speed)
        ply:SetMaxSpeed(ply:GetMaxSpeed() * tbl.speed)
    end

    if tobool(tbl.stripweapons) == true then
        ply:StripWeapons() end
    for k, v in pairs(tbl.set) do
        if tonumber(v) < 1 then
            ply:Give(k)
        end
    end

    if tobool(tbl.stripammo) == true then
        ply:StripAmmo() end
    for k, v in pairs(tbl.set) do
        if tonumber(v) > 0 then
            ply:GiveAmmo(v, k, true)
        end
    end

    ply:AllowFlashlight(tobool(tbl.allowflashlight))
    if ply:FlashlightIsOn() and !tobool(tbl.allowflashlight) then
        ply:Flashlight(false)
    end

    ply:SwitchToDefaultWeapon()

    return true, tobool(tbl.stripweapons)
end


--[[---------------------------------------------------------
    Net functions
---------------------------------------------------------]]--

-- Save weapon set to file
WEAPONSETS.NetFuncs.saveSet = function(ply, data)
    if WEAPONSETS:Access(ply) then
        WEAPONSETS:SaveToFile(data.name, data.tbl)
    end
end

-- Delete weapon set
WEAPONSETS.NetFuncs.deleteSet = function(ply, data)
    if WEAPONSETS:Access(ply) then
        WEAPONSETS:DeleteFile(data.name)
    end
end

-- Save settings
WEAPONSETS.NetFuncs.saveOptions = function(ply, data)
    if WEAPONSETS:Access(ply) then
        WEAPONSETS.Options = data
        WEAPONSETS:SaveOptions()
    end
end


--[[---------------------------------------------------------
    Concommands and hooks
---------------------------------------------------------]]--

net.Receive("wepsetsToSv", function(len, ply)
    local name = net.ReadString()
    local data = net.ReadTable()

    if WEAPONSETS.NetFuncs[name] != nil then
        WEAPONSETS.NetFuncs[name](ply, data) end
end)

-- give concommand
concommand.Add("weaponsets_give", function(ply, _, args, _)
    if !IsValid(ply) then return false end
    if !WEAPONSETS:Access(ply) then return false end

    if #args < 1 then
        net.Start("wepsetsToCl")
            net.WriteString("openGiveMenu")
            net.WriteTable(WEAPONSETS:GetList())
        net.Send(ply)
    else
        local name = tostring(args[1])

        if #args < 2 then
            for _,v in pairs(player.GetAll()) do
                WEAPONSETS:Give(v, name)
            end
        else
            for i = 2, #args, 1 do
                local id = tonumber(args[i])
                if !id then continue end
                WEAPONSETS:Give(Player(id), name)
            end
        end
    end
end, _, "Usage: weaponsets_give <weaponSetName> [userId1] [userId2] ...", FCVAR_CLIENTCMD_CAN_EXECUTE)

-- "weaponsets" concommand
concommand.Add("weaponsets", function(ply, _, args, _)
    if !IsValid(ply) then return false end
    if !WEAPONSETS:Access(ply) then return false end

    if #args == 1 then
        local name = tostring(args[1])
        local tbl = WEAPONSETS:LoadFromFile(name)
        net.Start("wepsetsToCl")
            net.WriteString("openEditMenu")
            net.WriteTable({ name = tbl.name or name, tbl = tbl })
        net.Send(ply)
    else
        net.Start("wepsetsToCl")
            net.WriteString("openMainMenu")
            net.WriteTable({ list = WEAPONSETS:GetList(), options = WEAPONSETS.Options })
        net.Send(ply)
    end
end, nil, "Usage: weaponsets <weaponSetName>", FCVAR_CLIENTCMD_CAN_EXECUTE)

-- Player loadout hook
hook.Add("PlayerLoadout", "weaponsets_plyloadout", function(ply)
    local name = WEAPONSETS.Options.loadoutset
    if name and name ~= "<default>" then
        local _, strip = WEAPONSETS:Give(ply, WEAPONSETS.Options.loadoutset)
        if strip then return false end
    end
end)

-- Init hook
hook.Add("Initialize", "weaponsets_init", function()
    WEAPONSETS:LoadOptions()
    timer.Simple( 5, function()
        WEAPONSETS:Download()
    end)
end)

-- Shutdown hook
hook.Add("ShutDown", "weaponsets_shutdown", function()
    WEAPONSETS:SaveOptions()
end)
