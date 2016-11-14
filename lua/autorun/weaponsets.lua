wepsets = wepsets or {}
wepsets.netFuncs = wepsets.netFuncs or {}

if ( SERVER ) then
    AddCSLuaFile( "weaponsets/cl_init.lua" );

    include( "weaponsets/init.lua" );
else
    include( "weaponsets/cl_init.lua" );
end
