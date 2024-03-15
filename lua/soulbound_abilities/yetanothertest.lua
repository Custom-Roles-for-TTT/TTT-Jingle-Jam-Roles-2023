local ABILITY = {}

ABILITY.Name = "Yet Another Test"
ABILITY.Id = "yetanothertest"
ABILITY.Description = "Yet another test ability"
ABILITY.Icon = "vgui/ttt/icon_cbar"

function ABILITY:Condition()
    return true
end

function ABILITY:Use(soulbound, target)
    soulbound:PrintMessage(HUD_PRINTTALK, "There are so many abilities")
end

function ABILITY:DrawHUD(x, y, width, height)

end

SOULBOUND:RegisterAbility(ABILITY)