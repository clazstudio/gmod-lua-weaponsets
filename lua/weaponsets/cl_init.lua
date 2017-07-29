--[[---------------------------------------------------------
    CLIENT - cl_init.lua
---------------------------------------------------------]]--

include("weaponsets/shared.lua" )

include("weaponsets/gui/giveMenu.lua")
include("weaponsets/gui/editMenu.lua")
include("weaponsets/gui/sandbox.lua")

WEAPONSETS.WeaponSetsList = {}
WEAPONSETS.SettingsPanel = nil
WEAPONSETS.ModifyPanel = nil


--[[---------------------------------------------------------
    Net functions
---------------------------------------------------------]]--

-- Open weapon set editing window
WEAPONSETS.NetFuncs.openEditMenu = function(data)
    WEAPONSETS:OpenEditMenu(data.name, data.tbl)
end

-- Open give menu
WEAPONSETS.NetFuncs.openGiveMenu = function(data)
    WEAPONSETS:OpenGiveMenu(data.plys, data.sets)
end

-- Apply player hull changes
WEAPONSETS.NetFuncs.applyNewScale = function(data)
    if data.scale and isnumber(data.scale) then
        local ply = Player(data.ply)
        if !IsValid(ply) then return end

        local matrix = Matrix()
        matrix:Scale(Vector(data.scale, data.scale, data.scale))
        ply:EnableMatrix("RenderMultiply", matrix)
        
        local r_min, r_max = ply:GetRenderBounds()
        local lastScale = ply.weaponsets_lastscale or 1
        ply:SetRenderBounds(r_min * data.scale / lastScale, r_max * data.scale / lastScale)
        ply.weaponsets_lastscale = data.scale

        if ply == LocalPlayer() then
            WEAPONSETS:SetPlayerSize(LocalPlayer(), data.scale) end
    end
end

-- Receive weapon sets list
WEAPONSETS.NetFuncs.receiveList = function(data)
    WEAPONSETS.WeaponSetsList = data
    
    if WEAPONSETS.SettingsPanel then
        WEAPONSETS.SettingsPanel.combo1:Clear()
        for _, v in pairs(data) do
            WEAPONSETS.SettingsPanel.combo1:AddChoice(v)
        end
        WEAPONSETS.SettingsPanel.combo1:AddChoice("<default>")
        WEAPONSETS.SettingsPanel.combo1:SetText(GetConVar("weaponsets_loadoutset"):GetString())
    end

    if WEAPONSETS.ModifyPanel then
        WEAPONSETS.ModifyPanel.list:Clear()
        for _, v in pairs(data) do
            WEAPONSETS.ModifyPanel.list:AddLine(v)
        end
        if #WEAPONSETS.ModifyPanel.list:GetLines() > 0 then
            WEAPONSETS.ModifyPanel.list:SelectFirstItem() end
    end
end


--[[---------------------------------------------------------
    Hooks
---------------------------------------------------------]]--

net.Receive("wepsetsToCl", function()
    local name = net.ReadString()
    local data = net.ReadTable()

    if WEAPONSETS.NetFuncs[name] != nil then
        WEAPONSETS.NetFuncs[name](data) end
end)