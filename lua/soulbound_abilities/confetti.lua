local ABILITY = {}

ABILITY.Name = "Confetti"
ABILITY.Id = "confetti"
ABILITY.Description = "Throw confetti and play a sound as if a Clown had activated"
ABILITY.Icon = "vgui/ttt/roles/sbd/abilities/icon_confetti.png"

local confetti_uses = CreateConVar("ttt_soulbound_confetti_uses", "3", FCVAR_REPLICATED, "How many uses should of the confetti ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 10)
local confetti_cooldown = CreateConVar("ttt_soulbound_confetti_cooldown", "3", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the confetti ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_confetti_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_confetti_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    util.AddNetworkString("TTT_SoulboundCreateConfetti")

    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundConfettiUses", confetti_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundConfettiNextUse", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if not soulbound:IsInWorld() then return false end
        if confetti_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundConfettiUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundConfettiNextUse") then return false end
        return true
    end

    local clown = Sound("clown.wav")

    function ABILITY:Use(soulbound, target)
        local pos = soulbound:GetPos()
        net.Start("TTT_SoulboundCreateConfetti")
        net.WriteVector(pos)
        net.Broadcast()

        EmitSound(clown, pos)

        local uses = soulbound:GetNWInt("TTTSoulboundConfettiUses", 0)
        uses = math.max(uses - 1, 0)
        soulbound:SetNWInt("TTTSoulboundConfettiUses", uses)
        soulbound:SetNWFloat("TTTSoulboundConfettiNextUse", CurTime() + confetti_cooldown:GetFloat())
    end

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWInt("TTTSoulboundConfettiUses", 0)
        soulbound:SetNWFloat("TTTSoulboundConfettiNextUse", 0)
    end
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local max_uses = confetti_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundConfettiUses", 0)
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
        local text = "Press '" .. key .. "' to throw confetti"
        local next_use = soulbound:GetNWFloat("TTTSoulboundConfettiNextUse")
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

    local confetti = Material("confetti.png")

    net.Receive("TTT_SoulboundCreateConfetti", function(len, ply)
        local pos = net.ReadVector()

        local velMax = 200
        local gravMax = 50
        local gravity = Vector(math.random(-gravMax, gravMax), math.random(-gravMax, gravMax), math.random(-gravMax, 0))

        local em = ParticleEmitter(pos, true)
        for _ = 1, 150 do
            local p = em:Add(confetti, pos)
            p:SetStartSize(math.random(6, 10))
            p:SetEndSize(0)
            p:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
            p:SetAngleVelocity(Angle(math.random(5, 50), math.random(5, 50), math.random(5, 50)))
            p:SetVelocity(Vector(math.random(-velMax, velMax), math.random(-velMax, velMax), math.random(-velMax, velMax)))
            p:SetColor(255, 255, 255)
            p:SetDieTime(math.random(4, 7))
            p:SetGravity(gravity)
            p:SetAirResistance(125)
        end

        em:Finish()
    end)
end

SOULBOUND:RegisterAbility(ABILITY)