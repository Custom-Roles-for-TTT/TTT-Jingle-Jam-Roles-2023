--// Logan Christianson
local IceOverlay, DarkOverlay = {
	["$pp_colour_brightness"] = 0,
	["$pp_colour_colour"] = 1
}

-- I ripped this from my other addon lol
function CreateIceOverlay()
    if IsValid(IceOverlay) and ispanel(IceOverlay) then return end

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
        overlayPanel.alphaCounter = overlayPanel.alphaCounter or 0
        if overlayPanel.alphaCounter <= 200 then overlayPanel.alphaCounter = overlayPanel.alphaCounter + 0.5 end
        surface.SetDrawColor(255, 255, 255, overlayPanel.alphaCounter)
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

    CreateIceOverlay()
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