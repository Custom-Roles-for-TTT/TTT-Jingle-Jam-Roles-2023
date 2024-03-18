local ABILITY = {}

ABILITY.Name = "Place Box"
ABILITY.Id = "box"
ABILITY.Description = "Place a box"
ABILITY.Icon = "vgui/ttt/icon_nades"

local box_uses = CreateConVar("ttt_soulbound_box_uses", "10", FCVAR_REPLICATED, "How many uses should of the place box ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 50)
local box_cooldown = CreateConVar("ttt_soulbound_box_cooldown", "0", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the place box ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_box_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_box_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundBoxUses", box_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundBoxNextUse", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if not soulbound:IsInWorld() then return false end
        if box_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundBoxUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundBoxNextUse") then return false end
        return true
    end

    function ABILITY:Use(soulbound, target)
        local plyPos = soulbound:GetPos()
        local hitPos = soulbound:GetEyeTrace().HitPos
        local vec = hitPos - plyPos
        local spawnPos = hitPos - (vec:GetNormalized() * 40)

        local ent = ents.Create("prop_physics")
        ent:SetModel("models/props_junk/wood_crate001a.mdl")
        ent:SetPos(spawnPos)
        ent:Spawn()

        local uses = soulbound:GetNWInt("TTTSoulboundBoxUses", 0)
        uses = math.max(uses - 1, 0)
        soulbound:SetNWInt("TTTSoulboundBoxUses", uses)
        soulbound:SetNWFloat("TTTSoulboundBoxNextUse", CurTime() + box_cooldown:GetFloat())
    end

    hook.Add("TTTPrepareRound", "Soulbound_Box_TTTPrepareRound", function()
        for _, p in ipairs(player.GetAll()) do
            p:SetNWInt("TTTSoulboundBoxUses", 0)
            p:SetNWFloat("TTTSoulboundBoxNextUse", 0)
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
        local max_uses = box_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundBoxUses", 0)
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
        local text = "Press '" .. key .. "' to place a box"
        local next_use = soulbound:GetNWFloat("TTTSoulboundBoxNextUse")
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