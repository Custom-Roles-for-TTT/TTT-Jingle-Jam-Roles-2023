-- Logan Christianson
local shouldDrawdarkOverlay = false
local iceOverlay = nil
local darkOverlay = {
    ["$pp_colour_brightness"] = 1,
    ["$pp_colour_colour"] = 1
}

local function CreateIceOverlay(maxOverlay)
    if IsValid(iceOverlay) and ispanel(iceOverlay) then return end

    local alphaCounter = 0
    if maxOverlay then alphaCounter = 230 end

    -- We're assuming the player is emitting the ice-over sound
    timer.Simple(2, function() LocalPlayer():SetDSP(14, true) end)

    iceOverlay = vgui.Create("DFrame")
    iceOverlay:SetSize(ScrW(), ScrH())
    iceOverlay:SetPos(0, 0)
    iceOverlay:SetTitle("")
    iceOverlay:SetVisible(true)
    iceOverlay:SetDraggable(false)
    iceOverlay:ShowCloseButton(false)
    iceOverlay.Paint = function()
    end

    local iceOverlayMat = Material("ui/roles/elm/frosted.png") --Smooth 1
    local overlayPanel = vgui.Create("DPanel", iceOverlay)
    overlayPanel:SetSize(iceOverlay:GetWide(), iceOverlay:GetTall())
    overlayPanel:SetPos(0, 0)
    overlayPanel.Paint = function()
        if alphaCounter <= 125 then alphaCounter = alphaCounter + 0.5 end
        surface.SetDrawColor(255, 255, 255, alphaCounter)
        surface.SetMaterial(iceOverlayMat)
        surface.DrawTexturedRect(0, 0, overlayPanel:GetWide(), overlayPanel:GetTall())
    end
end

local function CloseIceOverlay()
    if iceOverlay and ispanel(iceOverlay) then
        iceOverlay:Remove()
        LocalPlayer():SetDSP(0, false)
    end
end

local function StartBlindOverlay()
    darkOverlay = {
        ["$pp_colour_brightness"] = -1,
        ["$pp_colour_colour"] = 0
    }
end

local function StartDarkOverlay(percent)
    shouldDrawdarkOverlay = true

    local actualPercent = percent * 0.01
    darkOverlay = {
        ["$pp_colour_brightness"] = -0.25 * actualPercent,
        ["$pp_colour_colour"] = 1 - actualPercent
    }
end

local function EndDarkOverlay()
    shouldDrawdarkOverlay = false

    darkOverlay = {
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_colour"] = 1
    }
end

-- Screen dimming
hook.Add("RenderScreenspaceEffects", "Elementalist_RenderScreenspaceEffects", function()
    if shouldDrawdarkOverlay then
        DrawColorModify(darkOverlay)
    end
end)

net.Receive("BeginIceScreen", function(len)
    CreateIceOverlay(net.ReadBool())
end)

net.Receive("EndIceScreen", function(len)
    CloseIceOverlay()
end)

net.Receive("BeginDimScreen", function(len)
    local amount = net.ReadUInt(6)
    if amount == 100 then
        StartBlindOverlay()
    else
        StartDarkOverlay(amount)
    end
end)

net.Receive("EndDimScreen", function(len)
    EndDarkOverlay()
end)

hook.Add("TTTTutorialRoleText", "Elementalist_TTTTutorialRoleText", function(playerRole)
    local function GetStyleString(role)
        local roleColor = ROLE_COLORS[role]
        return "<span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>"
    end

    if playerRole == ROLE_ELEMENTALIST then
        local divStart = "<div style='margin-top: 10px;'>"
        local styleEnd = "</span>"

        local html = "The " .. ROLE_STRINGS[ROLE_ELEMENTALIST] .. " is a member of the " .. GetStyleString(ROLE_TRAITOR) .. "traitor team" .. styleEnd .. " whose goal is to eliminate all innocents and independents."

        html = html .. divStart .. "They have access to " .. GetStyleString(ROLE_ELEMENTALIST) .. "special powerups" .. styleEnd .. " in the " .. GetStyleString(ROLE_TRAITOR) .. "traitor shop" .. styleEnd .. " which do a variety of things when they shoot other terrorists.</div>"

        html = html .. divStart .. "The powerups available are:<ul style='margin-bottom: 0px; padding-bottom: 0px;'>"

        local ROLE = ROLE_DATA_EXTERNAL[ROLE_ELEMENTALIST]
        local allowUpgradedEffects = ROLE.ConvarTierUpgrades:GetBool()

        if ROLE.ConvarPyroUpgrades:GetBool() then
            html = html .. "<li>Pyromancer"
            if allowUpgradedEffects then
                html = html .. " and Pyromancer+"
            end
            html = html .. "</li>"
        end

        if ROLE.ConvarFrostUpgrades:GetBool() then
            html = html .. "<li>Frostbite"
            if allowUpgradedEffects then
                html = html .. " and Frostbite+"
            end
            html = html .. "</li>"
        end

        if ROLE.ConvarWindUpgrades:GetBool() then
            html = html .. "<li>Windburn"
            if allowUpgradedEffects then
                html = html .. " and Windburn+"
            end
            html = html .. "</li>"
        end

        if ROLE.ConvarDischargeUpgrades:GetBool() then
            html = html .. "<li>Discharge"
            if allowUpgradedEffects then
                html = html .. " and Discharge+"
            end
            html = html .. "</li>"
        end

        if ROLE.ConvarMidnightUpgrades:GetBool() then
            html = html .. "<li>Midnight"
            if allowUpgradedEffects then
                html = html .. " and Midnight+"
            end
            html = html .. "</li>"
        end

        if ROLE.ConvarLifeUpgrades:GetBool() then
            html = html .. "<li>Lifesteal"
            if allowUpgradedEffects then
                html = html .. " and Lifesteal+"
            end
            html = html .. "</li>"
        end

        html = html .. "</ul>" .. styleEnd

        if allowUpgradedEffects then
            html = html .. divStart .. "The '+' version of the upgrades cannot be purchased until the regular version has been acquired."
        end

        return html
    end
end)