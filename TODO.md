 TODO
======
// - use Kit word instead of Set and rename addon to LoadoutKits?
- Weapons and ammoes scan functions
- Deathmatch
- New GUI
- net messages?
- sandbox desktop 64x64 icon
- youtube demo video
- add to lang - sandbox, clientside convar and concommand help, gui 

 Files
-------

- lua/
  - autorun
    - weaponsets.lua // bootstrap
  - weaponsets
    - sh_core.lua
    - sv_core.lua
    - cl_lang.lua
    - lang/
      - en.lua
      - ru.lua
    - sh_files.lua
    - sv_files.lua
    - cl_files.lua
    - gui/
      - entry.lua
    - sv_commands.lua
    - sv_deathmatch.lua
    - cl_deathmatch.lua
    - ...
- data/
  - weaponsets/
    - set_id.txt
  - weaponsets_list.txt
  - weaponsets_version.txt

 Convars
---------
- `weaponsets_lang = "en"` // "" to use gmod_lang
- `weaponsets_adminonly = 1`
- `weaponsets_deathmatch = 0`
- `weaponsets_loadoutset = "<default>"`

 Commands
----------
- `weaponsets` - Open GUI
- `weaponsets <set_name>` - Edit a set
- `weaponsets_delete <set_name>`
- `weaponsets_duplicate <set_name> <copy_name>`
- `weaponsets_give` or `weaponsets_setloadout` - Open giving and loadout managment window
- `weaponsets_give <set_name>` - Give set to all players
- `weaponsets_give <set_name> <UserID1> <UserId2> ...` - Give set to player(s)*
- `weaponsets_setloadout <set_name> <UserID1> ...` - Set as loadout set for player(s)*

 API
-----

### Structure: `WeaponSet`
- name : string
- [description : string]
- [icon : string] // path to icon
- usergroup : string

### Structure: `SetOption`
- equip : (set : table, ply : Player, [midGame : bool]) -> bool
- [strip : (set : table, ply : Player) -> bool]
- [validate : (value : any, [option : table], [set : table]) -> bool, [err : string]]
- [getFromPlayer : (ply: Player) -> any]
- [default : any]
- [category : string]
- [priority : number] // (more = later) or use insert order? 
- [name : string] // lang?
- [description : string]
- [entryType : string // Checkbox, Text, Combobox]
- [initEntry : (value : any, [option : table], [set : table]) -> void]
- ... entry options

### Hooks
- `sh WeaponSets_InitOptions(WeaponSets)` - place to add options
- `sh WeaponSets_Access(ply, permission)` - ?

### Core
- `sh WeaponSets:AddOption(key : string, struct : SetOption)`
- `sh WeaponSets:OptionsList() -> map<string, SetOption>`
- `sv WeaponSets:Give(ply : Player, set : table, [midGame : bool]) -> bool`
- `sv WeaponSets:Strip(ply : Player, set : table) -> bool`
- `sh WeaponSets:Validate(set : table) -> bool, [err : string]`
- `sv WeaponSets:FromPlayer(ply : Player) -> set : table`
- `sv WeaponSets:PlayerClass(set : table, displayName : string) -> PLAYER`

### Files
Набор оружий, представленный таблицей значений (`values`) - таблица, где каждому ключу сопоставлено 
значение какой-то опции (`SetOption`).
Набор оружий, представленный строкой (`id`) - это, id который используется в качестве имени файла,
в котором хранится таблица значений.
Есть таблица зарегистрированных наборов, в ней хранятся соответствия `id` к структуре `WeaponSet`

- `sv WeaponSets:GiveSet(ply : Player, id : string) : bool, [err : string]`
- `sv WeaponSets:SetLoadout(ply : Player, id : string) : bool`
- `sv WeaponSets:SetLoadout(SteamId : string, setId : string) : bool`

- `sh WeaponSets:IdFromName(name : string) : string`
- `sv WeaponSets:AddSet(set : WeaponSet, values : table, [id : string]) : string`
- `sh WeaponSets:SetsList() : map<id : string, WeaponSet>`
- `sv WeaponSets:SaveSet(set : table, id : string)`
- `sv WeaponSets:LoadSet(id : string) : table`
- `sv WeaponSets:RemoveSet(id : string) : table`
- `sv WeaponSets:DuplicateSet(id : string, [copy : string]) : string`

- `sh WeaponSets:Access(ply : Player, permission : string) : bool`
