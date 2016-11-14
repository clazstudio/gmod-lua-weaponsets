
wepsets.version = "21.09.15";
wepsets.onlyAdmin = false;

util.AddNetworkString( "wepsetsToSv" )
util.AddNetworkString( "wepsetsToCl" )

--[[---------------------------------------------------------
    Проверка на наличие файла и директории
---------------------------------------------------------]]--
function wepsets.fExists( path )
    if ( !file.Exists( "weaponsets", "DATA" ) ) then
        file.CreateDir( "weaponsets" )
    end
    return file.Exists( path, "DATA" );
end

--[[---------------------------------------------------------
    Загрузка из файла
---------------------------------------------------------]]--
function wepsets.lff( name )
    name = string.lower( name )
    local path = "weaponsets/"..name..".txt";

    if ( wepsets.fExists( path ) ) then
        return util.JSONToTable( file.Read( path, "DATA" ) )
    else
        local tbl = {}
        tbl.health = 100
        tbl.armor = 0
        tbl.stripweapons = 0
        tbl.stripammo = 0
        tbl.name = name
        tbl.set = {}
        return tbl
    end
end

--[[---------------------------------------------------------
    Сохранение в файл
---------------------------------------------------------]]--
function wepsets.stf( name, tbl )
    name = string.lower( name )
    local path = "weaponsets/"..name..".txt";

    wepsets.fExists( path )
    file.Write( path, util.TableToJSON( tbl, true ) )
end

--[[---------------------------------------------------------
    Отправка сообщения в клиентскую консоль
---------------------------------------------------------]]--
function wepsets.cl_print( ply, str )
    ply:SendLua("print(\"[WeaponSets] "..str.."\")")
end

--[[---------------------------------------------------------
    Загрузка сетов с пастебина
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
                print("[WeaponSets] Downloading: "..set.name);
            end )
        end
        file.Write( "weaponsets_version.txt", wepsets.version )
    end )
end

--[[---------------------------------------------------------
    Выдача набора игроку
---------------------------------------------------------]]--
function wepsets.give( ply, name )
    if ( ply == nil or !IsValid( ply ) ) then return false end
    if ( !wepsets.fExists("weaponsets/"..name..".txt")) then
        return false end
    local tbl = wepsets.lff( name )
    if ( tbl == nil ) then return false end

    if ( tbl.health > 0 ) then
        ply:SetHealth( tbl.health )
    end
    if ( tbl.armor > -1 ) then
        ply:SetArmor( tbl.armor )
    end

    if ( tbl.stripweapons == true ) then
        ply:StripWeapons();
    end
    for k,v in pairs( tbl.set ) do
        if ( tonumber(v) < 1 ) then
            ply:Give( k )
        end
    end

    if ( tbl.stripammo == true ) then
        ply:StripAmmo();
    end
    for k,v in pairs( tbl.set ) do
        if ( tonumber(v) > 0 ) then
            ply:GiveAmmo( v, k, true )
        end
    end

    return true
end

--[[---------------------------------------------------------
    Имеет ли права игрок
---------------------------------------------------------]]--
function wepsets.cancmd( ply )
    if ( wepsets.onlyAdmin ) then
        return ( ply == nil ) or ( IsValid( ply ) and ply:IsSuperAdmin() )
    else
        return true
    end
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
        -- wepsets.stf( data.name, data.tbl )
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
    if ( wepsets.cancmd( ply ) ) then
        if ( #args != 2) then
            print( "[WeaponSets] Usage: weaponsets_give nick set" )
        else
            local name = tostring( args[2] )

            if ( args[1] == "*" ) then
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
            end
        end
    end
end, _, _, FCVAR_CLIENTCMD_CAN_EXECUTE );

-- "weaponsets" concommand
concommand.Add( "weaponsets", function( ply, _, args, _ )
    if ( wepsets.cancmd( ply ) ) then
        if ( #args == 1 and IsValid( ply ) ) then
            local name = tostring( args[1] )
            net.Start( "wepsetsToCl" )
                net.WriteString( "openEditMenu" );
                net.WriteTable( { name = name, tbl = wepsets.lff( name ) } );
            net.Send( ply );
        else
            wepsets.fExists( "weaponsets" )
            local sets, _ = file.Find( "weaponsets/*.txt", "DATA" )
            for k,v in pairs( sets ) do
                sets[k] = string.Left( v, #v-4 )
            end
            print("[WeaponSets] List: "..table.concat( sets, ", " ))
        end
    end
end, nil, nil, FCVAR_CLIENTCMD_CAN_EXECUTE );

-- Init hook
hook.Add( "Initialize", "weaponsets_init", function()
    timer.Simple( 5, function()
        wepsets.dl()
    end)
end )
