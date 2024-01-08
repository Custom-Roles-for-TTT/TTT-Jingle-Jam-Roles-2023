--// Logan Christianson
local IceOverlay, DarkOverlay = {
	["$pp_colour_brightness"] = 0,
	["$pp_colour_colour"] = 1
}

-- I ripped this from my other addon lol
function CreateIceOverlay(maxOverlay)
    if IsValid(IceOverlay) and ispanel(IceOverlay) then return end

    local alphaCounter = 0
    if maxOverlay then alphaCounter = 230 end

    timer.Simple(2, function() LocalPlayer():SetDSP(14, false) end) --We're assuming the player is emitting the ice-over sound

    IceOverlay = vgui.Create("DFrame")
    IceOverlay:SetSize(ScrW(), ScrH())
    IceOverlay:SetPos(0, 0)
    IceOverlay:SetTitle("")
    IceOverlay:SetVisible(true)
    IceOverlay:SetDraggable(false)
    IceOverlay:ShowCloseButton(false)
    IceOverlay.Paint = function()
    end

    local IceOverlayMat = Material("ui/roles/elm/frosted.png") --Smooth 1
    local overlayPanel = vgui.Create("DPanel", IceOverlay)
    overlayPanel:SetSize(IceOverlay:GetWide(), IceOverlay:GetTall())
    overlayPanel:SetPos(0, 0)
    overlayPanel.Paint = function()
        if alphaCounter <= 125 then alphaCounter = alphaCounter + 0.5 end
        surface.SetDrawColor(255, 255, 255, alphaCounter)
        surface.SetMaterial(IceOverlayMat)
        surface.DrawTexturedRect(0, 0, overlayPanel:GetWide(), overlayPanel:GetTall())
    end
end

function CloseIceOverlay()
    if IceOverlay and ispanel(IceOverlay) then IceOverlay:Remove() end
end

function StartBlindOverlay()
    DarkOverlay = {
        ["$pp_colour_brightness"] = -1,
        ["$pp_colour_colour"] = 0
    }
end

function StartDarkOverlay(percent)
    local actualPercent = percent * 0.01

    DarkOverlay = {
        ["$pp_colour_brightness"] = -0.25 * actualPercent,
        ["$pp_colour_colour"] = 1 - (1 * actualPercent)
    }
end

function EndDarkOverlay()
    DarkOverlay = {
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_colour"] = 1
    }
end

hook.Add("RenderScreenspaceEffects", "ElementalistScreenDimming", function()
    DrawColorModify(DarkOverlay)
end)

net.Receive("BeginIceScreen", function(len)
    local frozen = net.ReadBool()

    CreateIceOverlay(frozen)
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

hook.Add("TTTTutorialRoleText", "SummonerTutorialRoleText", function(playerRole)
    local function getStyleString(role)
        local roleColor = ROLE_COLORS[role]
        return "<span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>"
    end

    if playerRole == ROLE_ELEMENTALIST then
        local divStart = "<div style='margin-top: 10px;'>"
        local styleEnd = "</span>"

        local html = "The " .. ROLE_STRINGS[ROLE_ELEMENTALIST] .. " is a member of the " .. getStyleString(ROLE_TRAITOR) .. ROLE_STRINGS_EXT[ROLE_TRAITOR] .. " team" .. styleEnd .. " whose goal is to eliminate all innocents and independents."

        html = html .. divStart .. "They have access to special powerups in the " .. getStyleString(ROLE_ELEMENTALIST) .. "traitor shop" .. styleEnd .. " which do a variety of things when they shoot other terrorists.</div>"

        html = html .. divStart .. "The powerups available are:<ul>"

        local ROLE = ROLE_DATA_EXTERNAL[ROLE_ELEMENTALIST]
        local allowUpgradedEffects = ROLE.ConvarTierUpgrades:GetBool()

        if ROLE.ConvarPyroUpgrades:GetBool() then
            html = html .. "<li>Pyromancer"
            if allowUpgradedEffects then
                html = html .. " and Pyromancer+"
            end
            html = html .. ".</li>"
        end

        if ROLE.ConvarFrostUpgrades:GetBool() then
            html = html .. "<li>Frostbite"
            if allowUpgradedEffects then
                html = html .. " and Frostbite+"
            end
            html = html .. ".</li>"
        end

        if ROLE.ConvarWindUpgrades:GetBool() then
            html = html .. "<li>Windburn"
            if allowUpgradedEffects then
                html = html .. " and Windburn+"
            end
            html = html .. ".</li>"
        end

        if ROLE.ConvarDischargeUpgrades:GetBool() then
            html = html .. "<li>Discharge"
            if allowUpgradedEffects then
                html = html .. " and Discharge+"
            end
            html = html .. ".</li>"
        end

        if ROLE.ConvarMidnightUpgrades:GetBool() then
            html = html .. "<li>Midnight"
            if allowUpgradedEffects then
                html = html .. " and Midnight+"
            end
            html = html .. ".</li>"
        end

        if ROLE.ConvarLifeUpgrades:GetBool() then
            html = html .. "<li>Lifesteal"
            if allowUpgradedEffects then
                html = html .. " and Lifesteal+"
            end
            html = html .. ".</li>"
        end

        html = html .. "</ul>" .. styleEnd
        
        if allowUpgradedEffects then
            html = html .. divStart .. "The '+' version of the upgrades cannot be purchased until the regular version has been acquired."
        end

        return html
    end
end)