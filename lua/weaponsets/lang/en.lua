local add = language.Add;

add("weaponsets", "Weapon sets")

-- Blood types
add("blood." .. DONT_BLEED,             "No blood")
add("blood." .. BLOOD_COLOR_RED,        "Normal red blood")
add("blood." .. BLOOD_COLOR_YELLOW,     "Yellow blood")
add("blood." .. BLOOD_COLOR_GREEN,      "Green blood")
add("blood." .. BLOOD_COLOR_MECH,       "Sparks")
add("blood." .. BLOOD_COLOR_ANTLION,    "Yellow (Antlion) blood")
add("blood." .. BLOOD_COLOR_ZOMBIE,     "Zombie blood")
add("blood." .. BLOOD_COLOR_ANTLION_WORKER, "Bright green blood")

-- Infinite ammo enum
add("infiniteammo.0", "Disable")
add("infiniteammo.1", "Primary")
add("infiniteammo.2", "Secondary")
add("infiniteammo.3", "All")

-- Default sets
add("weaponsets.set.clear",     "Without weapons")
add("weaponsets.set.sandbox",   "Default sandbox")
add("weaponsets.set.build",     "Build")
add("weaponsets.set.default",   "Garry's mod default")
add("weaponsets.set.inherit",   "Inherit from global")

-- Options categories
add("weaponsets.category.weapons",  "Weapons related")
add("weaponsets.category.player",   "Player model")
add("weaponsets.category.movement", "Movement")
add("weaponsets.category.other",    "Other options")

-- Weapons options
add("weaponsets.stripweapons",          "Strip weapons")
add("weaponsets.stripweapons.desc",     "Remove all weapons from the player before giving weaponset")
add("weaponsets.stripammo",             "Strip ammo")
add("weaponsets.stripammo.desc",        "Remove all ammo from the player before giving weaponset")
add("weaponsets.infiniteammo",          "Infinite ammo")
add("weaponsets.infiniteammo.desc",     "Enable infinite primary and/or secondary ammo for all weapons. Sets ammo to 99 every 5 seconds")
add("weaponsets.givewithoutammo",       "Give weapons without ammo")
add("weaponsets.givewithoutammo.desc",  "Do not give reserved by DefaultClip ammo. Completely empty magazine")
add("weaponsets.dropweapons",           "Drop weapon on death")
add("weaponsets.dropweapons.desc",      "Whether the player's current weapon should drop on death.")
add("weaponsets.defaultweapon",         "Default weapon")
add("weaponsets.defaultweapon.desc",    "Default active weapon. Player will be switched to it immediately after the weaponset is given")

-- Player model options
add("weaponsets.model",             "Player model")
add("weaponsets.model.desc",        "Model should be precached")
add("weaponsets.material",          "Model material override")
add("weaponsets.material.desc",     "Rendering material override of the entity. Use an empty string to reset to the default materials.")
add("weaponsets.color",             "Model color")
add("weaponsets.color.desc",        "Model color with opacity.")
add("weaponsets.teamcolor",         "Player team color")
add("weaponsets.teamcolor.desc",    "Player model's color. The part of the model that is colored is determined by the model itself, and is different for each model.")
add("weaponsets.weaponcolor",       "Weapon color")
add("weaponsets.weaponcolor.desc",  "Color of a part of the player weapon model (ex: phys gun beam color")
add("weaponsets.blood",             "Blood type")
add("weaponsets.blood.desc",        "Player's blood color")
add("weaponsets.scale",             "Model scale [EXPERIMENTAL]")
add("weaponsets.scale.desc",        "Scales model, vew offsets, step size and hulls, but ignores hitboxes.")

-- Movement options
add("weaponsets.jump",              "Jump power")
add("weaponsets.jump.desc",         "The velocity the player will applied to when he jumps")
add("weaponsets.stepsize",          "Step size")
add("weaponsets.stepsize.desc",     "Maximum height a player can step onto without jumping.")
add("weaponsets.gravity",           "Gravity multiplier [EXPERIMENTAL]")
add("weaponsets.gravity.desc",      "") -- TODO
add("weaponsets.mass",              "Mass [EXPERIMENTAL]")
add("weaponsets.mass.desc",         "Player's mass")
add("weaponsets.friction",          "Friction [EXPERIMENTAL]")
add("weaponsets.friction.desc",     "How much friction the player has when sliding against a surface.")
add("weaponsets.timescale",         "Player timescale")
add("weaponsets.timescale.desc",    "Slow down or speed up the player movement. Like host_timescale")
add("weaponsets.enablewalk",        "Enable slow walk")
add("weaponsets.enablewalk.desc",   "Allow or disallow player to +walk using the (default) alt key.")
add("weaponsets.normalspeed",       "Normal walk speed")
add("weaponsets.normalspeed.desc",  "Player's normal walking speed. Not sprinting, not slow walking +walk.")
add("weaponsets.runspeed",          "Run speed")
add("weaponsets.runspeed.desc",     "Player's sprint speed. +speed")
add("weaponsets.crouchspeed",       "Crouched walk speed")
add("weaponsets.crouchspeed.desc",  "The crouched walk speed multiplier. Doesn't work for values above 1.")
add("weaponsets.duckspeed",         "Duck speed (in seconds)")
add("weaponsets.duckspeed.desc",    "How quickly a player ducks in seconds. Will not work for values >= 1.")
add("weaponsets.unduckspeed",       "Unduck speed (in seconds)")
add("weaponsets.unduckspeed.desc",  "How quickly a player un-ducks in seconds.")

-- Other options
add("weaponsets.removesuit",            "Disable HEV suit")
add("weaponsets.removesuit.desc",
[[Equip or not the player with the HEV suit.
Allows the player to zoom, walk slowly, sprint, pickup armor batteries, use the health and armor stations and also shows the HUD.
The player also emits a flatline sound on death]])
add("weaponsets.allowflashlight",       "Allow flashlight")
add("weaponsets.allowflashlight.desc",  "Allow plater to toggle his flashlight.")
add("weaponsets.allowzoom",             "Allow zoom")
add("weaponsets.allowzoom.desc",        "Whether to make the player able or unable to zoom. (\"+zoom\" bind)")
add("weaponsets.fov",                   "FOV")
add("weaponsets.fov.desc",              "Player's Field Of View. Set to 0 to use default user FOV")
add("weaponsets.godmode",               "God mode")
add("weaponsets.godmode.desc",          "")
add("weaponsets.health",                "Health")
add("weaponsets.health.desc",           "Start health")
add("weaponsets.maxhealth",             "Max health")
add("weaponsets.maxhealth.desc",        "Max health")
add("weaponsets.armor",                 "Armor")
add("weaponsets.armor.desc",            "Start armor")
