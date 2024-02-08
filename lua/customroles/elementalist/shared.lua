-- Logan Christianson
local ROLE = {}

-- Allowing of individual effect upgrades
ROLE.ConvarTierUpgrades = CreateConVar("ttt_elementalist_allow_effect_upgrades", "1", FCVAR_REPLICATED, "Controls whether \"upgrades\" for the elemental effects should be available for purchase", 0, 1)
ROLE.ConvarPyroUpgrades = CreateConVar("ttt_elementalist_allow_pyromancer_upgrades", "1", FCVAR_REPLICATED, "Controls whether the Pyromancer upgrade(s) should be available in the elementalist shop", 0, 1)
ROLE.ConvarFrostUpgrades = CreateConVar("ttt_elementalist_allow_frostbite_upgrades", "1", FCVAR_REPLICATED, "Controls whether the Frostbite upgrade(s) should be available in the elementalist shop", 0, 1)
ROLE.ConvarWindUpgrades = CreateConVar("ttt_elementalist_allow_windburn_upgrades", "1", FCVAR_REPLICATED, "Controls whether the Windburn upgrade(s) should be available in the elementalist shop", 0, 1)
ROLE.ConvarDischargeUpgrades = CreateConVar("ttt_elementalist_allow_discharge_upgrades", "1", FCVAR_REPLICATED, "Controls whether the Discharge upgrade(s) should be available in the elementalist shop", 0, 1)
ROLE.ConvarMidnightUpgrades = CreateConVar("ttt_elementalist_allow_midnight_upgrades", "1", FCVAR_REPLICATED, "Controls whether the Midnight upgrade(s) should be available in the elementalist shop", 0, 1)
ROLE.ConvarLifeUpgrades = CreateConVar("ttt_elementalist_allow_lifesteal_upgrades", "1", FCVAR_REPLICATED, "Controls whether the Lifesteal upgrade(s) should be available in the elementalist shop", 0, 1)

if SERVER then
    -- Durations & associated chances
    ROLE.ConvarFrostEffectDur = CreateConVar("ttt_elementalist_frostbite_effect_duration", "3", FCVAR_NONE, "How long the Frostbite slow & freeze effect lasts. Value must be greater than 0 and less than 6", 1, 5)
    ROLE.ConvarFrostExplodeCha = CreateConVar("ttt_elementalist_frostbite+_freeze_chance", "5", FCVAR_NONE, "The percent chance shooting a victim which has been slowed by Frostbite will instead freeze them. Value must be greater than 0 and less than 101", 1, 100)
    ROLE.ConvarPyroBurnDur = CreateConVar("ttt_elementalist_pyromancer_burn_duration", "3", FCVAR_NONE, "How long the Pryomancer effect should burn the victim for. 100 damage would scale for the full length. Value must be greater than 0 and less than 6", 1, 5)
    ROLE.ConvarPyroExplodeCha = CreateConVar("ttt_elementalist_pyromancer+_explode_chance", "5", FCVAR_NONE, "The percent chance shooting a victim ignited by Pyromancer will cause them to explode. Value must be greater than 0 and less than 101", 1, 100)
    ROLE.ConvarMidEffectDur = CreateConVar("ttt_elementalist_midnight_dim_duration", "3", FCVAR_NONE, "How long the Midnight screen dimming effect should last. Value must be greater than 0 and less than 6", 1, 5)
    ROLE.ConvarMidBlindCha = CreateConVar("ttt_elementalist_midnight+_blindness_chance", "5", FCVAR_NONE, "The percent chance shooting a victim affected by Midnight will instead completely blind them. Value must be greater than 0 and less than 101", 1, 100)

    -- One-offs and associated chances
    ROLE.ConvarWindPushPow = CreateConVar("ttt_elementalist_windburn_push_power", "700", FCVAR_NONE, "How much push power the windburn effect should apply to victims, scales with damage done. Must be greater than 299 and less than 1001", 300, 1000)
    ROLE.ConvarWindLaunchCha = CreateConVar("ttt_elementalist_windburn+_launch_chance", "5", FCVAR_NONE, "The percent chance shooting a victim will launch instead of push them. Value must be greater than 0 and less than 101", 1, 100)
    ROLE.ConvarDisPunchPow = CreateConVar("ttt_elementalist_discharge_punch_power", "5", FCVAR_NONE, "How much view punch power the discharge effect should apply to victims, scales with damage done. Must be greater than 0 and less than 11", 1, 10)
    ROLE.ConvarDisInputCha = CreateConVar("ttt_elementalist_discharge+_input_chance", "5", FCVAR_NONE, "The percent chance shooting a victim will cause them to apply a random input in additional to the view punch. Value must be greater than 0 and less than 101", 1, 100)
    ROLE.ConvarLifeHealPer = CreateConVar("ttt_elementalist_lifesteal_heal_percentage", "30", FCVAR_NONE, "What percent of damage done by shooting should be converted into health for the Elementalist. Must be greater than 0 and less than 101", 1, 100)
    ROLE.ConvarLifeExecute = CreateConVar("ttt_elementalist_lifesteal+_execute_amount", "15", FCVAR_NONE, "How much life a victim must reach before Lifesteal+ will execute them. Value must be greater than 0 and less than 101", 1, 100)
