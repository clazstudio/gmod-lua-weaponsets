--[[---------------------------------------------------------
    GUI - Weapon sets edit window
---------------------------------------------------------]]--

function WEAPONSETS:OpenEditMenu(name, tbl)
    name, tbl = self:ValidateWeaponSet(name, tbl)
    local pad = 2 -- = padding/2 = margin/2

    local wepList = {}
    local ammoList = {}
    
    for i = 1, 50 do
        local name = game.GetAmmoName(i)
        if !name then break end
        ammoList[name] = 0
    end

    for k, v in pairs(list.Get("Weapon")) do
    	if !v.Spawnable then continue end
    	wepList[k] = { 
            ["name"] = v.PrintName or k,
            ["inSet"] = tbl.set[k] != nil 
        }
    end

    for k, v in pairs(tbl.set) do
    	if tonumber(v) > 0 then
            ammoList[k] = tonumber(v)
        elseif !wepList[k] then
            wepList[k] = { name = k, inSet = true }
        end
    end

    -- for _, v in pairs(weapons.GetList()) do
    --     local prim = (v.Primary or {}).Ammo
    --     local sec = (v.Secondary or {}).Ammo

    --     if (prim and !ammoList[prim]) then ammoList[prim] = false end
    --     if (sec and !ammoList[sec]) then ammoList[sec] = false end
    -- end
    -- PrintTable(ammoList)
    -- PrintTable(wepList)


    ----------------[[ MAIN FRAME ]]----------------
    local f = vgui.Create("DFrame")
    f:SetSize(500, 400)
    f:SetMinWidth(400)
    f:SetMinHeight(300)
    f:SetTitle("WeaponSets Edit - " .. name)
    f:DockPadding(pad, 24, pad, pad)
    f:ShowCloseButton(true)
    f:SetDeleteOnClose(true)
    f:SetDraggable(true)
    f:SetSizable(true)
    f:Center()
    f:MakePopup()

    -- DPropertySheet
    local sheet = vgui.Create("DPropertySheet", f)
    sheet:DockMargin(pad, pad, pad, pad)
    sheet:DockPadding(pad, pad, pad, pad)
    sheet:Dock(FILL)


    ----------------[[ WEAPONs LIST PANEL ]]----------------
    local wepListPan = vgui.Create("DPanel", sheet)
    wepListPan:SetDrawBackground(false)
    sheet:AddSheet("Weapons", wepListPan, "icon16/text_list_bullets.png")

    -- Panel with weapons list
    local wepScroll = vgui.Create("DScrollPanel", wepListPan)
    wepScroll:DockMargin(pad, pad, pad, pad)
    wepScroll:Dock(FILL)

    -- Panel with weapon information

    local function buildWeaponPanel(class, tbl)
        local p = vgui.Create("DButton")
        p.inSet = tbl.inSet
        p.col = p.inSet and Color(200, 230, 201) or Color(255, 205, 210)
        p:SetText(tbl.name .. " (" .. class .. ")")
        p:DockMargin(0, pad, 0, pad)
        p:SetHeight(32)
        p:Dock(TOP)

        p.DoClick = function()
            p.inSet = !p.inSet
            wepList[class].inSet = p.inSet
            p.col = p.inSet and Color(200, 230, 201) or Color(255, 205, 210)
        end

        function p:Paint(w, h)
            draw.RoundedBox(pad * 2, 0, 0, w, h, p.col)
        end

        return p
    end

    -- Scroll panel filling algorithm
    local FILL_MODE_ALL = 1
    local FILL_MODE_ADDED = 2
    local FILL_MODE_NOT_ADDED = 3
    local function fillWepScroll(fillMode)
        wepScroll:Clear()

        for k, v in pairs(wepList) do
            if v.inSet and fillMode == FILL_MODE_NOT_ADDED then continue end
            if !v.inSet and fillMode == FILL_MODE_ADDED then continue end
            wepScroll:AddItem(buildWeaponPanel(k, v))
        end
    end

    -- top weapon panel
    local wepTopPan = vgui.Create("DPanel", wepListPan)
    wepTopPan:SetDrawBackground(false)
    wepTopPan:DockMargin(pad, pad, pad, pad)
    wepTopPan:SetHeight(20)
    wepTopPan:Dock(TOP)

    -- Show mode combo
    wepShowCombo = vgui.Create("DComboBox", wepTopPan)
    wepShowCombo:SetWide(128)
    wepShowCombo:Dock(RIGHT)
    wepShowCombo:AddChoice("Show all", FILL_MODE_ALL, true)
    wepShowCombo:AddChoice("Show only added", FILL_MODE_ADDED)
    wepShowCombo:AddChoice("Show not added", FILL_MODE_NOT_ADDED)
    wepShowCombo.OnSelect = function(_, _, _, fillMode)
        fillWepScroll(fillMode)
    end

    -- Add custom weapon button
    wepCustomBt = vgui.Create("DButton", wepTopPan)
    wepCustomBt:SetText("Add weapon manually")
    wepCustomBt:SetWide(144)
    wepCustomBt:Dock(LEFT)
    wepCustomBt.DoClick = function()
        Derma_StringRequest("Manual weapon adding", "Please, enter weapon classname", "weapon_crowbar", function(val)
            if wepList[val] then
                wepList[val].inSet = true
            else
                wepList[val] = { name = "Manually added", inSet = true }
            end

            local _, fm = wepShowCombo:GetSelected()
            fillWepScroll(fm)
        end, nil, "Add it", "Cancel")
    end

    fillWepScroll(FILL_MODE_ALL)

    -- -- List
    -- local ls = vgui.Create( "DListView", lPan )
    -- ls:Dock( FILL )
    -- ls:DockMargin( pad, pad, pad, pad )
    -- ls:SetMultiSelect( false )
    -- ls:AddColumn( "Name" );
    -- ls:AddColumn( "Count" );
    -- for k,v in pairs( tbl.set ) do
    --     ls:AddLine( k, v )
    -- end
    -- ls:SelectFirstItem();

    -- -- Remove button
    -- local bt1 = vgui.Create( "DButton", lPan )
    -- bt1:SetText( "Remove selected item" )
    -- bt1:Dock( BOTTOM )
    -- bt1:DockMargin( pad, pad, pad, pad )
    -- bt1:SetSize( 150, 24 )
    -- bt1.DoClick = function()
    --     if ( #ls:GetLines() > 0 ) then
    --         local rem = ls:GetSelectedLine();
    --         ls:RemoveLine( rem );
    --         ls:SelectFirstItem();
    --     end
    -- end

    -- -- Creating DNumberWang with DLabel
    -- local function labWang( val, min, max, label )
    --     local pan = vgui.Create( "DPanel" )
    --     pan:SetDrawBackground( false )
    --     pan:DockMargin( pad, pad, pad, pad )
    --     pan:DockPadding( 0, 0, 0, 0)
    --     pan:Dock( TOP )

    --     local t1 = vgui.Create( "DNumberWang", pan )
    --     t1:Dock( RIGHT )
    --     t1:SetSize( 100, 20 )
    --     t1:SetMinMax( min, max )
    --     t1:SetValue( val )
    --     t1:SetDecimals( 0 )

    --     local lbl1 = vgui.Create( "DLabel", pan )
    --     lbl1:Dock( FILL )
    --     lbl1:SetContentAlignment( 6 )
    --     lbl1:SetText( label )
    --     lbl1:SetDark( true )

    --     pan.numberWang = t1
    --     return pan
    -- end

    -- -- Weapon panel
    -- local wepPan = vgui.Create( "DPanel", rPan )
    -- wepPan:DockMargin( pad, pad, pad, pad )
    -- wepPan:DockPadding( pad, pad, pad, pad )
    -- wepPan:SetHeight( 20 + 24 + pad * 6 )
    -- wepPan:Dock( TOP )

    --     local cb1 = vgui.Create( "DComboBox", wepPan ) -- Weapon
    --     cb1:SetValue( "Select a weapon..." )
    --     cb1:DockMargin( pad, pad, pad, pad )
    --     cb1:SetSize( 150, 20 )
    --     cb1:Dock( TOP )
    --     for k, v in pairs( weplist ) do
    --         cb1:AddChoice( tostring(v[2]) .. " (" .. tostring(k) .. ")", tostring(k) )
    --     end

    --     local bt2 = vgui.Create( "DButton", wepPan )
    --     bt2:SetText( "Add weapon" )
    --     bt2:DockMargin( pad, pad, pad, pad )
    --     bt2:Dock( BOTTOM )
    --     bt2:SetSize( 150, 24 )
    --     bt2.DoClick = function()
    --         if !cb1:GetSelectedID() then return false end
    --         ls:ClearSelection();
    --         local val = cb1:GetOptionData( cb1:GetSelectedID() );
    --         ls:AddLine( val, "-1" ):SetSelected( true )
    --     end

    -- -- Ammo panel
    -- local ammoPan = vgui.Create( "DPanel", rPan )
    -- ammoPan:DockMargin( pad, pad, pad, pad )
    -- ammoPan:DockPadding( pad, pad, pad, pad)
    -- ammoPan:SetHeight( 68 + pad * 8 )
    -- ammoPan:Dock( TOP )

    --     local cb2 = vgui.Create( "DComboBox", ammoPan ) -- Ammo
    --     cb2:SetValue( "Select an ammo type..." )
    --     cb2:Dock( TOP )
    --     cb2:DockMargin( pad, pad, pad, pad )
    --     cb2:SetSize( 150, 20 )
    --     for _,v in pairs( ammolist ) do
    --         cb2:AddChoice( tostring(v) )
    --     end

    --     -- Ammo count pan
    --     local ammoCountPan = labWang( 256, 1, 9999, "Ammo count: " )
    --     ammoCountPan:SetParent( ammoPan )

    --     local bt3 = vgui.Create( "DButton", ammoPan )
    --     bt3:SetText( "Add ammo" )
    --     bt3:Dock( BOTTOM )
    --     bt3:DockMargin( pad, pad, pad, pad )
    --     bt3:SetSize( 150, 24 )
    --     bt3.DoClick = function()
    --         if !cb2:GetSelectedID() then return false end
    --         local val1 = ammoCountPan.numberWang:GetValue()
    --         local val2 = cb2:GetOptionText( cb2:GetSelectedID() )

    --         if game.GetAmmoID( val2 ) == -1 then
    --             Derma_Message( "Ammo type don't found", "WeaponSets", "Ok" )
    --             return false
    --         end

    --         ls:ClearSelection()
    --         val1 = math.max( val1, -1 )
    --         ls:AddLine( val2, val1 ):SetSelected( true )
    --     end

    -- -- Custom adding panel
    -- local custPan = vgui.Create( "DPanel", rPan )
    -- custPan:DockMargin( pad, pad, pad, pad )
    -- custPan:DockPadding( pad, pad, pad, pad )
    -- custPan:SetHeight( 64 + pad * 10 )
    -- custPan:Dock( TOP )

    --     local e1 = vgui.Create( "DTextEntry", custPan )
    --     e1:Dock( TOP )
    --     e1:DockMargin( pad, pad, pad, pad )
    --     e1:SetSize( 150, 20 )
    --     e1:SetText( "weapon_crowbar" )

    --     local custValuePan = labWang( -1, -1, 9999, "Value: " )
    --     custValuePan:SetParent( custPan )

    --     local bt5 = vgui.Create( "DButton", custPan )
    --     bt5:SetText( "Add custom" )
    --     bt5:DockMargin( pad, pad, pad, pad )
    --     bt5:Dock( TOP )
    --     bt5:SetSize( 150, 24 )
    --     bt5.DoClick = function()
    --         ls:ClearSelection();
    --         local val = custValuePan.numberWang:GetValue()
    --         val = math.max( val, -1 )
    --         ls:AddLine( e1:GetValue(), val ):SetSelected( true )
    --     end


    ----------------[[ AMMOES LIST PANEL ]]----------------
    local ammoListPan = vgui.Create("DPanel", sheet)
    ammoListPan:SetDrawBackground(false)
    sheet:AddSheet("Ammoes", ammoListPan, "icon16/box.png")

    local ammoListProp = vgui.Create("DProperties", ammoListPan)
    ammoListProp:DockMargin(pad, pad, pad, pad)
    ammoListProp:Dock(FILL)

    local function fillAmmoList()
        ammoListProp:Clear()
        for k, v in pairs(ammoList) do
            local category = v == 0 and "Not in set" or "In set" 
            local row = ammoListProp:CreateRow(category, k)
            row:Setup("Int", { min = 0, max = 1000 })
            row:SetValue(v)
            row.DataChanged = function(_, val)
                ammoList[k] = val
            end
        end
    end
    fillAmmoList()
    
    local ammoCustomBt = vgui.Create("DButton", ammoListPan)
    ammoCustomBt:DockMargin(pad, pad, pad, pad)
    ammoCustomBt:SetText("Add ammo manually")
    ammoCustomBt:Dock(BOTTOM)
    ammoCustomBt.DoClick = function()
        Derma_StringRequest("Manual ammo adding", "Please, enter an ammo name", "Pistol", function(ammoName)
        Derma_StringRequest("Manual ammo adding", "Enter ammo count:", "0", function(ammoCount)
            ammoCount = tonumber(ammoCount) or 0
            if ammoCount < 1 or ammoName == "" then return end
            if game.GetAmmoID(ammoName) == -1 then
                Derma_Message("Unknown for game engine ammo name!", "Manual ammo adding", "Ok")
            end
            ammoList[ammoName] = ammoCount
            fillAmmoList()
        end, nil, "Add it!", "Cancel")
        end, nil, "Ok", "Cancel")
    end

    ----------------[[ PLAYER SETTINGS PANEL ]]----------------
    local plySetPan = vgui.Create("DPanel", sheet)
    plySetPan:SetDrawBackground(false)
    sheet:AddSheet("Player settings", plySetPan, "icon16/user_edit.png")

    -- Tree
    local plyProp = vgui.Create( "DProperties", plySetPan )
    plyProp:DockMargin( pad, pad, pad, pad )
    plyProp:Dock( FILL )

    -- Weapon strip row
    local plyRow1 = plyProp:CreateRow( "Booleans", "Strip weapons before giving" )
    plyRow1:Setup( "Boolean" )
    plyRow1:SetValue( tbl.stripweapons == true and 1 or 0 )
    plyRow1.DataChanged = function( _, val )
        tbl.stripweapons = val
    end

    -- Ammo strip row
    local plyRow2 = plyProp:CreateRow( "Booleans", "Strip ammo before giving" )
    plyRow2:Setup( "Boolean" )
    plyRow2:SetValue( tbl.stripammo == true and 1 or 0 )
    plyRow2.DataChanged = function( _, val )
        tbl.stripammo = val
    end

    -- Flashlight row
    local plyRow3 = plyProp:CreateRow( "Booleans", "Allow flashlight" )
    plyRow3:Setup( "Boolean" )
    plyRow3:SetValue( tbl.allowflashlight == true and 1 or 0 )
    plyRow3.DataChanged = function( _, val )
        tbl.allowflashlight = val
    end

    -- Drop weapons on death row
    local plyRowBool4 = plyProp:CreateRow( "Booleans", "Drop weapons on death" )
    plyRowBool4:Setup( "Boolean" )
    plyRowBool4:SetValue( tbl.dropweapons == true and 1 or 0 )
    plyRowBool4.DataChanged = function( _, val )
        tbl.dropweapons = val
    end

    -- Number rows
    local function numRow( cat, text, typ, def, min, max, func )
        local row = plyProp:CreateRow( cat, text )
        row:Setup( typ, { min = min, max = max } )
        row:SetValue( def or min )
        row.DataChanged = function( _, val )
            --val = math.min( val, max )
            val = math.max( val, min )
            if ( func != nil ) then
                func( val ) end
        end
    end

    -- Health row
    local plyRow4 = numRow( "Numbers", "Health (-1 = don't change)", "Int",
                            tbl.health, -1, 2147483647, function( val )
        tbl.health = val;
    end )

    -- MaxHealth row
    local plyRow5 = numRow( "Numbers", "Max health (or -1)", "Int",
                            tbl.maxhealth, -1, 2147483647, function( val )
        tbl.maxhealth = val;
    end )

    -- Armor row
    local plyRow6 = numRow( "Numbers", "Armor (or -1)", "Int",
                            tbl.armor, -1, 255, function( val )
        tbl.armor = val;
    end )

    -- Jump row
    local plyRow7 = numRow( "Numbers", "Jump power (or -1)", "Int",
                            tbl.jump, -1, 10000, function( val )
        tbl.jump = val;
    end )

    -- Gravity row
    local plyRow8 = numRow( "Numbers", "Gravity (def. 1)", "Float",
                            tbl.gravity or 1, 0, 10, function( val )
        tbl.gravity = val;
    end )

    -- Speed row
    local plyRow9 = numRow( "Numbers", "Speed multiplier (def. 1)", "Float",
                            tbl.speed or 1, 0, 100, function( val )
        tbl.speed = val;
    end )

    -- Opacity row
    local plyRow10 = numRow( "Numbers", "Opacity (-1 = no draw)", "Int",
                            tbl.opacity or 255, -1, 255, function( val )
        tbl.opacity = val;
    end )

    -- Friction row
    local plyRow11 = numRow( "Numbers", "Friction (-1 = don't change)", "Float",
                            tbl.friction or 1, -1, 2, function( val )
        tbl.friction = val;
    end )

    -- Scale row
    local plyRow12 = numRow( "Numbers", "Scale [experimental] (def. 1)", "Float",
                            tbl.scale or 1, 0.01, 20, function( val )
        tbl.scale = val;
    end )

    -- Blood type row
    local bloodCombo = plyProp:CreateRow("Other", "Blood type")
    bloodCombo:Setup("Combo", {text = WEAPONSETS.BloodEnums[tbl.blood] or "Don't change"})
    for k, v in pairs(WEAPONSETS.BloodEnums) do
        bloodCombo:AddChoice(v, k)
    end
    bloodCombo:AddChoice("Don't change", -10)
    bloodCombo.DataChanged = function(self, data)
        tbl.blood = data
    end

    ----------------[[ SAVE BUTTON ]]----------------

    local bt4 = vgui.Create( "DButton", f )
    bt4:SetText( "Save and exit" )
    bt4:Dock( BOTTOM )
    bt4:DockMargin( pad, pad, pad, pad )
    bt4:SetSize( 150, 32 )
    bt4.DoClick = function()
        tbl.set = {}
        for k, v in pairs(wepList) do
            if v.inSet then
                tbl.set[k] = -1
            end
        end
        for k, v in pairs(ammoList) do
            if v > 0 then
                tbl.set[k] = v
            end
        end

        net.Start("wepsetsToSv")
            net.WriteString("saveSet")
            net.WriteTable({ name = name, tbl = tbl })
        net.SendToServer()

        f:Close()
    end

    return f
end
