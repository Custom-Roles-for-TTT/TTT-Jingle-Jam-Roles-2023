local ABILITY = {}

ABILITY.Name = "Test"
ABILITY.Id = "test"
ABILITY.Description = "Test ability"
ABILITY.Icon = "vgui/ttt/icon_cbar"

function ABILITY:Condition()
    return true
end

function ABILITY:Use(soulbound, target)
    soulbound:PrintMessage(HUD_PRINTTALK, "Wow such a cool ability")
end

function ABILITY:DrawHUD(x, y, width, height)

end

SOULBOUND:RegisterAbility(ABILITY)