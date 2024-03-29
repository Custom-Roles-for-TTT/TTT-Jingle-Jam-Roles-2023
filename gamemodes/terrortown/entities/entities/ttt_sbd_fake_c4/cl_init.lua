-- bomb menus

include("shared.lua")

local draw = draw
local IsValid = IsValid
local net = net
local surface = surface
local table = table
local util = util
local vgui = vgui

local T = LANG.GetTranslation
local PT = LANG.GetParamTranslation

hook.Add("Initialize", "Soulbound_FakeC4_Initialize_Lang", function()
    LANG.AddToLanguage("english", "c4_disarm_fake", "Cut a wire to disarm the bomb. It's a fake bomb, so every wire will result in a confetti explosion.")
end)

---- DISARM

local wire_cut = Sound("ttt/wirecut.wav")

local c4_bomb_mat = Material("vgui/ttt/c4_bomb")
local c4_cut_mat = Material("vgui/ttt/c4_cut")
local c4_wire_mat = Material("vgui/ttt/c4_wire")
local c4_wirecut_mat = Material("vgui/ttt/c4_wire_cut")

-- Wire
local PANEL = {}

local wire_colors = {
    Color(200, 0, 0, 255), -- red
    Color(255, 255, 0, 255), -- yellow
    Color(90, 90, 250, 255), -- blue
    COLOR_WHITE, -- white/grey
    Color(20, 200, 20, 255), -- green
    Color(255, 160, 50, 255)  -- brown
};

function PANEL:Init()
    self.BaseClass.Init(self)

    self:NoClipping(true)
    self:SetMouseInputEnabled(true)
    self:MoveToFront()

    self.IsCut = false
end

local c4_cut_tex = surface.GetTextureID(c4_cut_mat:GetName())
function PANEL:PaintOverHovered()

    surface.SetTexture(c4_cut_tex)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(175, -20, 32, 32)

    draw.SimpleText(PT("c4_disarm_cut", { num = self.Index }), "DermaDefault", 85, -10, COLOR_WHITE, 0, 0)
end

PANEL.OnMousePressed = DButton.OnMousePressed

PANEL.OnMouseReleased = DButton.OnMouseReleased

function PANEL:OnCursorEntered()
    if not self.IsCut then
        self.PaintOver = self.PaintOverHovered
    end
end

function PANEL:OnCursorExited()
    self.PaintOver = self.BaseClass.PaintOver
end

local bomb
function PANEL:DoClick()
    if self:GetParent():GetDisabled() then return end

    self.IsCut = true

    self.PaintOver = self.BaseClass.PaintOver

    self.m_Image:SetMaterial(c4_wirecut_mat)

    surface.PlaySound(wire_cut)

    RunConsoleCommand("ttt_fake_c4_disarm", tostring(bomb:EntIndex()))
end

