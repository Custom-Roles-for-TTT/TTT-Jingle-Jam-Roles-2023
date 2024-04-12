local ABILITY = {}

ABILITY.Name = "Place Fake C4"
ABILITY.Id = "fakec4"
ABILITY.Description = "Place fake C4 that explodes into confetti instead of dealing damage"
ABILITY.Icon = "vgui/ttt/icon_c4"

local fakec4_fuse = CreateConVar("ttt_soulbound_fakec4_fuse", "60", FCVAR_NONE, "How long the fuse for the Soulbound's fake C4 should be", 1, 300)
local fakec4_uses = CreateConVar("ttt_soulbound_fakec4_uses", "1", FCVAR_REPLICATED, "How many uses should of the place fake C4 ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 20)
local fakec4_cooldown = CreateConVar("ttt_soulbound_fakec4_cooldown", "0", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the place fake C4 ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_fakec4_fuse",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_fakec4_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_fakec4_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    util.AddNetworkString("TTT_SoulboundFakeC4Config")
    util.AddNetworkString("TTT_SoulboundFakeC4DisarmResult")

    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundFakeC4Uses", fakec4_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundFakeC4NextUse", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if not soulbound:IsInWorld() then return false end
        if fakec4_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundFakeC4Uses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundFakeC4NextUse") then return false end
        return true
    end

    function ABILITY:Use(soulbound, target)
        local plyPos = soulbound:GetPos()
        local hitPos = soulbound:GetEyeTrace().HitPos
        local vec = hitPos - plyPos
        local fwd = Vector(0, 0, 0)
        if target then
            fwd = soulbound:GetForward() * 48
            vec = Vector(0, 0, -1)
        end
        local spawnPos = hitPos - (vec:GetNormalized() * 15) + fwd

        local ent = ents.Create("ttt_sbd_fake_c4")
        ent:SetPos(spawnPos)
        ent:Spawn()
        ent:PhysWake()

        -- Wait a moment before arming so the bomb isnt floating in the air
        timer.Simple(3, function()
            if IsValid(ent) then
                ent:Arm(soulbound, fakec4_fuse:GetInt())
            end
        end)

        local uses = soulbound:GetNWInt("TTTSoulboundFakeC4Uses", 0)
        uses = math.max(uses - 1, 0)
        soulbound:SetNWInt("TTTSoulboundFakeC4Uses", uses)
        soulbound:SetNWFloat("TTTSoulboundFakeC4NextUse", CurTime() + fakec4_cooldown:GetFloat())
    end

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWInt("TTTSoulboundFakeC4Uses", 0)
        soulbound:SetNWFloat("TTTSoulboundFakeC4NextUse", 0)
    end
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local max_uses = fakec4_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundFakeC4Uses", 0)
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
        local text = "Press '" .. key .. "' to place fake C4"
        local next_use = soulbound:GetNWFloat("TTTSoulboundFakeC4NextUse")
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