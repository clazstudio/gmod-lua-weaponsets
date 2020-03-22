WeaponSets.Sets = {}

local adminOnly = CreateConVar("weaponsets_adminonly", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE},
    "If enabled only superadmin can give and edit weaponsets")

function WeaponSets:Access(ply, perm, target)
    if not IsValid(ply) then return true end -- server console

    local res = hook.Call("WeaponSets_Access", nil, ply, perm, target)
    return res ~= false
end

hook.Add("WeaponSets_Access", "weaponsets_adminonly", function(ply, perm)
    if adminOnly:GetBool() then
        return ply:IsSuperAdmin() or (
            (perm == "select" or perm == "retrieve_sets") and
            cvars.Bool("weaponsets_deathmatch")
        )
    end
end)

local fileCounters = {}
function WeaponSets:IdFromName(name)
    local id = string.gsub(string.lower(name), "[^%w]+", "_")

    if id == "" then
        id = "set"
    end

    if self.Sets[id] then
        local cnt = fileCounters[id] or 1
        while self.Sets[id .. cnt] do
            cnt = cnt + 1
        end
        fileCounters[id] = cnt

        return id .. cnt
    end

    return id
end

local nonScriptedAmmo = {
    -- HL2 weapons
    ["weapon_smg1"] =       {primary = "SMG1", secondary = "SMG1_Grenade"},
    ["weapon_ar2"] =        {primary = "AR2", secondary = "AR2AltFire"},
    ["weapon_frag"] =       {primary = "Grenade"},
    ["weapon_crossbow"] =   {primary = "XBowBolt"},
    ["weapon_rpg"] =        {primary = "RPG_Round"},
    ["weapon_shotgun"] =    {primary = "Buckshot"},
    ["weapon_pistol"] =     {primary = "Pistol"},
    ["weapon_slam"] =       {primary = "slam"},
    ["weapon_357"] =        {primary = "357"},
    ["weapon_alyxgun"] =    {primary = "AlyxGun"},

    -- HL1 weapons
    ["weapon_snark"] =      {primary = "Snark"},
    ["weapon_handgrenade"] = {primary = "GrenadeHL1"},
    ["weapon_mp5_hl1"] =    {primary = "9mmRound", secondary = "MP5_Grenade"}, -- 12mmRound?
    ["weapon_hornetgun"] =  {primary = "Hornet"},
    ["weapon_satchel"] =    {primary = "Satchel"},
    ["weapon_tripmine"] =   {primary = "TripMine"},
    ["weapon_crossbow_hl1"] = {primary = "XBowBoltHL1"},
    ["weapon_357_hl1"] =    {primary = "357Round"},
    ["weapon_rpg_hl1"] =    {primary = "RPG_Rocket"},
    ["weapon_shotgun_hl1"] = {primary = "BuckshotHL1"},
    ["weapon_glock_hl1"] =  {primary = "9mmRound"},
    ["weapon_gauss"] =      {primary = "Uranium"},
    ["weapon_egon"] =       {primary = "Uranium"},
}

function WeaponSets:WeaponsTable()
    local weps = {}

    if istable(list) and isfunction(list.Get) then
        for wep, tbl in pairs(list.Get("Weapon")) do
            -- if not v.Spawnable then continue end

            weps[wep] = {
                name = tbl.PrintName or wep,
                spawnable = tbl.Spawnable,
                -- category = tbl.Category,
            }

            if nonScriptedAmmo[wep] then
                weps[wep].primary = nonScriptedAmmo[wep].primary
                weps[wep].secondary = nonScriptedAmmo[wep].secondary
            end
        end
    end

    -- TODO: icons or worldmodel?
    for _, tbl in pairs(weapons.GetList()) do
        local wep = tbl.ClassName
        weps[wep] = {
            name = tbl.PrintName or wep,
            spawnable = tbl.Spawnable,
            worldmodel = tbl.WorldModel,
            adminOnly = tbl.AdminOnly,
        }
        if tbl.Primary and tbl.Primary.Ammo ~= "none" then
            weps[wep].primary = tbl.Primary.Ammo
        end
        if tbl.Secondary and tbl.Secondary.Ammo ~= "none" then
            weps[wep].secondary = tbl.Secondary.Ammo
        end
    end

    return weps
end

function WeaponSets:AmmoTable()
    local ammo = {}
    for id = 1, 128 do
        local name = game.GetAmmoName(id)
        if not name then break end
        ammo[name] = {
            primary = {},
            secondary = {}
        }
    end

    for wep, tbl in pairs(self:WeaponsTable()) do
        if tbl.primary and ammo[tbl.primary] then
            table.insert(ammo[tbl.primary].primary, wep)
        end
        if tbl.secondary and ammo[tbl.secondary] then
            table.insert(ammo[tbl.secondary].secondary, wep)
        end
    end

    return ammo
end
