local ABILITY = {}

ABILITY.Name = "New Test"
ABILITY.Id = "newtest"
ABILITY.Description = "New test ability"
ABILITY.Icon = "vgui/ttt/icon_cbar"

function ABILITY:Condition(soulbound, target)
    return true
end

function ABILITY:Use(soulbound, target)
    soulbound:PrintMessage(HUD_PRINTTALK, "Wow such a cool new ability")
end

function ABILITY:DrawHUD(x, y, width, height, key)

end

SOULBOUND:RegisterAbility(ABILITY)