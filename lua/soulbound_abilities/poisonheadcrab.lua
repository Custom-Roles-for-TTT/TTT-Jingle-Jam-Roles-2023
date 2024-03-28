local ABILITY = {}

ABILITY.Name = "Summon Poison Headcrab"
ABILITY.Id = "poisonheadcrab"
ABILITY.Description = "Summon a poison headcrab"
ABILITY.Icon = "vgui/ttt/icon_poisonheadcrab.png"

local poisonheadcrab_health = CreateConVar("ttt_soulbound_poisonheadcrab_health", "35", FCVAR_NONE, "How much health poison headcrabs spawned by the Soulbound should have", 0, 200)
local poisonheadcrab_uses = CreateConVar("ttt_soulbound_poisonheadcrab_uses", "2", FCVAR_REPLICATED, "How many uses should of the summon poison headcrab ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 10)
local poisonheadcrab_cooldown = CreateConVar("ttt_soulbound_poisonheadcrab_cooldown", "0", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the summon poison headcrab ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_poisonheadcrab_health",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_poisonheadcrab_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_poisonheadcrab_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundPoisonHeadcrabUses", poisonheadcrab_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundPoisonHeadcrabNextUse", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if not soulbound:IsInWorld() then return false end
        if poisonheadcrab_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundPoisonHeadcrabUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundPoisonHeadcrabNextUse") then return false end
        return true
    end

    function ABILITY:Use(soulbound, target)
        local plyPos = soulbound:GetPos()
        local hitPos = soulbound:GetEyeTrace().HitPos
        local vec = hitPos - plyPos
        local spawnPos = hitPos - (vec:GetNormalized() * 30)

        local ent = ents.Create("npc_headcrab_black")
        ent:SetPos(spawnPos)
        ent:SetHealth(poisonheadcrab_health:GetInt())
        ent:Spawn()

        local uses = soulbound:GetNWInt("TTTSoulboundPoisonHeadcrabUses", 0)
        uses = math.max(uses - 1, 0)
        soulbound:SetNWInt("TTTSoulboundPoisonHeadcrabUses", uses)
        soulbound:SetNWFloat("TTTSoulboundPoisonHeadcrabNextUse", CurTime() + poisonheadcrab_cooldown:GetFloat())
    end

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWInt("TTTSoulboundPoisonHeadcrabUses", 0)
        soulbound:SetNWFloat("TTTSoulboundPoisonHeadcrabNextUse", 0)
    end
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local max_uses = poisonheadcrab_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundPoisonHeadcrabUses", 0)
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
        local text = "Press '" .. key .. "' to summon a poison headcrab"
        local next_use = soulbound:GetNWFloat("TTTSoulboundPoisonHeadcrabNextUse")
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