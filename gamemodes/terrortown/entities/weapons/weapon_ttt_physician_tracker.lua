AddCSLuaFile()

-- DEFINE_BASECLASS "weapon_tttbase"

SWEP.HoldType               = "pistol"

if CLIENT then
   SWEP.PrintName           = "Health Tracker"
   SWEP.Slot                = 8

   SWEP.DrawCrosshair       = false
   SWEP.ViewModelFlip       = false

   SWEP.Icon                = "vgui/ttt/icon_flare"
end

SWEP.Base                   = "weapon_tttbase"

SWEP.AutoSpawnable          = false

SWEP.ViewModel              = Model("models/weapons/v_stunbaton.mdl")
SWEP.WorldModel             = Model("models/weapons/w_stunbaton.mdl")

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"
SWEP.Primary.Delay          = 0.75

SWEP.Kind                   = WEAPON_EQUIP
SWEP.InLoadoutFor           = {ROLE_PHYSICIAN}
SWEP.Category               = WEAPON_CATEGORY_ROLE

SWEP.AllowDelete            = false
SWEP.AllowDrop              = false
SWEP.NoSights               = true

function SWEP:PlaceTracker()
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
    self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

    if SERVER then
        local ply = self:GetOwner()

        if ply then
            local trace = ply:GetEyeTrace()
            local traceEnt = trace.Entity

            if IsValid(traceEnt) and traceEnt:IsPlayer() and traceEnt:Alive() and not GAMEMODE.PHYSICIAN:IsPlayerBeingTracked(ply, traceEnt) and (ply:EyePos() - trace.HitPos):Length() < 100 then
                self:SendWeaponAnim(ACT_VM_HITCENTER)
                GAMEMODE.PHYSICIAN:AddNewTrackedPlayer(ply, traceEnt)
                traceEnt:EmitSound("buttons/combine_button7.wav")
            end
        end
    end
end

function SWEP:PrimaryAttack()
    self:PlaceTracker()
end

function SWEP:SecondaryAttack()
    self:PlaceTracker()
end

function SWEP:Drop()
    return
end