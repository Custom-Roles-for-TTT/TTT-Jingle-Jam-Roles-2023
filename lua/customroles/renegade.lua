local hook = hook
local player = player
local table = table

local AddHook = hook.Add
local GetAllPlayers = player.GetAll
local TableInsert = table.insert

local ROLE = {}

ROLE.nameraw = "renegade"
ROLE.name = "Renegade"
ROLE.nameplural = "Renegades"
ROLE.nameext = "a Renegade"
ROLE.nameshort = "ren"

ROLE.desc = [[You are {role}!]]
-- TODO: List the traitors

ROLE.team = ROLE_TEAM_INDEPENDENT

ROLE.translations = {
    ["english"] = {
        ["win_renegade"] = "",
        ["ev_win_renegade"] = ""
    }
}

ROLE.shop = {}

ROLE.canseejesters = true
ROLE.canseemia = true

ROLE.convars = {}
TableInsert(ROLE.convars, {
    cvar = "ttt_renegade_warn_all",
    type = ROLE_CONVAR_TYPE_BOOL
})

if SERVER then
    AddCSLuaFile()

    local renegade_warn_all = CreateConVar("ttt_renegade_warn_all", "0", FCVAR_REPLICATED)

    ------------------
    -- ANNOUNCEMENT --
    ------------------

    -- Warn other players that there is a renegade
    AddHook("TTTBeginRound", "Renegade_Announce_TTTBeginRound", function()
        timer.Simple(1.5, function()
            local plys = GetAllPlayers()

            local hasRenegade = false
            for _, v in ipairs(plys) do
                if v:IsRenegade() then
                    hasRenegade = true
                end
            end

            if hasRenegade then
                for _, v in ipairs(plys) do
                    local isTraitor = v:IsTraitorTeam()
                    -- Warn this player about the Renegade if they are a traitor or we are configured to warn everyone
                    if not v:IsRenegade() and (isTraitor or renegade_warn_all:GetBool()) then
                        v:QueueMessage(MSG_PRINTBOTH, "There is " .. ROLE_STRINGS_EXT[ROLE_RENEGADE] .. ".")
                    end
                end
            end
        end)
    end)

    ----------------
    -- WIN CHECKS --
    ----------------

    AddHook("Initialize", "Renegade_Initialize", function()
        WIN_RENEGADE = GenerateNewWinID(ROLE_RENEGADE)
    end)

    AddHook("TTTCheckForWin", "Renegade_TTTCheckForWin", function()
        local renegade_alive = false
        local other_alive = false
        for _, v in ipairs(GetAllPlayers()) do
            if v:IsActive() then
                if v:IsRenegade() then
                    renegade_alive = true
                elseif not v:ShouldActLikeJester() then
                    other_alive = true
                end
            end
        end

        if renegade_alive and not other_alive then
            return WIN_RENEGADE
        elseif renegade_alive then
            return WIN_NONE
        end
    end)

    AddHook("TTTPrintResultMessage", "Renegade_TTTPrintResultMessage", function(type)
        if type == WIN_RENEGADE then
            LANG.Msg("win_renegade", { role = ROLE_STRINGS[ROLE_RENEGADE] })
            ServerLog("Result: " .. ROLE_STRINGS[ROLE_RENEGADE] .. " wins.\n")
            return true
        end
    end)

    ------------------
    -- TRAITOR CHAT --
    ------------------

    -- TODO: Show traitor team messages to renegade
    -- TODO: Allow renegade to send messages to traitor team
end

if CLIENT then

    ---------------
    -- TARGET ID --
    ---------------

    -- TODO: Show traitors with red question mark icon on target ID and scoreboard
    -- TODO: Show renegade to traitors on target ID and scoreboard
    -- TODO: ConVar so that the Renegade also sees the Glitch as a traitor (not sure whether this should be enabled or disabled by default)

    ----------------
    -- WIN CHECKS --
    ----------------

    AddHook("TTTScoringWinTitle", "Renegade_TTTScoringWinTitle", function(wintype, wintitles, title, secondary_win_role)
        if wintype == WIN_RENEGADE then
            return { txt = "hilite_win_role_singular", params = { role = string.upper(ROLE_STRINGS[ROLE_RENEGADE]) }, c = ROLE_COLORS[ROLE_RENEGADE] }
        end
    end)

    ------------
    -- EVENTS --
    ------------

    AddHook("TTTEventFinishText", "Renegade_TTTEventFinishText", function(e)
        if e.win == WIN_RENEGADE then
            return LANG.GetParamTranslation("ev_win_renegade", { role = string.lower(ROLE_STRINGS[ROLE_RENEGADE]) })
        end
    end)

    AddHook("TTTEventFinishIconText", "Renegade_TTTEventFinishIconText", function(e, win_string, role_string)
        if e.win == WIN_RENEGADE then
            return win_string, ROLE_STRINGS[ROLE_RENEGADE]
        end
    end)

    --------------
    -- TUTORIAL --
    --------------

    AddHook("TTTTutorialRoleText", "Renegade_TTTTutorialRoleText", function(role, titleLabel)
        if role == ROLE_RENEGADE then
            -- TODO
        end
    end)
end

RegisterRole(ROLE)