--[[---------------------------------------------------------
    SERVER - init.lua
---------------------------------------------------------]]--

include("weaponsets/shared.lua")
include("weaponsets/player.lua")
include("weaponsets/commands.lua")

WEAPONSETS.PasteBinSets = "Q72iy08U"
WEAPONSETS.Version = "30.12.2017"

WEAPONSETS.Convars = {
    ["loadoutSet"] = CreateConVar("weaponsets_loadoutset", "<default>", { FCVAR_REPLICATED, FCVAR_ARCHIVE }, 
                                  "Loadout weapon set for all players"),
    ["adminOnly"] = CreateConVar("weaponsets_adminonly", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, 
                                 "If enabled only superadmin can give and edit weaponsets"),
    ["deathmatch"] = CreateConVar("weaponsets_deathmatch", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE }, 
                                 "If enabled all players will can choose loadout set.")
}

util.AddNetworkString("wepsetsToSv")
util.AddNetworkString("wepsetsToCl")


--[[---------------------------------------------------------
    Player access
---------------------------------------------------------]]--
function WEAPONSETS:Access(ply)
    if !IsValid(ply) then return true end
    if self.Convars["adminOnly"]:GetBool() then
        return ply:IsSuperAdmin()
    else
        return true
    end
end


--[[---------------------------------------------------------
    File functions
---------------------------------------------------------]]--

-- File exists and addon folder creation
function WEAPONSETS:FileExists(name)
    local path = "weaponsets/" .. (name or "") .. ".txt"
    if !file.Exists("weaponsets", "DATA") then
        file.CreateDir("weaponsets")
        return false
    end
    return file.Exists(path, "DATA"), path
end

-- Load wepset from file
local lastLoadedName = nil
local lastLoadedTable = nil
function WEAPONSETS:LoadFromFile(name)
    if lastLoadedName == name then
        return lastLoadedTable end
    name = self:FormatFileName(name)

    local exists, path = self:FileExists(name)
    if exists then
        local tbl = util.JSONToTable(file.Read(path, "DATA"))
        if tbl != nil then
            lastLoadedName = name
            lastLoadedTable = tbl
        end
        return tbl
    end

    return nil
end

-- Save wepset to file
function WEAPONSETS:SaveToFile(name, tbl)
    name = self:FormatFileName(name)
    local exists, path = self:FileExists(name)

    if lastLoadedName == name then 
        lastLoadedTable = tbl end
    file.Write(path, util.TableToJSON(tbl))
    return exists
end

-- Delete wepset file
function WEAPONSETS:DeleteFile(name)
    name = self:FormatFileName(name)
    local exists, path = self:FileExists(name)
    if !exists then return false end

    file.Delete(path)
    return true
end

