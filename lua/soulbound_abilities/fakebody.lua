local ABILITY = {}

ABILITY.Name = "Place Fake Body"
ABILITY.Id = "fakebody"
ABILITY.Description = "Place a fake dead body that looks like you. Explodes into confetti when searched"
ABILITY.Icon = "vgui/ttt/roles/sbd/abilities/icon_body.png"

local fakebody_uses = CreateConVar("ttt_soulbound_fakebody_uses", "1", FCVAR_REPLICATED, "How many uses should of the place fake body ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 10)
local fakebody_cooldown = CreateConVar("ttt_soulbound_fakebody_cooldown", "0", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the place fake body ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_fakebody_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_fakebody_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundFakeBodyUses", fakebody_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundFakeBodyNextUse", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if not soulbound:IsInWorld() then return false end
        if fakebody_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundFakeBodyUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundFakeBodyNextUse") then return false end
        return true
    end

    local deathsounds = {
        Sound("player/death1.wav"),
        Sound("player/death2.wav"),
        Sound("player/death3.wav"),
        Sound("player/death4.wav"),
        Sound("player/death5.wav"),
        Sound("player/death6.wav"),
        Sound("vo/npc/male01/pain07.wav"),
        Sound("vo/npc/male01/pain08.wav"),
        Sound("vo/npc/male01/pain09.wav"),
        Sound("vo/npc/male01/pain04.wav"),
        Sound("vo/npc/Barney/ba_pain06.wav"),
        Sound("vo/npc/Barney/ba_pain07.wav"),
        Sound("vo/npc/Barney/ba_pain09.wav"),
        Sound("vo/npc/Barney/ba_ohshit03.wav"),
        Sound("vo/npc/Barney/ba_no01.wav"),
        Sound("vo/npc/male01/no02.wav"),
        Sound("hostage/hpain/hpain1.wav"),
        Sound("hostage/hpain/hpain2.wav"),
        Sound("hostage/hpain/hpain3.wav"),
        Sound("hostage/hpain/hpain4.wav"),
        Sound("hostage/hpain/hpain5.wav"),
        Sound("hostage/hpain/hpain6.wav")
    };

    function ABILITY:Use(soulbound, target)
        local plyPos = soulbound:GetPos()
        local hitPos = soulbound:GetEyeTrace().HitPos
        local vec = hitPos - plyPos
        local fwd = Vector(0, 0, 0)
        if target then
            fwd = soulbound:GetForward() * 48
            vec = Vector(0, 0, -1)
        end
        local spawnPos = hitPos - (vec:GetNormalized() * 40) + fwd

        local ragdoll = ents.Create("prop_ragdoll")
        ragdoll:SetPos(spawnPos)
        ragdoll:SetModel(soulbound:GetModel())
        ragdoll:SetSkin(soulbound:GetSkin())
        for _, value in pairs(soulbound:GetBodyGroups()) do
            ragdoll:SetBodygroup(value.id, soulbound:GetBodygroup(value.id))
        end
        ragdoll:SetAngles(soulbound:GetAngles())
        ragdoll:SetColor(soulbound:GetColor())
        ragdoll:Spawn()
        ragdoll:Activate()

        timer.Create("FakeRagdoll" .. tostring(CurTime()), 0.5, 5, function()
            local jitter = VectorRand() * 30
            jitter.z = 20
            util.PaintDown(ragdoll:GetPos() + jitter, "Blood", ragdoll)
        end)

        -- Trick the game into thinking this is a real dead body but dont provide an ID so defibs dont work
        CORPSE.SetPlayerNick(ragdoll, soulbound)
        ragdoll.player_ragdoll = true
        ragdoll:SetNWBool("TTTSoulboundIsFakeRagdoll", true)

        sound.Play(table.Random(deathsounds), spawnPos, 90, 100)

        local uses = soulbound:GetNWInt("TTTSoulboundFakeBodyUses", 0)
        uses = math.max(uses - 1, 0)
        soulbound:SetNWInt("TTTSoulboundFakeBodyUses", uses)
        soulbound:SetNWFloat("TTTSoulboundFakeBodyNextUse", CurTime() + fakebody_cooldown:GetFloat())
    end

    local birthday = Sound("birthday.wav")

    hook.Add("TTTCanSearchCorpse", "Soulbound_FakeBody_TTTCanSearchCorpse", function(ply, corpse, is_covert, is_long_range, was_traitor)
        if corpse:GetNWBool("TTTSoulboundIsFakeRagdoll", false) then
            local pos = corpse:GetPos()
            net.Start("TTT_SoulboundCreateConfetti")
            net.WriteVector(pos)
            net.Broadcast()

            EmitSound(birthday, pos)

            corpse:Remove()
            return false
        end
    end)

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWInt("TTTSoulboundFakeBodyUses", 0)
        soulbound:SetNWFloat("TTTSoulboundFakeBodyNextUse", 0)
    end
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local max_uses = fakebody_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundFakeBodyUses", 0)
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
        local text = "Press '" .. key .. "' to place a fake body"
        local next_use = soulbound:GetNWFloat("TTTSoulboundFakeBodyNextUse")
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