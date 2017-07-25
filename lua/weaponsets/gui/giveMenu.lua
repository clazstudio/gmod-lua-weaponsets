--[[---------------------------------------------------------
    GUI - Weapon sets give menu
---------------------------------------------------------]]--

function WEAPONSETS:GiveMenu(list)
    local pad = 2

    -- Main frame
    local f = vgui.Create( "DFrame" )
    f:SetSize( 300, 250 )
    f:SetTitle( "WeaponSets Give menu" )
    f:ShowCloseButton( true )
    f:SetDeleteOnClose( true )
    f:SetDraggable( true )
    f:SetVisible( true )
    f:SetSizable( true )
    f:DockPadding( 0, 24, 0, 0 )
    f:Center()
    f:MakePopup()

    local lPan = vgui.Create( "DPanel", f )
    lPan:DockPadding( pad, pad, 0, pad )
    lPan:SetDrawBackground( false )
    lPan:Dock( FILL )

    -- Right panel
    local rPan = vgui.Create( "DPanel", f )
    rPan:DockPadding( pad, pad, pad, pad )
    rPan:SetDrawBackground( false )
    rPan:SetWidth( 100 )
    rPan:Dock( RIGHT )

    -- List
    local ls = vgui.Create( "DListView", lPan )
    ls:Dock( FILL )
    ls:DockMargin( pad, pad, pad, pad )
    ls:SetMultiSelect( true )
    ls:AddColumn( "UserID" ):SetWidth( 10 )
    ls:AddColumn( "Nick" )

    -- Refresh button
    local bt1 = vgui.Create( "DButton", lPan )
    bt1:SetText( "Refresh" )
    bt1:Dock( BOTTOM )
    bt1:DockMargin( pad, pad, pad, pad )
    bt1:SetSize( 150, 24 )
    bt1.DoClick = function()
        ls:Clear();
        for _, v in pairs( player.GetAll() ) do
            ls:AddLine( v:UserID(), v:Nick() )
        end
        if ( #ls:GetLines() > 0 ) then
            ls:SelectFirstItem() end
    end

    -- Label
    --[[local lbl1 = vgui.Create( "DLabel", pan )
    lbl1:Dock( TOP )
    lbl1:DockMargin( pad, pad, pad, pad )
    lbl1:SetContentAlignment( 4 )
    lbl1:SetText( "WeaponSet:" )
    lbl1:SetDark( true )]]

    -- Combobox
    local cb1 = vgui.Create( "DComboBox", rPan )
    cb1:SetValue( "Select a set..." )
    cb1:DockMargin( pad, pad, pad, pad )
    cb1:SetSize( 150, 20 )
    cb1:Dock( TOP )
    for k, v in pairs( list ) do
        cb1:AddChoice( v )
    end

    -- Give button
    local bt2 = vgui.Create( "DButton", rPan )
    bt2:SetText( "Give" )
    bt2:Dock( BOTTOM )
    bt2:DockMargin( pad, pad, pad, pad )
    bt2:SetSize( 150, 24 )
    bt2.DoClick = function()
        if !cb1:GetSelectedID() then return false end
        local name = cb1:GetOptionText(cb1:GetSelectedID())
        local tbl = {}

        for k, v in pairs(ls:GetSelected()) do
            table.insert(tbl, v:GetColumnText(1))
        end

        RunConsoleCommand("weaponsets_give", name, unpack(tbl))
    end

    -- Give button
    local bt3 = vgui.Create( "DButton", rPan )
    bt3:SetText( "Give to all" )
    bt3:Dock( BOTTOM )
    bt3:DockMargin( pad, pad, pad, pad )
    bt3:SetSize( 150, 24 )
    bt3.DoClick = function()
        if cb1:GetSelectedID() == -1 then return false end
        local name = cb1:GetOptionText(cb1:GetSelectedID())
        RunConsoleCommand("weaponsets_give", name)
    end

    bt1.DoClick()
    return f
end
