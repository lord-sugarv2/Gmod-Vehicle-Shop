local val = false
hook.Add("LCarNPC:LoadConfig", "LCarNPC:LoadConfig", function()
    LCarNPC:RefreshCars() -- Dont delete this resets the config
    LCarNPC:AddCar("ID:BMP-2M", "BMP-2M", "gred_simfphys_bmp2m_custom", 1250000, "Simfphys", "models/vehicles_shelby/tanks/bmp3/bmp3.mdl")
    LCarNPC:AddCar("ID:Leopard-2A6", "Leopard 2A6", "gred_simfphys_leopard2a6_custom", 2352000, "Simfphys", "models/vehicles_shelby/tanks/leopard2a6/leopard2a6_v2.mdl")
    LCarNPC:AddCar("ID:Little-Bird-AH-6", "Little Bird AH-6", "wac_hc_littlebird_ah6", 8653000, "WAC", "models/flyboi/littlebird/littlebird_fb.mdl")

    -- use console commands LGetPos, LGetAngle
    LCarNPC:AddNPC("Car NPC", "models/characters/hostage_01.mdl", Vector(520, -18, -12288), Angle(0, 169, 0), {
        {Vector(200, -66, -12288), Angle(0, 0, 0)},
        {Vector(-270, 432, -12288), Angle(0, 0, 0)},
    })

    LCarNPC:SetSetting("Shop Title", "Lords Car NPC") -- The title of the store
end)

hook.Add("InitPostEntity", "LCarNPC:SpawnNPC's", function()
    LCarNPC:SpawnNPCs()
end)