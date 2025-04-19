local hook = hook
local player = player
local string = string
local table = table

local AddHook = hook.Add
local PlayerIterator = player.Iterator
local StringUpper = string.upper
local StringLower = string.lower
local TableInsert = table.insert

local ROLE = {}

ROLE.nameraw = "renegade"
ROLE.name = "Renegade"
ROLE.nameplural = "Renegades"
ROLE.nameext = "a Renegade"
ROLE.nameshort = "ren"

ROLE.desc = [[You are {role}! Beware of the {traitors}!
You can see who they are, but they can see who you are as well.
Create a silent partnership or secretly work to undermine them,
it's completely up to you!

These are the {traitors}:
{traitorlist}]]
ROLE.shortdesc = "Can see and be seen by the traitors and so must choose to work with or against them. Wins by being the last player alive."

ROLE.team = ROLE_TEAM_INDEPENDENT

ROLE.translations = {
    ["english"] = {
        ["win_renegade"] = "The {role} has overpowered their enemies to win!",
        ["ev_win_renegade"] = "The powerful {role} has fought their way to victory!",
        ["info_popup_renegade_glitch"] = [[You are {role}! Beware of the {traitors}!
You can see who they are, but they can see who you are as well.
Create a silent partnership or secretly work to undermine them,
it's completely up to you!

BUT BEWARE! There was {aglitch} in the system and one among the
{traitors} does not seek the same goal.

These may or may not be the {traitors}:
{traitorlist}]]
    }
}

ROLE.shop = {}

ROLE.canseejesters = true
ROLE.canseemia = true

local renegade_show_glitch = CreateConVar("ttt_renegade_show_glitch", "0", FCVAR_REPLICATED, "Whether to allow the renegade to see the glitch. They will show as an unknown traitor", 0, 1)

ROLE.convars = {
    {
        cvar = "ttt_renegade_warn_all",
        type = ROLE_CONVAR_TYPE_BOOL
    },
    {
        cvar = "ttt_renegade_show_glitch",
        type = ROLE_CONVAR_TYPE_BOOL
    }
}

RegisterRole(ROLE)

local function IsRenegade(ply)
    return ply:IsRenegade() and not ply:IsRoleAbilityDisabled()
end

