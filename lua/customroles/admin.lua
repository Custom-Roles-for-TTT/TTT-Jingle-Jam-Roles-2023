local draw = draw
local hook = hook
local player = player
local table = table
local timer = timer
local util = util

local PlayerIterator = player.Iterator

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
ROLE.shortdesc = "Has a menu of admin commands that they can use against other players to help or to hurt."

ROLE.team = ROLE_TEAM_DETECTIVE

local admin_power_rate = CreateConVar("ttt_admin_power_rate", 1.5, FCVAR_NONE, "How often (in seconds) the Admin gains power", 0.1, 10)
local admin_starting_power = CreateConVar("ttt_admin_starting_power", 20, FCVAR_NONE, "How much power the Admin should spawn with", 0, 100)

ROLE.convars = {}
table.insert(ROLE.convars, {
    cvar = "ttt_admin_power_rate",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})
table.insert(ROLE.convars, {
    cvar = "ttt_admin_starting_power",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
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
        ["admin_power_title"] = "ADMIN POWER"
    }
}

ROLE.onroleassigned = function(ply)
    ply:SetNWInt("TTTAdminPower", admin_starting_power:GetInt())
end

RegisterRole(ROLE)

ADMIN_MESSAGE_TEXT = 0
ADMIN_MESSAGE_PLAYER = 1
ADMIN_MESSAGE_VARIABLE = 2

if SERVER then
    AddCSLuaFile()

    util.AddNetworkString("TTT_AdminBlindClient")
    util.AddNetworkString("TTT_AdminKickClient")
    util.AddNetworkString("TTT_AdminMessage")

    hook.Add("TTTPrepareRound", "Admin_TTTPrepareRound", function()
        for _, p in PlayerIterator() do
            p:SetNWInt("TTTAdminPower", 0)
        end
    end)

    hook.Add("TTTBeginRound", "Admin_TTTBeginRound", function()
        local time = admin_power_rate:GetFloat()
        if time <= 0 then return end
        timer.Create("AdminPowerTimer", time, 0, function()
            for _, p in PlayerIterator() do
                if p:IsActiveAdmin() then
                    local power = p:GetNWInt("TTTAdminPower")
                    if power < 100 then
                        power = power + 1
                        p:SetNWInt("TTTAdminPower", power)
                    end
                end
            end
        end)
    end)

    hook.Add("TTTEndRound", "Admin_TTTEndRound", function()
        for _, p in PlayerIterator() do
            p:SetNWInt("TTTAdminPower", 0)
        end
        timer.Remove("AdminPowerTimer")
    end)
end

