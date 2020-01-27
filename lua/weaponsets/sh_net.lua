WeaponSets.Net = {
    -- Client -> Server
    RetrieveSets = 0,
    RetrieveSet = 1,
    UpdateSet = 2,
    GiveSetTable = 3,

    -- Server -> Client
    SendSets = 0,
    SendSet = 1,
    SendPlayers = 2,
    Response = 3
}

local typeBits = 2

if SERVER then
    util.AddNetworkString("WeaponSets")
end

function WeaponSets:StartNet(type)
    net.Start("WeaponSets")
    net.WriteUInt(type, typeBits)
    self.D("StartNet", type)
end

-- FIXME: как-нибудь покрасивее хочу, а не так

local COMPRESS_LENGTH = 512
local DATA_LENGTH_BITS = 15

function WeaponSets:NetWriteTable(tbl)
    local json = (istable(tbl)) and util.TableToJSON(tbl) or ""
    local compress = (#json > COMPRESS_LENGTH)
    net.WriteBit(compress)
    if compress then
        json = util.Compress(json)
        local len = #json
        net.WriteUInt(len, DATA_LENGTH_BITS)
        net.WriteData(json, len)
    else
        net.WriteString(json)
    end
end

function WeaponSets:NetReadTable()
    local compress = net.ReadBit(compress)
    local json = nil
    if compress == 1 then
        local len = net.ReadUInt(DATA_LENGTH_BITS)
        json = net.ReadData(len)
        json = util.Decompress(json)
    else
        json = net.ReadString()
    end
    return util.JSONToTable(json)
end

-- TODO: throttle?
net.Receive("WeaponSets", function(len, ply)
    local id = net.ReadUInt(typeBits)
    local func = WeaponSets.Net[id]
    WeaponSets.D("ReceiveNet", id)

    if func ~= nil then
        func(len, ply)
    end
end)
