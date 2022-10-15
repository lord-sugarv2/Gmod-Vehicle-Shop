ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.PrintName = "Car NPC"
ENT.Author = "Lord Sugar"
ENT.Category = "Lord Sugar"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ID")
end