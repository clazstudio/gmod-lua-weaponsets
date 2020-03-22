local PANEL = {}

local WEP_PANEL_COLOR_IN = Color(200, 230, 201)
local WEP_PANEL_COLOR_OUT = Color(255, 205, 210)

function PANEL:Init()
    self:SetHeight(64)
    self:SetIncluded(false)

    self.DoClick = function()
        self.m_incl = not self.m_incl
        self:OnToggled(self.m_incl)
    end
end

function PANEL:Setup(wepClass, wepInfo, isIncluded)
    local imgPath = "entities/" .. wepClass .. ".png"

    if not file.Exists("materials/" .. imgPath, "GAME") then
        self.icon = vgui.Create("DImage", self)
        self.icon:SetImage(imgPath)
    elseif wepInfo.worldModel then
        local modelImage = "spawnicons/models/" .. string.sub(wepInfo.worldModel, 1, -5)

        self.icon = vgui.Create("ModelImage", self)
        if file.Exists("materials/" .. modelImage, "GAME") then
            self.icon:SetSpawnIcon(modelImage)
        else
            self.icon:SetModel(wepInfo.worldModel)
            self.icon:RebuildSpawnIcon()
        end
    else
        self.icon = vgui.Create("DImage", self)
        self.icon:SetImage("vgui/avatar_default")
    end

    self.icon:SetSize(64, 64)
    self.icon:Dock(LEFT)
    self.icon:DockMargin(0, 0, 4, 0)

    self:SetIncluded(isIncluded or false)
    self.m_wepClass = wepClass
    self.m_wepInfo = wepInfo
end

function PANEL:SetIncluded(isIncluded)
    self.m_incl = isIncluded
end

function PANEL:OnToggled(isIncluded)

end

function PANEL:OnAmmoChanged(ammo, count)

end

function PANEL:Paint(w, h)
    local pad = 4
    local color = self.m_incl and WEP_PANEL_COLOR_IN or WEP_PANEL_COLOR_OUT
    draw.RoundedBox(pad * 2, 0, 0, w, h, color)
    draw.SimpleText(self.m_wepInfo.name, "DermaLarge", 64 + pad * 4, pad * 2,
        Color(50, 50, 50), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText(self.m_wepClass, "Trebuchet18", 64 + pad * 4, 32 + pad * 3,
        Color(50, 50, 50), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

vgui.Register("WS_Weapon", PANEL, "DPanel")
