WEAPONSETS = WEAPONSETS or {}
WEAPONSETS.NetFuncs = WEAPONSETS.NetFuncs or {}

if SERVER then
    AddCSLuaFile("weaponsets/gui/giveMenu.lua")
    AddCSLuaFile("weaponsets/gui/editMenu.lua")
    AddCSLuaFile("weaponsets/gui/sandbox.lua")

    AddCSLuaFile("weaponsets/cl_init.lua")
    AddCSLuaFile("weaponsets/shared.lua")

    include("weaponsets/init.lua")
else
    include("weaponsets/cl_init.lua")
end
