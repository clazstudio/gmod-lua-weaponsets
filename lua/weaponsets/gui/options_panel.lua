local PANEL = {}

local ENTRIES = {
    ["string"] = "WS_TextEntry",
    -- "bool" = "WS_CheckEntry",
}

function PANEL:Init()

end

function PANEL:Setup(options, values)

end

function PANEL:SetValues(values)

end

vgui.Register("WS_OptionsPanel", PANEL, "DScrollPanel")
