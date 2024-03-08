AddCSLuaFile()

local string = string

if CLIENT then
    SWEP.PrintName = "Ghosting Device"
    SWEP.Slot = 8
end

SWEP.Base = "weapon_cr_defibbase"
SWEP.Category = WEAPON_CATEGORY_ROLE
SWEP.InLoadoutFor = {ROLE_GHOSTWHISPERER}
SWEP.InLoadoutForDefault = {ROLE_GHOSTWHISPERER}
SWEP.Kind = WEAPON_ROLE

if SERVER then
    SWEP.DeviceTimeConVar = CreateConVar("ttt_ghostwhisperer_ghosting_time", "8", FCVAR_NONE, "The amount of time (in seconds) the Ghost Whisperer's ghosting device takes to use", 0, 60)
end

if CLIENT then
    function SWEP:Initialize()
        self:AddHUDHelp("ghostingdevice_help_pri", nil, true)
        return self.BaseClass.Initialize(self)
    end
end

if SERVER then
    function SWEP:OnSuccess(ply, body)
        local message = ROLE_STRINGS_EXT[ROLE_GHOSTWHISPERER]
        message = message:gsub("^%l", string.upper)
        message = message + " has granted you the ability to talk in chat!"
        ply:QueueMessage(MSG_PRINTBOTH, message)
        ply:SetNWBool("TTTIsGhosting", true)
    end

    function SWEP:ValidateTarget(ply, body, bone)
        if ply:GetNWBool("TTTIsGhosting", false) then
            return false, "SUBJECT IS ALREADY GHOSTING"
        end
        return true, ""
    end

    function SWEP:GetProgressMessage(ply, body, bone)
        return "GHOSTING " .. string.upper(ply:Nick())
    end

    function SWEP:GetAbortMessage()
        return "GHOSTING ABORTED"
    end
end