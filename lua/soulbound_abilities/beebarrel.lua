local ABILITY = {}

ABILITY.Name = "Place Bee Barrel"
ABILITY.Id = "beebarrel"
ABILITY.Description = "Place a bee barrel that will release bees when it explodes"
ABILITY.Icon = "vgui/ttt/roles/sbd/abilities/icon_beebarrel.png"

local beebarrel_uses = CreateConVar("ttt_soulbound_beebarrel_uses", "3", FCVAR_REPLICATED, "How many uses of the place bee barrel ability should the Soulbound get. (Set to 0 for unlimited uses)", 0, 10)
local beebarrel_bees = CreateConVar("ttt_soulbound_beebarrel_bees", "3", FCVAR_REPLICATED, "How many bees per beebarrel", 1, 10)
local beebarrel_cooldown = CreateConVar("ttt_soulbound_beebarrel_cooldown", "0", FCVAR_NONE, "How long should the Soulbound have to wait between uses of the place bee barrel ability", 0, 10)

table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_beebarrel_uses",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 0
})
table.insert(ROLE_CONVARS[ROLE_SOULBOUND], {
    cvar = "ttt_soulbound_beebarrel_cooldown",
    type = ROLE_CONVAR_TYPE_NUM,
    decimal = 1
})

if SERVER then

    local function BeebarrelDamage(target, dmginfo)
        if target:GetClass() == "prop_physics" then
            
            local model = target:GetModel()
            if model == "models/bee_drum/beedrum001_explosive.mdl" and dmginfo:GetDamage() >= 1 then
                local pos = target:GetPos()
                timer.Create("TTTSoulboundBeeBarrelSpawn",0.1,beebarrel_bees:GetInt(),function()
                    local spos = pos + Vector(math.random(-50, 50), math.random(-50, 50), math.random(0, 100))
                    local headBee = ents.Create("npc_manhack")
                    headBee:SetPos(spos)
                    headBee:Spawn()
                    headBee:Activate()
                    headBee:SetNPCState(NPC_STATE_ALERT)
                    if scripted_ents.Get("ttt_beenade_proj") ~= nil then
                        local bee = ents.Create("prop_dynamic")
                        bee:SetModel("models/lucian/props/stupid_bee.mdl")
                        bee:SetPos(spos)
                        bee:SetParent(headBee)
                        headBee:SetNoDraw(true)
                    end
                    headBee:SetHealth(10)
                end)
            end
        end
    end

    function ABILITY:Bought(soulbound)
        soulbound:SetNWInt("TTTSoulboundBeeBarrelUses", beebarrel_uses:GetInt())
        soulbound:SetNWFloat("TTTSoulboundBeeBarrelNextUse", CurTime())
        hook.Add( "EntityTakeDamage", "TTTSoulboundbeeBarrelDamage", BeebarrelDamage)
    end

    function ABILITY:Condition(soulbound, target)
        if not soulbound:IsInWorld() then return false end
        if beebarrel_uses:GetInt() > 0 and soulbound:GetNWInt("TTTSoulboundbeeBarrelUses", 0) <= 0 then return false end
        if CurTime() < soulbound:GetNWFloat("TTTSoulboundbeeBarrelNextUse") then return false end
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

        local ent = ents.Create("prop_physics")
        ent:SetModel("models/bee_drum/beedrum002_explosive.mdl")
        ent:SetPos(spawnPos)
        ent:Spawn()

        local uses = soulbound:GetNWInt("TTTSoulboundbeeBarrelUses", 0)
        uses = math.max(uses - 1, 0)
        soulbound:SetNWInt("TTTSoulboundbeeBarrelUses", uses)
        soulbound:SetNWFloat("TTTSoulboundBeeBarrelNextUse", CurTime() + beebarrel_cooldown:GetFloat())
    end

    function ABILITY:Cleanup(soulbound)
        soulbound:SetNWInt("TTTSoulboundBeeBarrelUses", 0)
        soulbound:SetNWFloat("TTTSoulboundBeeBarrelNextUse", 0)
    end
end

if CLIENT then
    local ammo_colors = {
        border = COLOR_WHITE,
        background = Color(100, 60, 0, 222),
        fill = Color(205, 155, 0, 255)
    }

    function ABILITY:DrawHUD(soulbound, x, y, width, height, key)
        local max_uses = beebarrel_uses:GetInt()
        local uses = soulbound:GetNWInt("TTTSoulboundBeeBarrelUses", 0)
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
        local text = "Press '" .. key .. "' to place an bee barrel"
        local next_use = soulbound:GetNWFloat("TTTSoulboundBeeBarrelNextUse")
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