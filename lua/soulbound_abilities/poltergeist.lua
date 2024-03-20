local ABILITY = {}

ABILITY.Name = "Poltergeist"
ABILITY.Id = "poltergeist"
ABILITY.Description = "Shoot a poltergeist"
ABILITY.Icon = "vgui/ttt/icon_polter"

local poltergeist_uses = CreateConVar("ttt_soulbound_poltergeist_uses", "3", FCVAR_REPLICATED, "How many uses should of the poltergeist ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 10)
local poltergeist_cooldown = CreateConVar("ttt_soulbound_poltergeist_cooldown", "0", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the poltergeist ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_poltergeist_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_poltergeist_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

local function ValidPoltergeistTarget(ent)
    return IsValid(ent) and ent:GetMoveType() == MOVETYPE_VPHYSICS and ent:GetPhysicsObject() and (not ent:IsWeapon()) and (not ent:GetNWBool("punched", false)) and (not ent:IsPlayer())
end

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundPoltergeistUses", poltergeist_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundPoltergeistNextUse", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if not soulbound:IsInWorld() then return false end
        if poltergeist_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundPoltergeistUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundPoltergeistNextUse") then return false end
        local tr = soulbound:GetEyeTrace()
        if tr.HitWorld then return false end
        if not ValidPoltergeistTarget(tr.Entity) then return false end
        if not tr.Entity:GetPhysicsObject():IsMoveable() then return false end
        return true
    end

    function ABILITY:Use(soulbound, target)
        local tr = soulbound:GetEyeTrace()
        local ang = soulbound:GetAimVector():Angle()
        ang:RotateAroundAxis(ang:Right(), 90)

        local ent = ents.Create("ttt_physhammer")
        ent:SetPos(tr.HitPos)
        ent:SetAngles(ang)
        ent:Spawn()
        ent:SetOwner(soulbound)

        local stuck = ent:StickTo(tr.Entity)
        if not stuck then
            ent:Remove()
            return
        end

        local uses = soulbound:GetNWInt("TTTSoulboundPoltergeistUses", 0)
        uses = math.max(uses - 1, 0)
        soulbound:SetNWInt("TTTSoulboundPoltergeistUses", uses)
        soulbound:SetNWFloat("TTTSoulboundPoltergeistNextUse", CurTime() + poltergeist_cooldown:GetFloat())
    end

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWInt("TTTSoulboundPoltergeistUses", 0)
        soulbound:SetNWFloat("TTTSoulboundPoltergeistNextUse", 0)
    end
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local max_uses = poltergeist_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundPoltergeistUses", 0)
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
        local text = "Press '" .. key .. "' to shoot a poltergeist"
        local next_use = soulbound:GetNWFloat("TTTSoulboundPoltergeistNextUse")
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
            local tr = soulbound:GetEyeTrace()
            if tr.HitWorld or not ValidPoltergeistTarget(tr.Entity) then
                ready = false
                text = "Aim at a valid prop"
            end
        end

        draw.SimpleText(text, "TabLarge", x + margin, y + height - margin, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        return ready
    end
end

SOULBOUND:RegisterAbility(ABILITY)