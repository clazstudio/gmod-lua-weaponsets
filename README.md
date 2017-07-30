# [Garry's mod Addon] Weapon Sets
This addon allows you to create, edit and give sets (kits) of weapons and ammunitions and change player's loadout set.

## Installation
1. Download the zip file of this repository (or clone it)
2. Copy `gmod-lua-weaponsets-master` into your `GarrysMod\garrysmod\addons\` directory
3. Run (or restart) Garry's mod

## Places in Sandbox gamemode
Tool menu: **Q -> Utilities -> Weapon sets** 
![Screenshot of sandbox menu](https://steamuserimages-a.akamaihd.net/ugc/842589110371303061/C745122E795E1F9FF1140F92B948FD61A4A4BF71/)

Sandbox desktop: **C -> Weaponsets** (left-top corner) 
![Screenshot of sandbox desktop](https://steamuserimages-a.akamaihd.net/ugc/842589193401016289/B6762C22D58C443E1D89B9E2B9BBF07B5567AD5C/)

Right click on player 
![Right click screenshot](https://steamuserimages-a.akamaihd.net/ugc/842589110371305024/D7A448B2EEFB42F0AE8EA130923A5FDB01407E99/)

### Console commands
- `weaponsets` - Print sets list in server console
- `weaponsets <set_name>` - Edit a set
- `weaponsets_delete <set_name>` - Delete a set
- `weaponsets_give` or `weaponsets_setloadout` - Open giving and loadout managment window
- `weaponsets_give <set_name>` - Give set to all players
- `weaponsets_give <set_name> <UserID1> <UserId2> ...` - Give set to player(s)*
- `weaponsets_setloadout <set_name> <UserID1> ...` - Set as loadout set for player(s)*
_*You can get player's UserID by typing status concommand_

### Convars:
- `weaponsets_loadoutset "<default>"` - Loadout weapon set for all players
- `weaponsets_adminonly "1"` - If enabled only superadmin can give and edit weaponsets

Steam workshop page: http://steamcommunity.com/sharedfiles/filedetails/?id=523399678
