-- Logan Christianson
AddCSLuaFile()

util.AddNetworkString("GetAllPhysicianTrackedPlayers")
util.AddNetworkString("GetAllPhysicianTrackedPlayersCallback")

local PHYSICIAN = PHYSICIAN or {tracking = {}}

function PHYSICIAN:ResetAllTrackedPlayers()
    PHYSICIAN.tracking = {}
end

function PHYSICIAN:AddNewTrackedPlayer(physician, trackedPly)
    if not physician:IsPhysician() then
        return
    end

    local physicianSteamId = physician:SteamID64()

    if not self.tracking[physicianSteamId] then
        self.tracking[physicianSteamId] = {}
        self.tracking[physicianSteamId][physicianSteamId] = PHYSICIAN_TRACKER_ACTIVE
    end
    self.tracking[physicianSteamId][trackedPly:SteamID64()] = PHYSICIAN_TRACKER_ACTIVE
end

function PHYSICIAN:DestructTracker(plyToDestruct, plyCauser) -- Doing anything with plyCauser?
    for _, v in ipairs(player.GetAll()) do
        local plyId = v:SteamID64()

        if self.tracking[plyId] then
            self.tracking[plyId][plyToDestruct:SteamID64()] = PHYSICIAN_TRACKER_DEAD
        end
    end
end

function PHYSICIAN:IsPlayerBeingTracked(physician, ply)
    return self.tracking[physician:SteamID64()] and self.tracking[physician:SteamID64()][ply:SteamID64()]
end

net.Receive("GetAllPhysicianTrackedPlayers", function(len, ply)
    local physicianSteamId = ply:SteamID64()

    if not PHYSICIAN.tracking[physicianSteamId] or not IsValid(ply) or not ply:IsTerror() then
        return
    end

    local distanceOverride = {}
    local plyPos = ply:GetPos()
    local maxDist

    if ply:HasEquipmentItem(EQUIP_PHS_TRACKER) then
        maxDist = GetConVar("ttt_physician_tracker_range_boosted"):GetInt()
    else
        maxDist = GetConVar("ttt_physician_tracker_range_default"):GetInt()
    end

    maxDist = maxDist * 10
    maxDist = maxDist * maxDist

    for _, p in pairs(player.GetAll()) do
        local plyId = p:SteamID64()
        if PHYSICIAN.tracking[physicianSteamId][plyId] and (not p:Alive() or plyPos:DistToSqr(p:GetPos()) > maxDist) then
            distanceOverride[plyId] = PHYSICIAN_TRACKER_DEAD
        end
    end

    net.Start("GetAllPhysicianTrackedPlayersCallback")
        net.WriteInt(table.Count(PHYSICIAN.tracking[physicianSteamId]), 16)
        for trackedPly, status in pairs(PHYSICIAN.tracking[physicianSteamId]) do
            net.WriteString(trackedPly)
            net.WriteInt(distanceOverride[trackedPly] or status, 4)
        end
    net.Send(ply)
end)

-- Automatically track yourself as a phyiscian
hook.Add("TTTPlayerRoleChanged", "Physician_TTTPlayerRoleChanged", function(ply, _, newRole)
    if newRole == ROLE_PHYSICIAN then
        PHYSICIAN:AddNewTrackedPlayer(ply, ply)
    end
end)

-- Remove old targets
hook.Add("TTTPrepareRound", "Physician_TTTPrepareRound", function()
    PHYSICIAN:ResetAllTrackedPlayers()
end)

GM.PHYSICIAN = PHYSICIAN