function PANEL:GetWireColor(i)
    i = i or 1
    i = i % (#wire_colors + 1)

    return wire_colors[i] or COLOR_WHITE
end

function PANEL:SetWireIndex(i)
    self.m_Image:SetImageColor(self:GetWireColor(i))

    self.Index = i
end

vgui.Register("DisarmWire", PANEL, "DImageButton")


-- Bomb
PANEL = {}

AccessorFunc(PANEL, "wirecount", "WireCount")

function PANEL:Init()
    self.Bomb = vgui.Create("DImage", self)
    self.Bomb:SetSize(256, 256)
    self.Bomb:SetPos(0, 0)
    self.Bomb:SetMaterial(c4_bomb_mat)

    self:SetWireCount(C4_WIRE_COUNT)

    self.Wires = {}

    local wx, wy = -84, 70
    for i = 1, self:GetWireCount() do
        local w = vgui.Create("DisarmWire", self)
        w:SetPos(wx, wy)
        w:SetImage(c4_wire_mat:GetName())
        w:SizeToContents()

        w:SetWireIndex(i)

        table.insert(self.Wires, w)

        wy = wy + 27
    end

    self:SetPaintBackground(false)
end

vgui.Register("DisarmPanel", PANEL, "DPanel")

surface.CreateFont("C4Timer", {
    font = "TabLarge",
    size = 30,
    weight = 750
})

local disarm

local function ShowC4Disarm(ent)
    local dframe = vgui.Create("DFrame")
    local w, h = 420, 340
    dframe:SetSize(w, h)
    dframe:Center()
    dframe:SetTitle(T("c4_disarm"))
    dframe:SetVisible(true)
    dframe:ShowCloseButton(true)
    dframe:SetMouseInputEnabled(true)

    local m = 5
    local title_h = 20

    local left_w, left_h = 270, 270
    local right_w, right_h = 135, left_h

    local bw, bh = 100, 25

    local dleft = vgui.Create("ColoredBox", dframe)
    dleft:SetColor(Color(50, 50, 50))
    dleft:SetSize(left_w, left_h)
    dleft:SetPos(m, m + title_h)

    local dright = vgui.Create("ColoredBox", dframe)
    dright:SetColor(Color(50, 50, 50))
    dright:SetSize(right_w, right_h)
    dright:SetPos(left_w + m * 2, m + title_h)

    local dtimer = vgui.Create("DLabel", dright)
    dtimer:SetText("99:99:99")
    dtimer:SetFont("C4Timer")
    dtimer:SetTextColor(Color(200, 0, 0, 255))
    dtimer:SetExpensiveShadow(1, COLOR_BLACK)
    dtimer:SizeToContents()
    dtimer:SetWide(120)
    dtimer:SetPos(10, m)

    dtimer.Bomb = ent
    dtimer.Stop = false

    dtimer.Think = function(s)
        if not IsValid(ent) then return end
        if s.Stop then return end

        local t = ent:GetExplodeTime()
        if t then
            local r = t - CurTime()
            if r > 0 then
                s:SetText(util.SimpleTime(r, "%02i:%02i:%02i"))
            end
        end
    end

    local dstatus = vgui.Create("DLabel", dright)
    dstatus:SetText(T("c4_status_armed"))
    dstatus:SetFont("HealthAmmo")
    dstatus:SetTextColor(Color(200, 0, 0, 255))
    dstatus:SetExpensiveShadow(1, COLOR_BLACK)
    dstatus:SizeToContents()
    dstatus:SetPos(m, m * 2 + 30)
    dstatus:CenterHorizontal()

    local dgrab = vgui.Create("DButton", dright)
    dgrab:SetPos(m, right_h - m * 2 - bh * 2)
    dgrab:SetSize(bw, bh)
    dgrab:CenterHorizontal()
    dgrab:SetText(T("c4_remove_pickup"))
    dgrab:SetDisabled(true)

    local ddestroy = vgui.Create("DButton", dright)
    ddestroy:SetPos(m, right_h - m - bh)
    ddestroy:SetSize(bw, bh)
    ddestroy:CenterHorizontal()
    ddestroy:SetText(T("c4_remove_destroy1"))
    ddestroy:SetDisabled(true)
    ddestroy.Confirmed = false

    local desc_h = 45

    local ddesc = vgui.Create("DLabel", dleft)
    ddesc:SetBright(true)
    ddesc:SetFont("DermaDefaultBold")
    ddesc:SetSize(256, desc_h)
    ddesc:SetWrap(true)
    if LocalPlayer():IsTraitorTeam() or LocalPlayer() == ent:GetOwner() then
        ddesc:SetText(T("c4_disarm_fake"))
    else
        ddesc:SetText(T("c4_disarm_other"))
    end
    ddesc:SetPos(m, m)

    local bg = vgui.Create("ColoredBox", dleft)
    bg:StretchToParent(m, m + desc_h, m, m)
    bg:SetColor(Color(20, 20, 20, 255))

    local dbomb = vgui.Create("DisarmPanel", bg)
    dbomb:SetSize(256, 256)
    dbomb:Center()

    local dcancel = vgui.Create("DButton", dframe)
    dcancel:SetPos(w - bw - m, h - bh - m)
    dcancel:SetSize(bw, bh)
    dcancel:CenterHorizontal()
    dcancel:SetText(T("close"))
    dcancel.DoClick = function()
        dframe:Close()
    end

    dframe:MakePopup()

    disarm = function()
        dframe:Close()
    end
end

---- Communication

local function C4ConfigHook()
    bomb = net.ReadEntity()

    if IsValid(bomb) then
        ShowC4Disarm(bomb)
    end
end
net.Receive("TTT_SoulboundFakeC4Config", C4ConfigHook)

local function C4DisarmResultHook()
    bomb = net.ReadEntity()

    if IsValid(bomb) then
        disarm()
    end
end
net.Receive("TTT_SoulboundFakeC4DisarmResult", C4DisarmResultHook)
