--[[---------------------------------------------------------
    GUI - Weapon sets main menu
---------------------------------------------------------]]--

function wepsets.mainMenu( list, options )
    local pad = 2;

    -- Main frame
    local f = vgui.Create( "DFrame" )
    f:SetSize( 400, 300 )
    f:SetMinWidth( 250 )
    f:SetMinHeight( 300 )
    f:Center()
    f:SetTitle( "WeaponSets Main menu" );
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
    local optionsTree = vgui.Create( "DProperties", rPan )
    optionsTree:DockMargin( pad, pad, pad, pad )
    optionsTree:Dock( FILL )

    -- Divider
    local div = vgui.Create( "DHorizontalDivider", f )
    div:SetLeft( lPan )
    div:SetRight( rPan )
    div:SetDividerWidth( 4 )
    div:SetLeftMin( 150 )
    div:SetRightMin( 200 )
    div:SetLeftWidth( 150 )
    div:DockMargin( 0, 0, 0, 0 )
    div:Dock( FILL )

    ----------------[[ LEFT PANEL ]]----------------

    -- List
    local ls = vgui.Create( "DListView", lPan )
    ls:Dock( FILL )
    ls:DockMargin( pad, pad, pad, pad )
    ls:SetMultiSelect( false )
    ls:AddColumn( "Set name" )
    for _, v in pairs( list ) do
        ls:AddLine( v )
    end
    if ( #ls:GetLines() > 0 ) then
        ls:SelectFirstItem() end

    -- Remove button
    local bt1 = vgui.Create( "DButton", lPan )
    bt1:SetText( "Remove selected" )
    bt1:Dock( BOTTOM )
    bt1:DockMargin( pad, pad, pad, pad )
    bt1:SetSize( 150, 24 )
    bt1.DoClick = function()
        if ( #ls:GetLines() < 1 ) then return end
        local name = ls:GetSelected()[1]:GetColumnText( 1 )
        local ind = ls:GetSelectedLine();

        Derma_Query( "Are you sure?", "Weapon set deleting", "Delete!", function()
            net.Start( "wepsetsToSv" )
                net.WriteString( "deleteSet" );
                net.WriteTable( { name = name } );
            net.SendToServer();

            ls:RemoveLine( ind );
            if ( #ls:GetLines() > 0 ) then
                ls:SelectFirstItem() end
        end, "Cancel", nil )
    end

    -- Edit button
    local bt2 = vgui.Create( "DButton", lPan )
    bt2:SetText( "Edit selected" )
    bt2:Dock( BOTTOM )
    bt2:DockMargin( pad, pad, pad, pad )
    bt2:SetSize( 150, 24 )
    bt2.DoClick = function()
        if ( #ls:GetLines() < 1 ) then return end
        local name = ls:GetSelected()[1]:GetColumnText( 1 )
        RunConsoleCommand( "weaponsets", name )
    end

    -- Add button
    local bt3 = vgui.Create( "DButton", lPan )
    bt3:SetText( "Add new weapon set" )
    bt3:Dock( BOTTOM )
    bt3:DockMargin( pad, pad, pad, pad )
    bt3:SetSize( 150, 24 )
    bt3.DoClick = function()
        Derma_StringRequest( "New weapon set", "Enter new set's name", "newset", function ( text )
            RunConsoleCommand( "weaponsets", wepsets.fNameChange( text ) or "newset" )
            f:Close()
        end, _, "Ok", "Cancel" )
    end

    ----------------[[ RIGHT PANEL ]]----------------

    local row1 = optionsTree:CreateRow( "WeaponSets Options", "Loadout WeaponSet" )
    row1:Setup( "Combo", { text = options.loadoutset or "<default>" } )
    row1:AddChoice( "<default>", "<default>" )
    row1.DataChanged = function( self, data)
    	options.loadoutset = data
        --print( data )
    end
    for _, v in pairs( list ) do
        row1:AddChoice( v, v )
    end

    -- Only admin row
    local row2 = optionsTree:CreateRow( "WeaponSets Options", "Only admins" )
    row2:Setup( "Boolean" )
    row2:SetValue( options.onlyAdmin )
    row2.DataChanged = function( _, val )
        options.onlyAdmin = tobool( val );
    end

    -- Options save button
    local bt4 = vgui.Create( "DButton", rPan )
    bt4:SetText( "Save options" )
    bt4:Dock( BOTTOM )
    bt4:DockMargin( pad, pad, pad, pad )
    bt4:SetSize( 150, 24 )
    bt4.DoClick = function()
        net.Start( "wepsetsToSv" )
            net.WriteString( "saveOptions" );
            net.WriteTable( options );
        net.SendToServer();
    end

    return f
end

-- Derma_Query( msgText, msgTitle, bt1Text, bt1Func, bt2Text, bt2Func )
