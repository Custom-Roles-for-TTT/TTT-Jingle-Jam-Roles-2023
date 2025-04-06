AddCSLuaFile()

-- DEFINE_BASECLASS "weapon_tttbase"

SWEP.HoldType               = "pistol"

if CLIENT then
   SWEP.PrintName           = "Health Tracker"
   SWEP.Slot                = 8

   SWEP.DrawCrosshair       = false
   SWEP.ViewModelFlip       = false

   SWEP.Icon                = "vgui/ttt/roles/phy/shop/icon_physician_scanner_upgrade"
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

SWEP.Kind                   = WEAPON_ROLE
SWEP.InLoadoutFor           = {ROLE_PHYSICIAN}
SWEP.Category               = WEAPON_CATEGORY_ROLE

SWEP.AllowDelete            = false
SWEP.AllowDrop              = false
SWEP.NoSights               = true

function SWEP:PlaceTracker()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

    if not SERVER then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if owner:IsRoleAbilityDisabled() then return end

    local trace = owner:GetEyeTrace()
    local traceEnt = trace.Entity
    if not IsPlayer(traceEnt) then return end
    if not traceEnt:Alive() or traceEnt:IsSpec() then return end

    if not GAMEMODE.PHYSICIAN:IsPlayerBeingTracked(owner, traceEnt) and (owner:EyePos() - trace.HitPos):Length() < 100 then
        self:SendWeaponAnim(ACT_VM_HITCENTER)
        GAMEMODE.PHYSICIAN:AddNewTrackedPlayer(owner, traceEnt)
        traceEnt:EmitSound("buttons/combine_button7.wav")
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