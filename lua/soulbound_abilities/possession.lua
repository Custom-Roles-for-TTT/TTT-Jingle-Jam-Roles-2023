local ABILITY = {}

ABILITY.Name = "Ultra Prop Possession"
ABILITY.Id = "possession"
ABILITY.Description = "Removes the cooldown/recharge time and increases force for prop possession"
ABILITY.Icon = "vgui/ttt/icon_possession.png"

if SERVER then
    function ABILITY:Bought(soulbound)
        hook.Add("KeyPress", "Soulbound_Possession_KeyPress_" .. soulbound:SteamID64(), function(ply, key)
            if not IsPlayer(ply) then return end
            if ply ~= soulbound then return end
            if not ply.propspec then return end

            local ent = ply.propspec.ent
            local phys = IsValid(ent) and ent:GetPhysicsObject()
            if not IsValid(ent) or not IsValid(phys) then return end
            if not phys:IsMoveable() then return end
            if phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) then return end

            local m = math.min(150, phys:GetMass())
            local force = GetConVar("ttt_spec_prop_force"):GetInt()
            local mf = m * force
            local aim = ply:GetAimVector()

            -- This applies on top of the usual prop spectator forces effectively doubling the strength
            if key == IN_JUMP then
                phys:ApplyForceCenter(Vector(0,0, mf))
            elseif key == IN_FORWARD then
                phys:ApplyForceCenter(aim * mf)
            elseif key == IN_BACK then
                phys:ApplyForceCenter(aim * (mf * -1))
            elseif key == IN_MOVELEFT then
                phys:AddAngleVelocity(Vector(0, 0, 200))
                phys:ApplyForceCenter(Vector(0,0, mf / 3))
            elseif key == IN_MOVERIGHT then
                phys:AddAngleVelocity(Vector(0, 0, -200))
                phys:ApplyForceCenter(Vector(0,0, mf / 3))
            end
        end)
    end

    function ABILITY:Condition(soulbound, target)
        if not soulbound.propspec then return false end
        return true
    end

    function ABILITY:Passive(soulbound, target)
        soulbound.propspec.punches = 1
        soulbound:SetNWFloat("specpunches", 1)
        soulbound:GetNWInt("bonuspunches", 0)
    end

    function ABILITY:Cleanup(soulbound)
        hook.Remove("KeyPress", "Soulbound_Possession_KeyPress_" .. soulbound:SteamID64())
    end
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local margin = 6
        local ammo_height = 28
        CRHUD:PaintBar(8, x + margin, y + margin, width - (margin * 2), ammo_height, ammo_colors, 1)
        CRHUD:ShadowedText("Passive Item", "HealthAmmo", x + (margin * 2), y + margin + (ammo_height / 2), COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local ready = true
        local text = "Your prop possession powers have been buffed"
        local target = soulbound:GetObserverTarget()
        if not IsValid(target) or target:GetNWEntity("spec_owner", nil) ~= soulbound then
            ready = false
            text = "Possess a prop"
        end

        draw.SimpleText(text, "TabLarge", x + margin, y + height - margin, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        return ready
    end
end

SOULBOUND:RegisterAbility(ABILITY)