--[[---------------------------------------------------------
    SERVER - init.lua
---------------------------------------------------------]]--
include( "weaponsets/shared.lua" )

wepsets.pasteBinSets = "Q72iy08U"
wepsets.version = "21.09.15";
wepsets.options = wepsets.options or {
    loadoutset = "<default>",
    onlyAdmin = true
}

util.AddNetworkString( "wepsetsToSv" )
util.AddNetworkString( "wepsetsToCl" )


--[[---------------------------------------------------------
    Player access
---------------------------------------------------------]]--
function wepsets.cancmd( ply )
    if !ply then return false end
    if ( wepsets.options.onlyAdmin == true ) then
        return ply:IsSuperAdmin()
    else
        return true
    end
end


--[[---------------------------------------------------------
    File functions
---------------------------------------------------------]]--

-- File exists and addon folder creation
function wepsets.fExists( path )
    if ( !file.Exists( "weaponsets", "DATA" ) ) then
        file.CreateDir( "weaponsets" )
    end
    return file.Exists( path, "DATA" );
end


-- Load wepset from file
function wepsets.lff( name )
    name = wepsets.fNameChange( name )
    local path = "weaponsets/"..name..".txt";
    local tbl = {}

    if ( wepsets.fExists( path ) ) then
        tbl = util.JSONToTable( file.Read( path, "DATA" ) )
        if tbl ~= nil then
            return tbl end
    end

    tbl = table.Copy( wepsets.newSetTable )
    tbl.name = name
    return tbl
end


-- Save wepset to file
function wepsets.stf( name, tbl )
    name = wepsets.fNameChange( name )
    local path = "weaponsets/"..name..".txt";

    wepsets.fExists( path )
    file.Write( path, util.TableToJSON( tbl, true ) )
end


-- Delete wepset file
function wepsets.delf( name )
    name = wepsets.fNameChange( name )
    local path = "weaponsets/"..name..".txt";
    if !wepsets.fExists( path ) then return false end

    file.Delete( path )
    return true
end

-- Load options
function wepsets.loadOptions()
    local path = "weaponsets_options.txt"

    if file.Exists( path, "DATA" ) then
        local tbl = util.JSONToTable( file.Read( path, "DATA" ) )
        if tbl ~= nil then
            wepsets.options = tbl
        end
    end
end

-- Save options
function wepsets.saveOptions()
    if !wepsets.options then return false end
    file.Write( "weaponsets_options.txt", util.TableToJSON( wepsets.options, true ) )
end


--[[---------------------------------------------------------
    Downloading sets from pastebin
---------------------------------------------------------]]--
function wepsets.dl()
    if file.Exists( "weaponsets_version.txt", "DATA" ) then
        if ( file.Read( "weaponsets_version.txt", "DATA" ) == wepsets.version ) then
            return false end end
    http.Fetch( "http://pastebin.com/raw.php?i=Q72iy08U", function( body, _, _, _ )
        local tbl = util.JSONToTable( body )
        if ( tbl == nil ) then return false end
        for k,v in pairs( tbl ) do
            http.Fetch( "http://pastebin.com/raw.php?i="..v, function( json, _, _, _ )
                local set = util.JSONToTable( json )
                if ( set == nil ) then return false end
                wepsets.stf( set.name, set )
                print("[WeaponSets] Downloaded: "..set.name);
            end )
        end
        file.Write( "weaponsets_version.txt", wepsets.version )
    end )
end


--[[---------------------------------------------------------
    Weapon set giving
---------------------------------------------------------]]--
function wepsets.give( ply, name )
    if ( ply == nil or !IsValid( ply ) ) then return false end
    if ( !wepsets.fExists( "weaponsets/"..name..".txt" )) then
        return false end
    local tbl = wepsets.lff( name )
    if ( tbl == nil ) then return false end

    if ( tbl.health > 0 ) then
        ply:SetHealth( tbl.health ) end
    if ( tbl.armor > -1 ) then
        ply:SetArmor( tbl.armor ) end
    if ( tbl.maxhealth > -1 ) then
        ply:SetMaxHealth( tbl.maxhealth ) end
    if ( tbl.jump > -1 ) then
        ply:SetJumpPower( tbl.jump ) end
    if ( tbl.gravity ~= 1 ) then
        ply:SetGravity( tbl.gravity ) end
    if ( tbl.speed ~= 1 ) then
        ply:SetCrouchedWalkSpeed( ply:GetCrouchedWalkSpeed() * tbl.speed )
        ply:SetWalkSpeed( ply:GetWalkSpeed() * tbl.speed )
        ply:SetRunSpeed( ply:GetRunSpeed() * tbl.speed )
        ply:SetMaxSpeed( ply:GetMaxSpeed() * tbl.speed )
    end

    if ( tobool(tbl.stripweapons or 0) == true ) then
        ply:StripWeapons() end
    for k,v in pairs( tbl.set ) do
        if ( tonumber(v) < 1 ) then
            ply:Give( k )
        end
    end

    if ( tobool(tbl.stripammo or 0) == true ) then
        ply:StripAmmo() end
    for k,v in pairs( tbl.set ) do
        if ( tonumber(v) > 0 ) then
            ply:GiveAmmo( v, k, true )
        end
    end

    ply:AllowFlashlight( tobool(tbl.allowflashlight or 1) )
    if ply:FlashlightIsOn() and !tobool(tbl.allowflashlight or 1) then
        ply:Flashlight( false )
    end

    ply:SwitchToDefaultWeapon()

    return true, tobool( tbl.stripweapons or 0 )