if SERVER then
    AddCSLuaFile()

    local renegade_warn_all = CreateConVar("ttt_renegade_warn_all", "0", FCVAR_REPLICATED, "Whether to warn all players there is a renegade in the round. If disabled, only traitors are warned", 0, 1)

    ------------------
    -- ANNOUNCEMENT --
    ------------------

    -- Warn other players that there is a renegade
    AddHook("TTTBeginRound", "Renegade_Announce_TTTBeginRound", function()
        timer.Simple(1.5, function()
            local renegade = nil
            local hasGlitch = false
            for _, v in PlayerIterator() do
                if v:IsRenegade() then
                    renegade = v
                elseif v:IsGlitch() then
                    hasGlitch = true
                end
            end

            if renegade then
                for _, v in PlayerIterator() do
                    -- Warn the Renegade about the glitch, if there is one
                    -- Do this in the loop in case there are multiple renegades
                    if v:IsRenegade() then
                        if hasGlitch and renegade_show_glitch:GetBool() then
                            v:QueueMessage(MSG_PRINTBOTH, "There is " .. ROLE_STRINGS_EXT[ROLE_GLITCH] .. ".")
                        end
                        continue
                    end

                    -- Warn this player about the renegade if they are a traitor or we are configured to warn everyone
                    if v:IsTraitorTeam() or renegade_warn_all:GetBool() then
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
        for _, v in PlayerIterator() do
            if v:IsActive() then
                if v:IsRenegade() then
                    renegade_alive = true
                elseif not v:ShouldActLikeJester() and not ROLE_HAS_PASSIVE_WIN[v:GetRole()] then
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

    -- Allow renegade to send messages to traitor team
    AddHook("PlayerSay", "Renegade_PlayerSay", function(ply, text, team_only)
        if not team_only then return end
        if not IsPlayer(ply) or not ply:Alive() or ply:IsSpec() then return end
        if not IsRenegade(ply) then return end

        local targets = {}
        for _, v in PlayerIterator() do
            if v:IsTraitorTeam() or v:IsRenegade() then
                TableInsert(targets, v)
            end
        end

        -- Don't send chat messages if there is a glitch
        if ShouldGlitchBlockCommunications() then
            ply:PrintMessage(HUD_PRINTTALK, "The glitch is scrambling your communications")
        -- Send the message as a role message to all traitors and renegades
        else
            net.Start("TTT_RoleChat")
                net.WriteInt(ply:GetRole(), 8)
                net.WritePlayer(ply)
                net.WriteString(text)
            net.Send(targets)
        end
        return ""
    end)

    -- Allow renegades to read traitor chat
    AddHook("TTTTeamChatTargets", "Renegade_TTTTeamChatTargets", function(sender, msg, targets, from_chat)
        if not IsPlayer(sender) or not sender:Alive() or sender:IsSpec() then return end

        -- Send traitor chat messages to renegades, but use a separate message so we can override their role to always show "traitor"
        if sender:IsTraitorTeam() then
            -- Don't send the chat message unless this is being called from the chat method so we don't get duplicates
            if not from_chat then return end

            local renegades = {}
            for _, v in PlayerIterator() do
                if not v:IsActive() then continue end
                if not IsRenegade(v) then continue end
                TableInsert(renegades, v)
            end

            net.Start("TTT_RoleChat")
                net.WriteInt(ROLE_TRAITOR, 8)
                net.WritePlayer(sender)
                net.WriteString(msg)
            net.Send(renegades)
        -- Send renegade messages to traitors and themselves
        elseif IsRenegade(sender) then
            for _, v in PlayerIterator() do
                if not v:IsActive() then continue end
                if IsRenegade(v) or v:IsTraitorTeam() then
                    TableInsert(targets, v)
                end
            end
        end
    end)

    --- Allow renegades and traitors to see that each other is speaking
    AddHook("TTTTeamVoiceChatTargets", "Renegade_TTTTeamVoiceChatTargets", function(speaker, targets)
        if not IsPlayer(speaker) or not speaker:Alive() or speaker:IsSpec() then return end

        -- Add renegades to the traitor team target list
        if speaker:IsTraitorTeam() then
            for _, v in PlayerIterator() do
                if not v:IsActive() then continue end
                if not IsRenegade(v) then continue end
                TableInsert(targets, v)
            end
        -- Send renegade messages to traitors and themselves
        elseif IsRenegade(speaker) then
            for _, v in PlayerIterator() do
                if not v:IsActive() then continue end
                if IsRenegade(v) or v:IsTraitorTeam() then
                    TableInsert(targets, v)
                end
            end
        end
    end)
end

-- Allow renegades to speak to and listen to traitors
AddHook("TTTCanUseTraitorVoice", "Renegade_TTTCanUseHearTraitorVoice", function(ply)
    if not IsPlayer(ply) then return end
    if not IsRenegade(ply) then return end

    return true
end)

if CLIENT then

    ---------------
    -- TARGET ID --
    ---------------

    AddHook("TTTTargetIDPlayerRoleIcon", "Renegade_TTTTargetIDPlayerRoleIcon", function(ply, cli, role, noz, color_role, hideBeggar, showJester, hideBodysnatcher)
        if GetRoundState() < ROUND_ACTIVE then return end
        if IsRenegade(cli) and (ply:IsTraitorTeam() or (renegade_show_glitch:GetBool() and ply:IsGlitch())) then
            local icon_overridden, _, _ = ply:IsTargetIDOverridden(cli)
            if icon_overridden then return end

            return ROLE_NONE, false, ROLE_TRAITOR
        elseif cli:IsTraitorTeam() and IsRenegade(ply) then
            local icon_overridden, _, _ = cli:IsTargetIDOverridden(ply)
            if icon_overridden then return end

            return ROLE_RENEGADE, false, ROLE_RENEGADE
        end
    end)

    AddHook("TTTTargetIDPlayerRing", "Renegade_TTTTargetIDPlayerRing", function(ent, cli, ring_visible)
        if GetRoundState() < ROUND_ACTIVE then return end
        if not IsPlayer(ent) then return end

        if IsRenegade(cli) and (ent:IsTraitorTeam() or (renegade_show_glitch:GetBool() and ent:IsGlitch())) then
            local _, ring_overridden, _ = ent:IsTargetIDOverridden(cli)
            if ring_overridden then return end

            return true, ROLE_COLORS_RADAR[ROLE_TRAITOR]
        elseif cli:IsTraitorTeam() and IsRenegade(ent) then
            local _, ring_overridden, _ = cli:IsTargetIDOverridden(ent)
            if ring_overridden then return end

            return true, ROLE_COLORS_RADAR[ROLE_RENEGADE]
        end
    end)

    AddHook("TTTTargetIDPlayerText", "Renegade_TTTTargetIDPlayerText", function(ent, cli, text, col, secondary_text)
        if GetRoundState() < ROUND_ACTIVE then return end
        if not IsPlayer(ent) then return end

        if IsRenegade(cli) and (ent:IsTraitorTeam() or (renegade_show_glitch:GetBool() and ent:IsGlitch())) then
            local _, _, text_overridden = ent:IsTargetIDOverridden(cli)
            if text_overridden then return end

            local role_string = LANG.GetParamTranslation("target_unknown_team", { targettype = LANG.GetTranslation("traitor")})
            return StringUpper(role_string), ROLE_COLORS_RADAR[ROLE_TRAITOR]
        elseif IsPlayer(ent) and cli:IsTraitorTeam() and IsRenegade(ent) then
            local _, _, text_overridden = cli:IsTargetIDOverridden(ent)
            if text_overridden then return end

            return StringUpper(ROLE_STRINGS[ROLE_RENEGADE]), ROLE_COLORS_RADAR[ROLE_RENEGADE]
        end
    end)

    ROLE.istargetidoverridden = function(ply, target)
        if GetRoundState() < ROUND_ACTIVE then return end
        if not IsPlayer(target) then return end

        local visible = (IsRenegade(ply) and (target:IsTraitorTeam() or (renegade_show_glitch:GetBool() and target:IsGlitch()))) or
                        (ply:IsTraitorTeam() and IsRenegade(target))
        ------ icon,    ring,    text
        return visible, visible, visible
    end

    ----------------
    -- SCOREBOARD --
    ----------------

    AddHook("TTTScoreboardPlayerRole", "Renegade_TTTScoreboardPlayerRole", function(ply, cli, color, roleFileName)
        if GetRoundState() < ROUND_ACTIVE then return end
        if IsRenegade(cli) and (ply:IsTraitorTeam() or (renegade_show_glitch:GetBool() and ply:IsGlitch())) then
            local _, role_overridden = ply:IsScoreboardInfoOverridden(cli)
            if role_overridden then return end

            return ROLE_COLORS_SCOREBOARD[ROLE_TRAITOR], ROLE_STRINGS_SHORT[ROLE_NONE]
        end
        if (cli:IsTraitorTeam() and IsRenegade(ply)) or (cli == ply and IsRenegade(cli)) then
            local _, role_overridden = cli:IsScoreboardInfoOverridden(ply)
            if role_overridden then return end

            return ROLE_COLORS_SCOREBOARD[ROLE_RENEGADE], ROLE_STRINGS_SHORT[ROLE_RENEGADE]
        end
    end)

    ROLE.isscoreboardinfooverridden = function(ply, target)
        if GetRoundState() < ROUND_ACTIVE then return end
        if not IsPlayer(target) then return end

        local visible = (IsRenegade(ply) and (target:IsTraitorTeam() or (renegade_show_glitch:GetBool() and target:IsGlitch()))) or
                        (ply:IsTraitorTeam() and IsRenegade(target))
        ------ name,  role
        return false, visible
    end

    ----------------
    -- ROLE POPUP --
    ----------------

    AddHook("TTTRolePopupParams", "Renegade_TTTRolePopupParams", function(cli)
        if not cli:IsRenegade() then return end

        local traitorlist = ""
        for _, ply in PlayerIterator() do
            if ply:IsTraitorTeam() or (renegade_show_glitch:GetBool() and ply:IsGlitch()) then
                traitorlist = traitorlist .. string.rep(" ", 42) .. ply:Nick() .. "\n"
            end
        end

        return { traitorlist = traitorlist }
    end)

    AddHook("TTTRolePopupRoleStringOverride", "Renegade_TTTRolePopupRoleStringOverride", function(cli, roleString)
        if not cli:IsRenegade() then return end
        if not renegade_show_glitch:GetBool() then return end

        for _, ply in PlayerIterator() do
            -- Show a different popup if there is a glitch
            if renegade_show_glitch:GetBool() and ply:IsGlitch() then
                return roleString .. "_glitch"
            end
        end
    end)

    ----------------
    -- WIN CHECKS --
    ----------------

    AddHook("TTTSyncWinIDs", "Renegade_TTTSyncWinIDs", function()
        WIN_RENEGADE = WINS_BY_ROLE[ROLE_RENEGADE]
    end)

    AddHook("TTTScoringWinTitle", "Renegade_TTTScoringWinTitle", function(wintype, wintitles, title, secondary_win_role)
        if wintype == WIN_RENEGADE then
            return { txt = "hilite_win_role_singular", params = { role = StringUpper(ROLE_STRINGS[ROLE_RENEGADE]) }, c = ROLE_COLORS[ROLE_RENEGADE] }
        end
    end)

    ------------
    -- EVENTS --
    ------------

    AddHook("TTTEventFinishText", "Renegade_TTTEventFinishText", function(e)
        if e.win == WIN_RENEGADE then
            return LANG.GetParamTranslation("ev_win_renegade", { role = StringLower(ROLE_STRINGS[ROLE_RENEGADE]) })
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
        if role ~= ROLE_RENEGADE then return end

        local T = LANG.GetTranslation
        local traitorColor = ROLE_COLORS[ROLE_TRAITOR]
        local roleColor = ROLE_COLORS[ROLE_RENEGADE]
        local html = "The " .. ROLE_STRINGS[ROLE_RENEGADE] .. " is an <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>independent</span> role whose goal is to be the last player alive."

        html = html .. "<span style='display: block; margin-top: 10px;'>The " .. ROLE_STRINGS[ROLE_RENEGADE] .. " <span style='color: rgb(" .. traitorColor.r .. ", " .. traitorColor.g .. ", " .. traitorColor.b .. ")'>knows who the " .. T("traitors") .. " are</span> and the " .. T("traitors") .. " <span style='color: rgb(" .. traitorColor.r .. ", " .. traitorColor.g .. ", " .. traitorColor.b .. ")'>know who the " .. ROLE_STRINGS[ROLE_RENEGADE] .. " is</span>."
        if renegade_show_glitch:GetBool() then
            html = html .. " They can also see the " .. ROLE_STRINGS[ROLE_GLITCH] .. " as " .. ROLE_STRINGS_EXT[ROLE_TRAITOR] .. " as well."
        end
        html = html .. "</span>"

        html = html .. "<span style='display: block; margin-top: 10px;'>The " .. ROLE_STRINGS[ROLE_RENEGADE] .. " can also read and send messages in <span style='color: rgb(" .. traitorColor.r .. ", " .. traitorColor.g .. ", " .. traitorColor.b .. ")'>" .. T("traitor") .. "</span> chat.</span>"

        return html
    end)
end