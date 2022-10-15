local PANEL = {}
function PANEL:Init()
    self.margin, self.panels = PIXEL.Scale(6), {}
    self.Scroll = self:Add("PIXEL.ScrollPanel")
    self.Scroll:Dock(FILL)

    self.Search = self.Scroll:Add("PIXEL.TextEntry")
    self.Search:Dock(TOP)
    self.Search:SetTall(PIXEL.Scale(35))
    self.Search:SetPlaceholderText("Search")
    self.Search.OnChange = function()
        self:Build()
    end

    self:Build()
end

function PANEL:AddItem(int, data)
    local panel = self.Scroll:Add("DPanel")
    panel:Dock(TOP)
    panel:DockMargin(0, self.margin, 0, 0)
    panel:SetTall(PIXEL.Scale(135))
    panel.Paint = function(s, w, h)
        PIXEL.DrawRoundedBox(self.margin, 0, 0, w, h, PIXEL.Colors.Header)
    end

    local mdlpnl = panel:Add("DModelPanel")
    mdlpnl:Dock(FILL)
    mdlpnl:SetModel(data.model)
    local sc, fc = PIXEL.Scale(50), PIXEL.Scale(22)
    mdlpnl.PaintOver = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 75)
        surface.DrawRect(0, h-sc, w, sc)
        if LCarNPC.Cars[data.id] then
            PIXEL.DrawSimpleText(data.name, "UI.TextEntry", w/2, h-sc+self.margin+self.margin, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            PIXEL.DrawSimpleText("Equip", "UI.TextEntry", w/2, h-(sc/2), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        else
            PIXEL.DrawSimpleText(data.name, "UI.FrameTitle", self.margin, h-sc+self.margin, color_white)
            PIXEL.DrawSimpleText(DarkRP.formatMoney(data.price), "UI.TextEntry", self.margin, h-sc+self.margin+fc, LocalPlayer():canAfford(data.price) and PIXEL.Colors.Positive or PIXEL.Colors.Negative)
        end
    end

    local mn, mx = mdlpnl.Entity:GetRenderBounds()
    local size = 0
    size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
    size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
    size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
    mdlpnl:SetFOV(50)
    mdlpnl:SetCamPos(Vector(size, size, size))
    mdlpnl:SetLookAt((mn + mx) * 0.5)
    mdlpnl.LayoutEntity = function() return end
    mdlpnl.DoClick = function()
        if not IsValid(self.ent) then return end
        net.Start("LCarNPC:ClickVehicle")
        net.WriteUInt(int, 32)
        net.WriteEntity(self.ent)
        net.SendToServer()
    end

    table.insert(self.panels, panel)
end

function PANEL:SetEnt(ent)
    self.ent = ent
end

function PANEL:Build()
    for k, v in ipairs(self.panels) do
        v:Remove()
    end

    for k, v in ipairs(LCarNPC.Cars) do
        local a, b = string.find(string.lower(v.name), string.lower(self.Search:GetValue()))
        local c, d = string.find(string.lower(v.price), string.lower(self.Search:GetValue()))
        if not a and not c then continue end
        self:AddItem(k, v)
    end
end
vgui.Register("LCarNPC:ShopPanel", PANEL, "EditablePanel")