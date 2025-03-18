local player = player

local PlayerIterator = player.Iterator

local ROLE = {}

ROLE.nameraw = "ghostwhisperer"
ROLE.name = "Ghost Whisperer"
ROLE.nameplural = "Ghost Whisperers"
ROLE.nameext = "a Ghost Whisperer"
ROLE.nameshort = "gwh"

ROLE.desc = [[You are {role}! Use your ghosting device to
allow a dead player to talk in chat.]]
ROLE.shortdesc = "Has a Ghosting Device that they can use on dead players to allow speaking from beyond the grave."

ROLE.team = ROLE_TEAM_INNOCENT

ROLE.convars = {}
table.insert(ROLE.convars, {
    cvar = "ttt_ghostwhisperer_ghosting_time",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE.convars, {
    cvar = "ttt_ghostwhisperer_limited_chat",
    type = ROLE_CONVAR_TYPE_BOOL
})
table.insert(ROLE.convars, {
    cvar = "ttt_ghostwhisperer_max_abilities",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})

ROLE.translations = {
    ["english"] = {
        ["ghostingdevice_help_pri"] = "Hold {primaryfire} on a dead body to allow that player to talk in chat.",
    }
}

RegisterRole(ROLE)

local ghostwhisperer_limited_chat = CreateConVar("ttt_ghostwhisperer_limited_chat", "0", FCVAR_REPLICATED, "Whether only the ghost whisperer should be able to see the chat of their dead target", 0, 1)

if SERVER then
    AddCSLuaFile()

    hook.Add("TTTPrepareRound", "GhostWhisperer_TTTPrepareRound", function()
        for _, p in PlayerIterator() do
            p:ClearProperty("TTTIsGhosting")
        end
    end)

    hook.Add("PlayerCanSeePlayersChat", "GhostWhisperer_PlayerCanSeePlayersChat", function(text, teamOnly, listener, speaker)
        if not IsPlayer(listener) or not IsPlayer(speaker) then return end
        -- If the listener is dead then let the base logic handle this
        if not listener:IsActive() then return end
        -- If this listener is not the ghost whisperer and the chat ability to limited to only them, then let the base logic handle this
        if ghostwhisperer_limited_chat:GetBool() and not listener:IsGhostWhisperer() then return end

        if speaker:Team() == TEAM_SPEC and speaker.TTTIsGhosting then
            return true
        end
    end)

    hook.Add("TTTPlayerSpawnForRound", "GhostWhisperer_TTTPlayerSpawnForRound", function(ply, dead_only)
        if not IsPlayer(ply) then return end
        ply:ClearProperty("TTTIsGhosting")
    end)
end

if CLIENT then
    --------------
    -- TUTORIAL --
    --------------

    hook.Add("TTTTutorialRoleText", "GhostWhisperer_TTTTutorialRoleText", function(role, titleLabel)
        if role == ROLE_GHOSTWHISPERER then
            local roleColor = ROLE_COLORS[ROLE_INNOCENT]

            local html = "The " .. ROLE_STRINGS[ROLE_GHOSTWHISPERER] .. " is a member of the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>innocent team</span> who can use their ghosting device to allow a dead player to talk"
            if ghostwhisperer_limited_chat:GetBool() then
                html = html .. " to them"
            end
            html = html .. " in chat."

            return html
        end
    end)
end