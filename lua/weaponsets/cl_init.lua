--[[---------------------------------------------------------
    CLIENT - cl_init.lua
-----------------------------------------------------------]]
include("weaponsets/shared.lua")
include("weaponsets/gui/give_menu.lua")
include("weaponsets/gui/edit_menu.lua")
include("weaponsets/gui/sandbox.lua")
WEAPONSETS.WeaponSetsList = {}
WEAPONSETS.SettingsPanel = nil
WEAPONSETS.ModifyPanel = nil

-- to make this variable available to clients
CreateConVar("weaponsets_loadoutset", "<default>", {FCVAR_REPLICATED}, "Loadout weapon set for all players")

--[[---------------------------------------------------------
    Net functions
-----------------------------------------------------------]]
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
        if not isfunction(Player) then return end
        local ply = Player(data.ply)
        if not IsValid(ply) then return end
        local matrix = Matrix()
        matrix:Scale(Vector(data.scale, data.scale, data.scale))
        ply:EnableMatrix("RenderMultiply", matrix)
        local r_min, r_max = ply:GetRenderBounds()
        local lastScale = ply.weaponsets_lastscale or 1
        ply:SetRenderBounds(r_min * data.scale / lastScale, r_max * data.scale / lastScale)
        ply.weaponsets_lastscale = data.scale

        if ply == LocalPlayer() then
            WEAPONSETS:SetPlayerSize(LocalPlayer(), data.scale)
        end
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
        WEAPONSETS.SettingsPanel.combo1:SetValue(GetConVar("weaponsets_loadoutset"):GetString())
    end

    if WEAPONSETS.ModifyPanel then
        WEAPONSETS.ModifyPanel.list:Clear()

        for _, v in pairs(data) do
            WEAPONSETS.ModifyPanel.list:AddLine(v)
        end

        if #WEAPONSETS.ModifyPanel.list:GetLines() > 0 then
            WEAPONSETS.ModifyPanel.list:SelectFirstItem()
        end
    end
end

WEAPONSETS.NetFuncs.openTeamMenu = function(data)
    local pad = 16
    local f = vgui.Create("DFrame")
    f:SetTitle("")
    f:SetBackgroundBlur(true)
    f:ShowCloseButton(false)
    f:SetDeleteOnClose(true)
    f:SetDraggable(false)
    f:SetSizable(false)
    f:DockPadding(0, pad * 4, 0, 0)
    f:Dock(FILL)
    f:Center()
    f:MakePopup()

    f.Paint = function(_, w, h)
        surface.SetDrawColor(38, 50, 56, 250)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("Select a loadout set", "DermaLarge", w / 2, pad * 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    end

    local pan = vgui.Create("DScrollPanel", f)
    pan:DockMargin(pad * 4, pad * 2, pad * 4, pad)
    pan:Dock(FILL)

    for _, name in pairs(WEAPONSETS.WeaponSetsList) do
        local bt = vgui.Create("DButton")
        bt:DockMargin(0, 0, 0, pad)
        bt:Dock(TOP)
        bt:SetText(name)
        bt:SetHeight(pad * 2)
        bt:SetFont("DermaLarge")

        bt.DoClick = function()
            net.Start("wepsetsToSv")
            net.WriteString("selectLoadout")

            net.WriteTable({
                name = name
            })

            net.SendToServer()
            f:Close()
        end

        pan:AddItem(bt)
    end

    local closeBt = vgui.Create("DButton", f)
    closeBt:SetText("#cancel")
    closeBt:DockMargin(pad * 4, pad * 3, pad * 4, pad * 2)
    closeBt:Dock(BOTTOM)
    closeBt:SetHeight(pad * 3)
    closeBt:SetFont("DermaLarge")

    closeBt.DoClick = function()
        f:Close()
    end
end

--[[---------------------------------------------------------
    Hooks
-----------------------------------------------------------]]
net.Receive("wepsetsToCl", function()
    local name = net.ReadString()
    local data = net.ReadTable()

    if WEAPONSETS.NetFuncs[name] ~= nil then
        WEAPONSETS.NetFuncs[name](data)
    end
end)
