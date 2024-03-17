local ABILITY = {}

ABILITY.Name = "Instant Smoke"
ABILITY.Id = "smoke"
ABILITY.Description = "Create a cloud of smoke"
ABILITY.Icon = "vgui/ttt/icon_nades"

local smoke_linger_time = CreateConVar("ttt_soulbound_smoke_linger_time", "30", FCVAR_REPLICATED, "How long the fuse for the Soulbound's instant smoke should linger for", 5, 120)
local smoke_uses = CreateConVar("ttt_soulbound_smoke_uses", "3", FCVAR_REPLICATED, "How many uses should of the smoke grenade ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 10)
local smoke_cooldown = CreateConVar("ttt_soulbound_smoke_cooldown", "1", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the smoke grenade ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_smoke_linger_time",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_smoke_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_smoke_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundSmokeUses", smoke_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundSmokeNextUse", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if not soulbound:IsInWorld() then return false end
        if smoke_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundSmokeUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundSmokeNextUse") then return false end
        return true
    end

    if SERVER then
        util.AddNetworkString("TTT_SoulboundCreateSmoke")
    else
        local smokeparticles = {
            Model("particle/particle_smokegrenade"),
            Model("particle/particle_noisesphere")
        };

        net.Receive("TTT_SoulboundCreateSmoke", function(len, ply)
            local pos = net.ReadVector()
            local em = ParticleEmitter(pos)

            local r = 20
            for _ = 1, 20 do
                local prpos = VectorRand() * r
                prpos.z = prpos.z + 32
                local p = em:Add(table.Random(smokeparticles), pos + prpos)
                if p then
                    local gray = math.random(75, 200)
                    p:SetColor(gray, gray, gray)
                    p:SetStartAlpha(255)
                    p:SetEndAlpha(200)
                    p:SetVelocity(VectorRand() * math.Rand(900, 1300))
                    p:SetLifeTime(0)

                    local life_time = smoke_linger_time:GetInt()
                    p:SetDieTime(math.Rand(life_time - 5, life_time + 5))

                    p:SetStartSize(math.random(140, 150))
                    p:SetEndSize(math.random(1, 40))
                    p:SetRoll(math.random(-180, 180))
                    p:SetRollDelta(math.Rand(-0.1, 0.1))
                    p:SetAirResistance(600)

                    p:SetCollide(true)
                    p:SetBounce(0.4)

                    p:SetLighting(false)
                end
            end

            em:Finish()
        end)
    end

    local extinguish = Sound("extinguish.wav")

    function ABILITY:Use(soulbound, target)
        local pos = soulbound:GetPos()
        net.Start("TTT_SoulboundCreateSmoke")
        net.WriteVector(pos)
        net.Broadcast()

        if GetConVar("ttt_smokegrenade_extinguish"):GetBool() then
            local target_ents = {"ttt_flame", "env_fire", "_firesmoke"}
            local entities = ents.FindInSphere(pos, 100)
            local was_extinguished = false
            for _, e in ipairs(entities) do
                local ent_class = e:GetClass()
                if table.HasValue(target_ents, ent_class) then
                    SafeRemoveEntity(e)
                    was_extinguished = true
                    hook.Call("TTTSmokeGrenadeExtinguish", nil, ent_class, pos)
                end
            end

            -- Play a sound if something was extinguished
            if was_extinguished then
                EmitSound(extinguish, pos)
            end
        end

        local uses = soulbound:GetNWInt("TTTSoulboundSmokeUses", 0)
        uses = math.max(uses - 1, 0)
        soulbound:SetNWInt("TTTSoulboundSmokeUses", uses)
        soulbound:SetNWFloat("TTTSoulboundSmokeNextUse", CurTime() + smoke_cooldown:GetFloat())
    end

    hook.Add("TTTPrepareRound", "Soulbound_Smoke_TTTPrepareRound", function()
        for _, p in ipairs(player.GetAll()) do
            p:SetNWInt("TTTSoulboundSmokeUses", 0)
            p:SetNWFloat("TTTSoulboundSmokeNextUse", 0)
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
        local max_uses = smoke_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundSmokeUses", 0)
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
        local text = "Press '" .. key .. "' to create a cloud of smoke"
        local next_use = soulbound:GetNWFloat("TTTSoulboundSmokeNextUse")
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