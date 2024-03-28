local ABILITY = {}

ABILITY.Name = "Revealing Presence"
ABILITY.Id = "reveal"
ABILITY.Description = "Reveal the location of the player you are spectating to your fellow traitors"
ABILITY.Icon = "vgui/ttt/icon_reveal.png"

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWBool("TTTSoulboundRevealBought", true)
    end

    function ABILITY:Condition(soulbound, target)
        return false
    end

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWBool("TTTSoulboundRevealBought", false)
    end
end

if CLIENT then
    local client = nil
    local vision_enabled = false
    local highlighted_players = {}

    local function EnableSoulboundHighlights()
        hook.Add("PreDrawHalos", "Soulbound_Reveal_PreDrawHalos", function()
            halo.Add(highlighted_players, ROLE_COLORS[ROLE_INNOCENT], 1, 1, 1, true, true)
        end)
    end

    hook.Add("TTTUpdateRoleState", "Soulbound_Reveal_TTTUpdateRoleState", function()
        client = LocalPlayer()

        -- Disable highlights on role change
        if vision_enabled then
            hook.Remove("PreDrawHalos", "Soulbound_Reveal_PreDrawHalos")
            vision_enabled = false
        end
    end)

    hook.Add("Think", "Soulbound_Reveal_Think", function()
        highlighted_players = {}
        if not IsPlayer(client) or not client:Alive() or client:IsSpec() then return end
        if not client:IsTraitorTeam() then return end
        for _, v in ipairs(player.GetAll()) do
            if not v:IsSoulbound() then continue end
            if not v:GetNWBool("TTTSoulboundRevealBought", false) then continue end

            local target = v:GetObserverMode() ~= OBS_MODE_ROAMING and v:GetObserverTarget() or nil
            if not target or not IsPlayer(target) then continue end
            if not target:Alive() or client:IsSpec() then continue end
                if target:IsTraitorTeam() then continue end

            if not table.HasValue(highlighted_players, target) then
                table.insert(highlighted_players, target)
            end
        end

        if #highlighted_players > 0 then
            if not vision_enabled then
                EnableSoulboundHighlights()
                vision_enabled = true
            end
        else
            hook.Remove("PreDrawHalos", "Soulbound_Reveal_PreDrawHalos")
            vision_enabled = false
        end
    end)

    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local margin = 6
        local ammo_height = 28
        CRHUD:PaintBar(8, x + margin, y + margin, width - (margin * 2), ammo_height, ammo_colors, 1)
        CRHUD:ShadowedText("Passive Item", "HealthAmmo", x + (margin * 2), y + margin + (ammo_height / 2), COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local ready = true
        local text
        local target = soulbound:GetObserverMode() ~= OBS_MODE_ROAMING and soulbound:GetObserverTarget() or nil
        if not target or not IsPlayer(target) then
            ready = false
            text = "Spectate a player"
        elseif target:IsTraitorTeam() then
            ready = false
            text = "Spectate a non-traitor player"
        else
            text = "Revealing the location of " .. target:Nick()
        end

        draw.SimpleText(text, "TabLarge", x + margin, y + height - margin, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        return ready
    end
end

SOULBOUND:RegisterAbility(ABILITY)