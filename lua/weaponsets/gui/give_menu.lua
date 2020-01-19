--[[---------------------------------------------------------
    GUI - Weapon sets give and loadout management window
-----------------------------------------------------------]]
function WEAPONSETS:OpenGiveMenu(tbl, sets)
    local pad = 2

    -- Main frame
    local f = vgui.Create("DFrame")
    f:SetSize(600, 400)
    f:SetMinWidth(400)
    f:SetMinHeight(300)
    f:SetTitle("WeaponSets Give and Loadout management")
    f:ShowCloseButton(true)
    f:SetDeleteOnClose(true)
    f:SetDraggable(true)
    f:SetSizable(true)
    f:DockPadding(0, 24, 0, 0)
    f:Center()
    f:MakePopup()

    -- left side
    local lPan = vgui.Create("DPanel", f)
    lPan:DockPadding(pad, pad, 0, pad)
    lPan:SetPaintBackground(false)
    lPan:Dock(FILL)

    -- right side
    local rPan = vgui.Create("DPanel", f)
    rPan:DockPadding(pad, pad, pad, pad)
    rPan:SetPaintBackground(false)
    rPan:SetWidth(200)
    rPan:Dock(RIGHT)

    -- List
    local ls = vgui.Create("DListView", lPan)
    ls:Dock(FILL)
    ls:DockMargin(pad, pad, pad, pad)
    ls:SetMultiSelect(true)
    ls:AddColumn("UserID"):SetWidth(10)
    ls:AddColumn("Nick")
    ls:AddColumn("Loadout set")
    ls:AddColumn("Last given")
    local localPlayerId = LocalPlayer():UserID()

    for _, v in pairs(tbl) do
        local line = ls:AddLine(v.id, v.nick, v.loadout, v.last)

        if v.id == localPlayerId then
            ls:SelectItem(line)
        end
    end

    ------------------
    -- Bottom panel --
    ------------------
    local bottPan = vgui.Create("DPanel", rPan)
    bottPan:SetPaintBackground(false)
    bottPan:Dock(BOTTOM)
    bottPan:DockMargin(pad, pad, pad, pad)
    bottPan:SetHeight(48 + pad * 2)

    -- Refresh button
    local bt1 = vgui.Create("DButton", bottPan)
    bt1:SetText("Refresh list (reopen this window)")
    bt1:Dock(BOTTOM)
    bt1:DockMargin(0, pad * 2, 0, 0)
    bt1:SetEnabled(false)
    bt1:SetHeight(24)

    bt1.DoClick = function()
        f:Close()
        RunConsoleCommand("weaponsets_give")
    end

    timer.Simple(5, function()
        if IsValid(bt1) then
            bt1:SetEnabled(true)
        end
    end)

    -- Select all button
    local bt2 = vgui.Create("DButton", bottPan)
    bt2:SetText("Select all")
    bt2:Dock(BOTTOM)
    bt2:SetHeight(24)

    bt2.DoClick = function()
        for _, v in pairs(ls:GetLines()) do
            ls:SelectItem(v)
        end
    end

    -----------------------
    -- Selection actions --
    -----------------------
    local function massPlysUnpack(col, comm, name)
        local plyTbl = {}

        for _, v in pairs(ls:GetSelected()) do
            table.insert(plyTbl, v:GetColumnText(1))
            v:SetColumnText(col, name)
        end

        RunConsoleCommand(comm, name, unpack(plyTbl))
    end

    local function buildWeaponListMenu(subMenu, callback)
        subMenu = subMenu or DermaMenu()

        for _, name in pairs(sets) do
            subMenu:AddOption(name, function()
                callback(name)
            end)
        end
    end

    local rPan1 = vgui.Create("DCollapsibleCategory", rPan)
    rPan1:Dock(TOP)
    rPan1:DockMargin(pad, pad, pad, pad)
    rPan1:DockPadding(pad, pad, pad, pad)
    rPan1:SetLabel("Selection actions")

    -- Select loadout combobox
    local combo1 = vgui.Create("DComboBox", rPan1)
    combo1:Dock(TOP)
    combo1:DockMargin(pad, pad, pad, pad)
    combo1:SetHeight(24)
    combo1:SetValue("Choose loadout set for selection")

    for _, v in pairs(sets) do
        combo1:AddChoice(v)
    end

    combo1:AddChoice("<inherit>")
    combo1:AddChoice("<default>")

    combo1.OnSelect = function(_, _, name)
        massPlysUnpack(3, "weaponsets_setloadout", name)
        combo1:SetValue("Choose loadout set for selection")
    end

    -- Give loadout combobox
    local combo2 = vgui.Create("DComboBox", rPan1)
    combo2:Dock(TOP)
    combo2:DockMargin(pad, pad, pad, pad)
    combo2:SetHeight(24)
    combo2:SetValue("Give set to selected players")

    for _, v in pairs(sets) do
        combo2:AddChoice(v)
    end

    combo2.OnSelect = function(_, _, name)
        massPlysUnpack(4, "weaponsets_give", name)
        combo2:SetValue("Give set for selection")
    end

    function ls:OnRowRightClick(ind, line)
        local acts = DermaMenu()
        local subMenu1, _ = acts:AddSubMenu("Give a set...")

        buildWeaponListMenu(subMenu1, function(name)
            massPlysUnpack(4, "weaponsets_give", name)
        end)

        local subMenu2, _ = acts:AddSubMenu("Set as loadout...")

        subMenu2:AddOption("<inherit>", function()
            massPlysUnpack(3, "weaponsets_setloadout", "<inherit>")
        end)

        subMenu2:AddOption("<default>", function()
            massPlysUnpack(3, "weaponsets_setloadout", "<default>")
        end)

        buildWeaponListMenu(subMenu2, function(name)
            massPlysUnpack(3, "weaponsets_setloadout", name)
        end)

        acts:Open()
    end

    ---------------------
    -- SteamID loadout --
    ---------------------
    local rPan2 = vgui.Create("DCollapsibleCategory", rPan)
    rPan2:Dock(TOP)
    rPan2:DockMargin(pad, pad, pad, pad)
    rPan2:DockPadding(pad, pad, pad, pad)
    rPan2:SetLabel("Loadout for offline players")
    local e1 = vgui.Create("DTextEntry", rPan2)
    e1:Dock(TOP)
    e1:DockMargin(pad, pad, pad, pad)
    e1:SetText("Player's SteamID")

    -- Select loadout by steamid
    local combo3 = vgui.Create("DComboBox", rPan2)
    combo3:Dock(TOP)
    combo3:DockMargin(pad, pad, pad, pad)
    combo3:SetHeight(24)
    combo3:SetValue("Choose loadout set for SteamID")

    for _, v in pairs(sets) do
        combo3:AddChoice(v)
    end

    combo3:AddChoice("<inherit>")
    combo3:AddChoice("<default>")

    combo3.OnSelect = function(_, _, name)
        local id = e1:GetText()
        RunConsoleCommand("weaponsets_setloadout", name, id)
        combo3:SetValue("Choose loadout set for SteamID")
        e1:SetText("")
    end

    return f
end
