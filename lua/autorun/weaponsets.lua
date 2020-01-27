WeaponSets = WeaponSets or {}
WeaponSets.Version = 202001221 -- YYYYMMDDX
WeaponSets.Debug = true

if SERVER then
    AddCSLuaFile("weaponsets/sh_core.lua")
    AddCSLuaFile("weaponsets/sh_playerscale.lua")
    AddCSLuaFile("weaponsets/sh_net.lua")
    AddCSLuaFile("weaponsets/sh_files.lua")

    AddCSLuaFile("weaponsets/cl_lang.lua")
    AddCSLuaFile("weaponsets/cl_files.lua")
    AddCSLuaFile("weaponsets/gui/sandbox.lua")

    local lang_files = file.Find("weaponsets/lang/*.lua", "LUA")
    for _, lang_file in ipairs(lang_files) do
        AddCSLuaFile("weaponsets/lang/" .. lang_file)
    end

    include("weaponsets/sh_core.lua")
    include("weaponsets/sh_playerscale.lua")
    include("weaponsets/sh_net.lua")
    include("weaponsets/sh_files.lua")

    include("weaponsets/sv_core.lua")
    include("weaponsets/sv_files.lua")
    include("weaponsets/sv_commands.lua")
else
    include("weaponsets/sh_core.lua")
    include("weaponsets/sh_playerscale.lua")
    include("weaponsets/sh_net.lua")
    include("weaponsets/sh_files.lua")

    include("weaponsets/cl_lang.lua")
    include("weaponsets/cl_files.lua")
    include("weaponsets/gui/sandbox.lua")
end

WeaponSets.D("Init complete", #WeaponSets._optionsOrder .. " options")

-- By CLazStudio
