local ABILITY = {}

ABILITY.Name = "Drop Weapon"
ABILITY.Id = "dropweapon"
ABILITY.Description = "Force the player you are spectating to drop their weapon"
ABILITY.Icon = "vgui/ttt/icon_dropweapon.png"

local dropweapon_uses = CreateConVar("ttt_soulbound_dropweapon_uses", "3", FCVAR_REPLICATED, "How many uses should of the drop weapon ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 50)
local dropweapon_cooldown = CreateConVar("ttt_soulbound_dropweapon_cooldown", "10", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the drop weapon ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_dropweapon_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_dropweapon_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundDropWeaponUses", dropweapon_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundDropWeaponNextUse", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if dropweapon_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundDropWeaponUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundDropWeaponNextUse") then return false end
        if not target or not IsPlayer(target) then return false end
        return true
    end

    function ABILITY:Use(soulbound, target)
        local wep = target:GetActiveWeapon()
        if IsValid(wep) and wep.AllowDrop then
            target:DropWeapon(wep)
            target:SetFOV(0, 0.2)

            local uses = soulbound:GetNWInt("TTTSoulboundDropWeaponUses", 0)
            uses = math.max(uses - 1, 0)
            soulbound:SetNWInt("TTTSoulboundDropWeaponUses", uses)
            soulbound:SetNWFloat("TTTSoulboundDropWeaponNextUse", CurTime() + dropweapon_cooldown:GetFloat())
        end
    end

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWInt("TTTSoulboundDropWeaponUses", 0)
        soulbound:SetNWFloat("TTTSoulboundDropWeaponNextUse", 0)
    end
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local max_uses = dropweapon_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundDropWeaponUses", 0)
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
        local next_use = soulbound:GetNWFloat("TTTSoulboundDropWeaponNextUse")
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
            else
                local wep = target:GetActiveWeapon()
                if IsValid(wep) and wep.AllowDrop then
                    text = "Press '" .. key .. "' to make " .. target:Nick() .. " drop their weapon"
                else
                    ready = false
                    text = target:Nick() .. "'s held weapon can't be dropped"
                end
            end
        end

        draw.SimpleText(text, "TabLarge", x + margin, y + height - margin, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        return ready
    end
end

SOULBOUND:RegisterAbility(ABILITY)