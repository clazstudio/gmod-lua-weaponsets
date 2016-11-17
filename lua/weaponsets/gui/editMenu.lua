--[[---------------------------------------------------------
    GUI - Weapon sets edit menu
---------------------------------------------------------]]--

function wepsets.editMenu( name, tbl )
    local pad = 2 -- = padding/2 = margin/2

    local weplist = {
        --[["weapon_357" = {""},
        "weapon_alyxgun" = {},
        "weapon_annabelle" = {},
        "weapon_ar2" = {},
        "weapon_bugbait" = {},
        "weapon_citizenpackage" = {},
        "weapon_citizensuitcase" = {},
        "weapon_crossbow" = {},
        "weapon_crowbar" = {},
        "weapon_frag" = {},
        "weapon_physcannon" = {},
        "weapon_physgun" = {},
        "weapon_pistol" = {},
        "weapon_rpg" = {},
        "weapon_shotgun" = {},
        "weapon_smg1" = {},
        "weapon_stunstick" = {}]]
        --"gmod_camera" = {},
        --"gmod_tool" = {},
        --"weapon_medkit" = {},
        --"weapon_fists" = {}
    }

    local ammolist = {}

    for i = 1, 25 do
        if (game.GetAmmoName(i) == nil) then break end
        table.insert(ammolist, game.GetAmmoName(i))
    end

    for k, v in pairs( list.Get( "Weapon" ) ) do
    	if ( !v.Spawnable ) then continue end
    	weplist[k] = {v.Category, v.PrintName or k};
    end

    for _, v in pairs( weapons.GetList() ) do
        local prim = (v.Primary or {}).Ammo
        local sec = (v.Secondary or {}).Ammo
        if (prim != nil and !table.HasValue(ammolist, prim)) then
            table.insert(ammolist, prim) end
        if (sec != nil and !table.HasValue(ammolist, sec)) then
            table.insert(ammolist, sec) end
        --[[if ( !v.Spawnable ) then continue end
        if (v.ClassName == nil) then continue end
        weplist[v.ClassName] = {v.PrintName, v.Slot, prim, sec}]]
    end

    --[[PrintTable(weplist)
    print("---------------------------")
    PrintTable(ammolist)]]

    ----------------[[ MAIN FORM ]]----------------

    -- Main frame
    local f = vgui.Create( "DFrame" )
    f:SetSize( 450, 350 )
    f:SetMinWidth( 400 )
    f:SetMinHeight( 350 )
    f:Center()
    f:SetTitle( "WeaponSets Edit - "..name );
    f:ShowCloseButton( true )
    f:SetDeleteOnClose( true )
    f:SetDraggable( true )
    f:SetSizable( true )
    f:SetVisible( true )
    f:DockPadding( pad, 24, pad, pad )
    f:MakePopup()

    -- DPropertySheet
    local sheet = vgui.Create( "DPropertySheet", f )
    sheet:DockMargin( pad, pad, pad, pad )
    sheet:DockPadding( pad, pad, pad, pad )
    sheet:Dock( FILL )

    -- Weapon list panel
    local wepListPan = vgui.Create( "DPanel", sheet )
    wepListPan:SetDrawBackground( false )
    sheet:AddSheet( "Weapon list", wepListPan, "icon16/text_list_bullets.png" )

    -- Player settings panel
    local plySetPan = vgui.Create( "DPanel", sheet )
    plySetPan:SetDrawBackground( false )
    sheet:AddSheet( "Player settings", plySetPan, "icon16/user_edit.png" )

    ----------------[[ WEAPON LIST PANEL ]]----------------

    -- Left panel
    local lPan = vgui.Create( "DPanel", wepListPan )
    lPan:SetDrawBackground( false )

    -- Right panel
    local rPan = vgui.Create( "DPanel", wepListPan )
    rPan:SetDrawBackground( false )

    -- Divider
    local div = vgui.Create( "DHorizontalDivider", wepListPan )
    div:SetLeft( lPan )
    div:SetRight( rPan )
    div:SetDividerWidth( 4 )
    div:SetLeftMin( 200 )
    div:SetRightMin( 200 )
    div:SetLeftWidth( 200 )
    div:DockMargin( 0, 0, 0, 0 )
    div:Dock( FILL )

    ----------------[[ LEFT PANEL ]]----------------

    -- List
    local ls = vgui.Create( "DListView", lPan )
    ls:Dock( FILL )
    ls:DockMargin( pad, pad, pad, pad )
    ls:SetMultiSelect( false )
    ls:AddColumn( "Name" );
    ls:AddColumn( "Count" );
    for k,v in pairs( tbl.set ) do
        ls:AddLine( k, v )
    end
    ls:SelectFirstItem();

    -- Remove button
    local bt1 = vgui.Create( "DButton", lPan )
    bt1:SetText( "Remove selected item" )
    bt1:Dock( BOTTOM )
    bt1:DockMargin( pad, pad, pad, pad )
    bt1:SetSize( 150, 24 )
    bt1.DoClick = function()
        if ( #ls:GetLines() > 0 ) then
            local rem = ls:GetSelectedLine();
            ls:RemoveLine( rem );
            ls:SelectFirstItem();
        end
    end

    ----------------[[ RIGHT PANEL ]]----------------

    -- Creating DNumberWang with DLabel
    local function labWang( val, min, max, label )
        local pan = vgui.Create( "DPanel" )
        pan:SetDrawBackground( false )
        pan:DockMargin( pad, pad, pad, pad )
        pan:DockPadding( 0, 0, 0, 0)
        pan:Dock( TOP )

        local t1 = vgui.Create( "DNumberWang", pan )
        t1:Dock( RIGHT )
        t1:SetSize( 100, 20 )
        t1:SetValue( val )
        t1:SetMinMax( min, max )
        t1:SetDecimals( 0 )

        local lbl1 = vgui.Create( "DLabel", pan )
        lbl1:Dock( FILL )
        lbl1:SetContentAlignment( 6 )
        lbl1:SetText( label )
        lbl1:SetDark( true )

        pan.numberWang = t1
        return pan
    end

    -- Weapon panel
    local wepPan = vgui.Create( "DPanel", rPan )
    wepPan:DockMargin( pad, pad, pad, pad )
    wepPan:DockPadding( pad, pad, pad, pad)
    wepPan:SetHeight( 20 + 24 + pad * 6 )
    wepPan:Dock( TOP )

        local cb1 = vgui.Create( "DComboBox", wepPan ) -- Weapon
        cb1:DockMargin( pad, pad, pad, pad )
        cb1:SetSize( 150, 20 )
        cb1:Dock( TOP )
        for k, v in pairs( weplist ) do
            cb1:AddChoice( v[2].." ("..k..")", k )
        end
        cb1:ChooseOptionID( math.random( 1,5 ) )

        local bt2 = vgui.Create( "DButton", wepPan )
        bt2:SetText( "Add weapon" )
        bt2:DockMargin( pad, pad, pad, pad )
        bt2:Dock( BOTTOM )
        bt2:SetSize( 150, 24 )
        bt2.DoClick = function()
            ls:ClearSelection();
            local val = cb1:GetOptionData( cb1:GetSelectedID() );
            ls:AddLine( val, "-1" ):SetSelected( true )
        end

    -- Ammo panel
    local ammoPan = vgui.Create( "DPanel", rPan )
    ammoPan:DockMargin( pad, pad, pad, pad )
    ammoPan:DockPadding( pad, pad, pad, pad)
    ammoPan:SetHeight( 68 + pad * 8 )
    ammoPan:Dock( TOP )

        local cb2 = vgui.Create( "DComboBox", ammoPan ) -- Ammo
        cb2:Dock( TOP )
        cb2:DockMargin( pad, pad, pad, pad )
        cb2:SetSize( 150, 20 )
        for _,v in pairs( ammolist ) do
            cb2:AddChoice( v )
        end
        cb2:ChooseOptionID( math.random( 1, #ammolist-1 ) )

        -- Ammo count pan
        local ammoCountPan = labWang( 256, 1, 9999, "Ammo count: " )
        ammoCountPan:SetParent( ammoPan )

        local bt3 = vgui.Create( "DButton", ammoPan )
        bt3:SetText( "Add ammo" )
        bt3:Dock( BOTTOM )
        bt3:DockMargin( pad, pad, pad, pad )
        bt3:SetSize( 150, 24 )
        bt3.DoClick = function()
            local val1 = ammoCountPan.numberWang:GetValue()
            local val2 = cb2:GetOptionText( cb2:GetSelectedID() )

            if game.GetAmmoID( val2 ) == -1 then
                Derma_Message( "Ammo type don't found", "WeaponSets", "Ok" ) end

            ls:ClearSelection()
            val1 = math.max( val1, -1 )
            ls:AddLine( val2, val1 ):SetSelected( true )
        end

    -- Custom adding panel
    local custPan = vgui.Create( "DPanel", rPan )
    custPan:DockMargin( pad, pad, pad, pad )
    custPan:DockPadding( pad, pad, pad, pad )
    custPan:SetHeight( 64 + pad * 10 )
    custPan:Dock( TOP )

        local e1 = vgui.Create( "DTextEntry", custPan )
        e1:Dock( TOP )
        e1:DockMargin( pad, pad, pad, pad )
        e1:SetSize( 150, 20 )
        e1:SetText( "weapon_crowbar" )

        local custValuePan = labWang( -1, -1, 9999, "Value: " )
        custValuePan:SetParent( custPan )

        local bt5 = vgui.Create( "DButton", custPan )
        bt5:SetText( "Add custom" )
        bt5:DockMargin( pad, pad, pad, pad )
        bt5:Dock( TOP )
        bt5:SetSize( 150, 24 )
        bt5.DoClick = function()
            ls:ClearSelection();
            local val = custValuePan.numberWang:GetValue()
            val = math.max( val, -1 )
            ls:AddLine( e1:GetValue(), val ):SetSelected( true )
        end

    ----------------[[ PLAYER SETTINGS PANEL ]]----------------

    -- Tree
    local plyProp = vgui.Create( "DProperties", plySetPan )
    plyProp:DockMargin( pad, pad, pad, pad )
    plyProp:Dock( FILL )

    -- Weapon strip row
    local plyRow1 = plyProp:CreateRow( "Booleans", "Strip weapons before giving" )
    plyRow1:Setup( "Boolean" )
    plyRow1:SetValue( tbl.stripweapons or 0 )
    plyRow1.DataChanged = function( _, val )
        tbl.stripweapons = val;
    end

    -- Ammo strip row
    local plyRow2 = plyProp:CreateRow( "Booleans", "Strip ammo before giving" )
    plyRow2:Setup( "Boolean" )
    plyRow2:SetValue( tbl.stripammo or 0 )
    plyRow2.DataChanged = function( _, val )
        tbl.stripammo = val;
    end

    -- Flashlight row
    local plyRow3 = plyProp:CreateRow( "Booleans", "Allow flashlight" )
    plyRow3:Setup( "Boolean" )
    plyRow3:SetValue( tbl.allowflashlight or 1 )
    plyRow3.DataChanged = function( _, val )
        tbl.allowflashlight = val;
    end

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
                            tbl.jump, -1, 100000, function( val )
        tbl.jump = val;
    end )

    -- Gravity row
    local plyRow8 = numRow( "Numbers", "Gravity multiplier", "Float",
                            tbl.gravity or 1, 0, 10, function( val )
        tbl.gravity = val;
    end )

    -- Speed row
    local plyRow9 = numRow( "Numbers", "Speed multiplier", "Float",
                            tbl.speed or 1, 0, 100, function( val )
        tbl.speed = val;
    end )

    ----------------[[ SAVE BUTTON ]]----------------

    local bt4 = vgui.Create( "DButton", f )
    bt4:SetText( "Save and exit" )
    bt4:Dock( BOTTOM )
    bt4:DockMargin( pad, pad, pad, pad )
    bt4:SetSize( 150, 32 )
    bt4.DoClick = function()
        tbl.set = {}
        for k,v in pairs( ls:GetLines() ) do
            tbl.set[v:GetValue( 1 )] = v:GetValue( 2 );
        end
        -- PrintTable( tbl )

        net.Start( "wepsetsToSv" )
            net.WriteString( "saveSet" );
            net.WriteTable( { name = name, tbl = tbl } );
        net.SendToServer();

        f:Close()
    end

    return f
end
