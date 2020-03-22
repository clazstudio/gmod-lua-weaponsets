local PANEL = {}

function PANEL:Init()
    self.entry = vgui.Create("DTextEntry", self)
    self.entry:Dock(FILL)

    function self.entry.OnValueChange(_, value)
        self:OnValueChanged(value)
    end
end

vgui.Register("WS_TextEntry", PANEL, "WS_Entry")

derma.DefineControl("WS_TextEntry", "WeaponSets - Text entry", PANEL, "WS_Entry")
function PANEL:GenerateExample(className, propertySheet, Width, Height )
    local entry = vgui.Create( className )
    entry:Setup("material", {
        default = "",
        entryType = "string",
        category = "player",
        validate = function(value)
            return isstring(value)
        end,
        sanitize = function(x)
            return tostring(x) or ""
        end
    }, "text")
    entry:Dock(TOP)

    propertySheet:AddSheet(className, entry, nil, true, true)
end
