local ABILITY = {}

ABILITY.Name = "Place Explosive Barrel"
ABILITY.Id = "explosivebarrel"
ABILITY.Description = "Place an explosive barrel"
ABILITY.Icon = "vgui/ttt/icon_explosivebarrel.png"

local explosivebarrel_uses = CreateConVar("ttt_soulbound_explosivebarrel_uses", "2", FCVAR_REPLICATED, "How many uses should of the place explosive barrel ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 10)
local explosivebarrel_cooldown = CreateConVar("ttt_soulbound_explosivebarrel_cooldown", "0", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the place explosive barrel ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_explosivebarrel_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_explosivebarrel_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundExplosiveBarrelUses", explosivebarrel_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundExplosiveBarrelNextUse", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if not soulbound:IsInWorld() then return false end
        if explosivebarrel_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundExplosiveBarrelUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundExplosiveBarrelNextUse") then return false end
        return true
    end

    function ABILITY:Use(soulbound, target)
        local plyPos = soulbound:GetPos()
        local hitPos = soulbound:GetEyeTrace().HitPos
        local vec = hitPos - plyPos
        local spawnPos = hitPos - (vec:GetNormalized() * 15)

        local ent = ents.Create("prop_physics")
        ent:SetModel("models/props_c17/oildrum001_explosive.mdl")
        ent:SetPos(spawnPos)
        ent:Spawn()

        local uses = soulbound:GetNWInt("TTTSoulboundExplosiveBarrelUses", 0)
        uses = math.max(uses - 1, 0)
        soulbound:SetNWInt("TTTSoulboundExplosiveBarrelUses", uses)
        soulbound:SetNWFloat("TTTSoulboundExplosiveBarrelNextUse", CurTime() + explosivebarrel_cooldown:GetFloat())
    end

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWInt("TTTSoulboundExplosiveBarrelUses", 0)
        soulbound:SetNWFloat("TTTSoulboundExplosiveBarrelNextUse", 0)
    end
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local max_uses = explosivebarrel_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundExplosiveBarrelUses", 0)
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
        local text = "Press '" .. key .. "' to place an explosive barrel"
        local next_use = soulbound:GetNWFloat("TTTSoulboundExplosiveBarrelNextUse")
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
        end

        draw.SimpleText(text, "TabLarge", x + margin, y + height - margin, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        return ready
    end
end

SOULBOUND:RegisterAbility(ABILITY)