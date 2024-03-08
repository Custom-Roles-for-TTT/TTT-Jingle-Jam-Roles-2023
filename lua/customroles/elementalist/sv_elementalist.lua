-- Logan Christianson
util.AddNetworkString("BeginIceScreen")
util.AddNetworkString("EndIceScreen")
util.AddNetworkString("BeginDimScreen")
util.AddNetworkString("EndDimScreen")

local GetConVar = GetConVar

local function IsValidPlayerEnt(ent)
    return IsPlayer(ent) and ent:Alive()
end

local function GetChanceConVarOutcome(conVarName)
    local int = math.random(100)
    local toCompare = GetConVar(conVarName):GetInt()

    return int <= toCompare
end

local chilledPlayers = {}
local ignitedPlayers = {}
local blindedPlayers = {}

-- Frostbite effect
hook.Add("TTTSpeedMultiplier", "Elementalist_TTTSpeedMultiplier", function(ply, mults)
    local effect = chilledPlayers[ply:SteamID64()]

    if effect then
        table.Add(mults, effect)
    end
end)

hook.Add("EntityTakeDamage", "Elementalist_EntityTakeDamage", function(ent, dmginfo)
    local att = dmginfo:GetAttacker()

    if not IsValidPlayerEnt(ent) or not IsValidPlayerEnt(att) or not dmginfo:IsBulletDamage() then -- For some reason, crowbar attacks return true on this
        return
    end

    if not att:IsElementalist() then
        return
    end

    -- Att is a valid elementalist damaging a valid player
    local ROLE = ROLE_DATA_EXTERNAL[ROLE_ELEMENTALIST]
    local vicId = ent:SteamID64()
    local damage = math.Clamp(dmginfo:GetDamage(), 1, 100)
    local scale = damage * 0.01

    if att:HasEquipmentItem(EQUIP_ELEMENTALIST_FROSTBITE) then
        local MovementSlow = math.Round(math.Clamp(20 + (scale * 20), 20, 40))
        local Timer = ROLE.ConvarFrostEffectDur:GetInt()

        if att:HasEquipmentItem(EQUIP_ELEMENTALIST_FROSTBITE_UP) and chilledPlayers[vicId] and GetChanceConVarOutcome("ttt_elementalist_frostbite+_freeze_chance") then
            --Upgrade functionality
            chilledPlayers[vicId] = false
            ent:Freeze(true)

            net.Start("BeginIceScreen")
                net.WriteBool(true)
            net.Send(ent)
        else
            --Base fucntionality
            chilledPlayers[vicId] = 1 - (MovementSlow * 0.01)

            net.Start("BeginIceScreen")
                net.WriteBool(false)
            net.Send(ent)
        end

        local function EndFrostbite()
            if ent then
                chilledPlayers[vicId] = false
                ent:Freeze(false)

                net.Start("EndIceScreen")
                net.Send(ent)
            end
        end

        if not timer.Exists(vicId .. "_IsSlowed") then
            timer.Create(vicId .. "_IsSlowed", Timer, 1, EndFrostbite)
        else
            timer.Adjust(vicId .. "_IsSlowed", Timer, 1, EndFrostbite)
        end
    end

    if att:HasEquipmentItem(EQUIP_ELEMENTALIST_PYROMANCER) then
        local fixTimerId = vicId .. "_IsBurningShotgunFix"

        if att:HasEquipmentItem(EQUIP_ELEMENTALIST_PYROMANCER_UP) and ignitedPlayers[vicId] and GetChanceConVarOutcome("ttt_elementalist_pyromancer+_explode_chance") then
            --Upgrade functionality
            if timer.Exists(fixTimerId) then return end

            timer.Create(fixTimerId, 0.1, 1, function()
                timer.Remove(fixTimerId)
            end)

            local explosion = ents.Create("env_explosion")

            if IsValid(explosion) then
                ignitedPlayers[vicId] = nil
                ent:Extinguish()

                explosion:SetPos(ent:GetPos())
                explosion:SetOwner(att)
                explosion:Spawn()
                explosion:SetKeyValue("iMagnitude", ent:Health() * 2)
                explosion:Fire("Explode", 0, 0)
                util.BlastDamage(explosion, att, ent:GetPos(), ent:Health() * 4, ent:Health())
            end
        else
            --Base functionality
            ignitedPlayers[vicId] = true
            local timerId = vicId .. "_IsBurning"

            local timeToBurn = 1 + (ROLE.ConvarPyroBurnDur:GetInt() * scale)

            -- This isn't a very dynamic way of doing this, it always uses the newest time, even if smaller
            ent:Ignite(timeToBurn, 400 * scale)

            local function RemoveBurningStatus()
                if ent then
                    ignitedPlayers[ent:SteamID64()] = false
                    ent:Extinguish()
                end
            end

            if timer.Exists(timerId) then
                timer.Adjust(timerId, timeToBurn, 1, RemoveBurningStatus)
            else
                timer.Create(timerId, timeToBurn, 1, RemoveBurningStatus)
            end
        end
    end

    if att:HasEquipmentItem(EQUIP_ELEMENTALIST_WINDBURN) then
        if att:HasEquipmentItem(EQUIP_ELEMENTALIST_WINDBURN_UP) and GetChanceConVarOutcome("ttt_elementalist_windburn+_launch_chance") then
            --Upgrade functionality
            ent:SetVelocity(ent:GetVelocity() + Vector(0, 0, 1000 + (1000 * scale)))

            if ent.SetJumpLevel and ent.GetMaxJumpLevel then
                -- Wait a tick to make sure they're actually off the ground before disabling double jumping
                timer.Simple(0, function()
                    ent:SetJumpLevel(ent:GetMaxJumpLevel() + 1)
                end)
            end
        else
            --Base functionality
            local dir = ent:GetPos() - att:GetPos()
            local dirNormal = dir:GetNormalized()
            local forceScale = 300 + (ROLE.ConvarWindPushPow:GetInt() * scale) -- Based on the crowbar push effect
            local pushForce = Vector(dirNormal.x * forceScale, dirNormal.y * forceScale, dirNormal.z * forceScale * 0.5)

            ent:SetVelocity(ent:GetVelocity() + pushForce)
        end
    end

    if att:HasEquipmentItem(EQUIP_ELEMENTALIST_DISCHARGE) then
        --Base functionality
        local edata = EffectData()
        if edata then
            edata:SetEntity(ent)
            edata:SetMagnitude(3)
            edata:SetScale(2)

            util.Effect("TeslaHitBoxes", edata)
        end

        local eyeang = ent:EyeAngles()
        if eyeang then
            local punchPower = ROLE.ConvarDisPunchPow:GetInt() * damage
            eyeang.pitch = math.Clamp(eyeang.pitch + math.Rand(-punchPower, punchPower), -90, 90)
            eyeang.yaw = math.Clamp(eyeang.yaw + math.Rand(-punchPower, punchPower), -90, 90)
            ent:SetEyeAngles(eyeang)
        end

        if att:HasEquipmentItem(EQUIP_ELEMENTALIST_DISCHARGE_UP) and GetChanceConVarOutcome("ttt_elementalist_discharge+_input_chance") then
            --Upgrade functionality
            local function ForceAction(startCommand, endCommand)
                ent:ConCommand(startCommand)

                timer.Simple(1, function()
                    if ent then
                        ent:ConCommand(endCommand)
                    end
                end)
            end

            local choice = math.random(3)

            if choice == 1 then
                ForceAction("+attack", "-attack")
            elseif choice == 2 then
                local choice2 = math.random(2)
                local choice3 = math.random(2)

                if choice2 == 1 then
                    ForceAction("+forward", "-forward")
                end
                if choice2 == 2 then
                    ForceAction("+back", "-back")
                end
                if choice3 == 1 then
                    ForceAction("+moveleft", "-moveleft")
                end
                if choice3 == 2 then
                    ForceAction("+moveright", "-moveright")
                end
            elseif choice == 3 then
                ForceAction("+jump", "-jump")
            end
        end
    end

    if att:HasEquipmentItem(EQUIP_ELEMENTALIST_MIDNIGHT) then
        if att:HasEquipmentItem(EQUIP_ELEMENTALIST_MIDNIGHT_UP) and blindedPlayers[vicId] and GetChanceConVarOutcome("ttt_elementalist_midnight+_blindness_chance") then
            --Upgrade functionality
            blindedPlayers[vicId] = 100
        else
            --Base functionality
            blindedPlayers[vicId] = blindedPlayers[vicId] or 0
            blindedPlayers[vicId] = math.Clamp(blindedPlayers[vicId] + damage, 0, 50)
        end

        net.Start("BeginDimScreen")
            net.WriteUInt(blindedPlayers[vicId], 6)
        net.Send(ent)

        local function EndBlind()
            blindedPlayers[vicId] = 0

            net.Start("EndDimScreen")
            net.Send(ent)
        end

        if not timer.Exists(vicId .. "_IsBlind") then
            timer.Create(vicId .. "_IsBlind", ROLE.ConvarMidEffectDur:GetInt(), 1, EndBlind)
        else
            timer.Adjust(vicId .. "_IsBlind", ROLE.ConvarMidEffectDur:GetInt(), 1, EndBlind)
        end
    end

    if att:HasEquipmentItem(EQUIP_ELEMENTALIST_LIFESTEAL) then
        --Base functionality
        local healPercent = ROLE.ConvarLifeHealPer:GetInt() * 0.01
        local healAmount = math.Round(damage * healPercent, 0)

        if att:HasEquipmentItem(EQUIP_ELEMENTALIST_LIFESTEAL_UP) then
            --Upgrade functionality
            local healthDiff = math.Clamp(ent:Health() - damage, 0, ent:GetMaxHealth())

            if healthDiff < ROLE.ConvarLifeExecute:GetInt() then
                dmginfo:SetDamage(1000)
                healAmount = healAmount + math.Round(healthDiff * 0.33, 0)
            end
        end

        att:SetHealth(math.Clamp(att:Health() + healAmount, 0, att:GetMaxHealth()))
    end
end)

-- Reset all values, call all end net messages, end all timers
local function ResetEffects(ply)
    local id = ply:SteamID64()

    chilledPlayers[id] = nil
    ignitedPlayers[id] = nil
    blindedPlayers[id] = nil

    timer.Remove(id .. "_IsSlowed")
    net.Start("EndIceScreen")
    net.Send(ply)

    ply:Extinguish()
    timer.Remove(id .. "_IsBurning")

    timer.Remove(id .. "_IsBlind")
    net.Start("EndDimScreen")
    net.Send(ply)
end

hook.Add("PlayerDeath", "Reset Elementalist On Player Death", function(ply)
    ResetEffects(ply)
end)

hook.Add("PlayerSilentDeath", "Reset Elementalist On Silent Player death", function(ply)
    ResetEffects(ply)
end)