-- gets list of weaponsets
function WEAPONSETS:GetList()
    self:FileExists()

    local tbl, _ = file.Find("weaponsets/*.txt", "DATA")
    for k, v in pairs(tbl) do
        tbl[k] = string.Left(v, #v - 4)
    end

    return tbl
end


--[[---------------------------------------------------------
    Send weapon sets list to client(s)
---------------------------------------------------------]]--
function WEAPONSETS:SendList(ply)
    net.Start("wepsetsToCl")
    net.WriteString("receiveList")
    net.WriteTable(WEAPONSETS:GetList())

    if IsValid(ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

--[[---------------------------------------------------------
    Open Give and Players menu
---------------------------------------------------------]]--
function WEAPONSETS:OpenGiveMenu(ply)
    if !IsValid(ply) then return false end
    if !WEAPONSETS:Access(ply) then return false end

    local tbl = {}
    for _, v in pairs(player.GetAll()) do
        table.insert(tbl, {
            id = v:UserID(),
            nick = v:Nick(),
            loadout = v:GetWeaponSet(),
            last = v.lastWeaponSet or "none"
        })
    end
    
    net.Start("wepsetsToCl")
        net.WriteString("openGiveMenu")
        net.WriteTable({ sets = self:GetList(), plys = tbl })
    net.Send(ply)
end


--[[---------------------------------------------------------
    Save default multipliers values
---------------------------------------------------------]]--
function WEAPONSETS:SaveDefaults(ply)
    local tbl = {}

    tbl.gravity = ply:GetGravity()
    tbl.step = ply:GetStepSize()

    ply.weaponsets_defaults = tbl
    ply.weaponsets_affected = false
end


--[[---------------------------------------------------------
    Restore default multipliers values
---------------------------------------------------------]]--
function WEAPONSETS:RestoreDefaults(ply)
    if ply.weaponsets_affected == nil or ply.weaponsets_defaults == nil then
        return self:SaveDefaults(ply)
    end
    if !ply.weaponsets_affected then return false end
    local tbl = ply.weaponsets_defaults

    ply:SetGravity(tbl.gravity)
    self:SetPlayerSize(ply, 1)
    ply:SetStepSize(tbl.step)

    ply.weaponsets_affected = false
end


local function applySpeed(ply, speed) 
    if speed == 1 or speed < 0 then return end
    
    ply:SetWalkSpeed(math.max(ply:GetWalkSpeed() * speed, 0.001))
    ply:SetRunSpeed(math.max(ply:GetRunSpeed() * speed, 0.001))
    ply:SetMaxSpeed(math.max(ply:GetMaxSpeed() * speed, 0.001))
    ply:SetCanWalk(ply:GetWalkSpeed() >= 100); -- +walk
    
    -- issues with values greater than 1
    ply:SetDuckSpeed(math.Clamp(ply:GetDuckSpeed() / speed, 0, 1))
    ply:SetUnDuckSpeed(math.Clamp(ply:GetUnDuckSpeed() / speed, 0, 1))
end

--[[---------------------------------------------------------
    Weapon set giving
---------------------------------------------------------]]--
function WEAPONSETS:Give(ply, name)
    if !IsValid(ply) then return false end
    if name == "<inherit>" then
        name = self.Convars["loadoutSet"]:GetString() end
    ply.lastWeaponSet = name

    self:RestoreDefaults(ply)
    if name == "<default>" then return false end
    
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
    if self.BloodEnums[tbl.blood] then
        ply:SetBloodColor(tbl.blood) end
    if tbl.friction > -1.0 then
        ply:SetFriction(tbl.friction) end
    
    applySpeed(ply, tbl.speed);

    if tbl.opacity < 255 and tbl.opacity >= 0 then
        ply:SetNoDraw(false)
        ply:SetRenderMode(RENDERMODE_TRANSALPHA) 
        local col = ply:GetColor()
        col.a = tbl.opacity
        ply:SetColor(col)
    elseif tbl.opacity <= -1 then
        -- fully hidden
        ply:SetNoDraw(true)
    end

    if tbl.scale != 1 then
        self:SetPlayerSize(ply, tbl.scale)
        ply.weaponsets_affected = true
    end

    if tbl.gravity ~= 1 then
        ply:SetGravity(tbl.gravity) 
        ply.weaponsets_affected = true
    end

    ply:ShouldDropWeapon(tobool(tbl.dropweapons))

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
            ply:GiveAmmo(v, tostring(k), true)
        end
    end

    ply:AllowFlashlight(tobool(tbl.allowflashlight))
    if ply:FlashlightIsOn() and !tobool(tbl.allowflashlight) then
        ply:Flashlight(false)
    end

    if table.Count(tbl.set) != 0 then
        ply:SwitchToDefaultWeapon() end

    return true
end


--[[---------------------------------------------------------
    Downloading sets from Pastebin
---------------------------------------------------------]]--
function WEAPONSETS:Download()
    http.Fetch("http://pastebin.com/raw.php?i=" .. self.PasteBinSets, function(body, _, _, _)
        local tbl = util.JSONToTable(body)
        if tbl == nil then return false end
        for name, id in pairs(tbl) do
            http.Fetch( "http://pastebin.com/raw.php?i=" .. id, function(json, _, _, _)
                local set = util.JSONToTable(json)
                if set == nil then return false end
                self:SaveToFile(name, set)
                print("[WeaponSets] Downloaded: " .. name)
            end)
        end
    end)
end


--[[---------------------------------------------------------
    Backward compatibility
---------------------------------------------------------]]--
function WEAPONSETS:Upgrade()
    if file.Exists("weaponsets_version.txt", "DATA") then
        if file.Read("weaponsets_version.txt", "DATA") == self.Version then
            return
        else
            -- Options -> Convars
            if file.Exists("weaponsets_options.txt", "DATA") then
                local options = util.JSONToTable(file.Read("weaponsets_options.txt", "DATA"))
                if options then
                    if options.loadoutset then
                        self.Convars["loadoutSet"]:SetString(options.loadoutset) end
                    if options.onlyAdmin then
                        self.Convars["adminOnly"]:SetBool(tobool(options.onlyAdmin)) end
                end
                file.Delete("weaponsets_options.txt")
                print("[WeaponSets] Options -> Convars")
            end
            -- Validate all weapon sets
            local sets = self:GetList()
            for _, name in pairs(sets) do
                local tbl = self:LoadFromFile(name)
                self:SaveToFile(self:ValidateWeaponSet(name, tbl))
                print("[WeaponSets] Validated: " .. name)
            end
        end 
    end

    timer.Simple(5, function() WEAPONSETS:Download() end)
    file.Write("weaponsets_version.txt", self.Version)
end


--[[---------------------------------------------------------
    Net functions
---------------------------------------------------------]]--

-- Save weapon set to file
WEAPONSETS.NetFuncs.saveSet = function(ply, data)
    if WEAPONSETS:Access(ply) then
        if !WEAPONSETS:SaveToFile(WEAPONSETS:ValidateWeaponSet(data.name, data.tbl)) then
            WEAPONSETS:SendList() end
    end
end

-- Retrieve weapon sets list
WEAPONSETS.NetFuncs.retrieveList = function(ply, data)
    if WEAPONSETS:Access(ply) then
        WEAPONSETS:SendList(ply)
    end
end

-- Select DM loadout
WEAPONSETS.NetFuncs.selectLoadout = function(ply, data)
    if WEAPONSETS.Convars["deathmatch"]:GetBool() and IsValid(ply) then
        ply:SetWeaponSet(data.name or "<inherit>")
        ply:KillSilent();
        ply:Spawn()
    end
end


--[[---------------------------------------------------------
    Hooks
---------------------------------------------------------]]--

net.Receive("wepsetsToSv", function(len, ply)
    local name = net.ReadString()
    local data = net.ReadTable()

    if WEAPONSETS.NetFuncs[name] != nil then
        WEAPONSETS.NetFuncs[name](ply, data) end
end)

-- Player loadout hook
hook.Add("PlayerLoadout", "weaponsets_PlayerLoadout", function(ply)
    local result = ply:GiveWeaponSet()
    if result then return false end
end)

-- Init hook
hook.Add("Initialize", "weaponsets_Initialize", function()
    WEAPONSETS:Upgrade()
end)

-- Player initial spawn hook
hook.Add("PlayerInitialSpawn", "weaponsets_PlayerInitialSpawn", function(ply)
	WEAPONSETS.NetFuncs.retrieveList(ply)
end)

-- ShowTeam hook
hook.Add("ShowTeam", "weaponsets_ShowTeam", function(ply)
    if WEAPONSETS.Convars["deathmatch"]:GetBool() then
        net.Start("wepsetsToCl")
        net.WriteString("openTeamMenu")
        net.Send(ply)
    end
end)
