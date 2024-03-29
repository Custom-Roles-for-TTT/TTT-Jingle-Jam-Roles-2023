local ABILITY = {}

ABILITY.Name = "Fake Gunshots"
ABILITY.Id = "gunshots"
ABILITY.Description = "Play fake gunshot sounds"
ABILITY.Icon = "vgui/ttt/roles/sbd/abilities/icon_gunshots.png"

local gunshots_uses = CreateConVar("ttt_soulbound_gunshots_uses", "10", FCVAR_REPLICATED, "How many uses should of the gunshots grenade ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 50)
local gunshots_cooldown = CreateConVar("ttt_soulbound_gunshots_cooldown", "1", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the gunshots grenade ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_gunshots_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_gunshots_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then
    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundGunshotsUses", gunshots_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundGunshotsNextUse", CurTime())
    end

    function ABILITY:Condition(soulbound, target)
        if not soulbound:IsInWorld() then return false end
        if gunshots_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundGunshotsUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundGunshotsNextUse") then return false end
        return true
    end

    local gunsounds = {
        {
            sound = Sound( "Weapon_XM1014.Single" ),
            delay = 0.8,
            times = {1, 3},
            burst = false
        },

        {
            sound = Sound( "Weapon_FiveSeven.Single" ),
            delay = 0.4,
            times = {2, 4},
            burst = false
        },

        {
            sound = Sound( "Weapon_mac10.Single" ),
            delay = 0.065,
            times = {5, 10},
            burst = true
        },

        {
            sound = Sound( "Weapon_Deagle.Single" ),
            delay = 0.6,
            times = {1, 3},
            burst = false
        },

        {
            sound = Sound( "Weapon_M4A1.Single" ),
            delay = 0.2,
            times = {1, 5},
            burst = true
        },

        {
            sound = Sound( "weapons/scout/scout_fire-1.wav" ),
            delay = 1.5,
            times = {1, 1},
            burst = false,
            ampl = 80
        },

        {
            sound = Sound( "Weapon_m249.Single" ),
            delay = 0.055,
            times = {6, 12},
            burst = true
        }
    };

    function ABILITY:Use(soulbound, target)
        local pos = soulbound:GetPos()
        local gunsound = gunsounds[math.random(1, #gunsounds)]
        local times = math.random(gunsound.times[1], gunsound.times[2])
        local t = 0
        for _ = 1, times do
            timer.Simple(t, function()
                sound.Play(gunsound.sound, pos, gunsound.ampl or 90)
            end)
            if gunsound.burst then
                t = t + gunsound.delay
            else
                t = t + math.Rand(gunsound.delay, gunsound.delay * 2)
            end
        end

        local uses = soulbound:GetNWInt("TTTSoulboundGunshotsUses", 0)
        uses = math.max(uses - 1, 0)
        soulbound:SetNWInt("TTTSoulboundGunshotsUses", uses)
        soulbound:SetNWFloat("TTTSoulboundGunshotsNextUse", CurTime() + gunshots_cooldown:GetFloat())
    end

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWInt("TTTSoulboundGunshotsUses", 0)
        soulbound:SetNWFloat("TTTSoulboundGunshotsNextUse", 0)
    end
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local max_uses = gunshots_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundGunshotsUses", 0)
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
        local text = "Press '" .. key .. "' to play fake gunshot sounds"
        local next_use = soulbound:GetNWFloat("TTTSoulboundGunshotsNextUse")
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