if CLIENT then
    ---------
    -- HUD --
    ---------

    hook.Add("HUDDrawScoreBoard", "Admin_HUDDrawScoreBoard", function() -- Use HUDDrawScoreBoard instead of HUDPaint so it draws above the TTT HUD
        local client = LocalPlayer()
        local wep = client:GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "weapon_ttt_adm_menu" then return end

        local power_colors = {
            border = COLOR_WHITE,
            background = Color(17, 115, 135, 222),
            fill = Color(82, 226, 255, 255)
        }
        local current_power = client:GetNWInt("TTTAdminPower")

        local power_percentage = current_power / 100

        CRHUD:PaintBar(8, 20, ScrH() - 59, 230, 25, power_colors, power_percentage)
        draw.SimpleText(LANG.GetTranslation("admin_power_title"), "HealthAmmo", 30, ScrH() - 59, Color(0, 0, 10, 200), TEXT_ALIGN_LEFT)
        CRHUD:ShadowedText(tostring(current_power), "HealthAmmo", 230, ScrH() - 59, COLOR_WHITE, TEXT_ALIGN_RIGHT)
    end)

    --------------
    -- TUTORIAL --
    --------------

    hook.Add("TTTTutorialRoleText", "Admin_TTTTutorialRoleText", function(role, titleLabel)
        if role == ROLE_ADMIN then
            local roleColor = ROLE_COLORS[ROLE_ADMIN]
            local detectiveColor = ROLE_COLORS[ROLE_DETECTIVE]

            local html = "The " .. ROLE_STRINGS[ROLE_ADMIN] .. " is a " .. ROLE_STRINGS[ROLE_DETECTIVE] .. " and a member of the <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>innocent team</span> whose job is to find and eliminate their enemies."

            html = html .. "<span style='display: block; margin-top: 10px;'>Instead of getting a DNA Scanner like a vanilla <span style='color: rgb(" .. detectiveColor.r .. ", " .. detectiveColor.g .. ", " .. detectiveColor.b .. ")'>" .. ROLE_STRINGS[ROLE_DETECTIVE] .. "</span>, they have the ability to open an admin menu and use powerful commands. Commands require admin power which generates over time.</span>"

            return html
        end
    end)

    -------------------
    -- BLIND OVERLAY --
    -------------------

    net.Receive("TTT_AdminBlindClient", function()
        if net.ReadBool() then
            hook.Add("HUDPaint", "Admin_HUDPaint_Blind", function()
                draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255))
            end)
        else
            hook.Remove("HUDPaint", "Admin_HUDPaint_Blind")
        end
    end)

    ----------------------
    -- FAKE KICK SCREEN --
    ----------------------

    local kickScreenMat = Material("ui/roles/adm/kickScreen.png")

    surface.CreateFont("KickText", {
        font = "Tahoma",
        size = 18,
        weight = 400,
        antialias = false
    })

    net.Receive("TTT_AdminKickClient", function()
        local client = LocalPlayer()

        hook.Add("HUDShouldDraw", "Admin_HUDShouldDraw_Kick", function(name)
            if name ~= "CHudGMod" then return false end
        end)

        hook.Add("PlayerBindPress", "Admin_PlayerBindPress_Kick", function(ply, bind, pressed)
            if (string.find(bind, "+showscores")) then return true end
        end)

        hook.Add("Think", "Admin_Think_Kick", function()
            client:ConCommand("soundfade 100 1")
        end)


        local dframe = vgui.Create("DFrame")
        dframe:SetSize(ScrW(), ScrH())
        dframe:SetPos(0, 0)
        dframe:SetTitle("")
        dframe:SetVisible(true)
        dframe:SetDraggable(false)
        dframe:ShowCloseButton(false)
        dframe:SetMouseInputEnabled(true)
        dframe:SetDeleteOnClose(true)
        dframe.Paint = function() end

        local overlayPanel = vgui.Create("DPanel", dframe)
        overlayPanel:SetSize(dframe:GetWide(), dframe:GetTall())
        overlayPanel:SetPos(0, 0)
        overlayPanel.Paint = function(_, w, h)
            surface.SetDrawColor(COLOR_WHITE)
            surface.SetMaterial(kickScreenMat)
            surface.DrawTexturedRect(0, 0, w, h)
        end

        local dpanel = vgui.Create("DPanel", dframe)
        dpanel:SetSize(380, 132)
        dpanel:Center()
        dpanel.Paint = function(_, w, h)
            surface.SetDrawColor(115, 115, 115, 245)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        local dlabel = vgui.Create("DLabel", dpanel)
        dlabel:SetWrap(true)
        dlabel:SetAutoStretchVertical(true)
        dlabel:SetSize(340, 48)
        dlabel:SetPos(20, 20)
        dlabel:SetFont("KickText")
        local message = "Disconnect: Kicked by " .. net.ReadString()
        message = message .. " - " .. net.ReadString()
        dlabel:SetText(message)

        local dbutton = vgui.Create("DButton", dpanel)
        dbutton:SetSize(72, 24)
        dbutton:SetPos(288, 88)
        dbutton:SetFont("KickText")
        dbutton:SetText("Close")
        dbutton.Paint = function(_, w, h)
            surface.SetDrawColor(228, 228, 228, 255)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
        dbutton.DoClick = function()
            hook.Remove("HUDShouldDraw", "Admin_HUDShouldDraw_Kick")
            hook.Remove("PlayerBindPress", "Admin_PlayerBindPress_Kick")
            hook.Remove("Think", "Admin_Think_Kick")
            dframe:Close()
        end

        dframe:MakePopup()
    end)

    ---------------------------
    -- FAKE CONSOLE MESSAGES --
    ---------------------------

    -- Colors copied from ULX and ULib
    local colorText = Color(151, 211, 255)
    local colorPlayer = Color(0, 201, 0)
    local colorSelf = Color(75, 0, 130)
    local colorVariable = Color(0, 255, 0)

    net.Receive("TTT_AdminMessage", function()
        local sid64 = LocalPlayer():SteamID64()

        local count = net.ReadUInt(4)
        local admin
        local message = {}
        for i = 1, count do
            local type = net.ReadUInt(2)
            local value = net.ReadString()
            if i == 1 then
                admin = value
                if value == sid64 then
                    table.insert(message, colorSelf)
                    table.insert(message, "You")
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
                    if value == admin then
                        table.insert(message, "Yourself")
                    else
                        table.insert(message, "You")
                    end
                elseif value == admin then
                    table.insert(message, colorPlayer)
                    table.insert(message, "Themselves")
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