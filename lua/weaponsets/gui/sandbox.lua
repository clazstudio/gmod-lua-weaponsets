--[[---------------------------------------------------------
    GUI - Sandbox toolmenu support
-----------------------------------------------------------]]
-- Retrieve weapon sets list from server
local function retrieveList()
    net.Start("wepsetsToSv")
    net.WriteString("retrieveList")
    net.WriteTable({})
    net.SendToServer()
end

-- this function fills up plyList menu with players
local function playersListMenu(plyList, callback)
    plyList:AddOption("All online players", function()
        callback()
    end):SetIcon("icon16/group.png")

    plyList:AddOption("Myself", function()
        callback(LocalPlayer())
    end):SetIcon("icon16/user.png")

    plyList:AddSpacer()

    for _, v in pairs(player.GetAll()) do
        plyList:AddOption(v:Nick(), function()
            callback(v)
        end)
    end

    return plyList
end

local function deleteWeaponSetDialog(name, callback)
    Derma_Query("Do you want to delete '" .. name .. "' weapon set?", "Are you sure?", "Delete!", callback, "Cancel", nil)
end

-- settings toolmenu DForm
local function buildSettingsPanel(pan)
    if not WEAPONSETS then return end
    pan:SetName("WeaponSets settings")
    local combo1, _ = pan:ComboBox("Global loadout set", "weaponsets_loadoutset")
    local sets = WEAPONSETS.WeaponSetsList or {}

    if #sets == 0 then
        retrieveList()
    else
        for _, v in pairs(sets) do
            combo1:AddChoice(v)
        end

        combo1:AddChoice("<default>")
    end
    combo1:SetValue(GetConVar("weaponsets_loadoutset"):GetString())

    pan:Help([[This set will be given for all players with "<inherit>" weapon set or without it on loadout]])
    pan:CheckBox("Only superadmins", "weaponsets_adminonly")
    pan:Help([[If enabled only superadmin will can give and edit weaponsets]])
    pan:CheckBox("Deathmatch mode", "weaponsets_deathmatch")
    pan:Help([[If enabled all players will can choose loadout set]])
    pan:Button("Refresh weapon sets list", "").DoClick = retrieveList
    pan.combo1 = combo1
    WEAPONSETS.SettingsPanel = pan
end

-- Toolmenu DForm for editing sets
local function buildModifyPanel(pan)
    if not WEAPONSETS then return end
    local ls = vgui.Create("DListView")
    ls:SetHeight(400)
    ls:SetMultiSelect(false)
    ls:AddColumn("Set name")
    local sets = WEAPONSETS.WeaponSetsList or {}

    if #sets == 0 then
        retrieveList()
    else
        for _, v in pairs(sets) do
            ls:AddLine(v)
        end

        if #ls:GetLines() > 0 then
            ls:SelectFirstItem()
        end
    end

    --pan:Button("Refresh weapon sets list", "").DoClick = retrieveList
    pan:AddItem(ls)

    function ls:DoDoubleClick(_, line)
        RunConsoleCommand("weaponsets", line:GetColumnText(1))
    end

    function ls:OnRowRightClick(ind, line)
        local name = line:GetColumnText(1)
        local acts = DermaMenu()

        acts:AddOption("Edit...", function()
            RunConsoleCommand("weaponsets", name)
        end):SetIcon("icon16/page_edit.png")

        acts:AddOption("Delete", function()
            deleteWeaponSetDialog(name, function()
                RunConsoleCommand("weaponsets_delete", name)
                ls:RemoveLine(ind)

                if #ls:GetLines() > 0 then
                    ls:SelectFirstItem()
                end
            end)
        end):SetIcon("icon16/cross.png")

        acts:AddSpacer()
        local subMenu1, subMenu1Icon = acts:AddSubMenu("Give to...")

        playersListMenu(subMenu1, function(ply)
            RunConsoleCommand("weaponsets_give", name, ply and ply:UserID())
        end)

        subMenu1Icon:SetIcon("icon16/user_go.png")
        local subMenu2, subMenu2Icon = acts:AddSubMenu("Set as loadout for...")

        playersListMenu(subMenu2, function(ply)
            RunConsoleCommand("weaponsets_setloadout", name, ply and ply:UserID())
        end)

        subMenu2Icon:SetIcon("icon16/user_go.png")
        acts:Open()
    end

    -- button creation with selection checking
    local function localBt(text, func)
        local bt = vgui.Create("DButton")
        bt:SetText(text)

        bt.DoClick = function()
            if #ls:GetLines() < 1 then return end
            local name = ls:GetSelected()[1]:GetColumnText(1)
            local ind = ls:GetSelectedLine()
            func(name, ind)
        end

        return bt
    end

    -- Edit button
    pan:AddItem(localBt("Edit selected weapon set", function(name)
        RunConsoleCommand("weaponsets", name)
    end))

    -- Delete button
    pan:AddItem(localBt("Delete selected weapon set", function(name, ind)
        deleteWeaponSetDialog(name, function()
            RunConsoleCommand("weaponsets_delete", name)
            ls:RemoveLine(ind)

            if #ls:GetLines() > 0 then
                ls:SelectFirstItem()
            end
        end, "Cancel", nil)
    end))

    -- Give buttons
    pan:AddItem(localBt("Give selected set to...", function(name)
        playersListMenu(DermaMenu(), function(ply)
            RunConsoleCommand("weaponsets_give", name, ply and ply:UserID())
        end):Open()
    end))

    pan:AddItem(localBt("Set as loadout set for...", function(name)
        playersListMenu(DermaMenu(), function(ply)
            RunConsoleCommand("weaponsets_setloadout", name, ply and ply:UserID())
        end):Open()
    end))

    -- New set section
    local newSetPanel = vgui.Create("DPanel")
    newSetPanel:DockPadding(0, 16, 0, 0)
    newSetPanel:SetPaintBackground(false)
    newSetPanel:SetHeight(36)
    local newSetName = vgui.Create("DTextEntry", newSetPanel)
    newSetName:SetText("newset")
    newSetName:DockMargin(0, 0, 8, 0)
    newSetName:Dock(FILL)
    local createBt = vgui.Create("DButton", newSetPanel)
    createBt:SetText("Create new set")
    createBt:SetWidth(96)
    createBt:Dock(RIGHT)

    createBt.DoClick = function()
        RunConsoleCommand("weaponsets", newSetName:GetValue())
    end

    pan:AddItem(newSetPanel)
    pan.list = ls
    WEAPONSETS.ModifyPanel = pan
