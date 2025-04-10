-- Logan Christianson
local ROLE = {}

ROLE.nameraw = "physician"
ROLE.name = "Physician"
ROLE.nameplural = "Physicians"
ROLE.nameext = "a Physician"
ROLE.nameshort = "phy"

ROLE.desc = [[You are a {role}!

Use your Health Tracker device to plant trackers on players to monitor their heartbeat.
Open the scoreboard to view tracked player's health status, but beware its limited range!

Press {menukey} to access the standard equipment shop, featuring an upgrade for your tracker.]]
ROLE.shortdesc = "Has a Health Tracker which allows them to plant tracking devices on players, allowing them to see their health status from a distance."

ROLE.team = ROLE_TEAM_DETECTIVE
ROLE.shopsyncroles = {ROLE_DETECTIVE}

ROLE.loadout = {"weapon_ttt_phy_tracker"}

ROLE.translations = {}

ROLE.convars = {
    {
        cvar = "ttt_physician_tracker_range_default",
        type = ROLE_CONVAR_TYPE_NUM,
        decimal = 0
    },
    {
        cvar = "ttt_physician_tracker_range_boosted",
        type = ROLE_CONVAR_TYPE_NUM,
        decimal = 0
    }
}

ROLE.moverolestate = function(source, target, keepOnSource)
    local sourceId = source:SteamID64()
    local targetId = target:SteamID64()

    GAMEMODE.PHYSICIAN.tracking[targetId] = GAMEMODE.PHYSICIAN.tracking[sourceId] or {}

    if not keepOnSource then
        table.Empty(GAMEMODE.PHYSICIAN.tracking[sourceId])
        GAMEMODE.PHYSICIAN.tracking[sourceId] = nil
    end
end

RegisterRole(ROLE)

PHYSICIAN_TRACKER_INACTIVE = 0  -- Player is untracked
PHYSICIAN_TRACKER_ACTIVE = 1    -- Player is being tracked
PHYSICIAN_TRACKER_DEAD = 2      -- Player is dead (or, potentially in future, has destroyed their tracker)

EQUIP_PHS_TRACKER = EQUIP_PHS_TRACKER or GenerateNewEquipmentID()
local function InitializeEquipment()
    if DefaultEquipment then
        DefaultEquipment[ROLE_PHYSICIAN] = {
            EQUIP_PHS_TRACKER
        }
    end

    if EquipmentItems then
        if not EquipmentItems[ROLE_PHYSICIAN] then
            EquipmentItems[ROLE_PHYSICIAN] = {}
        end

        -- If we haven't already registered this item, add it to the list
        if not table.HasItemWithPropertyValue(EquipmentItems[ROLE_PHYSICIAN], "id", EQUIP_PHS_TRACKER) then
            table.insert(EquipmentItems[ROLE_PHYSICIAN], {
                id          = EQUIP_PHS_TRACKER,
                type        = "item_passive",
                material    = "vgui/ttt/roles/phy/shop/icon_physician_scanner_upgrade",
                name        = "Health Tracker Upgrade",
                desc        = "Upgrades the range and information quality from the Health Tracker."
            })
        end
    end
end
InitializeEquipment()

hook.Add("Initialize", "Physician_Equipment_Initialize", InitializeEquipment)
hook.Add("TTTPrepareRound", "Physician_Equipment_TTTPrepareRound", InitializeEquipment)

if SERVER then
    AddCSLuaFile()

    CreateConVar("ttt_physician_tracker_range_default", "50", FCVAR_NONE, "Default range of the Physician's tracker device in meters", 0, 250)
    CreateConVar("ttt_physician_tracker_range_boosted", "100", FCVAR_NONE, "Boosted range of the Physician's tracker device in meters after the upgrade has been purchased", 0, 500)
end
