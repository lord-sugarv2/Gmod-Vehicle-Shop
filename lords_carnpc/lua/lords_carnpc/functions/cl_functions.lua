local blur = Material("pp/blurscreen")
function LCarNPC:DrawBlur(x, y, w, h, amount)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(blur)

    surface.SetDrawColor(30, 30, 30, 200)
    surface.DrawRect(x, y, w, h)

    for i = 1, 3 do
        blur:SetFloat("$blur", (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x, y, w, h)
    end
end

function LCarNPC:OpenMenu(ent)
    if IsValid(LCarNPC.Menu) then LCarNPC.Menu:Remove() end
    LCarNPC.Menu = vgui.Create("DPanel")
    LCarNPC.Menu:SetText("")
    LCarNPC.Menu:SetSize(ScrW(), ScrH())
    LCarNPC.Menu.Paint = function(s, w, h)
        LCarNPC:DrawBlur(0, 0, w, h)
    end

    local panel = LCarNPC.Menu:Add("PIXEL.Frame")
    panel:SetSize(PIXEL.Scale(500), PIXEL.Scale(600))
    panel:Center()
    panel:MakePopup()
    panel:SetTitle(LCarNPC:GetSetting("Shop Title"))
    panel.OnRemove = function()
        LCarNPC.Menu:Remove()
    end

    local panel = panel:Add("LCarNPC:ShopPanel")
    panel:Dock(FILL)
    panel:SetEnt(ent)
end

hook.Add("InitPostEntity", "LCarNPC:RequestData", function()
    net.Start("LCarNPC:RequestData")
    net.SendToServer()
end)

LCarNPC.Cars = LCarNPC.Cars or {}
net.Receive("LCarNPC:Wipe", function()
    LCarNPC.Cars = {}
end)

net.Receive("LCarNPC:SendData", function()
    local int = net.ReadUInt(32)
    if int < 1 then return end

    for i = 1, int do
        LCarNPC.Cars[net.ReadString()] = true
    end
end)

net.Receive("LCarNPC:UpdateVehicle", function()
    local id, bool = net.ReadString(), net.ReadBool()
    LCarNPC.Cars[id] = bool
end)

net.Receive("LCarNPC:OpenMenu", function()
    local ent = net.ReadEntity()
    LCarNPC:OpenMenu(ent)
end)