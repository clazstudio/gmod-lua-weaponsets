--[[---------------------------------------------------------
    CLIENT - cl_init.lua
---------------------------------------------------------]]--
include( "weaponsets/shared.lua" )
include( "weaponsets/gui/giveMenu.lua" )
include( "weaponsets/gui/mainMenu.lua" )
include( "weaponsets/gui/editMenu.lua" )


--[[---------------------------------------------------------
    Net functions
---------------------------------------------------------]]--

-- Open weapon set editing window
wepsets.netFuncs.openEditMenu = function( data )
    wepsets.editMenu( data.name, data.tbl )
end

-- Open main menu
wepsets.netFuncs.openMainMenu = function( data )
    wepsets.mainMenu( data.list, data.options )
end

-- Open give menu
wepsets.netFuncs.openGiveMenu = function( data )
    wepsets.giveMenu()
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