end

ROLE.convars = {}

-- Set One
table.insert(ROLE.convars, {
    cvar = "ttt_elementalist_allow_effect_upgrades",
    type = ROLE_CONVAR_TYPE_BOOL
})
table.insert(ROLE.convars, {
    cvar = "ttt_elementalist_allow_pyromancer_upgrades",
    type = ROLE_CONVAR_TYPE_BOOL
})
table.insert(ROLE.convars, {
    cvar = "ttt_elementalist_allow_frostbite_upgrades",
    type = ROLE_CONVAR_TYPE_BOOL
})
table.insert(ROLE.convars, {
    cvar = "ttt_elementalist_allow_windburn_upgrades",
    type = ROLE_CONVAR_TYPE_BOOL
})
table.insert(ROLE.convars, {
    cvar = "ttt_elementalist_allow_discharge_upgrades",
    type = ROLE_CONVAR_TYPE_BOOL
})
table.insert(ROLE.convars, {
    cvar = "ttt_elementalist_allow_discharge_upgrades",
    type = ROLE_CONVAR_TYPE_BOOL
})
table.insert(ROLE.convars, {
    cvar = "ttt_elementalist_allow_midnight_upgrades",
    type = ROLE_CONVAR_TYPE_BOOL
})
table.insert(ROLE.convars, {
    cvar = "ttt_elementalist_allow_lifesteal_upgrades",
    type = ROLE_CONVAR_TYPE_BOOL
})
--

if SERVER then
    -- Set Two
    table.insert(ROLE.convars, {
        cvar = "ttt_elementalist_frostbite_effect_duration",
        type = ROLE_CONVAR_TYPE_NUM
    })
    table.insert(ROLE.convars, {
        cvar = "ttt_elementalist_frostbite+_freeze_chance",
        type = ROLE_CONVAR_TYPE_NUM
    })
    table.insert(ROLE.convars, {
        cvar = "ttt_elementalist_pyromancer_burn_duration",
        type = ROLE_CONVAR_TYPE_NUM
    })
    table.insert(ROLE.convars, {
        cvar = "ttt_elementalist_pyromancer+_explode_chance",
        type = ROLE_CONVAR_TYPE_NUM
    })
    table.insert(ROLE.convars, {
        cvar = "ttt_elementalist_midnight_dim_duration",
        type = ROLE_CONVAR_TYPE_NUM
    })
    table.insert(ROLE.convars, {
        cvar = "ttt_elementalist_midnight+_blindness_chance",
        type = ROLE_CONVAR_TYPE_NUM
    })
    --

    -- Set Three
    table.insert(ROLE.convars, {
        cvar = "ttt_elementalist_windburn_push_power",
        type = ROLE_CONVAR_TYPE_NUM
    })
    table.insert(ROLE.convars, {
        cvar = "ttt_elementalist_windburn+_launch_chance",
        type = ROLE_CONVAR_TYPE_NUM
    })
    table.insert(ROLE.convars, {
        cvar = "ttt_elementalist_discharge_punch_power",
        type = ROLE_CONVAR_TYPE_NUM
    })
    table.insert(ROLE.convars, {
        cvar = "ttt_elementalist_discharge+_input_chance",
        type = ROLE_CONVAR_TYPE_NUM
    })
    table.insert(ROLE.convars, {
        cvar = "ttt_elementalist_lifesteal_heal_percentage",
        type = ROLE_CONVAR_TYPE_NUM
    })
    table.insert(ROLE.convars, {
        cvar = "ttt_elementalist_lifesteal+_execute_amount",
        type = ROLE_CONVAR_TYPE_NUM
    })
    --
