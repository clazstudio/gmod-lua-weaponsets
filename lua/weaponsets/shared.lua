--[[---------------------------------------------------------
    SHARED
---------------------------------------------------------]]--

-- new weapon set table
wepsets.newSetTable = {
    stripweapons = 0,
    stripammo = 0,
    allowflashlight = 1,
    health = -1,
    armor = -1,
    maxhealth = -1,
    jump = -1,
    gravity = 1,
    speed = 1,
    set = {}
}

-- Filename changing
function wepsets.fNameChange( text )
    text = string.Replace( string.lower( text ), " ", "_" )
    text = string.gsub( text, '[\\/:%*%?"<>|]', "" )
    return text
end
