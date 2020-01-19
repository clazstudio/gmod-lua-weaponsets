--[[---------------------------------------------------------
    SERVER - player.lua
-----------------------------------------------------------]]
local meta = FindMetaTable("Player")

-- Gets player's loadout weapon set
function meta:GetWeaponSet()
    return self:GetPData("loadoutWeaponSet", "<inherit>")
end

-- Sets player's loadout weapon set
function meta:SetWeaponSet(name)
    return self:SetPData("loadoutWeaponSet", name)
end

-- Gives player a weapon set
function meta:GiveWeaponSet(name)
    name = name or self:GetWeaponSet()

    return WEAPONSETS:Give(self, name)
end