end

ROLE.nameraw = "elementalist"
ROLE.name = "Elementalist"
ROLE.nameplural = "Elementalists"
ROLE.nameext = "an Elementalist"
ROLE.nameshort = "elm"

ROLE.desc = [[You are an {role}! {comrades}

Bullets you shoot may activate special effects when they hit your target.

Press {menukey} to purchase new effects as you unlock additional equipment points!]]

ROLE.team = ROLE_TEAM_TRAITOR

ROLE.shop = {}
ROLE.loadout = {}

ROLE.translations = {}

RegisterRole(ROLE)

if SERVER then
    AddCSLuaFile()
end

hook.Add("TTTPrepareRound", "Elementalist_Equipment_TTTPrepareRound", function()
    EQUIP_ELEMENTALIST_FROSTBITE = EQUIP_ELEMENTALIST_FROSTBITE or GenerateNewEquipmentID()
    EQUIP_ELEMENTALIST_FROSTBITE_UP = EQUIP_ELEMENTALIST_FROSTBITE_UP or GenerateNewEquipmentID()
    EQUIP_ELEMENTALIST_PYROMANCER = EQUIP_ELEMENTALIST_PYROMANCER or GenerateNewEquipmentID()
    EQUIP_ELEMENTALIST_PYROMANCER_UP = EQUIP_ELEMENTALIST_PYROMANCER_UP or GenerateNewEquipmentID()
    EQUIP_ELEMENTALIST_WINDBURN = EQUIP_ELEMENTALIST_WINDBURN or GenerateNewEquipmentID()
    EQUIP_ELEMENTALIST_WINDBURN_UP = EQUIP_ELEMENTALIST_WINDBURN_UP or GenerateNewEquipmentID()
    EQUIP_ELEMENTALIST_DISCHARGE = EQUIP_ELEMENTALIST_DISCHARGE or GenerateNewEquipmentID()
    EQUIP_ELEMENTALIST_DISCHARGE_UP = EQUIP_ELEMENTALIST_DISCHARGE_UP or GenerateNewEquipmentID()
    EQUIP_ELEMENTALIST_MIDNIGHT = EQUIP_ELEMENTALIST_MIDNIGHT or GenerateNewEquipmentID()
    EQUIP_ELEMENTALIST_MIDNIGHT_UP = EQUIP_ELEMENTALIST_MIDNIGHT_UP or GenerateNewEquipmentID()
    EQUIP_ELEMENTALIST_LIFESTEAL = EQUIP_ELEMENTALIST_LIFESTEAL or GenerateNewEquipmentID()
    EQUIP_ELEMENTALIST_LIFESTEAL_UP = EQUIP_ELEMENTALIST_LIFESTEAL_UP or GenerateNewEquipmentID()

    if DefaultEquipment then
        DefaultEquipment[ROLE_ELEMENTALIST] = {
            EQUIP_ELEMENTALIST_FROSTBITE,
            EQUIP_ELEMENTALIST_FROSTBITE_UP,
            EQUIP_ELEMENTALIST_PYROMANCER,
            EQUIP_ELEMENTALIST_PYROMANCER_UP,
            EQUIP_ELEMENTALIST_WINDBURN,
            EQUIP_ELEMENTALIST_WINDBURN_UP,
            EQUIP_ELEMENTALIST_DISCHARGE,
            EQUIP_ELEMENTALIST_DISCHARGE_UP,
            EQUIP_ELEMENTALIST_MIDNIGHT,
            EQUIP_ELEMENTALIST_MIDNIGHT_UP,
            EQUIP_ELEMENTALIST_LIFESTEAL,
            EQUIP_ELEMENTALIST_LIFESTEAL_UP
        }
    end

    if not EquipmentItems then return end

    if not EquipmentItems[ROLE_ELEMENTALIST] then
        EquipmentItems[ROLE_ELEMENTALIST] = {}
    end

    local allowEffectUpgrades = ROLE.ConvarTierUpgrades:GetBool()

    if ROLE.ConvarFrostUpgrades:GetBool() then
        if not table.HasItemWithPropertyValue(EquipmentItems[ROLE_ELEMENTALIST], "id", EQUIP_ELEMENTALIST_FROSTBITE) then
            table.insert(EquipmentItems[ROLE_ELEMENTALIST], {
                id          = EQUIP_ELEMENTALIST_FROSTBITE,
                type        = "item_passive",
                material    = "vgui/ttt/roles/elm/upgrades/frostbite",
                name        = "Frostbite",
                desc        = "Shoot players to slow down their movement, strength of slow depending on damage done."
            })
        end

        if allowEffectUpgrades and not table.HasItemWithPropertyValue(EquipmentItems[ROLE_ELEMENTALIST], "id", EQUIP_ELEMENTALIST_FROSTBITE_UP) then
            table.insert(EquipmentItems[ROLE_ELEMENTALIST], {
                id          = EQUIP_ELEMENTALIST_FROSTBITE_UP,
                type        = "item_passive",
                material    = "vgui/ttt/roles/elm/upgrades/frostbite+",
                name        = "Frostbite+",
                desc        = "Upgrades Frostbite, players who have been slowed have a chance to freeze when shot, losing all movement.",
                req         = EQUIP_ELEMENTALIST_FROSTBITE
            })
        end
    end

    if ROLE.ConvarPyroUpgrades:GetBool() then
        if not table.HasItemWithPropertyValue(EquipmentItems[ROLE_ELEMENTALIST], "id", EQUIP_ELEMENTALIST_PYROMANCER) then
            table.insert(EquipmentItems[ROLE_ELEMENTALIST], {
                id          = EQUIP_ELEMENTALIST_PYROMANCER,
                type        = "item_passive",
                material    = "vgui/ttt/roles/elm/upgrades/pyromancer",
                name        = "Pyromancer",
                desc        = "Shoot players to ignite them, duration scaling with damage done."
            })
        end

        if allowEffectUpgrades and not table.HasItemWithPropertyValue(EquipmentItems[ROLE_ELEMENTALIST], "id", EQUIP_ELEMENTALIST_PYROMANCER_UP) then
            table.insert(EquipmentItems[ROLE_ELEMENTALIST], {
                id          = EQUIP_ELEMENTALIST_PYROMANCER_UP,
                type        = "item_passive",
                material    = "vgui/ttt/roles/elm/upgrades/pyromancer+",
                name        = "Pyromancer+",
                desc        = "Upgrades Pyromancer, ignited players have a chance to explode when shot, doing damage to everyone around them.",
                req         = EQUIP_ELEMENTALIST_PYROMANCER
            })
        end
    end

    if ROLE.ConvarWindUpgrades:GetBool() then
        if not table.HasItemWithPropertyValue(EquipmentItems[ROLE_ELEMENTALIST], "id", EQUIP_ELEMENTALIST_WINDBURN) then
            table.insert(EquipmentItems[ROLE_ELEMENTALIST], {
                id          = EQUIP_ELEMENTALIST_WINDBURN,
                type        = "item_passive",
                material    = "vgui/ttt/roles/elm/upgrades/windburn",
                name        = "Windburn",
                desc        = "Shooting players pushes them backwards and away from you, force of push scaling with damage done."
            })
        end

        if allowEffectUpgrades and not table.HasItemWithPropertyValue(EquipmentItems[ROLE_ELEMENTALIST], "id", EQUIP_ELEMENTALIST_WINDBURN_UP) then
            table.insert(EquipmentItems[ROLE_ELEMENTALIST], {
                id          = EQUIP_ELEMENTALIST_WINDBURN_UP,
                type        = "item_passive",
                material    = "vgui/ttt/roles/elm/upgrades/windburn+",
                name        = "Windburn+",
                desc        = "Upgrades Windburn, instead of pushing, occasionally launch shot players into the air for a hard, painful, landing.", --should rob them of their second jump
                req         = EQUIP_ELEMENTALIST_WINDBURN
            })
        end
    end

    if ROLE.ConvarDischargeUpgrades:GetBool() then
        if not table.HasItemWithPropertyValue(EquipmentItems[ROLE_ELEMENTALIST], "id", EQUIP_ELEMENTALIST_DISCHARGE) then
            table.insert(EquipmentItems[ROLE_ELEMENTALIST], {
                id          = EQUIP_ELEMENTALIST_DISCHARGE,
                type        = "item_passive",
                material    = "vgui/ttt/roles/elm/upgrades/discharge",
                name        = "Discharge",
                desc        = "Shoot players to shock them, punching their view based on damage done, disorienting them."
            })
        end

        if allowEffectUpgrades and not table.HasItemWithPropertyValue(EquipmentItems[ROLE_ELEMENTALIST], "id", EQUIP_ELEMENTALIST_DISCHARGE_UP) then
            table.insert(EquipmentItems[ROLE_ELEMENTALIST], {
                id          = EQUIP_ELEMENTALIST_DISCHARGE_UP,
                type        = "item_passive",
                material    = "vgui/ttt/roles/elm/upgrades/discharge+",
                name        = "Discharge+",
                desc        = "Upgrades Discharge, causes shot players to additionally commit unintended actions, such as moving, shooting, or jumping.",
                req         = EQUIP_ELEMENTALIST_DISCHARGE
            })
        end
    end

    if ROLE.ConvarMidnightUpgrades:GetBool() then
        if not table.HasItemWithPropertyValue(EquipmentItems[ROLE_ELEMENTALIST], "id", EQUIP_ELEMENTALIST_MIDNIGHT) then
            table.insert(EquipmentItems[ROLE_ELEMENTALIST], {
                id          = EQUIP_ELEMENTALIST_MIDNIGHT,
                type        = "item_passive",
                material    = "vgui/ttt/roles/elm/upgrades/midnight",
                name        = "Midnight",
                desc        = "Shoot players to begin blinding them, dimming their screen and making it difficult for them to see."
            })
        end

        if allowEffectUpgrades and not table.HasItemWithPropertyValue(EquipmentItems[ROLE_ELEMENTALIST], "id", EQUIP_ELEMENTALIST_MIDNIGHT_UP) then
            table.insert(EquipmentItems[ROLE_ELEMENTALIST], {
                id          = EQUIP_ELEMENTALIST_MIDNIGHT_UP,
                type        = "item_passive",
                material    = "vgui/ttt/roles/elm/upgrades/midnight+",
                name        = "Midnight+",
                desc        = "Upgrades Midnight, players with dimmed screens have a chance to go completely blind when shot, seeing nothing.",
                req         = EQUIP_ELEMENTALIST_MIDNIGHT
            })
        end
    end

    if ROLE.ConvarLifeUpgrades:GetBool() then
        if not table.HasItemWithPropertyValue(EquipmentItems[ROLE_ELEMENTALIST], "id", EQUIP_ELEMENTALIST_LIFESTEAL) then
            table.insert(EquipmentItems[ROLE_ELEMENTALIST], {
                id          = EQUIP_ELEMENTALIST_LIFESTEAL,
                type        = "item_passive",
                material    = "vgui/ttt/roles/elm/upgrades/lifesteal",
                name        = "Lifesteal",
                desc        = "Shoot players to steal their life force, one bullet at a time."
            })
        end

        if allowEffectUpgrades and not table.HasItemWithPropertyValue(EquipmentItems[ROLE_ELEMENTALIST], "id", EQUIP_ELEMENTALIST_LIFESTEAL_UP) then
            table.insert(EquipmentItems[ROLE_ELEMENTALIST], {
                id          = EQUIP_ELEMENTALIST_LIFESTEAL_UP,
                type        = "item_passive",
                material    = "vgui/ttt/roles/elm/upgrades/lifesteal+",
                name        = "Lifesteal+",
                desc        = "Upgrades Lifesteal, executes shot players if their health gets too low, killing them instantly.",
                req         = EQUIP_ELEMENTALIST_LIFESTEAL
            })
        end
    end
end)