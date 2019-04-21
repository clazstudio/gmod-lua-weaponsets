Loadout Sets (Garry's mod Addon)
--------------------------------
This addon allows you to create, edit and give sets (kits) of weapons and ammunitions and change player's loadout set.

Steam workshop page: http://steamcommunity.com/sharedfiles/filedetails/?id=523399678


Installation
============
1. Download the zip file of this repository (or clone it)
2. Copy `gmod-lua-weaponsets-master` into your `GarrysMod\garrysmod\addons\` directory
3. Run (or restart) Garry's mod


Screenshots
===========

Editor: <br>
![Editor screenshot](https://steamuserimages-a.akamaihd.net/ugc/816750493524546762/541A413043AFE360AE8580902A2C00841D92925B/)

Give menu: <br>
![Give menu GIF screenshot](https://steamuserimages-a.akamaihd.net/ugc/842589110371303459/3B24FF40C0769E64E37AF2A6188E8E98B03E2C23/)


Console commands
================
- `weaponsets` - Print sets list in server console
- `weaponsets <set_name>` - Edit a set
- `weaponsets_delete <set_name>` - Delete a set
- `weaponsets_give` or `weaponsets_setloadout` - Open giving and loadout managment window
- `weaponsets_give <set_name>` - Give set to all players
- `weaponsets_give <set_name> <UserID1> <UserId2> ...` - Give set to player(s)*
- `weaponsets_setloadout <set_name> <UserID1> ...` - Set as loadout set for player(s)*

_*You can get player's UserID by typing status concommand_


Convars
=======
- `weaponsets_loadoutset "<default>"` - Loadout weapon set for all players
- `weaponsets_adminonly "1"` - If enabled only superadmin can give and edit weaponsets
- `weaponsets_deathmatch "0"` - If enabled all players will can choose loadout set (F2)
