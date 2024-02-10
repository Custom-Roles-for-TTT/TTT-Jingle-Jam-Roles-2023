local net = net
local util = util
local table = table
local hook = hook
local draw = draw

local ROLE = {}

ROLE.nameraw = "admin"
ROLE.name = "Admin"
ROLE.nameplural = "Admins"
ROLE.nameext = "an Admin"
ROLE.nameshort = "adm"

ROLE.desc = [[You are {role}! As {adetective}, HQ has given you special resources to find the {traitors}.
You can use your admin menu to access commands
that will help in the battle against the {traitors}.

Press {menukey} to receive your equipment!]]

ROLE.team = ROLE_TEAM_DETECTIVE

ROLE.convars = {}
table.insert(ROLE.convars, {
    cvar = "ttt_admin_slap_cost",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE.convars, {
    cvar = "ttt_admin_bring_cost",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE.convars, {
    cvar = "ttt_admin_goto_cost",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE.convars, {
    cvar = "ttt_admin_jail_cost",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE.convars, {
    cvar = "ttt_admin_ignite_cost",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE.convars, {
    cvar = "ttt_admin_blind_cost",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE.convars, {
    cvar = "ttt_admin_freeze_cost",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE.convars, {
    cvar = "ttt_admin_ragdoll_cost",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE.convars, {
    cvar = "ttt_admin_strip_cost",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE.convars, {
    cvar = "ttt_admin_respawn_cost",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE.convars, {
    cvar = "ttt_admin_slay_cost",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE.convars, {
    cvar = "ttt_admin_kick_cost",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})

ROLE.translations = {
    ["english"] = {
        ["adminmenu_help_pri"] = "Use {primaryfire} to open the admin menu",
    }
}

RegisterRole(ROLE)

if SERVER then
    util.AddNetworkString("TTT_AdminBlind")
end

if CLIENT then
    net.Receive("TTT_AdminBlind", function()
        if net.ReadBool() then
            hook.Add("HUDPaint", "Admin_HUDPaint_Blind", function()
                draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255))
            end)
        else
            hook.Remove("HUDPaint", "Admin_HUDPaint_Blind")
        end
    end)
end