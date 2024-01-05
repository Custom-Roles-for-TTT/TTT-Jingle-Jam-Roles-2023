--// Logan Christianson
AddCSLuaFile()

util.AddNetworkString("GetAllPhysicianTrackedPlayers")
util.AddNetworkString("GetAllPhysicianTrackedPlayersCallback")

local PHYSICIAN = PHYSICIAN or {tracking = {}}

function PHYSICIAN:ResetAllTrackedPlayers()
    PHYSICIAN.tracking = {}
end

function PHYSICIAN:AddNewTrackedPlayer(physician, trackedPly)
    if physician:GetRole() ~= ROLE_PHYSICIAN then
        return
    end

    local physicianSteamId = physician:SteamID64()
    
    self.tracking[physicianSteamId] = self.tracking[physicianSteamId] or {physicianSteamId = 1}
    self.tracking[physicianSteamId][trackedPly:SteamID64()] = 1
end

function PHYSICIAN:DestructTracker(plyToDestruct, plyCauser) -- Doing anything with plyCauser?
    for _, v in ipairs(player.GetAll()) do
        local plyId = v:SteamID64()
        
        if self.tracking[plyId] then
            self.tracking[plyId][plyToDestruct:SteamID64()] = 2
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
    local maxDist = nil
    
    if ply:HasEquipmentItem(EQUIP_PHS_TRACKER) then
        maxDist = GetConVar("ttt_physician_tracker_range_boosted"):GetInt()
    else
        maxDist = GetConVar("ttt_physician_tracker_range_default"):GetInt()
    end

    maxDist = maxDist * 10
    maxDist = maxDist * maxDist

    for _, ply in pairs(player.GetAll()) do
        local plyId = ply:SteamID64()
        if PHYSICIAN.tracking[physicianSteamId][plyId] and (not ply:Alive() or plyPos:DistToSqr(ply:GetPos()) > maxDist) then
            distanceOverride[plyId] = 2
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

hook.Add("TTTPlayerRoleChanged", "Reset Scoreboard On Given Physician Role", function(ply, _, newRole)
    if newRole == ROLE_PHYSICIAN then
        PHYSICIAN:AddNewTrackedPlayer(ply, ply)
    end
end)

hook.Add("TTTPrepareRound", "Remove Old Physician Targets", function()
    PHYSICIAN:ResetAllTrackedPlayers()
end)

GM.PHYSICIAN = PHYSICIAN