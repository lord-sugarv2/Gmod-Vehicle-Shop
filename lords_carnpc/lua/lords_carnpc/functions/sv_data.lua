function LCarNPC:CheckDatabase()
    sql.Query("CREATE TABLE IF NOT EXISTS LCarNPC (steamid TEXT, id TEXT)")
end
LCarNPC:CheckDatabase()

util.AddNetworkString("LCarNPC:Wipe")
function LCarNPC:ResetDatabase()
    sql.Query("DROP TABLE LCarNPC")
    LCarNPC:CheckDatabase()

    net.Start("LCarNPC:Wipe")
    net.Broadcast()
end

function LCarNPC:GetVehicles(steamid)
    local data = sql.Query("SELECT * FROM LCarNPC WHERE steamid = "..sql.SQLStr(steamid)..";")
    return data and data or {}
end

function LCarNPC:HasVehicle(steamid, id)
    local data = sql.Query("SELECT * FROM LCarNPC WHERE steamid = "..sql.SQLStr(steamid).." AND id = "..sql.SQLStr(id)..";")
    return data and data or false
end

util.AddNetworkString("LCarNPC:UpdateVehicle")
function LCarNPC:AddVehicle(steamid, id)
    if LCarNPC:HasVehicle(steamid, id) then return end
    sql.Query("INSERT INTO LCarNPC (steamid, id) VALUES("..sql.SQLStr(steamid)..", "..sql.SQLStr(id)..")")

    local ply = player.GetBySteamID(steamid)
    if not ply and not IsValid(ply) then return end
    net.Start("LCarNPC:UpdateVehicle")
    net.WriteString(id)
    net.WriteBool(true)
    net.Send(ply)
end

function LCarNPC:RemoveVehicle(steamid, id)
    sql.Query("DELETE FROM LCarNPC WHERE steamid = "..sql.SQLStr(steamid).." AND id = "..sql.SQLStr(id)..";")

    local ply = player.GetBySteamID(steamid)
    if not ply and not IsValid(ply) then return end
    net.Start("LCarNPC:UpdateVehicle")
    net.WriteString(id)
    net.WriteBool(false)
    net.Send(ply)
end