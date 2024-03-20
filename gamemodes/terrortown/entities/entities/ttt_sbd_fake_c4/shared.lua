-- c4 explosive

local cam = cam
local concommand = concommand
local draw = draw
local ents = ents
local hook = hook
local ipairs = ipairs
local IsValid = IsValid
local math = math
local net = net
local player = player
local surface = surface
local table = table
local timer = timer
local util = util

if SERVER then
    AddCSLuaFile("cl_init.lua")
    AddCSLuaFile("shared.lua")
end

if CLIENT then
    -- this entity can be DNA-sampled so we need some display info
    ENT.Icon = "vgui/ttt/icon_c4"
    ENT.PrintName = "C4"

    local GetPTranslation = LANG.GetParamTranslation
    local hint_params = { usekey = Key("+use", "USE") }

    ENT.TargetIDHint = {
        name = "C4",
        hint = "c4_hint",
        fmt = function(ent, txt) return GetPTranslation(txt, hint_params) end
    };
end

ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_c4_planted.mdl")

ENT.CanHavePrints = true
ENT.CanUseKey = true
ENT.Avoidable = true

AccessorFunc(ENT, "thrower", "Thrower")

AccessorFunc(ENT, "arm_time", "ArmTime", FORCE_NUMBER)
AccessorFunc(ENT, "timer_length", "TimerLength", FORCE_NUMBER)

-- Generate accessors for DT vars. This way all consumer code can keep accessing
-- the vars as they always did, the only difference is that behind the scenes
-- they are set up as DT vars.
AccessorFuncDT(ENT, "explode_time", "ExplodeTime")
AccessorFuncDT(ENT, "armed", "Armed")

ENT.Beep = 0
ENT.DetectiveNearRadius = 300
ENT.SafeWires = nil

function ENT:SetupDataTables()
    self:DTVar("Int", 0, "explode_time")
    self:DTVar("Bool", 0, "armed")
end

function ENT:Initialize()
    self:SetModel(self.Model)

    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
    end
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    if SERVER then
        self:SetUseType(SIMPLE_USE)
    end

    self.Beep = 0

    self:SetTimerLength(0)
    self:SetExplodeTime(0)
    self:SetArmed(false)
    if not self:GetThrower() then self:SetThrower(nil) end
end

function ENT:SetDetonateTimer(length)
    self:SetTimerLength(length)
    self:SetExplodeTime(CurTime() + length)
end

function ENT:UseOverride(activator)
    if IsPlayer(activator) then
        self:ShowC4Config(activator)
    end
end

function ENT:WeldToGround(state)
    if self.IsOnWall then return end

    if state then
        -- getgroundentity does not work for non-players
        -- so sweep ent downward to find what we're lying on
        local ignore = player.GetAll()
        table.insert(ignore, self)

        local tr = util.TraceEntity({ start = self:GetPos(), endpos = self:GetPos() - Vector(0, 0, 16), filter = ignore, mask = MASK_SOLID }, self)

        -- Start by increasing weight/making uncarryable
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            -- Could just use a pickup flag for this. However, then it's easier to
            -- push it around.
            self.OrigMass = phys:GetMass()
            phys:SetMass(150)
        end

        if tr.Hit and (IsValid(tr.Entity) or tr.HitWorld) then
            -- "Attach" to a brush if possible
            if IsValid(phys) and tr.HitWorld then
                phys:EnableMotion(false)
            end

            -- Else weld to objects we cannot pick up
            local entphys = tr.Entity:GetPhysicsObject()
            if IsValid(entphys) and entphys:GetMass() > CARRY_WEIGHT_LIMIT then
                constraint.Weld(self, tr.Entity, 0, 0, 0, true)
            end

            -- Worst case, we are still uncarryable
        end
    else
        constraint.RemoveConstraints(self, "Weld")
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(true)
            phys:SetMass(self.OrigMass or 10)
        end
    end
end

local birthday = Sound("birthday.wav")
local confetti = Material("confetti.png")

