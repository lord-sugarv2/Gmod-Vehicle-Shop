LCarNPC.Settings = LCarNPC.Settings or {}
LCarNPC.Cars = LCarNPC.Cars or {}
LCarNPC.NPCs = LCarNPC.NPCs or {}
function LCarNPC:RefreshCars()
    LCarNPC.Cars = {}
    LCarNPC.NPCs = {}
end

function LCarNPC:AddCar(id, name, class, price, spawner, modeloverride, canbuy, failmsg)
    id = id or name
    name = name or ""
    class = class or ""
    price = price or 0
    spawner = spawner or "Other" -- Simfphys, WAC, Other
    model = modeloverride or false
    canbuy = canbuy or false
    failmsg = failmsg or ""

    table.Add(LCarNPC.Cars, {{
        id = id,
        name = name,
        class = class,
        price = price,
        spawner = spawner,
        model = model,
        canbuy = canbuy,
        failmsg = failmsg,
    }})
end

function LCarNPC:AddNPC(name, model, npclocation, angle, spawnlocations)
    name = name or ""
    model = model or "models/characters/hostage_01.mdl"
    npclocation = npclocation or Vector(0, 0, 0)
    angle = angle or Angle(0, 0, 0)
    spawnlocations = spawnlocations or {}

    table.Add(LCarNPC.NPCs, {{
        name = name,
        model = model,
        location = npclocation,
        angle = angle,
        spawnlocations = spawnlocations,
    }})
end

LCarNPC.NPCEnts = LCarNPC.NPCEnts or {}
function LCarNPC:SpawnNPCs()
    if CLIENT then return end
    for k, v in ipairs(LCarNPC.NPCEnts) do
        if IsValid(v) then
            v:Remove()
        end
    end
    LCarNPC.NPCEnts = {}

    for k, v in ipairs(LCarNPC.NPCs) do
        local ent = ents.Create("lcarnpc")
        ent:Spawn()
        ent:SetModel(v.model)
        ent:SetID(k)
        ent:SetPos(v.location)
        ent:SetAngles(v.angle)

        table.insert(LCarNPC.NPCEnts, ent)
    end
end

function LCarNPC:SetSetting(str, val)
    LCarNPC.Settings[str] = val
end

function LCarNPC:GetSetting(str)
    return LCarNPC.Settings[str]
end
hook.Run("LCarNPC:LoadConfig")