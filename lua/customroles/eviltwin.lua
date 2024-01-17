local ROLE = {}

ROLE.nameraw = "eviltwin"
ROLE.name = "Evil Twin"
ROLE.nameplural = "Evil Twins"
ROLE.nameext = "an Evil Twin"
ROLE.nameshort = "etw"

ROLE.desc = [[You are {role}! {comrades}

You have a twin on the innocent team that knows who you are.
However, you and your twin are unable to damage each other.
If you are the last twin left alive you get temporary invulnerability.
Try to trick everyone into thinking you are the good twin!

Press {menukey} to receive your special equipment!]]

ROLE.team = ROLE_TEAM_TRAITOR

--------------------------
-- SPAWN LOGIC OVERRIDE --
--------------------------

ROLE.selectionpredicate = function()
    return false
end

hook.Add("TTTRoleSpawnsArtificially", "EvilTwin_TTTRoleSpawnsArtificially", function(role)
    if role == ROLE_EVILTWIN then
        if GetConVar("ttt_twins_enabled"):GetBool() then
            return true
        end
    end
end)

local eviltwin_enabled = CreateConVar("ttt_eviltwin_enabled", "0", FCVAR_REPLICATED)
cvars.AddChangeCallback("ttt_eviltwin_enabled", function(cvar, old, new)
    if old ~= new then
        ErrorNoHalt("WARNING: The twins do not use this ConVar. Please use 'ttt_twins_enabled' instead.")
        eviltwin_enabled:SetBool(false)
    end
end)

if SERVER then
    local eviltwin_spawn_weight = CreateConVar("ttt_eviltwin_spawn_weight", "1")
    cvars.AddChangeCallback("ttt_eviltwin_spawn_weight", function(cvar, old, new)
        if old ~= new then
            ErrorNoHalt("WARNING: The twins do not use this ConVar. Please use 'ttt_twins_chance' instead.")
            eviltwin_spawn_weight:SetInt(1)
        end
    end)

    local eviltwin_min_players = CreateConVar("ttt_eviltwin_min_players", "0")
    cvars.AddChangeCallback("ttt_eviltwin_min_players", function(cvar, old, new)
        if old ~= new then
            ErrorNoHalt("WARNING: The twins do not use this ConVar. Please use 'ttt_twins_min_players' instead.")
            eviltwin_min_players:SetInt(0)
        end
    end)

    local drunk_can_be_eviltwin = CreateConVar("ttt_drunk_can_be_eviltwin", "0")
    cvars.AddChangeCallback("ttt_drunk_can_be_eviltwin", function(cvar, old, new)
        if old ~= new then
            ErrorNoHalt("WARNING: The twins must spawn together so the Drunk cannot become an Evil Twin when they sober up.")
            drunk_can_be_eviltwin:SetBool(false)
        end
    end)
end

if CLIENT then
    ---------------
    -- TARGET ID --
    ---------------

    hook.Add("TTTTargetIDPlayerRoleIcon", "EvilTwin_TTTTargetIDPlayerRoleIcon", function(ply, cli, role, noz, colorRole, hideBeggar, showJester, hideBodysnatcher)
        if cli:IsActiveEvilTwin() and ply:IsActiveGoodTwin() then
            return ROLE_GOODTWIN, false
        end
    end)

    hook.Add("TTTTargetIDPlayerRing", "EvilTwin_TTTTargetIDPlayerRing", function(ent, cli, ringVisible)
        if not IsPlayer(ent) then return end

        if cli:IsActiveEvilTwin() and ent:IsActiveGoodTwin() then
            return true, ROLE_COLORS_RADAR[ROLE_GOODTWIN]
        end
    end)

    hook.Add("TTTTargetIDPlayerText", "EvilTwin_TTTTargetIDPlayerText", function(ent, cli, text, col)
        if not IsPlayer(ent) then return end

        if cli:IsActiveEvilTwin() and ent:IsActiveGoodTwin() then
            return string.upper(ROLE_STRINGS[ROLE_GOODTWIN]), ROLE_COLORS_RADAR[ROLE_GOODTWIN]
        end
    end)

    ROLE.istargetidoverridden = function(ply, target, showJester)
        if not IsPlayer(target) then return end

        -- Override all three pieces
        if ply:IsActiveEvilTwin() and target:IsActiveGoodTwin() then
            ------ icon, ring, text
            return true, true, true
        end
    end

    ----------------
    -- SCOREBOARD --
    ----------------

    hook.Add("TTTScoreboardPlayerRole", "EvilTwin_TTTScoreboardPlayerRole", function(ply, cli, color, roleFileName)
        if cli:IsActiveEvilTwin() and ply:IsActiveGoodTwin() then
            return ROLE_COLORS_SCOREBOARD[ROLE_GOODTWIN], ROLE_STRINGS_SHORT[ROLE_GOODTWIN]
        end
    end)

    ROLE.isscoreboardinfooverridden = function(ply, target)
        ------ name,  role
        return false, ply:IsActiveEvilTwin() and target:IsActiveGoodTwin()
    end

    --------------
    -- TUTORIAL --
    --------------

    hook.Add("TTTTutorialRoleText", "EvilTwin_TTTTutorialRoleText", function(role, titleLabel)
        if role == ROLE_EVILTWIN then
            local roleColor = ROLE_COLORS[ROLE_TRAITOR]
            local innocentColor = ROLE_COLORS[ROLE_INNOCENT]

            local html = "The " .. ROLE_STRINGS[ROLE_EVILTWIN] .. " is a member of the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor team</span> who has a good counterpart on the <span style='color: rgb(" .. innocentColor.r .. ", " .. innocentColor.g .. ", " .. innocentColor.b .. ")'>innocent team</span>."

            html = html .. "<span style='display: block; margin-top: 10px;'>The twins rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>cannot damage each other</span> unless they are the last two non-jester players alive."

            local invulnerability_timer = GetConVar("ttt_twins_invulnerability_timer"):GetInt()
            if invulnerability_timer > 0 then
                html = html .. "<span style='display: block; margin-top: 10px;'>If one twin dies, the other is given " .. invulnerability_timer .. " second(s) of invulnerability."
            end

            return html
        end
    end)
end