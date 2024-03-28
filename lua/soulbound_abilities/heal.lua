local ABILITY = {}

ABILITY.Name = "Healing Presence"
ABILITY.Id = "heal"
ABILITY.Description = "Slowly heal the player you are spectating"
ABILITY.Icon = "vgui/ttt/icon_heal.png"

local heal_rate = CreateConVar("ttt_soulbound_heal_rate", "0.5", FCVAR_REPLICATED, "How often the Soulbound's healing presence ability should heal their target", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_heal_rate",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWFloat("TTTSoulboundHealNext", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if not target or not IsPlayer(target) then return false end
        return true
    end

    function ABILITY:Passive(soulbound, target)
        local curTime = CurTime()
        if soulbound:GetNWFloat("TTTSoulboundHealNext", 0) < curTime then
            local health = math.min(target:GetMaxHealth(), target:Health() + 1)
            target:SetHealth(health)
            soulbound:SetNWFloat("TTTSoulboundHealNext", CurTime() + heal_rate:GetFloat())
        end
    end

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWFloat("TTTSoulboundHealNext", 0)
    end
end

if CLIENT then
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
        else
            text = "Healing " .. target:Nick() .. " (" .. tostring(target:Health()) .. "/" .. tostring(target:GetMaxHealth()) .. ")"
        end

        draw.SimpleText(text, "TabLarge", x + margin, y + height - margin, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        return ready
    end
end

SOULBOUND:RegisterAbility(ABILITY)