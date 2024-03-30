local ABILITY = {}

ABILITY.Name = "Incendiary Grenade"
ABILITY.Id = "incendiary"
ABILITY.Description = "Throw an incendiary grenade"
ABILITY.Icon = "vgui/ttt/roles/sbd/abilities/icon_incendiary.png"

local incendiary_fuse_time = CreateConVar("ttt_soulbound_incendiary_fuse_time", "5", FCVAR_NONE, "How long the fuse for the Soulbound's incendiary grenade should be", 0, 10)
local incendiary_uses = CreateConVar("ttt_soulbound_incendiary_uses", "2", FCVAR_REPLICATED, "How many uses should of the incendiary grenade ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 10)
local incendiary_cooldown = CreateConVar("ttt_soulbound_incendiary_cooldown", "1", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the incendiary grenade ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_incendiary_fuse_time",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_incendiary_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_incendiary_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundIncendiaryUses", incendiary_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundIncendiaryNextUse", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if not soulbound:IsInWorld() then return false end
        if incendiary_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundIncendiaryUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundIncendiaryNextUse") then return false end
        return true
    end

    function ABILITY:Use(soulbound, target)
        local ang = soulbound:EyeAngles()
        local src = soulbound:GetPos() + (soulbound:Crouching() and soulbound:GetViewOffsetDucked() or soulbound:GetViewOffset()) + (ang:Forward() * 8) + (ang:Right() * 10)
        local pos = soulbound:GetEyeTraceNoCursor().HitPos
        local tang = (pos-src):Angle() -- A target angle to actually throw the grenade to the crosshair instead of fowards
        -- Makes the grenade go upwards
        if tang.p < 90 then
            tang.p = -10 + tang.p * ((90 + 10) / 90)
        else
            tang.p = 360 - tang.p
            tang.p = -10 + tang.p * -((90 + 10) / 90)
        end
        tang.p = math.Clamp(tang.p, -90, 90) -- Makes the grenade not go backwards :/
        local vel = math.min(800, (90 - tang.p) * 6)
        local thr = tang:Forward() * vel + soulbound:GetVelocity()

        local gren = ents.Create("ttt_firegrenade_proj")
        if not IsValid(gren) then return end

        gren:SetPos(src)
        gren:SetAngles(Angle(0,0,0))

        gren:SetOwner(soulbound)
        gren:SetThrower(soulbound)

        gren:SetGravity(0.4)
        gren:SetFriction(0.2)
        gren:SetElasticity(0.45)

        gren:Spawn()

        gren:PhysWake()

        local phys = gren:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetVelocity(thr)
            phys:AddAngleVelocity(Vector(600, math.random(-1200, 1200)), 0)
        end

        gren:SetDetonateExact(CurTime() + incendiary_fuse_time:GetFloat())

        local uses = soulbound:GetNWInt("TTTSoulboundIncendiaryUses", 0)
        uses = math.max(uses - 1, 0)
        soulbound:SetNWInt("TTTSoulboundIncendiaryUses", uses)
        soulbound:SetNWFloat("TTTSoulboundIncendiaryNextUse", CurTime() + incendiary_cooldown:GetFloat())
    end

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWInt("TTTSoulboundIncendiaryUses", 0)
        soulbound:SetNWFloat("TTTSoulboundIncendiaryNextUse", 0)
    end
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local max_uses = incendiary_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundIncendiaryUses", 0)
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
        local text = "Press '" .. key .. "' to throw an incendiary grenade"
        local next_use = soulbound:GetNWFloat("TTTSoulboundIncendiaryNextUse")
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