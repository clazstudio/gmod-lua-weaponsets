--[[---------------------------------------------------------
    CLIENT - cl_init.lua
---------------------------------------------------------]]--
include("weaponsets/shared.lua" )

include("weaponsets/gui/giveMenu.lua")
include("weaponsets/gui/mainMenu.lua")
include("weaponsets/gui/editMenu.lua")


--[[---------------------------------------------------------
    Net functions
---------------------------------------------------------]]--

-- Open weapon set editing window
WEAPONSETS.NetFuncs.openEditMenu = function(data)
    WEAPONSETS:EditMenu(data.name, data.tbl)
end

-- Open main menu
WEAPONSETS.NetFuncs.openMainMenu = function(data)
    WEAPONSETS:MainMenu(data.list, data.options)
end

-- Open give menu
WEAPONSETS.NetFuncs.openGiveMenu = function(data)
    WEAPONSETS:GiveMenu(data)
end


--[[---------------------------------------------------------
    Concommands and hooks
---------------------------------------------------------]]--

net.Receive("wepsetsToCl", function()
    local name = net.ReadString();
    local data = net.ReadTable();

    if WEAPONSETS.NetFuncs[name] != nil then
        WEAPONSETS.NetFuncs[name](data) end
end)

-- sandbox toolmenu support
hook.Add("PopulateToolMenu", "weaponsets_PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Utilities", "WeaponSets", "WeaponSetsMainMenu", "Main menu", "weaponsets")
    spawnmenu.AddToolMenuOption("Utilities", "WeaponSets", "WeaponSetsGiveMenu", "Give menu", "weaponsets_give")
end)

hook.Add("AddToolMenuCategories", "weaponsets_AddToolMenuCategories", function()
	spawnmenu.AddToolCategory("Utilities", "WeaponSets", "Weapon sets")
end)
