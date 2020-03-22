local PANEL = {}

local function getPhraseOrNil(key)
    local phrase = language.GetPhrase(key)
    return phrase ~= key and phrase or nil
end

function PANEL:Init()
    self:DockPadding(4, 4, 4, 4)

    self.check = vgui.Create("DCheckBox", self)
    function self.check:OnChange(bVal)
        --self:SetIncluded(bVal)
        print("checked", bVal)

        if not bVal then
            self:SetValue(nil)
        else
            self:SetValue(self.m_option.default)
        end
    end
    self.check:Dock(LEFT)
    self.check:DockMargin(0, 0, 8, 0)
    self.check:SetTooltip("#toggle")

    self.description = vgui.Create("DLabel", self)
    self.description:SetAutoStretchVertical(true)
    self.description:Dock(BOTTOM)
    self.description:SetDark(true)

    self.title = vgui.Create("DLabel", self)
    self.title:SetFont("DermaDefaultBold")
    self.title:Dock(LEFT)
    self.title:DockMargin(0, 0, 4, 0)
    self.title:SetDark(true)
    self.title:SetWidth(150)
    self.title:SetHeight(24)
end

function PANEL:Setup(key, option, value)
    local name = getPhraseOrNil("weaponsets." .. key)
    self.title:SetText((name or key) .. ":")
    if name then
        self.title:SetTooltip(name .. " (" .. key .. ")")
    end

    local description = getPhraseOrNil("weaponsets." .. key .. ".desc")
    if description then
        self.description:SetText(description or "")
        self.description:DockMargin(0, 4, 0, 0)
    else
        self.description:SetText("")
        self.description:DockMargin(0, 0, 0, 0)
        self.description:SetHeight(0)
    end

    self.m_key = key -- ?
    self.m_option = option
    self:SetValue(value)

    self:InvalidateLayout(true)
    self:SizeToChildren(false, true)
end

function PANEL:PerformLayout(width, height)

end

function PANEL:SetError(highlight, msg)
    -- TODO:
end

function PANEL:SetIncluded(isIncluded)
    self.check:SetChecked(isIncluded)
    self.entry:SetEnabled(isIncluded)
end

function PANEL:SetValue(value)
    if value == nil then
        self:SetIncluded(false)
    else
        self:SetIncluded(true)
        self.entry:SetValue(value)
    end
end

function PANEL:GetValue()
    return self.entry:GetValue()
end

function PANEL:OnValueChanged(value)
end

vgui.Register("WS_Entry", PANEL, "DPanel")
