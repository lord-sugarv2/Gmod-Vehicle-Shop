include("shared.lua")

PIXEL.RegisterFont("LCarNPC20", "Open Sans SemiBold", 20)
function ENT:Draw()
	self:DrawModel()

	if not LCarNPC.NPCs[self:GetID()] then return end
  	local pos = self:GetPos()
  	local angle = self:GetAngles()
  	local eyeAngle = LocalPlayer():EyeAngles()

  	angle:RotateAroundAxis(angle:Forward(), 90)
  	angle:RotateAroundAxis(angle:Right(), - 90)

	cam.Start3D2D(pos + self:GetUp() * 80, Angle(0, eyeAngle.y - 90, 90), 0.1)
		PIXEL.DrawNPCOverhead(self, LCarNPC.NPCs[self:GetID()].name)
	cam.End3D2D()
end