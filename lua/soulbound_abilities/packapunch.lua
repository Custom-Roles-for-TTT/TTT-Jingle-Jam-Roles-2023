local ABILITY = {}

ABILITY.Name = "Pack-a-Punch"
ABILITY.Id = "packapunch"
ABILITY.Description = "Give the player you are spectating a Pack-a-Punch"
ABILITY.Icon = "vgui/ttt/ttt_pack_a_punch.png"

local packapunch_uses = CreateConVar("ttt_soulbound_packapunch_uses", "1", FCVAR_REPLICATED, "How many uses should of the packapunch ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 50)
local packapunch_cooldown = CreateConVar("ttt_soulbound_packapunch_cooldown", "5", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the packapunch ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_packapunch_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_packapunch_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundPackAPunchUses", packapunch_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundPackAPunchNextUse", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if packapunch_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundPackAPunchUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundPackAPunchNextUse") then return false end
        if not target then return false end
        if not TTTPAP:CanOrderPAP(target, false) then return false end
        return true
    end

    function ABILITY:Use(soulbound, target)
        TTTPAP:OrderPAP(target)

        local uses = soulbound:GetNWInt("TTTSoulboundPackAPunchUses", 0)
        uses = math.max(uses - 1, 0)
        soulbound:SetNWInt("TTTSoulboundPackAPunchUses", uses)
        soulbound:SetNWFloat("TTTSoulboundPackAPunchNextUse", CurTime() + packapunch_cooldown:GetFloat())
    end

    local enabled = GetConVar("ttt_soulbound_packapunch_enabled")
    hook.Add("TTTPrepareRound", "Soulbound_PackAPunch_TTTPrepareRound", function()
        for _, p in ipairs(player.GetAll()) do
            p:SetNWInt("TTTSoulboundPackAPunchUses", 0)
            p:SetNWFloat("TTTSoulboundPackAPunchNextUse", 0)
        end
        if enabled:GetBool() and not TTTPAP then
            ErrorNoHalt("WARNING: Pack-a-Punch must be installed to enable the Soulbound's Pack-a-Punch ability!")
            enabled:SetBool(false)
        end
    end)
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local max_uses = packapunch_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundPackAPunchUses", 0)
        local margin = 6
        local ammo_height = 28
        if max_uses == 0 then
            CRHUD:PaintBar(8, x + margin, y + margin, width - (margin * 2), ammo_height, ammo_colors, 1)
            CRHUD:ShadowedText("Unlimited Uses", "HealthAmmo", x + (margin * 2), y + margin + (ammo_height / 2), COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            CRHUD:PaintBar(8, x + margin, y + margin, width - (margin * 2), ammo_height, ammo_colors, uses / max_uses)
            CRHUD:ShadowedText(tostring(uses) .. "/" .. tostring(max_uses), "HealthAmmo", x + (margin * 2), y + margin + (ammo_height / 2), COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local ready = true
        local text
        local next_use = soulbound:GetNWFloat("TTTSoulboundPackAPunchNextUse")
        local cur_time = CurTime()
        if max_uses > 0 and uses <= 0 then
            ready = false
            text = "Out of uses"
        elseif cur_time < next_use then
            ready = false
            local s = next_use - cur_time
            local ms = (s - math.floor(s)) * 100
            s = math.floor(s)
            text = "On cooldown for " .. string.format("%02i.%02i", s, ms) .. " seconds"
        else
            local target = soulbound:GetObserverMode() ~= OBS_MODE_ROAMING and soulbound:GetObserverTarget() or nil
            if not target or not IsPlayer(target) then
                ready = false
                text = "Spectate a player"
            elseif not TTTPAP:CanOrderPAP(target, false) then
                ready = false
                text = target:Nick() .. "'s held item can't be upgraded"
            else
                text = "Press '" .. key .. "' to give " .. target:Nick() .. " a Pack-a-Punch"
            end
        end

        draw.SimpleText(text, "TabLarge", x + margin, y + height - margin, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        return ready
    end
end

SOULBOUND:RegisterAbility(ABILITY)