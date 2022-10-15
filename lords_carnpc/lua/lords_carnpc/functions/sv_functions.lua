concommand.Add("LGetPos", function(ply, cmd, args)
    local pos = ply:GetPos()
    print("Vector("..math.Round(pos.x)..", "..math.Round(pos.y)..", "..math.Round(pos.z).."),")
end)

concommand.Add("LGetAngle", function(ply, cmd, args)
    local ang = ply:GetAngles()
    print("Angle("..math.Round(ang[1])..", "..math.Round(ang[2])..", "..math.Round(ang[3]).."),")
end)

local function MakeVehicle( ply, Pos, Ang, model, Class, VName, VTable, data )
	local Ent = ents.Create( Class )
	if ( !IsValid( Ent ) ) then return NULL end

	duplicator.DoGeneric( Ent, data )

	Ent:SetModel( model )

	-- Fallback vehiclescripts for HL2 maps ( dupe support )
	if ( model == "models/buggy.mdl" ) then Ent:SetKeyValue( "vehiclescript", "scripts/vehicles/jeep_test.txt" ) end
	if ( model == "models/vehicle.mdl" ) then Ent:SetKeyValue( "vehiclescript", "scripts/vehicles/jalopy.txt" ) end

	-- Fill in the keyvalues if we have them
	if ( VTable && VTable.KeyValues ) then
		for k, v in pairs( VTable.KeyValues ) do

			local kLower = string.lower( k )

			if ( kLower == "vehiclescript" or
				 kLower == "limitview"     or
				 kLower == "vehiclelocked" or
				 kLower == "cargovisible"  or
				 kLower == "enablegun" )
			then
				Ent:SetKeyValue( k, v )
			end

		end
	end

	Ent:SetAngles( Ang )
	Ent:SetPos( Pos )

	DoPropSpawnedEffect( Ent )

	Ent:Spawn()
	Ent:Activate()

	if ( Ent.SetVehicleClass && VName ) then Ent:SetVehicleClass( VName ) end
	Ent.VehicleName = VName
	Ent.VehicleTable = VTable

	-- We need to override the class in the case of the Jeep, because it
	-- actually uses a different class than is reported by GetClass
	Ent.ClassOverride = Class

	if ( IsValid( ply ) ) then
		gamemode.Call( "PlayerSpawnedVehicle", ply, Ent )
	end

	return Ent

end

local function SpawnVehicle( ply, vname, spawnloc, ang )

	if ( !IsValid( ply ) ) then return end

	if ( !vname ) then return end

	local VehicleList = list.Get( "Vehicles" )
	local vehicle = VehicleList[ vname ]

	if ( !vehicle ) then return end

	if ( !tr ) then
		tr = ply:GetEyeTraceNoCursor()
	end

	local Angles = ang
	local Ent = MakeVehicle( ply, spawnloc, Angles, vehicle.Model, vehicle.Class, vname, vehicle )
	if ( !IsValid( Ent ) ) then return end

	if ( vehicle.Members ) then
		table.Merge( Ent, vehicle.Members )
		duplicator.StoreEntityModifier( Ent, "VehicleMemDupe", vehicle.Members )
	end
    return Ent
end


function LCarNPC:SpawnVehicle(ply, ent, pos, spawntype, ang)
    if spawntype == "Simfphys" then
        local vehicle = simfphys.SpawnVehicleSimple(ent, pos, ang)
        ply.TankVehicle = vehicle
        return vehicle
    elseif spawntype == "WAC" then
        local vehicle = ents.Create(ent)
        vehicle:Spawn()
        vehicle:SetPos(pos)
        vehicle:SetAngles(ang)
        ply.TankVehicle = vehicle
        return vehicle
    elseif spawntype == "Other" then
        local vehicle = SpawnVehicle(ply, ent, pos+Vector(0, 0, 10), ang)
        ply.TankVehicle = vehicle
        return vehicle
    end
end

util.AddNetworkString("LCarNPC:ClickVehicle")
net.Receive("LCarNPC:ClickVehicle", function(len, ply)
    local int, ent, steamid = net.ReadUInt(32), net.ReadEntity(), ply:SteamID()
    local data = LCarNPC.Cars[int]
    if not data then return end
    if not IsValid(ent) or not ent:GetID() then return end

    if LCarNPC:HasVehicle(steamid, data.id) then
        ply:ExitVehicle()
        if IsValid(ply.TankVehicle) then
            ply.TankVehicle:Remove()
        end

        local spawnpos = false
        for k, v in ipairs(LCarNPC.NPCs[ent:GetID()].spawnlocations) do
            if #ents.FindInBox(v[1]-Vector(30, 30, 30), v[1]+Vector(30, 30, 30)) > 0 then continue end
            spawnpos = {v[1], v[2]}
        end
        if not spawnpos then DarkRP.notify(ply, 1, 3, "There isnt a free spawn position!") return end

        local veh = LCarNPC:SpawnVehicle(ply, data.class, spawnpos[1], data.spawner, spawnpos[2])
        veh:CPPISetOwner(ply)        
        veh:keysOwn(ply)
        veh:Lock()
        DarkRP.notify(ply, 1, 3, "Spawning the vehicle in!")
        return
    end

    if data.canbuy and not data.canbuy(ply) then
        if data.failmsg then
            DarkRP.notify(ply, 1, 3, data.failmsg)
        end
        return
    end

    if not ply:canAfford(data.price) then
        DarkRP.notify(ply, 1, 3, "You cannot afford this!")
        return
    end

    LCarNPC:AddVehicle(steamid, data.id)
    DarkRP.notify(ply, 1, 3, "Vehicle purchased!")
end)

util.AddNetworkString("LCarNPC:RequestData")
util.AddNetworkString("LCarNPC:SendData")
net.Receive("LCarNPC:RequestData", function(len, ply)
    local data = LCarNPC:GetVehicles(ply:SteamID())
    net.Start("LCarNPC:SendData")
    net.WriteUInt(#data, 32)
    if #data > 0 then
        for k, v in ipairs(data) do
            print(v.id)
            net.WriteString(v.id)
        end
    end
    net.Send(ply)
end)