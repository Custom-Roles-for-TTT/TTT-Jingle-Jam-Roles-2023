local ABILITY = {}

ABILITY.Name = "More Tests"
ABILITY.Id = "moretests"
ABILITY.Description = "More test abilities"
ABILITY.Icon = "vgui/ttt/icon_cbar"

function ABILITY:Condition()
    return true
end

function ABILITY:Use(soulbound, target)
    soulbound:PrintMessage(HUD_PRINTTALK, "We need more abilities")
end

function ABILITY:DrawHUD(x, y, width, height, key)

end

SOULBOUND:RegisterAbility(ABILITY)