function ENT:Explode(tr)
    if SERVER then
        self:SetNoDraw(true)
        self:SetSolid(SOLID_NONE)

        -- pull out of the surface
        if tr.Fraction ~= 1.0 then
            self:SetPos(tr.HitPos + tr.HitNormal * 0.6)
        end

        local pos = self:GetPos()
        if util.PointContents(pos) == CONTENTS_WATER or GetRoundState() ~= ROUND_ACTIVE then
            self:Remove()
            self:SetExplodeTime(0)
            return
        end

        timer.Simple(0.1, function() sound.Play(birthday, pos, 100, 100) end)

        self:SetExplodeTime(0)

        self:Remove()
    else
        local spos = self:GetPos()

        local velMax = 200
        local gravMax = 50
        local gravity = Vector(math.random(-gravMax, gravMax), math.random(-gravMax, gravMax), math.random(-gravMax, 0))

        local em = ParticleEmitter(spos, true)
        for _ = 1, 150 do
            local p = em:Add(confetti, spos)
            p:SetStartSize(math.random(6, 10))
            p:SetEndSize(0)
            p:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
            p:SetAngleVelocity(Angle(math.random(5, 50), math.random(5, 50), math.random(5, 50)))
            p:SetVelocity(Vector(math.random(-velMax, velMax), math.random(-velMax, velMax), math.random(-velMax, velMax)))
            p:SetColor(255, 255, 255)
            p:SetDieTime(math.random(4, 7))
            p:SetGravity(gravity)
            p:SetAirResistance(125)
        end

        em:Finish()

        local trs = util.TraceLine({ start = spos + Vector(0, 0, 64), endpos = spos + Vector(0, 0, -128), filter = self })
        util.Decal("Scorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)

        self:SetExplodeTime(0)
    end
end

function ENT:IsDetectiveNear()
    local center = self:GetPos()
    local r = self.DetectiveNearRadius ^ 2
    local d
    local diff
    for _, ent in ipairs(player.GetAll()) do
        if IsValid(ent) and ent:IsActiveDetectiveLike() then
            -- dot of the difference with itself is distance squared
            diff = center - ent:GetPos()
            d = diff:Dot(diff)

            if d < r then
                if ent:HasWeapon("weapon_ttt_defuser") then
                    return true
                end
            end
        end
    end

    return false
end

local beep = Sound("weapons/c4/c4_beep1.wav")
local MAX_MOVE_RANGE = 1000000 -- sq of 1000
function ENT:Think()
    if not self:GetArmed() then return end

    if SERVER then
        local curpos = self:GetPos()
        if self.LastPos and self.LastPos:DistToSqr(curpos) > MAX_MOVE_RANGE then
            self:Disarm(nil)
            return
        end
        self.LastPos = curpos
    end

    local etime = self:GetExplodeTime()
    if self:GetArmed() and etime ~= 0 and etime < CurTime() then
        -- find the ground if it's near and pass it to the explosion
        local spos = self:GetPos()
        local tr = util.TraceLine({ start = spos, endpos = spos + Vector(0, 0, -32), mask = MASK_SHOT_HULL, filter = self:GetThrower() })

        local success, err = pcall(self.Explode, self, tr)
        if not success then
            -- prevent effect spam on Lua error
            self:Remove()

            ErrorNoHalt("ERROR CAUGHT: ttt_c4: " .. err .. "\n")
        end
    elseif self:GetArmed() and CurTime() > self.Beep then
        local amp = 48

        if self:IsDetectiveNear() then
            amp = 65

            local dlight = CLIENT and DynamicLight(self:EntIndex())
            if dlight then
                dlight.Pos = self:GetPos()
                dlight.r = 255
                dlight.g = 0
                dlight.b = 0
                dlight.Brightness = 1
                dlight.Size = 128
                dlight.Decay = 500
                dlight.DieTime = CurTime() + 0.1
            end

        elseif SERVER then
            -- volume lower for long fuse times, bottoms at 50 at +5mins
            amp = amp + math.max(0, 12 - (0.03 * self:GetTimerLength()))
        end

        if SERVER then
            sound.Play(beep, self:GetPos(), amp, 100)
        end

        local btime = (etime - CurTime()) / 30
        self.Beep = CurTime() + btime
    end
end

function ENT:Defusable()
    return self:GetArmed()
end

-- Timer configuration handlign

if SERVER then
    function ENT:Disarm(ply)
        -- tiny moment of zen and realization before the bang
        self:SetExplodeTime(CurTime() + 0.1)
    end

    function ENT:Arm(ply, time)
        -- Initialize armed state
        self:SetDetonateTimer(time)
        self:SetArmTime(CurTime())

        self:SetArmed(true)
        self:WeldToGround(true)

        -- ply may be a different player than they who dropped us.
        -- Arming player should be the damage owner = "thrower"
        self:SetThrower(ply)
        -- Owner determines who gets messages and can quick-disarm if traitor,
        -- make that the armer as well for now. Theoretically the dropping player
        -- should also be able to quick-disarm, but that's going to be rare.
        self:SetOwner(ply)
    end

    function ENT:ShowC4Config(ply)
        -- show menu to player to configure or disarm us
        net.Start("TTT_SoulboundFakeC4Config")
        net.WriteEntity(self)
        net.Send(ply)
    end

    local function ReceiveC4Disarm(ply, cmd, args)
        if not (IsValid(ply) and ply:IsTerror() and #args == 1) then return end
        local idx = tonumber(args[1])

        if not idx then return end

        local bomb = ents.GetByIndex(idx)
        if IsValid(bomb) and bomb:GetClass() == "ttt_sbd_fake_c4" and bomb:GetArmed() then
            if bomb:GetPos():Distance(ply:GetPos()) > 256 then return end

            net.Start("TTT_SoulboundFakeC4DisarmResult")
            net.WriteEntity(bomb)
            net.Send(ply)
            bomb:Disarm(ply)
        end
    end
    concommand.Add("ttt_fake_c4_disarm", ReceiveC4Disarm)
end

if CLIENT then
    surface.CreateFont("C4ModelTimer", {
        font = "Default",
        size = 13,
        weight = 0,
        antialias = false
    })

    function ENT:GetTimerPos()
        local att = self:GetAttachment(self:LookupAttachment("controlpanel0_ur"))
        if att then
            return att
        else
            local ang = self:GetAngles()
            ang:RotateAroundAxis(self:GetUp(), -90)
            local pos = (self:GetPos() + self:GetForward() * 4.5 +
                    self:GetUp() * 9.0 + self:GetRight() * 7.8)
            return { Pos = pos, Ang = ang }
        end
    end

    local strtime = util.SimpleTime
    local max = math.max
    function ENT:Draw()
        self:DrawModel()

        if self:GetArmed() then
            local angpos_ur = self:GetTimerPos()
            if angpos_ur then
                cam.Start3D2D(angpos_ur.Pos, angpos_ur.Ang, 0.2)
                draw.DrawText(strtime(max(0, self:GetExplodeTime() - CurTime()), "%02i:%02i"), "C4ModelTimer", -1, 1, COLOR_RED, TEXT_ALIGN_RIGHT)
                cam.End3D2D()
            end
        end
    end
end
