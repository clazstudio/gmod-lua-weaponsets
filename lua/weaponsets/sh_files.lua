WeaponSets.Sets = {}

local adminOnly = CreateConVar("weaponsets_adminonly", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE},
    "If enabled only superadmin can give and edit weaponsets")

function WeaponSets:Access(ply, perm)
    if not IsValid(ply) then return true end -- server console

    if adminOnly:GetBool() then
        self.D("Access (" .. tostring(ply) .. ", " .. perm .. ") = " .. ply:IsSuperAdmin())
        return ply:IsSuperAdmin()
    else
        return true
    end
end

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
