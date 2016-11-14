
wepsets.sets = wepsets.sets or {}


--[[---------------------------------------------------------
    Window with list of sets
---------------------------------------------------------]]--
function wepsets.mainMenu( list, options )

end


--[[---------------------------------------------------------
    Set editing window
---------------------------------------------------------]]--
function wepsets.editMenu( name, tbl )
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

    PrintTable(weplist)
    print("---------------------------")
    PrintTable(ammolist)

    --------[[ MAIN FORM ]]---------

    local pad = 2

    -- Creating DNumberWang with DLabel
    local function labWang( val, min, max, label, func )
        local pan = vgui.Create( "DPanel" )
        pan:SetDrawBackground( false )
        pan:DockMargin( pad, pad, pad, pad )
        pan:DockPadding( 0, 0, 0, 0)
        pan:Dock( BOTTOM )

        local t1 = vgui.Create( "DNumberWang", pan )
        t1:Dock( RIGHT )
        t1:SetSize( 100, 20 )
        t1:SetValue( val )
        t1:SetMinMax( min, max )
        t1:SetDecimals( 0 )
        t1.OnValueChanged = function()
            if func != nil then
                local val = t1:GetValue()
                val = math.max( val, min )
                val = math.min( val, max )
                func( t1:GetValue() )
            end
        end

        local lbl1 = vgui.Create( "DLabel", pan )
        lbl1:Dock( FILL )
        lbl1:SetContentAlignment( 6 )
        lbl1:SetText( label )

        pan.numberWang = t1
        pan.label = lbl1
        return pan
    end

    -- Main frame
    local f = vgui.Create( "DFrame" )
    f:SetSize( 400, 400 )
    f:SetMinWidth( 400 )
    f:SetMinHeight( 300 )
    f:Center()
    f:SetTitle( "WeaponSets - "..name );
    f:ShowCloseButton( true )
    f:SetDeleteOnClose( true )
    f:SetDraggable( true )
    f:SetSizable( true )
    f:SetVisible( true )
    f:DockPadding( 0, 24, 0, 0 )
    f:MakePopup()

    -- Left panel
    local lPan = vgui.Create( "DPanel", f )
    lPan:DockPadding( pad, pad, pad, pad )
    lPan:SetDrawBackground( false )

    -- Right panel
    local rPan = vgui.Create( "DPanel", f )
    rPan:DockPadding( pad, pad, pad, pad )
    rPan:SetDrawBackground( false )

    -- Divider
    local div = vgui.Create( "DHorizontalDivider", f )
    div:SetLeft( lPan )
    div:SetRight( rPan )
    div:SetDividerWidth( 4 )
    div:SetLeftMin( 200 )
    div:SetRightMin( 200 )
    div:SetLeftWidth( 200 )
    div:DockMargin( 0, 0, 0, 0 )
    div:Dock( FILL )

    --------[[ LEFT PANEL ]]---------

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

    -- Health
    local healthPan = labWang( tbl.health, -1, 2147483647, "Health: ", function( val )
        tbl.health = val
    end )
    healthPan:SetParent(lPan);

    -- Armor
    local armorPan = labWang( tbl.armor, -1, 255, "Armor: ", function( val )
        tbl.armor = val
    end )
    armorPan:SetParent(lPan);

    -- Strip weapons
    local b1 = vgui.Create( "DCheckBoxLabel", lPan )
    b1:Dock( BOTTOM )
    b1:DockMargin( pad, pad, pad, pad )
    b1:SetText( "Strip weapons before giving" )
    b1:SetValue( tbl.stripweapons )
    b1:SizeToContents()
    b1.OnChange = function( self, val )
        tbl.stripweapons = val;
    end

    -- Strip ammo
    local b2 = vgui.Create( "DCheckBoxLabel", lPan )
    b2:Dock( BOTTOM )
    b2:DockMargin( pad, pad, pad, pad )
    b2:SetText( "Strip ammo before giving" )
    b2:SetValue( tbl.stripammo )
    b2:SizeToContents()
    b2.OnChange = function( self, val )
        tbl.stripammo = val;
    end

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

    --------[[ RIGHT PANEL ]]---------

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
        local ammoCountPan =  labWang( 100, 1, 9999, "Ammo count: ", nil )
        ammoCountPan.label:SetDark( true )
        ammoCountPan:SetParent( ammoPan )
        ammoCountPan:Dock( TOP )

        local bt3 = vgui.Create( "DButton", ammoPan )
        bt3:SetText( "Add ammo" )
        bt3:Dock( BOTTOM )
        bt3:DockMargin( pad, pad, pad, pad )
        bt3:SetSize( 150, 24 )
        bt3.DoClick = function()
            ls:ClearSelection();
            local val1 = ammoCountPan.numberWang:GetValue()
            val1 = math.max( val1, -1 )
            local val2 = cb2:GetOptionText( cb2:GetSelectedID() );
            ls:AddLine( val2, val1 ):SetSelected( true )
        end

    -- Custom adding panel
    local custPan = vgui.Create( "DPanel", rPan )
    custPan:DockMargin( pad, pad, pad, pad )
    custPan:DockPadding( pad, pad, pad, pad )
    custPan:SetHeight( 64 + pad * 8 )
    custPan:Dock( TOP )

        local e1 = vgui.Create( "DTextEntry", custPan )
        e1:Dock( TOP )
        e1:DockMargin( pad, pad, pad, pad )
        e1:SetSize( 150, 20 )
        e1:SetText( "weapon_crowbar" )

        local custValuePan =  labWang( -1, -1, 9999, "Value: ", nil )
        custValuePan.label:SetDark( true )
        custValuePan:SetParent( custPan )
        custValuePan:Dock( TOP )

        --[[local e2 = vgui.Create( "DTextEntry", custPan )
        e2:Dock( TOP )
        e2:DockMargin( pad, pad, pad, pad )
        e2:SetSize( 150, 20 )
        e2:SetText( "-1" )]]

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

    -- Save button
    local bt4 = vgui.Create( "DButton", f )
    bt4:SetText( "Save and exit" )
    bt4:Dock( BOTTOM )
    bt4:DockMargin( pad*2, pad*2, pad*2, pad*2)
    bt4:SetSize( 150, 32 )
    bt4.DoClick = function()
        tbl.set = {}
        for k,v in pairs( ls:GetLines() ) do
            tbl.set[v:GetValue( 1 )] = v:GetValue( 2 );
        end
        PrintTable( tbl )

        net.Start( "wepsetsToSv" )
            net.WriteString( "saveSet" );
            net.WriteTable( { name = name, tbl = tbl } );
        net.SendToServer();

        f:Close()
    end
end


--[[---------------------------------------------------------
    Net functions
---------------------------------------------------------]]--

-- Open weapon set editing window
wepsets.netFuncs.openEditMenu = function( data )
    wepsets.editMenu( data.name, data.tbl )
end

-- Open main menu (set selecting and settings)
wepsets.netFuncs.openMainMenu = function( data )
    wepsets.mainMenu( data.list, data.options )
end


--[[---------------------------------------------------------
    Concommands and hooks
---------------------------------------------------------]]--

net.Receive( "wepsetsToCl", function( _ )
    local name = net.ReadString();
    local data = net.ReadTable();

    if wepsets.netFuncs[name] != nil then
        wepsets.netFuncs[name]( data ) end
end )
