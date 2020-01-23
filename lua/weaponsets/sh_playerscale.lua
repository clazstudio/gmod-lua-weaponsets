WeaponSets:AddOption("scale", {
    default = 1.0,
    entryType = "number",
    category = "player",
    min = 0.01,
    max = 100,
    validate = function(x) return isnumber(x) and x > 0 end,
    equip = function(ply, value)
        WeaponSets:SetPlayerSize(ply, value)
    end,
    strip = function(ply)
        WeaponSets:SetPlayerSize(ply, 1.0)
    end,
    getFromPlayer = function(ply)
        return ply.wsLastScale
    end
})

function WeaponSets:SetPlayerSize(ply, scale)
    ply:ResetHull()
    ply:SetViewOffset(Vector(0, 0, 64) * scale)
    ply:SetViewOffsetDucked(Vector(0, 0, 28) * scale)
    ply:SetCurrentViewOffset(Vector(0, 0, 64) * scale)
    --ply:SetModelScale(scale, 0) -- Broken

    if scale ~= 1 then
        local h_b, h_t = ply:GetHull()
        local d_b, d_t = ply:GetHullDuck()
        ply:SetHull(h_b * scale, h_t * scale)
        ply:SetHullDuck(d_b * scale, d_t * scale)
    end

    if SERVER then
        self.D("SetPlayerSize", ply, scale, ply.wsLastScale)
        ply:SetStepSize(ply:GetStepSize() * scale)
        ply.wsLastScale = scale
        net.Start("WeaponSets_Scale")
        net.WriteEntity(ply)
        net.WriteFloat(scale)
        net.Broadcast()
    end
end

if SERVER then
    -- TODO: use sh_net.lua
    util.AddNetworkString("WeaponSets_Scale")
    return
end

net.Receive("WeaponSets_Scale", function(len)
    local ply = net.ReadEntity()
    local scale = net.ReadFloat()
    if not IsValid(ply) or not ply:IsPlayer() then
        return
    end

    local matrix = Matrix()
    matrix:Scale(Vector(scale, scale, scale))
    ply:EnableMatrix("RenderMultiply", matrix)
    local r_min, r_max = ply:GetRenderBounds()
    local lastScale = ply.wsLastScale or 1
    WeaponSets.D("SetPlayerSize", ply, scale, lastScale)
    ply:SetRenderBounds(r_min * scale / lastScale, r_max * scale / lastScale)
    ply.wsLastScale = scale

    if ply == LocalPlayer() then
        WeaponSets:SetPlayerSize(LocalPlayer(), scale)
    end
end)
