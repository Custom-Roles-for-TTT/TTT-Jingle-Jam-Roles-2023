local ABILITY = {}

ABILITY.Name = "Even More Tests"
ABILITY.Id = "evenmoretests"
ABILITY.Description = "Even more test abilities"
ABILITY.Icon = "vgui/ttt/icon_cbar"

function ABILITY:Condition()
    return true
end

function ABILITY:Use(soulbound, target)
    soulbound:PrintMessage(HUD_PRINTTALK, "So many abilities")
end

function ABILITY:DrawHUD(x, y, width, height)
    draw.RoundedBox(8, x, y, width, height, COLOR_PINK)
end

SOULBOUND:RegisterAbility(ABILITY)