end


--[[---------------------------------------------------------
    Net functions
---------------------------------------------------------]]--

-- Save weapon set to file
wepsets.netFuncs.saveSet = function( ply, data )
    if ( wepsets.cancmd( ply ) ) then
        wepsets.stf( data.name, data.tbl )
    end
end

-- Delete weapon set
wepsets.netFuncs.deleteSet = function( ply, data )
    if ( wepsets.cancmd( ply ) ) then
        wepsets.delf( data.name )
    end
end

-- Save settings
wepsets.netFuncs.saveOptions = function( ply, data )
    if ( wepsets.cancmd( ply ) ) then
        wepsets.options = data
        wepsets.saveOptions()
    end
end


--[[---------------------------------------------------------
    Concommands and hooks
---------------------------------------------------------]]--

net.Receive( "wepsetsToSv", function( ply, _ )
    local name = net.ReadString();
    local data = net.ReadTable();

    if wepsets.netFuncs[name] != nil then
        wepsets.netFuncs[name]( ply, data ) end
end )

-- give concommand
concommand.Add( "weaponsets_give", function( ply, _, args, _ )
    if !IsValid( ply ) then return false end
    if !wepsets.cancmd( ply ) then return false end

    if ( #args < 1 ) then
        print( "[WeaponSets] Usage: weaponsets_give set userId [userId2...]" )
    else
        local name = tostring( args[1] )

        if ( #args < 2 ) then
            for _,v in pairs( player.GetAll() ) do
                wepsets.give( v, name )
            end
        else
            for i = 2, #args, 1 do
                local id = tonumber( args[i] )
                if !id then continue end
                wepsets.give( Player( id ), name )
            end
        end
        --[[if ( args[1] == "*" ) then
            for _,v in pairs( player.GetAll() ) do
                wepsets.give( v, name )
            end
        elseif ( args[1] == "^" ) then
            wepsets.give( ply, name )
        else
            for _,v in pairs( player.GetAll() ) do
                if ( string.find( v:Nick(), args[1] ) ) then
                    wepsets.give( v, name ) end
            end
        end]]
    end
end, _, "Usage: weaponsets_give <weaponSetName> [userId1] [userId2] ...", FCVAR_CLIENTCMD_CAN_EXECUTE );

-- "weaponsets" concommand
concommand.Add( "weaponsets", function( ply, _, args, _ )
    if !IsValid( ply ) then return false end
    if !wepsets.cancmd( ply ) then return false end

    if ( #args == 1 ) then
        local name = tostring( args[1] )
        local tbl = wepsets.lff( name )
        net.Start( "wepsetsToCl" )
            net.WriteString( "openEditMenu" );
            net.WriteTable( { name = tbl.name or name, tbl = tbl } );
        net.Send( ply );
    else
        wepsets.fExists( "weaponsets" )
        local sets, _ = file.Find( "weaponsets/*.txt", "DATA" )
        for k,v in pairs( sets ) do
            sets[k] = string.Left( v, #v-4 )
        end
        net.Start( "wepsetsToCl" )
            net.WriteString( "openMainMenu" );
            net.WriteTable( { list = sets, options = wepsets.options } );
        net.Send( ply );
    end
end, nil, "Usage: weaponsets <weaponSetName>", FCVAR_CLIENTCMD_CAN_EXECUTE );

-- Player loadout hook
hook.Add( "PlayerLoadout", "weaponsets_plyloadout", function( ply )
    if wepsets.options.loadoutset ~= "<default>" then
        local _, strip = wepsets.give( ply, wepsets.options.loadoutset or "sandbox" )
        if strip then return false end
    end
end )

-- Init hook
hook.Add( "Initialize", "weaponsets_init", function()
    wepsets.loadOptions()
    timer.Simple( 5, function()
        wepsets.dl()
    end)
end )

-- Shutdown hook
hook.Add( "ShutDown", "weaponsets_shutdown", function()
    wepsets.saveOptions()
end )