end

-- Hooks
hook.Add("PopulateToolMenu", "weaponsets_PopulateToolMenu", function()
    spawnmenu.AddToolMenuOption("Utilities", "WeaponSets", "WeaponSetsGiveMenu", "Players and giving", "weaponsets_give")
    spawnmenu.AddToolMenuOption("Utilities", "WeaponSets", "WeaponSetsModifyMenu", "Modify weapon sets", "", "", buildModifyPanel)
    spawnmenu.AddToolMenuOption("Utilities", "WeaponSets", "WeaponSetsSettingsMenu", "Settings...", "", "", buildSettingsPanel)
end)

hook.Add("AddToolMenuCategories", "weaponsets_AddToolMenuCategories", function()
    spawnmenu.AddToolCategory("Utilities", "WeaponSets", "Weapon sets")
end)

--[[---------------------------------------------------------
    Sandbox desktop windows support
-----------------------------------------------------------]]
list.Set("DesktopWindows", "CLazWeaponSets", {
    title = "Weapon sets",
    icon = "icon64/tool.png",
    width = 0,
    height = 0,
    onewindow = true,
    init = function(icon, window)
        window:Close()
        local popupMenu = DermaMenu()

        popupMenu:AddOption("Open give and loadout menu...", function()
            RunConsoleCommand("weaponsets_give")
        end):SetIcon("icon16/application_side_list.png")

        popupMenu:AddSpacer()

        for _, name in pairs(WEAPONSETS.WeaponSetsList) do
            local subMenu, subMenuOption = popupMenu:AddSubMenu(name, function()
                RunConsoleCommand("weaponsets_give", name, LocalPlayer():UserID())
            end)

            subMenuOption.DoRightClick = function(_, keyCode)
                RunConsoleCommand("weaponsets", name)
            end

            subMenu:AddOption("Edit...", function()
                RunConsoleCommand("weaponsets", name)
            end):SetIcon("icon16/page_edit.png")

            subMenu:AddOption("Delete", function()
                deleteWeaponSetDialog(name, function()
                    RunConsoleCommand("weaponsets_delete", name)
                end)
            end):SetIcon("icon16/cross.png")

            subMenu:AddSpacer()

            subMenu:AddOption("Give to all", function()
                RunConsoleCommand("weaponsets_give", name)
            end):SetIcon("icon16/group_go.png")

            subMenu:AddOption("Give to me", function()
                RunConsoleCommand("weaponsets_give", name, LocalPlayer():UserID())
            end):SetIcon("icon16/user_go.png")

            subMenu:AddSpacer()

            subMenu:AddOption("Set as my loadout", function()
                RunConsoleCommand("weaponsets_setloadout", name, LocalPlayer():UserID())
            end)
        end

        popupMenu:AddSpacer()

        popupMenu:AddOption("Add new weapon set...", function()
            Derma_StringRequest("New weapon set creation", "Enter new weapon set name:", "newset", function(name)
                RunConsoleCommand("weaponsets", name)
            end, nil, "OK", "Cancel")
        end):SetIcon("icon16/add.png")

        popupMenu:Open()
    end
})

-- Sandbox context menu support
properties.Add("weaponsets_give_property", {
    MenuLabel = "Give an weapon set",
    Order = 2600,
    MenuIcon = "icon16/box.png",
    Action = function(self, ent)
        local pad = 2
        local f = vgui.Create("DFrame")
        f:SetTitle("Select a weapon set")
        f:SetBackgroundBlur(true)
        f:ShowCloseButton(true)
        f:SetDeleteOnClose(true)
        f:SetDraggable(true)
        f:SetSizable(false)
        f:DockPadding(0, 24, 0, 0)
        f:SetSize(150, 200)
        f:Center()
        f:MakePopup()

        f.Paint = function(_, w, h)
            draw.RoundedBox(pad * 2, 0, 0, w, h, Color(38, 50, 56, 250))
        end

        local pan = vgui.Create("DScrollPanel", f)
        pan:DockMargin(pad * 2, pad * 2, pad * 2, pad)
        pan:Dock(FILL)

        for _, name in pairs(WEAPONSETS.WeaponSetsList) do
            local bt = vgui.Create("DButton")
            bt:DockMargin(0, 0, 0, pad)
            bt:Dock(TOP)
            bt:SetText(name)

            bt.DoClick = function()
                RunConsoleCommand("weaponsets_give", name, ent:UserID())
                f:Close()
            end

            pan:AddItem(bt)
        end

        local closeBt = vgui.Create("DButton", f)
        closeBt:SetText("Cancel")
        closeBt:DockMargin(pad * 2, pad * 3, pad * 2, pad * 2)
        closeBt:Dock(BOTTOM)

        closeBt.DoClick = function()
            f:Close()
        end
    end,
    Filter = function(self, ent, ply) return IsValid(ent) and ent:IsPlayer() end
})
