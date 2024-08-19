AddCSLuaFile()

local string = string

if CLIENT then
    SWEP.PrintName = "Soulbinding Device"
    SWEP.Slot = 8
end

SWEP.Base = "weapon_cr_defibbase"
SWEP.Category = WEAPON_CATEGORY_ROLE
SWEP.InLoadoutFor = {ROLE_SOULMAGE}
SWEP.InLoadoutForDefault = {ROLE_SOULMAGE}
SWEP.Kind = WEAPON_ROLE

if SERVER then
    SWEP.DeviceTimeConVar = CreateConVar("ttt_soulmage_soulbinding_time", "8", FCVAR_NONE, "The amount of time (in seconds) the Soulmages's soulbinding device takes to use", 0, 60)
end

if CLIENT then
    function SWEP:Initialize()
        self:AddHUDHelp("soulbindingdevice_help_pri", nil, true)
        return self.BaseClass.Initialize(self)
    end
end

if SERVER then
    function SWEP:OnSuccess(ply, body)
        local message = ROLE_STRINGS_EXT[ROLE_SOULMAGE]
        message = message:gsub("^%l", string.upper)
        message = message .. " has converted you into " .. ROLE_STRINGS_EXT[ROLE_SOULBOUND] .. "!"
        ply:QueueMessage(MSG_PRINTBOTH, message)
        ply:QueueMessage(MSG_PRINTBOTH, "Help your team to victory by using the abilities in your buy menu!")
        ply:SetProperty("TTTIsGhosting", true, ply)
        ply:SetNWInt("TTTSoulboundOldRole", ply:GetRole())
        ply:SetRole(ROLE_SOULBOUND)
        SendFullStateUpdate()
    end

    function SWEP:ValidateTarget(ply, body, bone)
        if ply:IsSoulbound() then
            return false, "SUBJECT IS ALREADY " .. string.upper(ROLE_STRINGS_EXT[ROLE_SOULBOUND])
        end
        return true, ""
    end

    function SWEP:GetProgressMessage(ply, body, bone)
        return "SOULBINDING " .. string.upper(ply:Nick())
    end

    function SWEP:GetAbortMessage()
        return "SOULBINDING ABORTED"
    end
end