local add = language.Add;

add("weaponsets", "Weapon sets")

-- Blood types
add("blood." .. DONT_BLEED,           "No blood")
add("blood." .. BLOOD_COLOR_RED,      "Normal red blood")
add("blood." .. BLOOD_COLOR_YELLOW,   "Yellow blood")
add("blood." .. BLOOD_COLOR_GREEN,    "Green blood")
add("blood." .. BLOOD_COLOR_MECH,     "Sparks")
add("blood." .. BLOOD_COLOR_ANTLION,  "Yellow (Antlion) blood")
add("blood." .. BLOOD_COLOR_ZOMBIE,   "Zombie blood")
add("blood." .. BLOOD_COLOR_ANTLION_WORKER, "Bright green blood")

-- Options categories
add("weaponsets.category.weapons",  "Weapons related")
add("weaponsets.category.player",   "Player model")
add("weaponsets.category.movement", "Movement")
add("weaponsets.category.other",    "Other options")

-- Weapons options
add("weaponsets.stripweapons.name",         "Strip weapons")
add("weaponsets.stripweapons.description",  "Remove all weapons from the player before giving weaponset")
add("weaponsets.stripammo.name",            "Strip ammo")
add("weaponsets.stripammo.description",     "Remove all ammo from the player before giving weaponset")
add("weaponsets.infiniteammo.name",         "Infinite ammo")
add("weaponsets.infiniteammo.description",  "Enable infinite primary and secondary ammo for all weapons. Infinite magazine") -- TODO
add("weaponsets.givewithoutammo.name",      "Give weapons without ammo")
add("weaponsets.givewithoutammo.description", "Do not give reserved by DefaultClip ammo") -- TODO
add("weaponsets.dropweapons.name",          "Drop weapon on death")
add("weaponsets.dropweapons.description",   "Whether the player's current weapon should drop on death.")
add("weaponsets.defaultweapon.name",        "Default weapon")
add("weaponsets.defaultweapon.description", "Default active weapon. Player will be switched to it immediately after the weaponset is given") -- TODO

-- Player model options
add("weaponsets.model.name",                "Player model")
add("weaponsets.model.description",         "Model should be precached")
add("weaponsets.material.name",             "Model material override")
add("weaponsets.material.description",      "Rendering material override of the entity. Use an empty string to reset to the default materials.")
add("weaponsets.color.name",                "Model color")
add("weaponsets.color.description",         "Model color with opacity.")
add("weaponsets.teamcolor.name",            "Player team color")
add("weaponsets.teamcolor.description",     "Player model's color. The part of the model that is colored is determined by the model itself, and is different for each model.")
add("weaponsets.weaponcolor.name",          "Weapon color")
add("weaponsets.weaponcolor.description",   "Color of a part of the player weapon model (ex: phys gun beam color")
add("weaponsets.blood.name",                "Blood type")
add("weaponsets.blood.description",         "Player's blood color")
add("weaponsets.scale.name",                "Model scale [EXPERIMENTAL]")
add("weaponsets.scale.description",         "Scales model, vew offsets, step size and hulls, but ignores hitboxes.")

-- Movement options
add("weaponsets.jump.name",             "Jump power")
add("weaponsets.jump.description",      "The velocity the player will applied to when he jumps")
add("weaponsets.stepsize.name",         "Step size")
add("weaponsets.stepsize.description",  "Maximum height a player can step onto without jumping.")
add("weaponsets.gravity.name",          "Gravity multiplier [EXPERIMENTAL]")
add("weaponsets.gravity.description",   "") -- TODO
add("weaponsets.mass.name",             "Mass [EXPERIMENTAL]")
add("weaponsets.mass.description",      "Player's mass")
add("weaponsets.friction.name",         "Friction [EXPERIMENTAL]")
add("weaponsets.friction.description",  "How much friction the player has when sliding against a surface.")
add("weaponsets.timescale.name",        "Player timescale")
add("weaponsets.timescale.description", "Slow down or speed up the player movement. Like host_timescale")
add("weaponsets.enablewalk.name",       "Enable slow walk")
add("weaponsets.enablewalk.description","Allow or disallow player to +walk using the (default) alt key.")
add("weaponsets.normalspeed.name",      "Normal walk speed")
add("weaponsets.normalspeed.description","Player's normal walking speed. Not sprinting, not slow walking +walk.")
add("weaponsets.runspeed.name",         "Run speed")
add("weaponsets.runspeed.description",  "Player's sprint speed. +speed")
add("weaponsets.crouchspeed.name",      "Crouched walk speed")
add("weaponsets.crouchspeed.description","The crouched walk speed multiplier. Doesn't work for values above 1.")
add("weaponsets.duckspeed.name",        "Duck speed (in seconds)")
add("weaponsets.duckspeed.description", "How quickly a player ducks in seconds. Will not work for values >= 1.")
add("weaponsets.unduckspeed.name",      "Unduck speed (in seconds)")
add("weaponsets.unduckspeed.description","How quickly a player un-ducks in seconds.")

-- Other options
add("weaponsets.removesuit.name",           "Disable HEV suit")
add("weaponsets.removesuit.description",
[[Equip or not the player with the HEV suit.
Allows the player to zoom, walk slowly, sprint, pickup armor batteries, use the health and armor stations and also shows the HUD.
The player also emits a flatline sound on death]])
add("weaponsets.allowflashlight.name",      "Allow flashlight")
add("weaponsets.allowflashlight.description", "Allow plater to toggle his flashlight.")
add("weaponsets.allowzoom.name",            "Allow zoom")
add("weaponsets.allowzoom.description",     "Whether to make the player able or unable to zoom. (\"+zoom\" bind)")
add("weaponsets.fov.name",                  "FOV")
add("weaponsets.fov.description",           "Player's Field Of View. Set to 0 to use default user FOV")
add("weaponsets.godmode.name",              "God mode")
add("weaponsets.godmode.description",       "")
add("weaponsets.health.name",               "Health")
add("weaponsets.health.description",        "Start health")
add("weaponsets.maxhealth.name",            "Max health")
add("weaponsets.maxhealth.description",     "Max health")
add("weaponsets.armor.name",                "Armor")
add("weaponsets.armor.description",         "Start armor")
