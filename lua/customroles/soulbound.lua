local ROLE = {}

ROLE.nameraw = "soulbound"
ROLE.name = "Soulbound"
ROLE.nameplural = "Soulbounds"
ROLE.nameext = "a Soulbound"
ROLE.nameshort = "sbd"

ROLE.desc = [[You are an {role}! {comrades}

Seeing this message should be impossible! Please let
us know how you are seeing this so we can fix it.

Press {menukey} to receive your special equipment!]]

ROLE.team = ROLE_TEAM_TRAITOR

ROLE.convars = {}

ROLE.translations = {}

RegisterRole(ROLE)

hook.Add("TTTRoleSpawnsArtificially", "Soulbound_TTTRoleSpawnsArtificially", function(role)
    if role == ROLE_SOULBOUND and util.CanRoleSpawn(ROLE_SOULMAGE) then
        return true
    end
end)

if SERVER then
    hook.Add("TTTPlayerAliveThink", "Soulbound_TTTPlayerAliveThink", function(ply)
        if not IsPlayer(ply) then return end
        if ply:IsActiveSoulbound() then
            ply:SetRole(ROLE_TRAITOR)
            SendFullStateUpdate()
        end
    end)
end

if CLIENT then
    --------------
    -- TUTORIAL --
    --------------

    hook.Add("TTTTutorialRoleText", "Soulbound_TTTTutorialRoleText", function(role, titleLabel)
        if role == ROLE_SOULBOUND then
            local roleColor = ROLE_COLORS[ROLE_TRAITOR]

            local html = "The " .. ROLE_STRINGS[ROLE_SOULBOUND] .. " is a member of the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor team</span> who can use special powers while dead to help the traitor team."

            html = html .. "<span style='display: block; margin-top: 10px;'>The " .. ROLE_STRINGS[ROLE_SOULBOUND] .. " can only ever exist as a dead player. If a living player somehow becomes " .. ROLE_STRINGS_EXT[ROLE_SOULBOUND] .. ", they will instantly be changed into <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>" .. ROLE_STRINGS_EXT[ROLE_TRAITOR] .. ".</span>"

            return html
        end
    end)
end