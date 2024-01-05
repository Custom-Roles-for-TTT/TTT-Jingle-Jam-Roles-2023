--// Logan Christianson
local PHYSICIAN = PHYSICIAN or {}
local nextGet = 0
local nextGetOffset = 1

local healthcolors = {
    healthy = Color(0, 255, 0, 255),
    hurt    = Color(170, 230, 10, 255),
    wounded = Color(230, 215, 10, 255),
    badwound= Color(255, 140, 0, 255),
    death   = Color(255, 0, 0, 255)
};


local function ResetScoreboard()
    if sboard_panel then
        GAMEMODE:ScoreboardHide()
        sboard_panel:Remove()
        sboard_panel = nil
    end
end

function PHYSICIAN:GetAllPhysicianTrackedPlayers()
    self.trackedPlayers = self.trackedPlayers or {}

    if CurTime() > nextGet then
        net.Start("GetAllPhysicianTrackedPlayers")
        net.SendToServer()

        nextGet = CurTime() + nextGetOffset
    end

    return self.trackedPlayers
end

function PHYSICIAN:GetPlayerStatusText(ply)
    local status = self:GetAllPhysicianTrackedPlayers()[ply:SteamID64()]

    if status and status > 0 then
        if status == 1 then
            local text, color = self:GetStatusFromHealth(ply)

            return text, color
        elseif status == 2 then
            return "No Signal", healthcolors.death
        end
    end
end

function PHYSICIAN:GetStatusFromHealth(ply)
    local currentHealth = ply:Health()
    local maxHealth = ply:GetMaxHealth()

    if currentHealth < 1 or not LocalPlayer():Alive() then
        return "No Signal"
    end

    if LocalPlayer():HasEquipmentItem(EQUIP_PHS_TRACKER) then
        if currentHealth > maxHealth * 0.9 then
            return "Healthy", healthcolors.healthy
        elseif currentHealth > maxHealth * 0.7 then
            return "Hurt", healthcolors.hurt
        elseif currentHealth > maxHealth * 0.45 then
            return "Injured", healthcolors.wounded
        elseif currentHealth > maxHealth * 0.2 then
            return "Wounded", healthcolors.badwound
        else
            return "Near Death", healthcolors.death
        end
    else
        if currentHealth > maxHealth * 0.67 then
            return "Normal", healthcolors.healthy
        elseif currentHealth > maxHealth * 0.33 then
            return "Elevated", healthcolors.hurt
        else
            return "Dangerous", healthcolors.badwound
        end
    end
end

net.Receive("GetAllPhysicianTrackedPlayersCallback", function(len)
    local numPlayers = net.ReadInt(16)

    for i = 0, numPlayers do
        local playerSteamId = net.ReadString()
        local playerTrackedStatus = net.ReadInt(4)

        PHYSICIAN.trackedPlayers[playerSteamId] = playerTrackedStatus
    end
end)

hook.Add("TTTBoughtItem", "Reset Physician Scoreboard On Upgrade Purchased", function(isItemNotWep, equipment)
    if isItemNotWep and equipment == EQUIP_PHS_TRACKER then
        ResetScoreboard()
    end
end)

hook.Add("TTTPlayerRoleChanged", "Reset Scoreboard On Given Physician Role", function(_, oldRole, newRole)
    if oldRole ~= ROLE_PHYSICIAN and newRole == ROLE_PHYSICIAN then
        ResetScoreboard()
    end
end)

hook.Add("TTTScoreboardColumns", "Physician Health Column", function(basePanel)
    local ply = LocalPlayer()

    if ply:IsPhysician() then
        local columnLabel
        if ply:HasEquipmentItem(EQUIP_PHS_TRACKER) then
            columnLabel = "Status"
        else
            columnLabel = "Heartrate"
        end

        basePanel:AddColumn(columnLabel, function(p, dLabelPanel)
            local text, color = PHYSICIAN:GetPlayerStatusText(p)

            dLabelPanel:SetTextColor(color or healthcolors.death)

            return text or ""
        end, 90)
    end
end)

hook.Add("TTTTutorialRoleText", "SummonerTutorialRoleText", function(role)
    if role == ROLE_PHYSICIAN then
        return "The Physician is a member of the detective team who has access to a Health Tracker which can be used to track the health status of players a tracker has been placed on. They otherwise have full access to the default Detective shop."
    end
end)