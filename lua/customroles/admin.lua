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
    cvar = "ttt_admin_send_cost",
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

ADMIN_MESSAGE_TEXT = 0
ADMIN_MESSAGE_PLAYER = 1
ADMIN_MESSAGE_VARIABLE = 2

if SERVER then
    util.AddNetworkString("TTT_AdminBlind")
    util.AddNetworkString("TTT_AdminMessage")
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

    -- Colors copied from ULX and ULib
    local colorText = Color(151, 211, 255)
    local colorPlayer = Color(0, 201, 0)
    local colorSelf = Color(75, 0, 130)
    local colorVariable = Color(0, 255, 0)

    net.Receive("TTT_AdminMessage", function()
        local sid64 = LocalPlayer():SteamID64()

        local count = net.ReadUInt(4)
        local isAdmin = false
        local message = {}
        for i = 1, count do
            local type = net.ReadUInt(2)
            local value = net.ReadString()
            if i == 1 then
                if value == sid64 then
                    table.insert(message, colorSelf)
                    table.insert(message, "You")
                    isAdmin = true
                else
                    local ply = player.GetBySteamID64(value)
                    if not IsPlayer(ply) then return end
                    table.insert(message, colorPlayer)
                    table.insert(message, ply:Nick())
                end
            elseif type == ADMIN_MESSAGE_TEXT then
                table.insert(message, colorText)
                table.insert(message, value)
            elseif type == ADMIN_MESSAGE_PLAYER then
                if value == sid64 then
                    table.insert(message, colorSelf)
                    if isAdmin then
                        table.insert(message, "Yourself")
                    else
                        table.insert(message, "You")
                    end
                else
                    local ply = player.GetBySteamID64(value)
                    if not IsPlayer(ply) then return end
                    table.insert(message, colorPlayer)
                    table.insert(message, ply:Nick())
                end
            elseif type == ADMIN_MESSAGE_VARIABLE then
                table.insert(message, colorVariable)
                table.insert(message, value)
            end
        end
        if #message > 0 then
            chat.AddText(unpack(message))
        end
    end)
end