
local langs = {}
local langs_arr = {}

local lang_files = file.Find("weaponsets/lang/*.lua", "LUA")
for _, lang_file in ipairs(lang_files) do
    local key = string.sub(lang_file, 1, -5)
    langs[key] = "weaponsets/lang/" .. lang_file
    table.insert(langs_arr, key)
end

local supportedLangsStr = table.concat(langs_arr, ", ")
WeaponSets.D("Languages: " .. supportedLangsStr)
langs_arr = nil;

local curLang
local langConVar = CreateClientConVar("weaponsets_lang", "", true, false,
    "WeaponSets language. Set to \"\" to use gmod_language value")

--[[--
    Sets WeaponSets language.
]]
function WeaponSets:SetLang(newLang)
    if newLang == "" then
        newLang = cvars.String("gmod_language", "en")
    end
    if not langs[newLang] then
        self.Print("Unsupported language '" .. newLang .. "'. Using 'en'.")
        self.Print("Supported languages: " .. supportedLangsStr);
        newLang = "en"
    end

    if curLang ~= newLang then
        self.Print("Loading language: " .. newLang)
        include(langs[newLang])
        curLang = newLang
        langConVar:SetString(curLang)
    end
end

cvars.AddChangeCallback("weaponsets_lang", function(_, _, newLang)
    WeaponSets:SetLang(newLang)
end)

cvars.AddChangeCallback("gmod_language", function(_, _, newLang)
    if langConVar:GetString() == "" then
        WeaponSets:SetLang(newLang)
    end
end)

WeaponSets:SetLang(langConVar:GetString())
