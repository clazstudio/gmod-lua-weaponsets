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
    id = string.gsub(string.lower(name), "[^%w]+", "_")

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
