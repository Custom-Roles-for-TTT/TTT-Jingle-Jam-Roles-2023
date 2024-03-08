local ROLE = {}

ROLE.nameraw = "ghostwhisperer"
ROLE.name = "Ghost Whisperer"
ROLE.nameplural = "Ghost Whisperers"
ROLE.nameext = "a Ghost Whisperer"
ROLE.nameshort = "gwh"

ROLE.desc = [[You are {role}! Use your ghosting device to
allow a dead player to talk in chat.]]

ROLE.team = ROLE_TEAM_INNOCENT

ROLE.convars = {}
table.insert(ROLE.convars, {
    cvar = "ttt_ghostwhisperer_ghosting_time",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})

ROLE.translations = {
    ["english"] = {
        ["ghostingdevice_help_pri"] = "Hold {primaryfire} on a dead body to allow that player to talk in chat.",
    }
}

RegisterRole(ROLE)

if SERVER then
    hook.Add("TTTPrepareRound", "GhostWhisperer_TTTPrepareRound", function()
        for _, p in ipairs(player.GetAll()) do
            p:SetNWBool("TTTIsGhosting", false)
        end
    end)

    hook.Add("PlayerCanSeePlayersChat", "GhostWhisperer_PlayerCanSeePlayersChat", function(text, teamOnly, listener, speaker)
        if not IsPlayer(listener) or not IsPlayer(speaker) then return end
        if speaker:Team() == TEAM_SPEC and speaker:GetNWBool("TTTIsGhosting", false) then
            return true
        end
    end)

    hook.Add("TTTPlayerAliveThink", "GhostWhisperer_TTTPlayerAliveThink", function(ply)
        if not IsPlayer(ply) then return end
        if ply:IsActive() and ply:GetNWBool("TTTIsGhosting", false) then
            ply:SetNWBool("TTTIsGhosting", false)
        end
    end)
end

if CLIENT then
    --------------
    -- TUTORIAL --
    --------------

    hook.Add("TTTTutorialRoleText", "GhostWhisperer_TTTTutorialRoleText", function(role, titleLabel)
        if role == ROLE_GHOSTWHISPERER then
            local roleColor = ROLE_COLORS[ROLE_INNOCENT]

            local html = "The " .. ROLE_STRINGS[ROLE_GHOSTWHISPERER] .. " is a member of the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>innocent team</span> who can use their ghosting device to allow a dead player to talk in chat."

            return html
        end
    end)
end