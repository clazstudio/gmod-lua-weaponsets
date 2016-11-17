wepsets = wepsets or {}
wepsets.netFuncs = wepsets.netFuncs or {}

if ( SERVER ) then
    AddCSLuaFile( "weaponsets/gui/giveMenu.lua" )
    AddCSLuaFile( "weaponsets/gui/mainMenu.lua" )
    AddCSLuaFile( "weaponsets/gui/editMenu.lua" )
    AddCSLuaFile( "weaponsets/cl_init.lua" );
    AddCSLuaFile( "weaponsets/shared.lua" );

    include( "weaponsets/init.lua" );
else
    include( "weaponsets/cl_init.lua" );
end
