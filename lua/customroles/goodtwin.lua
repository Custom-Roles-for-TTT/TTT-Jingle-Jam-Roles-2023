local ROLE = {}

ROLE.nameraw = "goodtwin"
ROLE.name = "Good Twin"
ROLE.nameplural = "Good Twins"
ROLE.nameext = "a Good Twin"
ROLE.nameshort = "gtw"

ROLE.desc = [[You are {role}!

You have a twin on the traitor team that knows who you are.
However, you and your twin are unable to damage each other.
If you are the last twin left alive you get temporary invulnerability.
Try to convince everyone that you are the good twin!]]

ROLE.team = ROLE_TEAM_INNOCENT

--------------------------
-- SPAWN LOGIC OVERRIDE --
--------------------------

ROLE.selectionpredicate = function()
    return false
end

hook.Add("TTTRoleSpawnsArtificially", "GoodTwin_TTTRoleSpawnsArtificially", function(role)
    if role == ROLE_GOODTWIN then
        if GetConVar("ttt_twins_enabled"):GetBool() then
            return true
        end
    end
end)

local goodtwin_enabled = CreateConVar("ttt_goodtwin_enabled", "0", FCVAR_REPLICATED)
cvars.AddChangeCallback("ttt_goodtwin_enabled", function(cvar, old, new)
    if old ~= new then
        ErrorNoHalt("WARNING: The twins do not use this ConVar. Please use 'ttt_twins_enabled' instead.")
        goodtwin_enabled:SetBool(false)
    end
end)

if SERVER then
    local goodtwin_spawn_weight = CreateConVar("ttt_goodtwin_spawn_weight", "1")
    cvars.AddChangeCallback("ttt_goodtwin_spawn_weight", function(cvar, old, new)
        if old ~= new then
            ErrorNoHalt("WARNING: The twins do not use this ConVar. Please use 'ttt_twins_chance' instead.")
            goodtwin_spawn_weight:SetInt(1)
        end
    end)

    local goodtwin_min_players = CreateConVar("ttt_goodtwin_min_players", "0")
    cvars.AddChangeCallback("ttt_goodtwin_min_players", function(cvar, old, new)
        if old ~= new then
            ErrorNoHalt("WARNING: The twins do not use this ConVar. Please use 'ttt_twins_min_players' instead.")
            goodtwin_min_players:SetInt(0)
        end
    end)

    local drunk_can_be_goodtwin = CreateConVar("ttt_drunk_can_be_goodtwin", "0")
    cvars.AddChangeCallback("ttt_drunk_can_be_goodtwin", function(cvar, old, new)
        if old ~= new then
            ErrorNoHalt("WARNING: The twins must spawn together so the Drunk cannot become an Good Twin when they sober up.")
            drunk_can_be_goodtwin:SetBool(false)
        end
    end)
end

if CLIENT then
    ---------------
    -- TARGET ID --
    ---------------

    hook.Add("TTTTargetIDPlayerRoleIcon", "GoodTwin_TTTTargetIDPlayerRoleIcon", function(ply, cli, role, noz, colorRole, hideBeggar, showJester, hideBodysnatcher)
        if cli:IsActiveGoodTwin() and ply:IsActiveEvilTwin() then
            return ROLE_EVILTWIN, false
        end
    end)

    hook.Add("TTTTargetIDPlayerRing", "GoodTwin_TTTTargetIDPlayerRing", function(ent, cli, ringVisible)
        if not IsPlayer(ent) then return end

        if cli:IsActiveGoodTwin() and ent:IsActiveEvilTwin() then
            return true, ROLE_COLORS_RADAR[ROLE_EVILTWIN]
        end
    end)

    hook.Add("TTTTargetIDPlayerText", "GoodTwin_TTTTargetIDPlayerText", function(ent, cli, text, col)
        if not IsPlayer(ent) then return end

        if cli:IsActiveGoodTwin() and ent:IsActiveEvilTwin() then
            return string.upper(ROLE_STRINGS[ROLE_EVILTWIN]), ROLE_COLORS_RADAR[ROLE_EVILTWIN]
        end
    end)

    ROLE.istargetidoverridden = function(ply, target, showJester)
        if not IsPlayer(target) then return end

        -- Override all three pieces
        if ply:IsActiveGoodTwin() and target:IsActiveEvilTwin() then
            ------ icon, ring, text
            return true, true, true
        end
    end

    ----------------
    -- SCOREBOARD --
    ----------------

    hook.Add("TTTScoreboardPlayerRole", "GoodTwin_TTTScoreboardPlayerRole", function(ply, cli, color, roleFileName)
        if cli:IsActiveGoodTwin() and ply:IsActiveEvilTwin() then
            return ROLE_COLORS_SCOREBOARD[ROLE_EVILTWIN], ROLE_STRINGS_SHORT[ROLE_EVILTWIN]
        end
    end)

    ROLE.isscoreboardinfooverridden = function(ply, target)
        ------ name,  role
        return false, ply:IsActiveGoodTwin() and target:IsActiveEvilTwin()
    end

    --------------
    -- TUTORIAL --
    --------------

    hook.Add("TTTTutorialRoleText", "GoodTwin_TTTTutorialRoleText", function(role, titleLabel)
        if role == ROLE_GOODTWIN then
            local roleColor = ROLE_COLORS[ROLE_INNOCENT]
            local traitorColor = ROLE_COLORS[ROLE_TRAITOR]

            local html = "The " .. ROLE_STRINGS[ROLE_GOODTWIN] .. " is a member of the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>innocent team</span> who has an evil counterpart on the <span style='color: rgb(" .. traitorColor.r .. ", " .. traitorColor.g .. ", " .. traitorColor.b .. ")'>traitor team</span>."

            html = html .. "<span style='display: block; margin-top: 10px;'>The twins rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>cannot damage each other</span> unless they are the last two non-jester players alive."

            local invulnerability_timer = GetConVar("ttt_twins_invulnerability_timer"):GetInt()
            if invulnerability_timer > 0 then
                html = html .. "<span style='display: block; margin-top: 10px;'>If one twin dies, the other is given " .. invulnerability_timer .. " second(s) of invulnerability."
            end

            return html
        end
    end)
end