local ROLE = {}

ROLE.nameraw = "soulmage"
ROLE.name = "Soulmage"
ROLE.nameplural = "Soulmages"
ROLE.nameext = "a Soulmage"
ROLE.nameshort = "smg"

ROLE.desc = [[You are an {role}! {comrades}

Use your soulbinding device to get a dead player to
help you and your fellow {traitors} while pretending
to be an innocent ghost.

Press {menukey} to receive your special equipment!]]
ROLE.shortdesc = "Can use their Soulbinding Device to convert a dead player to be their Soulbound, granting them abilities to help their new teammates."

ROLE.team = ROLE_TEAM_TRAITOR

ROLE.startingcredits = 0

ROLE.convars = {}
table.insert(ROLE.convars, {
    cvar = "ttt_soulmage_soulbinding_time",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})

ROLE.translations = {
    ["english"] = {
        ["soulbindingdevice_help_pri"] = "Hold {primaryfire} on a dead body to convert them into a " .. ROLE_STRINGS[ROLE_SOULBOUND] .. ".",
    }
}

RegisterRole(ROLE)

if CLIENT then
    --------------
    -- TUTORIAL --
    --------------

    hook.Add("TTTTutorialRoleText", "Soulmage_TTTTutorialRoleText", function(role, titleLabel)
        if role == ROLE_SOULMAGE then
            local roleColor = ROLE_COLORS[ROLE_TRAITOR]

            local html = "The " .. ROLE_STRINGS[ROLE_SOULMAGE] .. " is a member of the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>traitor team</span> who can use their soulbinding device to convert a dead player into " .. ROLE_STRINGS_EXT[ROLE_SOULBOUND] .. "."

            return html
        end
    end)
end